//
//  VideoPicker.swift
//  Charging play
//
//  Created by Artem Sherbachuk on 8/9/21.
//

import PhotosUI
import UIKit

public protocol VideoPickerDelegate: AnyObject {
    func didSelectVideo(url: URL?)
    func didSelectImage(_ image: UIImage?)
}

open class VideoPicker: NSObject, UINavigationControllerDelegate {

    private var pickerController: PHPickerViewController?
    private weak var presentationController: UIViewController?
    private weak var delegate: VideoPickerDelegate?

    public init(presentationController: UIViewController, delegate: VideoPickerDelegate) {
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
    }

    func pick(_ sourceType: PHPickerFilter) {

        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = sourceType

        pickerController = PHPickerViewController(configuration: config)
        pickerController?.delegate = self
        presentationController?.present(pickerController!, animated: true, completion: nil)
    }

    private func dismiss() {
        pickerController?.dismiss(animated: true, completion: nil)
        pickerController = nil
    }
}

extension VideoPicker: PHPickerViewControllerDelegate {

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let provider = results.first?.itemProvider else {
            dismiss()
            return
        }

        if picker.configuration.filter == .videos {
            loadVideo(provider)
        } else if picker.configuration.filter == .images {
            loadImage(provider)
        } else {
            dismiss()
        }
    }


    private func loadVideo(_ provider: NSItemProvider) {
        let id = UTType.movie.identifier
        let hasVideo = provider.hasItemConformingToTypeIdentifier(id)
        guard hasVideo else { return }

        if let topView = UIApplication.shared.windows.first {
            ActivityIndicator.showActivity(topView: topView)
        }

        provider.loadFileRepresentation(forTypeIdentifier: id) { [weak self] url, error in

            if let url = url {
                VideoPicker.moveVideoToDocFrom(url) { url in
                    DispatchQueue.main.async {
                        self?.dismiss()
                        self?.delegate?.didSelectVideo(url: url)
                        ActivityIndicator.hideActivity()
                    }
                }

            } else {

                DispatchQueue.main.async {
                    ActivityIndicator.hideActivity()
                    self?.delegate?.didSelectVideo(url: nil)
                }

            }
        }
    }

    private func loadImage(_ provider: NSItemProvider) {

        if provider.canLoadObject(ofClass: UIImage.self) {

            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    self?.dismiss()

                    if let image = image as? UIImage {
                        self?.delegate?.didSelectImage(image)
                    } else {
                        self?.delegate?.didSelectImage(nil)
                    }
                }
            }
        }

    }


    private static func moveVideoToDocFrom(_ url: URL,
                            completion: @escaping (URL?) -> Void) {

        if let videoData = try? Data(contentsOf: url) {
            DispatchQueue.global().async(qos: .userInitiated) {
                let url = createTempVideoURL()
                try? FileManager.default.removeItem(at: url)
                try? videoData.write(to: url)
                completion(url)
            }
        } else {
            completion(nil)
        }

    }

    private static func createTempVideoURL() -> URL {
        let documentURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let outputURL = documentURL.appendingPathComponent("targetVideo.mp4")
        return outputURL
    }
}
