//
//  FireDispatchSearchView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import SwiftUI
import ComposableArchitecture

struct FireDispatchSearchView: View {
    
    @Bindable var store: StoreOf<FireDispatchSearchFeature>

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(uiColor: .lightGray))
                .padding(.leading, 10)
            
            TextField("", text: $store.text.sending(\.textFeildEditing))
            .placeholder(when: store.text.isEmpty, placeholder: {
                Text("소방서를 검색 해보세요 :)")
                    .foregroundStyle(Color(uiColor: .lightGray).opacity(0.6))
            })
            .foregroundColor(Color(uiColor: .lightGray))
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .darkGray).opacity(0.4))
        )
        .padding(.horizontal, 16)
    }
}
