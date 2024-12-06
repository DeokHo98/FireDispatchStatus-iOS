//
//  SearchView.swift.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import SwiftUI

@MainActor
struct SearchView: View {
    
    private let feature: SearchFeature
    
    init(feature: SearchFeature) {
        self.feature = feature
    }

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.appText)
                .padding(.leading, 10)
            
            TextField("", text: Binding(
                get: { feature.state.text },
                set: { newValue in
                    feature.send(.textFeildEditing(newValue))
                }
            ))
            .placeholder(when: feature.state.text.isEmpty, placeholder: {
                Text("소방서를 검색 해보세요 :)")
                    .foregroundStyle(Color.appText.opacity(0.6))
            })
            .foregroundColor(Color.appText)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appBackground.opacity(0.6))
        )
        .padding(.horizontal, 16)
    }
}
