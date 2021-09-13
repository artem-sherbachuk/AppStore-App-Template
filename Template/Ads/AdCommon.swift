//
//  AdCommon.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 1/26/21.
//

import AppTrackingTransparency
import UIKit
import AdSupport
import FBSDKCoreKit

var isIDFARequestCompleted = false {
    didSet {
        let window = UIApplication.shared.windows.first
        let vc = window?.rootViewController as? TabBarController
        if vc?.isViewLoaded == true && isFirstLaunch {
            vc?.presentSubscription()
        }
    }
}

var idfa: String {
    return ASIdentifierManager.shared().advertisingIdentifier.uuidString
}

func checkIfShouldRequestIDFA(completion:(() -> Void)? = nil) {
    if #available(iOS 14.5, *) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            DispatchQueue.main.async {
                FacebookCore.Settings.setAdvertiserTrackingEnabled(status == .authorized)
                completion?()
                isIDFARequestCompleted = true
            }
        })
    } else {
        FacebookCore.Settings.setAdvertiserTrackingEnabled(true)
        completion?()
        isIDFARequestCompleted = true
    }
}
