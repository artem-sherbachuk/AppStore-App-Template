//
//  LivePhoto.swift
//  Live Photos
//
//  Created by Alexander Pagliaro on 7/25/18.
//  Copyright © 2018 Limit Point LLC. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

struct LivePhotoData {
    let imageURL: URL
    let videoURL: URL
}

class LivePhoto {

    private let generatingQueue: DispatchQueue
    private let writingQueue: DispatchQueue

    lazy private var cacheDirectory: URL? = {
        let manager = FileManager.default

        if let cacheDirectoryURL = try? manager.url(for: .cachesDirectory,
                                                    in: .userDomainMask, appropriateFor: nil,
                                                    create: false) {
            let dir = cacheDirectoryURL.appendingPathComponent("LivePhoto", isDirectory: true)

            if !FileManager.default.fileExists(atPath: dir.absoluteString) {
                try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            }

            return dir
        }

        return nil
    }()

    init() {
        generatingQueue = DispatchQueue(label: "com.live.photo.generating.queue", qos: .userInitiated, attributes: .concurrent)

        writingQueue = DispatchQueue(label: "com.livePhoto.writing.queue", qos: .userInitiated)
    }

    deinit {
        clearCache()
    }

    private func clearCache() {
        if let cacheDirectory = cacheDirectory {
            try? FileManager.default.removeItem(at: cacheDirectory)
        }
    }

    /// Save a Live Photo to the Photo Library by passing the paired image and video.
    static func saveToLibrary(_ resources: LivePhotoData) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: resources.videoURL, options: options)
            creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: resources.imageURL, options: options)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                if success,
                   let topVC = UIApplication.shared.topMostViewController() {
                    presentAlert(controller: topVC, title: "Done".localized(), message: "saved to your photos library")
                }
            }
        })
    }

    func generate(_ videoURL: URL,
                  progress: @escaping (CGFloat) -> Void,
                  completion: @escaping (LivePhotoData?) -> Void) {

        generatingQueue.async { [weak self] in
            guard let `self` = self else {
                completion(nil)
                return
            }

            self.generate(videoURL, progress, completion)
        }
    }



    private func generate(_ videoURL: URL,
                  _ progress: @escaping (CGFloat) -> Void,
                  _ completion: @escaping (LivePhotoData?) -> Void) {

        guard let cacheDirectory = cacheDirectory else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        let assetIdentifier = UUID().uuidString

        let _keyPhotoURL = generateKeyPhoto(from: videoURL)

        guard let keyPhotoURL = _keyPhotoURL,
              let pairedImageURL = addAssetID(assetIdentifier, toImage: keyPhotoURL, saveTo: cacheDirectory.appendingPathComponent(assetIdentifier).appendingPathExtension("jpg")) else {

            DispatchQueue.main.async {
                completion(nil)
            }

            return
        }

        trimVideoToFitLivePhotoRequirements(videoURL) { trimmedURL in

            guard let trimmedURL = trimmedURL else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self.addAssetID(assetIdentifier, toVideo: trimmedURL, saveTo: cacheDirectory.appendingPathComponent(assetIdentifier).appendingPathExtension("mov"), progress: progress) { (_videoURL) in

                if let pairedVideoURL = _videoURL {
                    let livePhotoData = LivePhotoData(imageURL: pairedImageURL,
                                                      videoURL: pairedVideoURL)

                    DispatchQueue.main.async {
                        completion(livePhotoData)
                    }

                } else {

                    DispatchQueue.main.async {
                        completion(nil)
                    }

                }
            }
        }
    }


    private func generateKeyPhoto(from videoURL: URL) -> URL? {
        var percent:Float = 0.5
        let videoAsset = AVURLAsset(url: videoURL)
        if let stillImageTime = videoAsset.stillImageTime() {
            percent = Float(stillImageTime.value) / Float(videoAsset.duration.value)
        }
        guard let imageFrame = videoAsset.getAssetFrame(percent: percent) else { return nil }
        guard let jpegData = imageFrame.jpegData(compressionQuality: 1.0) else { return nil }
        guard let url = cacheDirectory?.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg") else { return nil }
        do {
            try? jpegData.write(to: url)
            return url
        }
    }


    private func saveAssetResource(_ resource: PHAssetResource, to directory: URL, resourceData: Data) -> URL? {
        let fileExtension = UTTypeCopyPreferredTagWithClass(resource.uniformTypeIdentifier as CFString,kUTTagClassFilenameExtension)?.takeRetainedValue()
        
        guard let ext = fileExtension else {
            return nil
        }
        
        var fileUrl = directory.appendingPathComponent(NSUUID().uuidString)
        fileUrl = fileUrl.appendingPathExtension(ext as String)
        
        do {
            try resourceData.write(to: fileUrl, options: [Data.WritingOptions.atomic])
        } catch {
            print("Could not save resource \(resource) to filepath \(String(describing: fileUrl))")
            return nil
        }
        
        return fileUrl
    }
    
    
    
    func addAssetID(_ assetIdentifier: String, toImage imageURL: URL, saveTo destinationURL: URL) -> URL? {
        guard let imageDestination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypeJPEG, 1, nil),
            let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
            var imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [AnyHashable : Any] else { return nil }
        let assetIdentifierKey = "17"
        let assetIdentifierInfo = [assetIdentifierKey : assetIdentifier]
        imageProperties[kCGImagePropertyMakerAppleDictionary] = assetIdentifierInfo
        CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, imageProperties as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        return destinationURL
    }
    
    
    
    private var audioReader: AVAssetReader?
    private var videoReader: AVAssetReader?
    private var assetWriter: AVAssetWriter?
    
    
    
    func addAssetID(_ assetIdentifier: String, toVideo videoURL: URL, saveTo destinationURL: URL, progress: @escaping (CGFloat) -> Void, completion: @escaping (URL?) -> Void) {

        var audioWriterInput: AVAssetWriterInput?
        var audioReaderOutput: AVAssetReaderOutput?
        let videoAsset = AVURLAsset(url: videoURL)
        let frameCount = videoAsset.countFrames(exact: false)
        
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            completion(nil)
            return
        }

        do {
            // Create the Asset Writer
            assetWriter = try AVAssetWriter(outputURL: destinationURL, fileType: .mov)

            // Create Video Reader Output
            videoReader = try AVAssetReader(asset: videoAsset)

            let videoReaderSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
            let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            videoReader?.add(videoReaderOutput)

            // Create Video Writer Input
            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey : AVVideoCodecType.h264, AVVideoWidthKey : videoTrack.naturalSize.width, AVVideoHeightKey : videoTrack.naturalSize.height])
            videoWriterInput.transform = videoTrack.preferredTransform
            videoWriterInput.expectsMediaDataInRealTime = true
            assetWriter?.add(videoWriterInput)



            // Create Audio Reader Output & Writer Input
            if let audioTrack = videoAsset.tracks(withMediaType: .audio).first {
                do {
                    let _audioReader = try AVAssetReader(asset: videoAsset)
                    let _audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
                    _audioReader.add(_audioReaderOutput)
                    audioReader = _audioReader
                    audioReaderOutput = _audioReaderOutput
                    let _audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
                    _audioWriterInput.expectsMediaDataInRealTime = false
                    assetWriter?.add(_audioWriterInput)
                    audioWriterInput = _audioWriterInput
                } catch {
                    print(error)
                }
            }

            // Create necessary identifier metadata and still image time metadata
            let assetIdentifierMetadata = metadataForAssetID(assetIdentifier)
            let stillImageTimeMetadataAdapter = createMetadataAdaptorForStillImageTime()
            assetWriter?.metadata = [assetIdentifierMetadata]
            assetWriter?.add(stillImageTimeMetadataAdapter.assetWriterInput)
            // Start the Asset Writer
            assetWriter?.startWriting()
            assetWriter?.startSession(atSourceTime: CMTime.zero)

            // Add still image metadata
            let _stillImagePercent: Float = 0.5
            stillImageTimeMetadataAdapter.append(AVTimedMetadataGroup(items: [metadataItemForStillImageTime()],timeRange: videoAsset.makeStillImageTimeRange(percent: _stillImagePercent, inFrameCount: frameCount)))

            // For end of writing / progress
            var writingVideoFinished = false
            var writingAudioFinished = false
            var currentFrameCount = 0
            func didCompleteWriting() {
                guard writingAudioFinished && writingVideoFinished else { return }
                assetWriter?.finishWriting {
                    if self.assetWriter?.status == .completed {
                        completion(destinationURL)
                    } else {
                        completion(nil)
                    }
                }
            }

            // Start writing video
            if videoReader?.startReading() ?? false {

                videoWriterInput.requestMediaDataWhenReady(on: self.writingQueue) {

                    while videoWriterInput.isReadyForMoreMediaData {
                        if let sampleBuffer = videoReaderOutput.copyNextSampleBuffer()  {
                            currentFrameCount += 1
                            let percent:CGFloat = CGFloat(currentFrameCount)/CGFloat(frameCount)

                            DispatchQueue.main.async {
                                progress(percent)
                            }

                            if !videoWriterInput.append(sampleBuffer) {
                                print("Cannot write: \(String(describing: self.assetWriter?.error?.localizedDescription))")
                                self.videoReader?.cancelReading()
                            }
                        } else {
                            videoWriterInput.markAsFinished()
                            writingVideoFinished = true
                            didCompleteWriting()
                        }
                    }
                }
            } else {
                writingVideoFinished = true
                didCompleteWriting()
            }


            // Start writing audio
            if audioReader?.startReading() ?? false {
                audioWriterInput?.requestMediaDataWhenReady(on: DispatchQueue(label: "audioWriterInputQueue")) {
                    while audioWriterInput?.isReadyForMoreMediaData ?? false {
                        guard let sampleBuffer = audioReaderOutput?.copyNextSampleBuffer() else {
                            audioWriterInput?.markAsFinished()
                            writingAudioFinished = true
                            didCompleteWriting()
                            return
                        }
                        audioWriterInput?.append(sampleBuffer)
                    }
                }
            } else {

                writingAudioFinished = true
                didCompleteWriting()

            }

        } catch {
            completion(nil)
        }
    }

    private var exportSession: AVAssetExportSession?
    private func trimVideoToFitLivePhotoRequirements(_ url: URL,
                                 completion:@escaping (URL?) -> Void) {

        exportSession = AVAssetExportSession(asset: AVAsset(url: url), presetName: AVAssetExportPresetPassthrough)
        exportSession?.outputFileType = .mp4

        let start = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        let duration = CMTimeMakeWithSeconds(9.0, preferredTimescale: 600)
        let range = CMTimeRangeMake(start: start, duration: duration)

        exportSession?.timeRange = range
        let outputURL = MusicPicker.ownSoundURL

        try? FileManager.default.removeItem(at: outputURL)

        exportSession?.outputURL = outputURL

        exportSession?.exportAsynchronously { [weak self] in
            DispatchQueue.main.async {
                if self?.exportSession?.status == .completed  {
                    completion(outputURL)
                } else if self?.exportSession?.status == .failed {
                    completion(nil)
                }
            }
        }
    }
    
    
    
    private func metadataForAssetID(_ assetIdentifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        let keyContentIdentifier =  "com.apple.quicktime.content.identifier"
        let keySpaceQuickTimeMetadata = "mdta"
        item.key = keyContentIdentifier as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: keySpaceQuickTimeMetadata)
        item.value = assetIdentifier as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
    }
    
    
    
    private func createMetadataAdaptorForStillImageTime() -> AVAssetWriterInputMetadataAdaptor {
        let keyStillImageTime = "com.apple.quicktime.still-image-time"
        let keySpaceQuickTimeMetadata = "mdta"
        let spec : NSDictionary = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString:
            "\(keySpaceQuickTimeMetadata)/\(keyStillImageTime)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString:
            "com.apple.metadata.datatype.int8"            ]
        var desc : CMFormatDescription? = nil
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(allocator: kCFAllocatorDefault, metadataType: kCMMetadataFormatType_Boxed, metadataSpecifications: [spec] as CFArray, formatDescriptionOut: &desc)
        let input = AVAssetWriterInput(mediaType: .metadata,
                                       outputSettings: nil, sourceFormatHint: desc)
        return AVAssetWriterInputMetadataAdaptor(assetWriterInput: input)
    }
    
    
    
    private func metadataItemForStillImageTime() -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        let keyStillImageTime = "com.apple.quicktime.still-image-time"
        let keySpaceQuickTimeMetadata = "mdta"
        item.key = keyStillImageTime as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: keySpaceQuickTimeMetadata)
        item.value = 0 as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.int8"
        return item
    }
    
}



fileprivate extension AVAsset {
    func countFrames(exact:Bool) -> Int {
        
        var frameCount = 0
        
        if let videoReader = try? AVAssetReader(asset: self)  {
            
            if let videoTrack = self.tracks(withMediaType: .video).first {
                
                frameCount = Int(CMTimeGetSeconds(self.duration) * Float64(videoTrack.nominalFrameRate))
                
                
                if exact {
                    
                    frameCount = 0
                    
                    let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
                    videoReader.add(videoReaderOutput)
                    
                    videoReader.startReading()
                    
                    // count frames
                    while true {
                        let sampleBuffer = videoReaderOutput.copyNextSampleBuffer()
                        if sampleBuffer == nil {
                            break
                        }
                        frameCount += 1
                    }
                    
                    videoReader.cancelReading()
                }
                
                
            }
        }
        
        return frameCount
    }
    
    
    
    func stillImageTime() -> CMTime?  {
        
        var stillTime:CMTime? = nil
        
        if let videoReader = try? AVAssetReader(asset: self)  {
            
            if let metadataTrack = self.tracks(withMediaType: .metadata).first {
                
                let videoReaderOutput = AVAssetReaderTrackOutput(track: metadataTrack, outputSettings: nil)
                
                videoReader.add(videoReaderOutput)
                
                videoReader.startReading()
                
                let keyStillImageTime = "com.apple.quicktime.still-image-time"
                let keySpaceQuickTimeMetadata = "mdta"
                
                var found = false
                
                while found == false {
                    if let sampleBuffer = videoReaderOutput.copyNextSampleBuffer() {
                        if CMSampleBufferGetNumSamples(sampleBuffer) != 0 {
                            let group = AVTimedMetadataGroup(sampleBuffer: sampleBuffer)
                            for item in group?.items ?? [] {
                                if item.key as? String == keyStillImageTime && item.keySpace!.rawValue == keySpaceQuickTimeMetadata {
                                    stillTime = group?.timeRange.start
                                    //print("stillImageTime = \(CMTimeGetSeconds(stillTime!))")
                                    found = true
                                    break
                                }
                            }
                        }
                    }
                    else {
                        break;
                    }
                }
                
                videoReader.cancelReading()
                
            }
        }
        
        return stillTime
    }
    
    
    
    func makeStillImageTimeRange(percent:Float, inFrameCount:Int = 0) -> CMTimeRange {
        
        var time = self.duration
        
        var frameCount = inFrameCount
        
        if frameCount == 0 {
            frameCount = self.countFrames(exact: true)
        }
        
        let frameDuration = Int64(Float(time.value) / Float(frameCount))
        
        time.value = Int64(Float(time.value) * percent)
        
        //print("stillImageTime = \(CMTimeGetSeconds(time))")
        
        return CMTimeRangeMake(start: time, duration: CMTimeMake(value: frameDuration, timescale: time.timescale))
    }
    
    
    
    func getAssetFrame(percent:Float) -> UIImage?
    {
        
        let imageGenerator = AVAssetImageGenerator(asset: self)
        imageGenerator.appliesPreferredTrackTransform = true
        
        imageGenerator.requestedTimeToleranceAfter = CMTimeMake(value: 1,timescale: 100)
        imageGenerator.requestedTimeToleranceBefore = CMTimeMake(value: 1,timescale: 100)
        
        var time = self.duration
        
        time.value = Int64(Float(time.value) * percent)
        
        do {
            var actualTime = CMTime.zero
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime:&actualTime)
            
            let img = UIImage(cgImage: imageRef)
            
            return img
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
}
