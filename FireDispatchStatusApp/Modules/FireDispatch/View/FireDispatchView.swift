//
//  FireDispatchView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import SwiftUI

@MainActor
struct FireDispatchView: View {
    
    private let feature = FireDispatchFeature()
    
    @AppStorage("isTutorialShown") private var isTutorialShown: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
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
                    SearchView(feature: feature.searchFeature)
                    
                    FilterView(feature: feature.filterFeature)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    ScrollView {
                        ScrollViewReader { proxy in
                            Section {
                                if let headerState = feature.state.headerState {
                                    FireDispatchHeaderView(state: headerState)
                                }
                            }
                            if feature.state.list.isEmpty {
                                ContentUnavailableView(
                                    "해당 화재 출동 건이 없습니다.",
                                    systemImage: "magnifyingglass"
                                )
                                .foregroundStyle(Color.appText)
                            } else {
                                LazyVStack {
                                    Section {
                                        ForEach(feature.state.list, id: \.sidoOvrNum) { model in
                                            FireDispatchListRow(model: model)
                                                .id(model.sidoOvrNum)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    feature.send(.didSelectedRow(model))
                                                }
                                                
                                        }
                                    }
                                    .background(Color.appBackground)
                                    .cornerRadius(15)
                                    .padding(.horizontal)
                                    .padding(.bottom, 10)
                                }
                                .onChange(of: feature.state.scrollToRow) { _, newValue in
                                    withAnimation(.smooth) {
                                        proxy.scrollTo(newValue, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                    .frame(minWidth: UIScreen.main.bounds.width)
                    .onTapGesture {
                        UIApplication.hideKeyBoard()
                    }
                    .refreshable {
                        feature.send(.fetchList)
                    }
                }
                .background(Color.appTheme)
                if !isTutorialShown {
                    TutorialView()
                }
            }
            .defaultAlert(feature.state.alertState, onDismiss: {
                feature.send(.dismissAlert)
            })
            .navigationTitle(Date().getMonthDayString() + " 화재출동 현황")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                feature.send(.fetchList)
            }
            .fullScreenCover(
                item: Binding(
                    get: { feature.state.mapState },
                    set: { _ in feature.send(.dismissMapFeature) }
                ),
                content: { state in
                    MapView(state: state)
                })
        }
    }
}
