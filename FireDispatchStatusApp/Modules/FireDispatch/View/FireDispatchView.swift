//
//  FireDispatchView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import SwiftUI
import ComposableArchitecture

struct FireDispatchView: View {
    
    @AppStorage("isTutorialShown") private var isTutorialShown: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var store: StoreOf<FireDispatchFeature>
    
    init(store: StoreOf<FireDispatchFeature>) {
        self.store = store
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "Text") ?? .white
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(named: "Text") ?? .white
        ]
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    SearchView(
                        store: store.scope(state: \.searchState, action: \.searchAction)
                    )
                    
                    FilterView(
                        store: store.scope(state: \.filterState, action: \.filterAction)
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    ScrollView {
                        Section {
                            if let headerState = store.headerState {
                                FireDispatchHeaderView(state: headerState)
                            }
                        }
                        if store.list.isEmpty {
                            ContentUnavailableView(
                                "해당 화재 출동 건이 없습니다.",
                                systemImage: "magnifyingglass"
                            )
                            .foregroundStyle(Color.appText)
                        } else {
                            LazyVStack {
                                Section {
                                    ForEach(store.list, id: \.sidoOvrNum) { model in
                                        FireDispatchListRow(model: model)
                                    }
                                }
                                .background(Color.appBackground)
                                .cornerRadius(15)
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .frame(minWidth: UIScreen.main.bounds.width)
                    .onTapGesture {
                        UIApplication.hideKeyBoard()
                    }
                    .refreshable {
                        store.send(.refreshButtonTap)
                    }
                }
                .background(Color.appTheme)
                if !isTutorialShown {
                    TutorialView()
                }
            }
            .alert($store.scope(state: \.alertState, action: \.alertAction))
            .navigationTitle(Date().getMonthDayString() + " 화재출동 현황")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: scenePhase) { (_, phase) in
                if phase == .active {
                    store.send(.fetchFireDispatchList)
                }
            }
        }
    }
}
