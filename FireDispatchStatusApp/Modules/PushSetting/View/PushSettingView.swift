//
//  PushSettingView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/22/24.
//

import SwiftUI

@MainActor
struct PushSettingView: View {
    
    private let feature = PushSettingFeature()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                SearchView(feature: feature.searchFeature)
                
                FilterView(feature: feature.filterFeature)
                .padding(.horizontal)
                .padding(.vertical, 10)
          
                if !feature.state.pushOnCenter.isEmpty {
                    HStack {
                        Spacer()
                        PushSettingHeaderView(pushOnCenter: feature.state.pushOnCenter)
                            .onTapGesture {
                                feature.send(.didSelectedRow(feature.state.pushOnCenter))
                            }
                        Spacer()
                    }
                }
                
                ScrollView {
                    if feature.state.list.isEmpty {
                        ContentUnavailableView("해당 소방서가 없습니다.", systemImage: "magnifyingglass")
                    } else {
                        LazyVStack {
                            Section {
                                ForEach(feature.state.list, id: \.id) { model in
                                    PushSettingRowView(model: model)
                                        .onTapGesture {
                                            UIApplication.hideKeyBoard()
                                            feature.send(.didSelectedRow(model.name))
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
            }
            .background(Color.appTheme)
            .navigationTitle("알림 설정")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                guard feature.state.list.isEmpty else { return }
                feature.send(.fetchList)
            }
            .modifier(
                PushSettingAlert(
                type: feature.state.alertState.type,
                model: feature.state.alertState.model,
                feature: feature
            )
            )
        }
    }
}

extension PushSettingView {
    struct PushSettingAlert: ViewModifier {
        let type: PushSettingFeature.Alert
        let model: AlertModel
        let feature: PushSettingFeature
        
        func body(content: Content) -> some View {
            switch type {
            case .default:
                content.defaultAlert(model) {
                    feature.send(.alertAction(.dismiss))
                }
            case .pushOn, .pushOff, .pushSetting:
                content.confirmAlert(model) {
                    feature.send(.alertAction(.dismiss))
                } onConfirm: {
                    feature.send(.alertAction(type))
                }
            default:
                content
            }
        }
    }
}
