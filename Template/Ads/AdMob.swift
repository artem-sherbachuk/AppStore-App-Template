//
//  AdMob.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 1/20/21.
//


import GoogleMobileAds
import UIKit

typealias AdPresentationCompletion = (Bool) -> Void

var isAdEnabled: Bool {

    if User.shared.isPremium || isFirstLaunch || Configs.isAdDisabled {
        return false
    }

    return true
}

final class AdMob: NSObject {

    static let testDevices = [""]

    static func run() {
        if isAdEnabled == false {
            return
        }

        let ad = GADMobileAds.sharedInstance()

        //init adMob & mediations
        ad.start { status in
            #if DEBUG
            ad.requestConfiguration.testDeviceIdentifiers = testDevices
            ad.disableSDKCrashReporting()
            #endif
            setAdvertiserTrackingEnabled()
        }

        interstitial = AdMobInterstitial()
        openAppAd = AdMobOpenAppAd()
        rewardedVideoAd = AdMobRewardedVideoAd()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AdMob.presentAppOpenAd()
        }
    }

    static func setAdvertiserTrackingEnabled(_ flag: Bool = false) {
//        if #available(iOS 14.5, *) {
//            FBAudienceAd.setAdvertiserTrackingEnabled(flag)
//        } else {
//            FBAudienceAd.setAdvertiserTrackingEnabled(true)
//        }
    }

    static func showTestMediationVC(presentingVC: UIViewController) {
        //GoogleMobileAdsMediationTestSuite.present(on: presentingVC, delegate: nil)
    }

    //MARK: - Interstitial

    private static var interstitial: AdMobInterstitial?

    static func presentApologyAdAllertIfNeed() {
        if UserDefaults.standard.bool(forKey: "isUserViewAd") == true {
            return
        }

        let title = "Info".localized()
        let message = "Dear user I'm apologizing for the ads, I have expensive cost per install, so I have to keep ads while you in the base app version. However once you activate premium you will no longer see any ads in this app. \n Kind Regards!".localized()

        if let topVC = UIApplication.shared.topMostViewController() {
            presentAlert(controller: topVC, title: title, message: message)
        }

        UserDefaults.standard.setValue(true, forKey: "isUserViewAd")
    }

    static func presentInterstitialAd(completion: AdPresentationCompletion? = nil) {
        if isAdEnabled == false {
            completion?(false)
            return
        }

        if let topVc = UIApplication.shared.topMostViewController(),
           topVc is SubscriptionViewController == false {
            AdMob.interstitial?.showAd(viewController: topVc, completion:  completion)
        } else {
            completion?(false)
        }
    }


    //MARK: - Present AdMob Open App Ad

    private static var openAppAd: AdMobOpenAppAd?

    static func presentAppOpenAd() {
        if isAdEnabled == false {
            return
        }

        if UIApplication.shared.topMostViewController() is SubscriptionViewController {
            return
        }

        openAppAd?.presentAppOpenAd()
    }


    //MARK: - Present Rewarded Mediation Ad

    private static var rewardedVideoAd: AdMobRewardedVideoAd?

    static func presentRewardedAd(controller: UIViewController,
                                  completion: @escaping AdPresentationCompletion) {
        if isAdEnabled == false {
            completion(false)
            return
        }

        AdMob.rewardedVideoAd?.showRewardedAd(viewController: controller, completion: completion)

    }
}


final class AdMobOpenAppAd: NSObject {

    //MARK: - openAppPlacement

    let openAppPlacementId = ""

    fileprivate var appOpenAd: GADAppOpenAd? {
        didSet {
            appOpenAd?.fullScreenContentDelegate = self
        }
    }

    private func requestAppOpenAd(completion: (() -> Void)? = nil) {
        appOpenAd = nil

        GADAppOpenAd.load(withAdUnitID: openAppPlacementId,
                          request: GADRequest(),
                          orientation: .portrait) { [weak self] (appOpenAd, error) in
            self?.appOpenAd = appOpenAd
            completion?()
        }
    }

    func presentAppOpenAd() {
        self.appOpenAd = nil

        requestAppOpenAd { [weak self] in
            if let ad = self?.appOpenAd,
               let rootViewController = UIApplication.shared.topMostViewController() {
                ad.present(fromRootViewController: rootViewController)
            }
        }
    }
}


extension AdMobOpenAppAd: GADFullScreenContentDelegate {

    func ad(_ ad: GADFullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        requestAppOpenAd()
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        requestAppOpenAd()
        AdMob.presentApologyAdAllertIfNeed()
    }
}



final class AdMobInterstitial: NSObject {

    let placementId = ""

    var requestAd: GADInterstitial?

    private var loadAdCompletion: AdPresentationCompletion?

    private var showAdCompletion: ((Bool) -> Void)? = nil

    private var adDidComplete: Bool = false

    private var attemptsToShowCount: Int = 0

    override init() {
        super.init()
        loadAd { _ in }
    }

    private func loadAd(completion: AdPresentationCompletion? = nil) {
        if requestAd != nil && requestAd?.isReady == true {
            completion?(true)
            return
        }

        requestAd = GADInterstitial(adUnitID: placementId)
        requestAd?.delegate = self
        let request = GADRequest()
        requestAd?.load(request)
        loadAdCompletion = completion
    }

    func showAd(viewController: UIViewController,
                completion: AdPresentationCompletion?) {

        if requestAd?.isReady == true {
            adDidComplete = false
            showAdCompletion = completion
            requestAd?.present(fromRootViewController: viewController)
        } else { //try after 1 sec. the ad can be in downloading state
            completion?(false)
            loadAd { _ in
            }
        }
    }

    private func doNextRequest() {
        self.requestAd = nil
        loadAd()
        showAdCompletion?(adDidComplete)
    }
}

extension AdMobInterstitial: GADInterstitialDelegate {

    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        loadAdCompletion?(true)
    }

    func interstitial(_ ad: GADInterstitial,
                      didFailToReceiveAdWithError error: GADRequestError) {
        loadAdCompletion?(false)
    }

    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
    }

    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        adDidComplete = true
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        doNextRequest()
        AdMob.presentApologyAdAllertIfNeed()
    }

    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
    }
}


//MARKL - RewardedAd

final class AdMobRewardedVideoAd: NSObject {

    let placementId = ""

    var rewardedAd: GADRewardedAd?

    private var loadRewardedAdCompletion: AdPresentationCompletion?

    private var showRewardedAdCompletion: ((Bool) -> Void)? = nil

    private var rewardedVideoDidComplete: Bool = false

    private var attemptsToShowCount: Int = 0

    override init() {
        super.init()
        loadRewardedAd { _ in }
    }

    private func loadRewardedAd(completion: AdPresentationCompletion? = nil) {
        if rewardedAd != nil && rewardedAd?.isReady == true {
            completion?(true)
            return
        }

        rewardedAd = GADRewardedAd(adUnitID: placementId)
        let request = GADRequest()
        rewardedAd?.load(request) { error in
            if let error = error {
                completion?(false)
            } else {
                completion?(true)
            }
        }
    }

    func showRewardedAd(viewController: UIViewController,
                        completion: @escaping AdPresentationCompletion) {
        if rewardedAd?.isReady == true {
            rewardedVideoDidComplete = false
            showRewardedAdCompletion = completion
            rewardedAd?.present(fromRootViewController: viewController,
                                delegate:self)
        } else { //try after 1 sec. the ad can be in downloading state
            completion(false)
            loadRewardedAd { _ in
            }
        }
    }

    private func doNextRequest() {
        self.rewardedAd = nil
        loadRewardedAd()
        showRewardedAdCompletion?(rewardedVideoDidComplete)
    }
}

extension AdMobRewardedVideoAd: GADRewardedAdDelegate {

    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        rewardedVideoDidComplete = true
    }

    func rewardedAd(_ rewardedAd: GADRewardedAd,
                    didFailToPresentWithError error: Error) {
    }

    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
    }

    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        doNextRequest()
    }
}
