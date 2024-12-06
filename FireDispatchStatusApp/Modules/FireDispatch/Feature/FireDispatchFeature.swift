//
//  FireDispatchFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import Foundation
import Combine

@MainActor
final class FireDispatchFeature {

    private let networkService: NetworkServiceDependency
    
    init(
        networkService: NetworkServiceDependency = NetworkService()
    ) {
        self.networkService = networkService
        sinkSearchDelegate()
        sinkFilterDelegate()
        sinkObserver()
    }
    
    private(set) var state = State()
    private var cancellables = Set<AnyCancellable>()
    private(set) var searchFeature = SearchFeature()
    private(set) var filterFeature = FilterFeature(filters: [.region, .state])
  
    @Observable
    final class State {
        var originList: [FireDispatchModel] = []
        var alertState = AlertModel()
        var list: [FireDispatchModel] = []
        var searchText = ""
        var pushOnCenter = ""
        var stateFilterItem = "전체"
        var regionFilterItem = "전체"
        var headerState: FireDispatchHeaderState?
        var scrollToRow: String = ""
        var mapState: MapFeature.State?
    }
    
    enum Action {
        case fetchList
        case dismissAlert
        case pushNotificationTap(String)
        case didSelectedRow(FireDispatchModel)
        case dismissMapFeature
    }
    
    func send(_ action: Action) {
        switch action {
        case .fetchList:
            Task {
                do {
                    let list: [FireDispatchModel] = try await networkService.request(
                        FireDispatchListRequest()
                    )
                    fetchListSuccess(list: list)
                } catch {
                    fetchListFail(error: error)
                }
            }
        case .dismissAlert:
            state.alertState = AlertModel()
        case .pushNotificationTap(let sidoOvrNum):
            state.scrollToRow = sidoOvrNum
        case .didSelectedRow(let model):
            state.mapState = MapFeature.State(fireDispatchModel: model)
        case .dismissMapFeature:
            state.mapState = nil
        }
    }
}

// MARK: - Delegate

extension FireDispatchFeature {
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
            switch filterType {
            case .region:
                state.regionFilterItem = selectedItem
            case .state:
                state.stateFilterItem = selectedItem
            }
        case .selectedPushFilterButton(let pushOnCenter):
            state.pushOnCenter = pushOnCenter
        }
        setFilteredList()
    }
}

// MARK: - Notification Center

extension FireDispatchFeature {
    private func sinkObserver() {
        NotificationCenter.default.publisher(for: .fireDispatchPushTap)
            .sink { [weak self] notification in
                guard let sidoOvrNum = notification.object as? String else { return }
                self?.send(.pushNotificationTap(sidoOvrNum))
            }
            .store(in: &cancellables)
    }
}

// MARK: - Helper Function

extension FireDispatchFeature {
    private func fetchListSuccess(list: [FireDispatchModel]) {
        state.originList = list
        setHeaderState()
        setFilteredList()
    }
    
    private func fetchListFail(error: Error) {
        let title = "에러가 발생했습니다. 다시 시도해주세요.\n"
        let errorMeessage = error.localizedDescription
        state.alertState = AlertModel(isShow: true, title: title + errorMeessage)
    }
    
    private func setHeaderState() {
        var stateEndListCount = 0
        var deadNum = 0
        var injuredNum = 0
        let originList = state.originList
        originList.forEach {
            if $0.state.contains("귀소") || $0.state.contains("오인") || $0.state.contains("잔불") {
                stateEndListCount += 1
            }
            deadNum += $0.deadNum
            injuredNum += $0.injuryNum
        }
        state.headerState = .init(
            totalCount: originList.count,
            inProgressCount: originList.count - stateEndListCount,
            endCount: stateEndListCount,
            deadCount: deadNum,
            injuredCount: injuredNum
        )
    }
    
    private func setFilteredList() {
        var list = state.originList
        if !state.searchText.isEmpty {
            list = list.filter { $0.centerName.contains(state.searchText) }
        }
        if state.regionFilterItem != "전체" {
            list = list.filter { $0.centerName.prefix(2) == state.regionFilterItem }
        }
        if state.stateFilterItem != "전체" {
            list = list.filter { $0.state.contains(state.stateFilterItem) }
        }
        if state.pushOnCenter != "" {
            list = list.filter { $0.centerName == state.pushOnCenter }
        }
        state.list = list
    }
}
