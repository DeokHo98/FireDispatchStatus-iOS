//
//  PushSettingHeaderView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 12/3/24.
//

import SwiftUI

struct PushSettingHeaderView: View {
    
    let pushOnCenter: String
    
    var body: some View {
        HStack {
            Text("현재 알림 설정한 소방서: \(pushOnCenter)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.appText)
            Image(systemName: "bell.fill")
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(Color.appText)
        }
        .padding()
        .background(Color.appBackground)
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}
