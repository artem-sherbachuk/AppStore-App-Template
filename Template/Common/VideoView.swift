//
//  VideoView.swift
//  Charging play
//
//  Created by Artem Sherbachuk on 8/6/21.
//

import AVFoundation
import UIKit

final class VideoView: SpringView {

    private var player = AVPlayer()
    private var videoPlayerLayer: AVPlayerLayer?

    var disableLoop: Bool = false {
        didSet {
            pause()
            play()
        }
    }

    @IBInspectable var isMuted: Bool = false {
        didSet {
            player.isMuted = isMuted
        }
    }

    var applyPreferredTransform: Bool = true

    var isHorizontal: Bool = false {
        didSet {
            layoutSubviews()
        }
    }

    private var isPortraitVideo: Bool {
        guard let url = url,
              let videoTrack = AVAsset(url: url).tracks(withMediaType: .video).first else {
            return false
        }

        let transformedVideoSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let videoIsPortrait = abs(transformedVideoSize.width) < abs(transformedVideoSize.height)
        return videoIsPortrait
    }

    private(set) var url: URL? {
        didSet {
            if applyPreferredTransform {
                isHorizontal = !isPortraitVideo
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayerLayer?.frame = frame
        let isHorizontal = self.isHorizontal
        videoPlayerLayer?.transform = isHorizontal ? CATransform3DMakeRotation(.pi/2, 0, 0, 1.0) : CATransform3DMakeRotation(0, 0, 0, 1.0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        videoPlayerLayer = AVPlayerLayer(player: player)
        videoPlayerLayer!.frame = bounds
        videoPlayerLayer!.videoGravity = .resizeAspectFill
        layer.addSublayer(videoPlayerLayer!)

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player.currentItem,
                                               queue: .main) { [weak self] _ in
            if self?.disableLoop == false {
                self?.player.seek(to: CMTime.zero)
                self?.player.play()
            }
        }

        clipsToBounds = true
        layer.cornerRadius = 25
    }

    func setupPlayerItem(url: URL?, isMuted: Bool) {
        guard let url = url else {
            return
        }
        self.isMuted = isMuted
        pause()

        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        self.url = url
    }

    func play() {
        player.pause()
        player.seek(to: .zero)
        player.play()
    }

    func pause() {
        player.pause()
    }

    func thumbnailImage() -> UIImage? {
        guard let asset = player.currentItem?.asset else { return nil }

        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true
        assetGenerator.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        let time = CMTimeMake(value: 0, timescale: 60)
        let cgImage = try? assetGenerator.copyCGImage(at: time, actualTime:nil)

        if let cgImage = cgImage {
            return UIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }


    func averageColorFromThumbnailImage() -> UIColor? {
        return thumbnailImage()?.averageColor
    }
}
