//
//  AppDelegate.swift
//  Video To
//
//  Created by Artem Sherbachuk on 9/13/21.
//

import UIKit
import Firebase
import FBSDKCoreKit
import AppsFlyerLib

var AppsFlyerUID: String { AppsFlyerLib.shared().getAppsFlyerUID() }

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AppsFlyerLibDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Theme.setupAppearance()
        launchesCount += 1
        FirebaseApp.configure()
        Configs.run()

        AppsFlyerLib.shared().appsFlyerDevKey = ""
        AppsFlyerLib.shared().appleAppID = ""
        AppsFlyerLib.shared().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(sendLaunch), name: UIApplication.didBecomeActiveNotification, object: nil)

        checkIfShouldRequestIDFA {
            ApplicationDelegate.shared.application(
                application,
                didFinishLaunchingWithOptions: launchOptions
            )
            RevenueCat.run()
            AdMob.run()
        }

        return true
    }

    @objc func sendLaunch() {
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        AppsFlyerLib.shared().start()
    }

    func application( _ app: UIApplication, open url: URL,
                      options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }

    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        if let status = conversionInfo["af_status"] as? String {
            if (status == "Non-organic") {
                // Business logic for Non-organic install scenario is invoked
                if let sourceID = conversionInfo["media_source"] as? String,
                   let campaign = conversionInfo["campaign"] as? String {
                    RevenueCat.sendCampaignData(mediaSource: sourceID, campaign: campaign)
                }
            }
            else {
                // Business logic for organic install scenario is invoked
            }
        }
    }

    func onConversionDataFail(_ error: Error) {

    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

