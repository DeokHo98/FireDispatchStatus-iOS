//
//  PushData.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/22/24.
//

import Foundation
import SwiftData

@Model
final class PushData {
    var fcmToken: String
    var centerName: String
    var isOn: Bool
    
    init(fcmToken: String, centerName: String, isOn: Bool) {
        self.fcmToken = fcmToken
        self.centerName = centerName
        self.isOn = isOn
    }
    
    func copy(fcmToken: String? = nil, centerName: String? = nil, isOn: Bool? = nil) -> Self {
        return Self(
            fcmToken: fcmToken ?? self.fcmToken,
            centerName: centerName ?? self.centerName,
            isOn: isOn ?? self.isOn
        )
    }
}
