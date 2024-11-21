//
//  FireDispatchFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import ComposableArchitecture

@Reducer
struct FireDispatchFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var alertState: AlertState<Alert>?
        var originList: [FireDispatchModel] = []
        var list: [FireDispatchModel] = []
        var searchState = FireDispatchSearchFeature.State()
    }
    
    enum Action {
        case fetchFireDispatchList
        case fetchFireDispatchListResponse(Result<[FireDispatchModel], Error>)
        case alertAction(PresentationAction<Alert>)
        case searchAction(FireDispatchSearchFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchFireDispatchList:
                return .run { send in
                    do {
                        let service = NetworkService(baseURL: .main)
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
                state.list = self.filteredList(list: list, searchText: state.searchState.text)
                return .none
            case .fetchFireDispatchListResponse(.failure(let error)):
                let title = "에러가 발생했습니다. 다시 시도해주세요.\n"
                let errorMessage = error.localizedDescription
                state.alertState = .onlyOkButtonAlert(title: title + errorMessage)
                return .none
            case .alertAction:
                return .none
            case .searchAction(.delegate(.textFeildEditing)):
                state.list = self.filteredList(
                    list: state.originList, searchText: state.searchState.text
                )
                return .none
            case .searchAction:
                return .none
            }
        }
        Scope(state: \.searchState, action: \.searchAction) {
            FireDispatchSearchFeature()
        }
    }
}

// MARK: - Alert

extension FireDispatchFeature {
    enum Alert: String {
        case error
    }
}

// MARK: - Helper Function

extension FireDispatchFeature {
    func filteredList(list: [FireDispatchModel], searchText: String) -> [FireDispatchModel] {
        guard !searchText.isEmpty else { return list }
        return list.filter { $0.centerName.contains(searchText) }
    }
}
