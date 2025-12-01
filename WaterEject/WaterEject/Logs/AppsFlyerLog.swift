//
//  AppsFlyerLog.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 31.10.2025.
//

import Foundation
import RevenueCat
import AppsFlyerLib

enum AFEvent: String {
  case install, start_app, subscribe, subscription_started,
       subscription_renewed, subscription_cancelled,
       subscription_refunded, subscription_expired,
       billing_issue_detected, product_change,
       purch, non_subscription_purchase
}

struct AF {
  static func log(_ e: AFEvent, _ vals: [String: Any] = [:]) {
    var v = vals
    v["af_user_id"] = Purchases.shared.appUserID
    AppsFlyerLib.shared().logEvent(e.rawValue, withValues: v)
  }
}

