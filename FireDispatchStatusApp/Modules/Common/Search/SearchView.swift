//
//  SearchView.swift.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    
    @Bindable var store: StoreOf<SearchFeature>

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.appText)
                .padding(.leading, 10)
            
            TextField("", text: $store.text.sending(\.textFeildEditing))
            .placeholder(when: store.text.isEmpty, placeholder: {
                Text("소방서를 검색 해보세요 :)")
                    .foregroundStyle(Color.appText.opacity(0.6))
            })
            .foregroundColor(Color.appText)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.background.opacity(0.6))
        )
        .padding(.horizontal, 16)
    }
}
