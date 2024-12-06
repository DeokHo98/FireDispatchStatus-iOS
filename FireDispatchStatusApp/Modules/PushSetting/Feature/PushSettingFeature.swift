//
//  PushSettingFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/22/24.
//
import Foundation
import UIKit
import FirebaseMessaging
import Combine

@MainActor
final class PushSettingFeature {
    private let netWorkService: NetworkServiceDependency
    private var swiftDataManager: SwiftDataManager<PushData>?
    
    init(
        netWorkService: NetworkServiceDependency = NetworkService(),
        swiftDataManager: SwiftDataManager<PushData>? = nil
    ) {
        if let swiftDataManager {
            self.swiftDataManager = swiftDataManager
        } else {
            self.swiftDataManager = try? SwiftDataManager<PushData>()
        }
        self.netWorkService = netWorkService
        sinkSearchDelegate()
        sinkFilterDelegate()
    }
    
    private(set) var state = State()
    private var cancellables = Set<AnyCancellable>()
    private(set) var searchFeature = SearchFeature()
    private(set) var filterFeature = FilterFeature(filters: [.region])
    
    @Observable
    final class State {
        var alertState: (type: Alert, model: AlertModel) = (.dismiss, AlertModel())
        var list: [FireStationModel] = []
        var originList: [FireStationModel] = []
        var pushOnCenter: String = ""
        var searchText = ""
        var regionFilterItem = "전체"
    }
    
    enum Action {
        case fetchList
        case didSelectedRow(String)
        case alertAction(Alert)
    }
    
    func send(_ action: Action) {
        switch action {
        case .fetchList:
            fetchList()
        case .didSelectedRow(let centerName):
            didSelectedRow(centerName: centerName)
        case .alertAction(let type):
            switch type {
            case .pushSetting:
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            case .pushOn, .pushOff:
                Task {
                    do {
                        if case .pushOn(let centerName) = type {
                            try await pushOn(centerName: centerName)
                        } else {
                            try await pushOff()
                        }
                        setPushOnCenter()
                    } catch let error as CustomError {
                        state.alertState = (
                            .default,
                            AlertModel(isShow: true, title: error.localizedDescription)
                        )
                    }
                }
            case .dismiss:
                state.alertState = (.dismiss, AlertModel())
            default:
                break
            }
        }
    }
}

// MARK: - Delegate

extension PushSettingFeature {
    private func sinkSearchDelegate() {
        self.searchFeature.delegatePublisher
            .sink { [weak self] action in
                self?.searchDelegateSend(action)
            }
            .store(in: &cancellables)
    }
    
    private func searchDelegateSend(_ action: SearchFeature.Delegate) {
        switch action {
        case .textFiledEditing(let text):
            state.searchText = text
            setFilteredList()
        }
    }
    
    private func sinkFilterDelegate() {
        self.filterFeature.delegatePublisher
            .sink { [weak self] action in
                self?.filterDelegateSend(action)
            }
            .store(in: &cancellables)
    }
    
    private func filterDelegateSend(_ action: FilterFeature.Delegate) {
        switch action {
        case .selectedOption(let filterType, let selectedItem):
            if filterType == .region {
                state.regionFilterItem = selectedItem
            }
            setFilteredList()
        case .selectedPushFilterButton:
            break
        }
    }
}

// MARK: - Helper Function

extension PushSettingFeature {
    private func fetchList() {
        guard let url = Bundle.main.url(
            forResource: "FireStationList",
            withExtension: "json"
        ) else { return }
        let data = try? Data(contentsOf: url)
        let list = try? JSONDecoder().decode([String].self, from: data ?? Data())
        let fireStationList = list ?? []
        let originList = fireStationList.map { FireStationModel(name: $0) }
        state.originList = originList
        setPushOnCenter()
        setFilteredList()
    }
    
    private func didSelectedRow(centerName: String) {
        guard let pushData = try? swiftDataManager?.get() else { return }
        guard pushData.isOn else {
            state.alertState = (
                .pushSetting,
                AlertModel(
                    isShow: true,
                    title: "알림설정이 비활성화 되어있습니다.\n설정 > 알림을 확인해주세요.",
                    confirmText: "설정으로 가기"
                )
            )
            return
        }
        if state.pushOnCenter == centerName {
            state.alertState = (
                .pushOff,
                AlertModel(isShow: true, title: "현재 등록된 \"\(centerName)\" 알림을 끄시겠습니까?")
            )
        } else {
            state.alertState = (
                .pushOn(centerName),
                AlertModel(isShow: true, title: "\"\(centerName)\" 알림을 켜시겠습니까?")
            )
        }
    }
    
    private func pushOn(centerName: String) async throws {
        guard let pushData = getPushData() else { throw CustomError.notData }
        guard let deviceID = DeviceIDManager().getToKeyChain() else { throw CustomError.notData }
        guard let fcmToken = Messaging.messaging().fcmToken else { throw CustomError.notData }
        let service = NetworkService()
        let request = FCMRegisterRequest(
            token: fcmToken,
            centerName: centerName,
            deviceID: deviceID
        )
        let result: FCMTokenResponse = try await service.request(request)
        guard result.success else {
            throw CustomError.rquestFailed
        }
        let newPushData = pushData.copy(centerName: centerName)
        try swiftDataManager?.save(item: newPushData)
    }
    
    private func pushOff() async throws {
        guard let pushData = getPushData() else { throw CustomError.notData }
        guard let deviceID = DeviceIDManager().getToKeyChain() else { throw CustomError.notData }
        let request = FCMTokenDeleteRequest(deviceId: deviceID)
        let result: FCMTokenResponse = try await netWorkService.request(request)
        guard result.success else {
            throw CustomError.rquestFailed
        }
        let newPushData = pushData.copy(centerName: "")
        try swiftDataManager?.save(item: newPushData)
    }
    
    private func setFilteredList() {
        var list = state.originList
        if !state.searchText.isEmpty {
            list = list.filter { $0.name.contains(state.searchText) }
        }
        if state.regionFilterItem != "전체" {
            list = list.filter { $0.name.prefix(2) == state.regionFilterItem }
        }
        state.list = list
    }
    
    private func setPushOnCenter() {
        guard let pushData = getPushData() else { return }
        guard pushData.isOn else { return }
        state.pushOnCenter = pushData.centerName
    }
    
    private func getPushData() -> PushData? {
        return try? swiftDataManager?.get()
    }
}

// MARK: - Alert

extension PushSettingFeature {
    enum Alert {
        case pushSetting
        case pushOn(String)
        case pushOff
        case `default`
        case dismiss
    }
}

// MARK: - CustomError

extension PushSettingFeature {
    enum CustomError: Error {
        case notData
        case rquestFailed
        
        var errorDescription: String? {
            switch self {
            case .notData:
                return "정보가 존재하지 않습니다"
            case .rquestFailed:
                return "실패했습니다"
            }
        }
    }
}
