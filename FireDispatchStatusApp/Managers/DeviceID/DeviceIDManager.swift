//
//  DeviceIDManager.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/22/24.
//

import Foundation
import UIKit

struct DeviceIDManager {
    private let deviceIdKey = "device_unique_id"
    private let service = Bundle.main.bundleIdentifier ?? "your.app.bundle"
    
    func saveToKeyChain() {
        guard getToKeyChain() == nil else { return }
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString,
        let deviceIDData = deviceID.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: deviceIdKey,
            kSecValueData as String: deviceIDData
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            return
        }
        print("DEBUG: KeyChain에 새롭게 저장된 DeviceID - \(deviceID)")
    }
    
    func getToKeyChain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: deviceIdKey,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let deviceId = String(data: data, encoding: .utf8) else {
            print("DEBUG: KeyChain에 저장된 DeviceID가 없습니다.")
            return nil
        }
        print("DEBUG: KeyChain에 저장된 DeviceID - \(deviceId)")
        return deviceId
    }
}
