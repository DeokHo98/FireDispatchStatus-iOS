//
//  MapView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 12/4/24.
//

import SwiftUI
import MapKit

@MainActor
struct MapView: View {
    
    private let feature: MapFeature
    @State private var showInfoPopover = false
    @Environment(\.dismiss) private var dismiss
    
    init(state: MapFeature.State) {
        self.feature = MapFeature(state: state)
    }
    
    var body: some View {
            ZStack(alignment: .bottom) {
                if let postion = feature.state.cameraPosition {
                    Map(
                        position: Binding(
                            get: {
                                postion
                            }, set: { _ in
                                
                            }
                        )
                    ) {
                        if let userLocation = feature.state.userLocation {
                            Annotation("", coordinate: userLocation) {
                                VStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 15, height: 15)
                                    Text("내 위치")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.appText)
                                }
                            }
                        }
                        if let fireLocation = feature.state.fireLocation {
                            let model = feature.state.fireDispatchModel
                            Annotation("", coordinate: fireLocation) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 15, height: 15)
                                Text("\(model.address)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.appText)
                                Text("\(model.centerName)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.appText)
                                Text("\(model.date)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.appText)
                                Text("\(model.state)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    moveToLocationButton()
                    infoPobOverButton()
                }
                dismissButton()
            }
            .onAppear {
                feature.send(.onAppear)
            }
            .modifier(
                MapViewAlert(
                    type: feature.state.alertState.type,
                    model: feature.state.alertState.model,
                    feature: feature)
            )
    }
    
    private func moveToLocationButton() -> some View {
        let type = feature.state.moveToLocationButtonState
        return Button(action: {
            feature.send(.moveToLocationButtonTap)
        }, label: {
            HStack {
                Image(systemName: "location")
                    .foregroundStyle(type == .userLocation ? Color.appText : .white)
                Text("\(type.rawValue)로 이동하기")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(type == .userLocation ? Color.appText : .white)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        })
        .background(type == .userLocation ? Color.appTheme : .red)
        .clipShape(.rect(cornerRadius: 28))
        .padding(.bottom, 25)
    }
    
    private func infoPobOverButton() -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showInfoPopover = true
                }, label: {
                    Image(systemName: "questionmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color.white)
                })
                .frame(width: 40, height: 40)
                .background(Color.red)
                .clipShape(Circle())
                .popover(
                    isPresented: $showInfoPopover,
                    attachmentAnchor: .point(.bottom)
                ) {
                    let text1 = "애플 지도 주소지 검색을 기반으로 합니다.\n"
                    let text2 = "위치정보는 대략적인 위치입니다. 신뢰하지 마세요.\n"
                    let text3 = "현재 진행중이 화재만 표시합니다.\n"
                    let text4 = "주소지가 제공되지 않은 경우 지도에 보이지 않습니다."
                    Text(text1 + text2 + text3 + text4)
                        .font(.system(size: 14, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.appText)
                        .presentationCompactAdaptation(.popover)
                        .presentationBackground(Color.appTheme)
                        .padding(10)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
    }
    
    private func dismissButton() -> some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.appText)
                })
                .frame(width: 40, height: 40)
                Spacer()
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

extension MapView {
    struct MapViewAlert: ViewModifier {
        @Environment(\.dismiss) private var dismiss
           
        let type: MapFeature.Alert
        let model: AlertModel
        let feature: MapFeature
        
        func body(content: Content) -> some View {
            switch type {
            case .error:
                content.defaultAlert(model) {
                    dismiss()
                }
            case .pushSetting:
                content.confirmAlert(model) {
                        feature.send(.alertAction(.dismiss))
                    } onConfirm: {
                        feature.send(.alertAction(.pushSetting))
                    }
            default:
                content
            }
        }
    }
}
