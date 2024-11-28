//
//  FCMRequest.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/22/24.
//

import Foundation

struct FCMRegisterRequest: NetworkRequest {
    let token: String
    let centerName: String
    let deviceID: String
    let path = "/fcm/register"
    let method: HTTPMethod = .post
    let headers: [String: String]? = ["Content-Type": "application/json"]
    var body: Data? {
        let parameters: [String: Any] = [
            "token": token,
            "centerName": centerName,
            "deviceId": deviceID
        ]
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}

struct FCMTokenDeleteRequest: NetworkRequest {
    let deviceId: String    
    let path = "/fcm/delete"
    let method: HTTPMethod = .post
    let headers: [String: String]? = ["Content-Type": "application/json"]
    var body: Data? {
        let parameters: [String: Any] = [
            "deviceId": deviceId
        ]
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}
