//
//  MusicPicker.swift
//  Charging play
//
//  Created by Artem Sherbachuk on 8/22/21.
//

import MediaPlayer
import AudioToolbox

protocol MusicPickerDelegate: AnyObject {
    func didStartExport(progress: Float)
    func didSelectMusic(url: URL?)
}

final class MusicPicker: NSObject, UINavigationControllerDelegate {

    static var ownSoundURL: URL {
        let documentURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let outputURL = documentURL.appendingPathComponent("ownSound.m4a")
        return outputURL
    }

    private weak var delegate: MusicPickerDelegate?

    private(set) var exportSession: AVAssetExportSession?

    public init(delegate: MusicPickerDelegate) {
        super.init()
        self.delegate = delegate
    }

    public func pickFrom(_ vc: UIViewController, sourceView: UIView?) {
        let controller = MPMediaPickerController(mediaTypes: .anyAudio)
        controller.popoverPresentationController?.sourceView = sourceView ?? vc.view
        controller.delegate = self
        vc.present(controller, animated: true)
    }
}

extension MusicPicker: MPMediaPickerControllerDelegate {

    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

        guard let mediaItem = mediaItemCollection.items.first,
              let url = mediaItem.assetURL else {
            dismiss(mediaPicker)
            return
        }

        dismiss(mediaPicker)
        moveToDocuments(pathURL: url) { [weak self] finalURL in
            self?.delegate?.didSelectMusic(url: finalURL)
        }
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(mediaPicker)
    }

    func dismiss(_ vc: UIViewController) {
        if let nav = vc.navigationController {
            nav.dismiss(animated: true, completion: nil)
        } else {
            vc.dismiss(animated: true, completion: nil)
        }
    }


    private func moveToDocuments(pathURL: URL,
                                 completion:@escaping (URL?) -> Void ) {
        let str = pathURL.absoluteString
        let str2 = str.replacingOccurrences( of : "ipod-library://item/item", with: "")
        let arr = str2.components(separatedBy: "?")
        var mimeType = arr[0]
        mimeType = mimeType.replacingOccurrences(of : ".", with: "")


        exportSession = AVAssetExportSession(asset: AVAsset(url: pathURL), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.outputFileType = .m4a
        let start = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        let duration = CMTimeMakeWithSeconds(15.0, preferredTimescale: 600)
        let range = CMTimeRangeMake(start: start, duration: duration)
        exportSession?.timeRange = range
        let outputURL = MusicPicker.ownSoundURL

        try? FileManager.default.removeItem(at: outputURL)

        exportSession?.outputURL = outputURL

        exportSession?.exportAsynchronously { [weak self] in
            DispatchQueue.main.async {
                let progress = self?.exportSession?.progress ?? 0
                self?.delegate?.didStartExport(progress: progress)

                if self?.exportSession?.status == .completed  {
                    completion(outputURL)
                } else if self?.exportSession?.status == .failed {
                    completion(nil)
                }
            }
        }
    }
}
