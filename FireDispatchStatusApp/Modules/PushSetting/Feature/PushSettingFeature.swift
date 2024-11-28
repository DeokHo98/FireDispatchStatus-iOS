//
//  PushSettingFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/22/24.
//

import ComposableArchitecture
import Foundation
import UIKit
import FirebaseMessaging

@Reducer
struct PushSettingFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var alertState: AlertState<Alert>?
        var list: [FireStationModel] = []
        var originList: [FireStationModel] = []
        var pushOnStation: String = ""
        var searchState = SearchFeature.State()
        var filterState = FilterFeature.State(viewType: .pushSettingView)
    }
    
    enum Action {
        case loadFireStationList
        case searchAction(SearchFeature.Action)
        case alertAction(PresentationAction<Alert>)
        case didSelectedRow(String)
        case pushOnOffSuccess(String)
        case pushOnOffFailed(String)
        case filterAction(FilterFeature.Action)
        case bellButtonTap
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.searchState, action: \.searchAction) {
            SearchFeature()
        }
        Scope(state: \.filterState, action: \.filterAction) {
            FilterFeature()
        }
        Reduce { state, action in
            switch action {
            case .loadFireStationList:
                guard let url = Bundle.main.url(
                    forResource: "FireStationList",
                    withExtension: "json"
                ) else { return .none }
                let data = try? Data(contentsOf: url)
                let list = try? JSONDecoder().decode([String].self, from: data ?? Data())
                let fireStationList = list ?? []
                let originList = fireStationList.map { FireStationModel(name: $0) }
                state.originList = originList
                state.pushOnStation = pushOnStation()
                state.list = self.filteredList(state: state)
                return .none
            case .searchAction(.delegate(.textFeildEditing)):
                state.pushOnStation = pushOnStation()
                state.list = self.filteredList(state: state)
                return .none
            case .didSelectedRow(let centerName):
                guard let swiftDataManager = try? SwiftDataManager<PushData>(),
                      let pushData = try? swiftDataManager.get() else { return .none }
                guard pushData.isOn else {
                    state.alertState = self.getPushSettingAlert()
                    return .none
                }
                if state.pushOnStation == centerName {
                    state.alertState = self.getPushOffAlert(centerName: centerName)
                } else {
                    state.alertState = self.getPushOnAlert(centerName: centerName)
                }
                return .none
            case .alertAction(.presented(.pushSettingAlert)):
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    return .none
                }
                UIApplication.shared.open(url)
                return .none
            case .alertAction(.presented(.pushOffAlert)):
                guard let swiftDataManager = try? SwiftDataManager<PushData>(),
                      let pushData = try? swiftDataManager.get() else { return .none }
                guard let deviceID = DeviceIDManager().getToKeyChain() else { return .none }
                let service = NetworkService()
                let request = FCMTokenDeleteRequest(deviceId: deviceID)
                return .run { send in
                    do {
                        let result: FCMTokenResponse = try await service.request(request)
                        guard result.success else {
                            await send(.pushOnOffFailed(result.error ?? "실패했습니다."))
                            return
                        }
                        let newPushData = pushData.copy(centerName: "")
                        try swiftDataManager.save(item: newPushData)
                        await send(.pushOnOffSuccess(""))
                    } catch {
                        await send(.pushOnOffFailed(error.localizedDescription))
                    }
        
                }
            case .alertAction(.presented(.pushOnAlert(let centerName))):
                guard let swiftDataManager = try? SwiftDataManager<PushData>(),
                      let pushData = try? swiftDataManager.get() else { return .none }
                guard let deviceID = DeviceIDManager().getToKeyChain() else { return .none }
                guard let fcmToken = Messaging.messaging().fcmToken else { return .none }
                let service = NetworkService()
                let request = FCMRegisterRequest(
                    token: fcmToken,
                    centerName: centerName,
                    deviceID: deviceID
                )
                return .run { send in
                    do {
                        let result: FCMTokenResponse = try await service.request(request)
                        guard result.success else {
                            await send(.pushOnOffFailed(result.error ?? "실패했습니다."))
                            return
                        }
                        let newPushData = pushData.copy(centerName: centerName)
                        try swiftDataManager.save(item: newPushData)
                        await send(.pushOnOffSuccess(centerName))
                    } catch {
                        await send(.pushOnOffFailed(error.localizedDescription))
                    }
        
                }
            case .pushOnOffSuccess(let pushOnStation):
                state.pushOnStation = pushOnStation
                return .none
            case .pushOnOffFailed(let errorMessage):
                state.alertState = .onlyOkButtonAlert(title: errorMessage)
                state.list = state.originList
                return .none
            case .bellButtonTap:
                state.alertState = getPushOffAlert(centerName: state.pushOnStation)
                return .none
            case .alertAction:
                state.alertState = nil
                return .none
            case .filterAction(.delegate(.selectedOption)):
                state.pushOnStation = pushOnStation()
                state.list = self.filteredList(state: state)
                return .none
            case .searchAction:
                return .none
            case .filterAction:
                return .none
            }
        }
    }
}

// MARK: - Alert

extension PushSettingFeature {
    enum Alert: Equatable {
        case pushSettingAlert
        case pushOffAlert
        case pushOnAlert(String)
    }
    
    func getPushSettingAlert() -> AlertState<Alert> {
        return AlertState {
            TextState("알림설정이 비활성화 되어있습니다.\n설정 > 알림을 확인해주세요.")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("확인")
            }
            ButtonState(role: .none, action: .pushSettingAlert) {
                TextState("설정으로 가기")
            }
        }
    }
    
    func getPushOffAlert(centerName: String) -> AlertState<Alert> {
        return AlertState {
            TextState("현재 등록된 \"\(centerName)\" 알림을 끄시겠습니까?")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("취소")
            }
            ButtonState(role: .none, action: .pushOffAlert) {
                TextState("확인")
            }
        }
    }
    
    func getPushOnAlert(centerName: String) -> AlertState<Alert> {
        return AlertState {
            TextState("\"\(centerName)\" 알림을 켜시겠습니까?")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("취소")
            }
            ButtonState(role: .none, action: .pushOnAlert(centerName)) {
                TextState("확인")
            }
        }
    }
}

// MARK: - Helper Function

extension PushSettingFeature {
    func filteredList(state: State) -> [FireStationModel] {
        var list = state.originList
        if !state.searchState.text.isEmpty {
            list = list.filter { $0.name.contains(state.searchState.text) }
        }
        if state.filterState.regionSelectedOption != "전체" {
            list = list.filter { $0.name.prefix(2) == state.filterState.regionSelectedOption }
        }
        return list
    }
    
    func pushOnStation() -> String {
        guard let swiftDataManager = try? SwiftDataManager<PushData>(),
              let pushData = try? swiftDataManager.get() else { return "" }
        guard pushData.isOn else { return "" }
        return pushData.centerName
    }
}
