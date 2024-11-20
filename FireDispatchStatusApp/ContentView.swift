//
//  ContentView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            
        }
        .task {
            let networkService = NetworkService(baseURL: .main)
            let request = FireDispatchListRequest()
            do {
                let data: [FireDispatchModel] = try await networkService.request(request)
            } catch {
            }
        }
    }
}
