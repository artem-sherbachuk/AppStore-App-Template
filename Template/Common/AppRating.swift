//
//  AppRating.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 12/22/20.
//

import UIKit
import StoreKit

public enum AppRating {

    static let removedKey = "AppRatingRemovedKey"

    private static var isRemoved: Bool {
        get { return UserDefaults.standard.bool(forKey: removedKey) }
        set { UserDefaults.standard.set(newValue, forKey: removedKey) }
    }


    static let minLaunchesCountKey = "AppRatingMinLaunchesCountKey"

    private static var minLaunchesCount: Int {
        get { return UserDefaults.standard.value(forKey: minLaunchesCountKey) as? Int ?? 3 }
        set { UserDefaults.standard.set(newValue, forKey: minLaunchesCountKey) }
    }

    // MARK: - Request

    /// Request rate app alert
    ///
    /// - parameter request: The request configuration model.
    /// - parameter viewController: The view controller that will present the UIAlertController.
    public static func requestReview(from viewController: UIViewController) {

        let title = "Enjoying This App?".localized()
        let message = "Could you please, rate the app with 5 stars? :)".localized()
        let cancel = "No, Thanks".localized()

        // Show alert
        guard !isRemoved,
              launchesCount >= minLaunchesCount else {
            return
        }

        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let rateAction = UIAlertAction(title: "Yes!".localized(),
                                       style: .default) { _ in
            isRemoved = true
            SKStoreReviewController.requestReviewInCurrentScene()
        }
        alertController.addAction(rateAction)

        let cancelAction = UIAlertAction(title: cancel, style: .default) {_ in
            minLaunchesCount = launchesCount + 3
        }
        alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            viewController.present(alertController, animated: true)
        }
    }
}

extension SKStoreReviewController {
    
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            requestReview(in: scene)
        }
    }
}
