//
//  User.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/17/21.
//

import Foundation

final class User: NSObject {

    static let shared = User()

    var subscriptionInfo: PurchasesInfo?

    var isPremium: Bool { subscriptionInfo?.isActive ?? false }
}
