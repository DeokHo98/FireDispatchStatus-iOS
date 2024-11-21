//
//  FireDispatchListRow.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import SwiftUI

struct FireDispatchListRow: View {
    
    let model: FireDispatchModel
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    defaultText(model.centerName, size: 20)
                    defaultText(model.date)
                }
                HStack {
                    defaultText("출동 상태:")
                    defaultText(model.state, color: .red)
                }
            
                defaultText("화재지 주소: " + model.address)
                defaultText("사망자: \(model.deadNum)명, 부상자: \(model.injuryNum)명")
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.leading, 8)
            .padding(.top, 5)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 2)
                .foregroundStyle(Color(uiColor: .darkGray))
                .padding(.top, 5)
        }
 
    }
}

extension FireDispatchListRow {
    private func defaultText(
        _ text: String,
        color: Color = .white,
        size: CGFloat = 15
    ) -> Text {
        Text(text)
            .foregroundStyle(color)
            .font(.system(size: size, weight: .semibold))
    }
}
