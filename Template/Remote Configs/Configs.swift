//
//  Configs.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 1/25/21.
//

import Firebase

struct Configs {

    private static let trialDurationKey = "trialDuration"

    private static let disableAdsKey = "disableAds"

    private static let config = RemoteConfig.remoteConfig()

    static func run() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        config.configSettings = settings
        config.setDefaults(fromPlist: "RemoteConfigDefaults")
        fetchConfigs()
    }

    static func fetchConfigs() {
        config.fetchAndActivate(completionHandler: nil)
    }

    static var trialDuration: Int {
        let value = config.configValue(forKey: trialDurationKey).numberValue
        return value.intValue
    }

    static var isAdDisabled: Bool {
        return config.configValue(forKey: disableAdsKey).boolValue
    }
}
