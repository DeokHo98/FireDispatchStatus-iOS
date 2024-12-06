//
//  PushSettingRowView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 12/3/24.
//

import SwiftUI

struct PushSettingRowView: View {
    
    let model: FireStationModel
    
    var body: some View {
        HStack {
            Text(model.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.appText)
                .padding(.trailing, 5)
            Spacer()
        }
        .frame(minHeight: 20)
        .padding()
        .contentShape(Rectangle())
    }
}
