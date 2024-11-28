//
//  FireDispatchFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct FireDispatchFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var alertState: AlertState<Alert>?
        var originList: [FireDispatchModel] = []
        var stateEndCount = 0
        var stateInProgressCount = 0
        var deadNum = 0
        var injuredNum = 0
        var list: [FireDispatchModel] = []
        var searchState = SearchFeature.State()
        var headerState: FireDispatchHeaderFeature.State?
        var filterState = FilterFeature.State(viewType: .fireDispatchView)
    }
    
    enum Action {
        case fetchFireDispatchList
        case fetchFireDispatchListResponse(Result<[FireDispatchModel], Error>)
        case alertAction(PresentationAction<Alert>)
        case searchAction(SearchFeature.Action)
        case filterAction(FilterFeature.Action)
        case refreshButtonTap
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
            case .fetchFireDispatchList:
                return .run { send in
                    do {
                        let service = NetworkService()
                        let list: [FireDispatchModel] = try await service.request(
                            FireDispatchListRequest()
                        )
                        await send(.fetchFireDispatchListResponse(.success(list)))
                    } catch {
                        await send(.fetchFireDispatchListResponse(.failure(error)))
                    }
                }
            case .fetchFireDispatchListResponse(.success(let list)):
                state.originList = list
                state.list = self.filteredList(state: &state)
                return .none
            case .fetchFireDispatchListResponse(.failure(let error)):
                let title = "에러가 발생했습니다. 다시 시도해주세요.\n"
                let errorMessage = error.localizedDescription
                state.alertState = .onlyOkButtonAlert(title: title + errorMessage)
                return .none
            case .alertAction(.dismiss):
                state.alertState = nil
                return .none
            case .searchAction(.delegate(.textFeildEditing)):
                state.list = self.filteredList(state: &state)
                return .none
            case .refreshButtonTap:
                return .run { send in
                    await send(.fetchFireDispatchList)
                }
            case .filterAction(.delegate(.selectedOption)):
                state.list = self.filteredList(state: &state)
                return .none
            case .alertAction:
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

extension FireDispatchFeature {
    enum Alert: Equatable {
        case defaultMessage
    }
}

// MARK: - Helper Function

extension FireDispatchFeature {
    private func filteredList(state: inout State) -> [FireDispatchModel] {
        var list = state.originList
        var stateEndListCount = 0
        var deadNum = 0
        var injuredNum = 0
        list.forEach {
            if $0.state.contains("귀소") || $0.state.contains("오인") || $0.state.contains("잔불") {
                stateEndListCount += 1
            }
            deadNum += $0.deadNum
            injuredNum += $0.injuryNum
        }
        state.headerState = .init(
            totalCount: list.count,
            inProgressCount: list.count - stateEndListCount,
            endCount: stateEndListCount,
            deadCount: deadNum,
            injuredCount: injuredNum
        )
        if !state.searchState.text.isEmpty {
            list = list.filter { $0.centerName.contains(state.searchState.text) }
        }
        if state.filterState.regionSelectedOption != "전체" {
            list = list.filter { $0.centerName.prefix(2) == state.filterState.regionSelectedOption }
        }
        if state.filterState.stateSelectedOption != "전체" {
            list = list.filter { $0.state.contains(state.filterState.stateSelectedOption) }
        }
        return list
    }
}
