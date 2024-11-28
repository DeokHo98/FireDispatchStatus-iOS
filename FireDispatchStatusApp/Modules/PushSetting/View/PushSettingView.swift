//
//  PushSettingView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/22/24.
//

import SwiftUI
import ComposableArchitecture

struct PushSettingView: View {
    
    @Bindable var store: StoreOf<PushSettingFeature>
    @State var isViewDidLoad = false
    
    var body: some View {
        NavigationStack {
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
                    if store.list.isEmpty {
                        ContentUnavailableView("해당 소방서가 없습니다.", systemImage: "magnifyingglass")
                    } else {
                        LazyVStack {
                            Section {
                                ForEach(store.list, id: \.id) { model in
                                    HStack {
                                        Text(model.name)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(Color.appText)
                                            .padding(.trailing, 5)
                                        if store.pushOnStation == model.name {
                                            Image(systemName: "bell.fill")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                                .foregroundStyle(Color.appText)
                                        }
                                        Spacer()
                                    }
                                    .frame(minHeight: 20)
                                    .padding()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        UIApplication.hideKeyBoard()
                                        store.send(.didSelectedRow(model.name))
                                    }
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
                .onAppear {
                    guard !isViewDidLoad else { return }
                    store.send(.loadFireStationList)
                    isViewDidLoad = true
                }
            }
            .background(Color.appTheme)
            .alert($store.scope(state: \.alertState, action: \.alertAction))
            .navigationTitle("알림 설정")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !store.pushOnStation.isEmpty {
                        Button {
                            store.send(.bellButtonTap)
                        } label: {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(Color.appText)
                        }
                    }
                }
            }
        }
    }
}
