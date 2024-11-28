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
                    defaultText(model.centerName, color: Color.appText, size: 16, weight: .bold)
                    Spacer()
                    defaultText(model.date, color: .gray, size: 14)
                }
                defaultText(model.address)
                defaultText("사망자: \(model.deadNum)명, 부상자: \(model.injuryNum)명")
                Text(model.state)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(model.stateBackGroundColor)
                    )
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

extension FireDispatchListRow {
    private func defaultText(
        _ text: String,
        color: Color = Color.appText,
        size: CGFloat = 14,
        weight: Font.Weight = .medium
    ) -> Text {
        Text(text)
            .foregroundStyle(color)
            .font(.system(size: size, weight: weight))
    }
}
