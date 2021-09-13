//
//  RevenuCat.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 1/19/21.
//

import Purchases
import FBSDKCoreKit

typealias ShopItem = Purchases.Package
typealias PurchasesInfo = Purchases.EntitlementInfo
typealias SubscriptionPeriod = SKProductSubscriptionPeriod

struct RevenueCat {

    private static let id = ""

    static func run() {
        Purchases.automaticAppleSearchAdsAttributionCollection = true
        Purchases.configure(withAPIKey: id)
        Purchases.shared.collectDeviceIdentifiers()
        Purchases.shared.delegate = User.shared

        // disable automatic tracking
        FBSDKCoreKit.Settings.isAutoLogAppEventsEnabled = false
        // optional: call activateApp
        FBSDKCoreKit.AppEvents.activateApp()
        Purchases.shared.setFBAnonymousID(FBSDKCoreKit.AppEvents.anonymousID)

        Purchases.shared.setAppsflyerID(AppsFlyerUID)
    }

    static var userId: String {
        return Purchases.shared.appUserID
    }

    static func sendCampaignData(mediaSource: String, campaign: String) {
        Purchases.shared.setAttributes(["$mediaSource" : mediaSource,
                                        "$campaign" : campaign])
    }

    //MARK: - Subscription
    static let proEntitlementKey = "Premium"

    static let weeklyId = ""
    static let monthlyId = ""
    static let annualId = ""
    static let lifetimeId = ""

    static func fetchSubscriptionOptions(completion: @escaping ([ShopItem]?) -> Void) {
        Purchases.shared.offerings { (offerings, error) in
            if let error = error {

                if (error as NSError).code == 10,
                   let topVc = UIApplication.shared.topMostViewController() {
                    presentAlert(controller: topVc,
                                 title: "Network Not Reachable",
                                 message: "The Internet connection appears to be offline.")
                } else {
                    presentError(error: error)
                }
            }

            let packages = offerings?.current?.availablePackages
            completion(packages)
        }
    }

    enum SubscriptionState {
        case subscribed, notSubscribed, unknown
    }

    static func purchaseSubscription(package: ShopItem,
                                     completion: @escaping (SubscriptionState) -> Void) {
        Purchases.shared.purchasePackage(package)
        { (transaction, purchaserInfo, error, userCancelled) in
            if let error = error {
                presentError(error: error)
                completion(.notSubscribed)
                return
            }

            let entitlement = purchaserInfo?.entitlements[proEntitlementKey]
            if entitlement?.isActive == true {
                completion(.subscribed)
            } else {
                completion(.unknown)
            }
        }
    }

    static func refetchSubscriptionInfo() {
        Purchases.shared.purchaserInfo { (info, error) in
            if let error = error {
                presentError(error: error)
                return
            }
            if let info = info {
                User.shared.purchases(Purchases.shared, didReceiveUpdated: info)
            }
        }
    }

    //MARK: - Restore Purchases
    static func restoreTransactions(completion: @escaping () -> Void) {
        Purchases.shared.restoreTransactions { (purchaserInfo, error) in
            if let error = error {
                presentError(error: error)
                completion()
                return
            }
            if let info = purchaserInfo {
                User.shared.purchases(Purchases.shared, didReceiveUpdated: info)
            }
            completion()
        }
    }
}

let DidUpdateSubscriptionInfo_NotificationName = NSNotification.Name.init("DidUpdateSubscriptionInfo")

extension User: PurchasesDelegate {

    func purchases(_ purchases: Purchases,
                   didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        self.subscriptionInfo = purchaserInfo.entitlements[RevenueCat.proEntitlementKey]
        NotificationCenter.default.post(name: DidUpdateSubscriptionInfo_NotificationName, object: nil)
    }
}

//MARK: - Extensions
extension SKProductSubscriptionPeriod {

    var calendarUnit: NSCalendar.Unit {
        switch self.unit {
        case .day:
            return .day
        case .month:
            return .month
        case .week:
            return .weekOfMonth
        case .year:
            return .year
        @unknown default:
            debugPrint("Unknown period unit")
        }
        return .day
    }

    func localizedPeriod() -> String? {
        return PeriodFormatter.format(unit: calendarUnit, numberOfUnits: numberOfUnits)
    }
}

extension Purchases.EntitlementInfo {
    var expirationLocalizedString: String {
        guard let date = expirationDate else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long

        let expiration =  dateFormatter.string(from: date)
        let prefix = periodType == .trial ? "Free Trial".localized() + " " : ""
        let desc = String(format: "Expire at  %@".localized(), expiration)
        return prefix + desc
    }
}

struct PeriodFormatter {

    static var componentFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }

    static func format(unit: NSCalendar.Unit, numberOfUnits: Int) -> String? {
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        componentFormatter.allowedUnits = [unit]
        switch unit {
        case .day:
            if numberOfUnits == 7 {
                return "Week".localized()
            } else {
                dateComponents.setValue(numberOfUnits, for: .day)
                return componentFormatter.string(from: dateComponents)
            }
        case .weekOfMonth:
            let days = numberOfUnits * 7
            dateComponents.setValue(days, for: .day)
            return componentFormatter.string(from: dateComponents)
        case .month:
            return "1 Month".localized()
        case .year:
            return "12 Month".localized()
        default:
            return nil
        }
    }
}
