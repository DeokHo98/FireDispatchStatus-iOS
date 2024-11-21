//
//  FireDispatchView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import SwiftUI
import ComposableArchitecture

struct FireDispatchView: View {
    
    @Bindable var store: StoreOf<FireDispatchFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Date().getMonthDayString() + " 화재 출동 현황")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.white)
                .padding(.leading, 20)
            
            FireDispatchSearchView(
                store: store.scope(state: \.searchState, action: \.searchAction)
            )
            
            ScrollView {
                LazyVStack {
                    ForEach(store.list, id: \.sidoOvrNum) { model in
                        FireDispatchListRow(model: model)
                    }
                }
            }
            .frame(minWidth: UIScreen.main.bounds.width)
            .onTapGesture {
                UIApplication.hideKeyBoard()
            }
        }
        .padding(.top, UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
        .background(Color("Theme"))
        .ignoresSafeArea(edges: .top)
        .alert($store.scope(state: \.alertState, action: \.alertAction))
        .onAppear {
            store.send(.fetchFireDispatchList)
        }
    }
}
