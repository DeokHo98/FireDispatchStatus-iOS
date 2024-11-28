//
//  FireDispatchListRequest.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import Foundation

struct FireDispatchListRequest: NetworkRequest {
    let path = "/firedispatch/list"
    let method: HTTPMethod = .get
}
