//
//  FilterFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/27/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct FilterFeature {
    @ObservableState
    struct State: Equatable {
        var viewType: ViewType
        var menuItems: [String] = []
        let regionItems = [
            "전체", "서울", "광주", "부산", "대구", "인천", "울산", "세종", "경기",
            "강원", "충북", "충남", "전북", "전남", "경북", "경남", "제주"
        ]
        let stateItems = [
            "전체", "화재접수", "화재출동",
            "현장도착", "귀소", "잔불감시"
        ]
        var regionSelectedOption = "전체"
        var stateSelectedOption = "전체"
        
        var regionImageColor: Color {
            regionSelectedOption == "전체" ? .appText : .appBackground
        }
        var stateImageColor: Color {
            stateSelectedOption == "전체" ? .appText : .appBackground
        }
        
        var regionTextColor: Color {
            regionSelectedOption == "전체" ? .appText : .appBackground
        }
        var stateTextColor: Color {
            stateSelectedOption == "전체" ? .appText : .appBackground
        }
        
        var regionBackgroundColor: Color {
            regionSelectedOption == "전체" ? .appBackground : .appText
        }
        var stateBackgroundColor: Color {
            stateSelectedOption == "전체" ? .appBackground : .appText
        }
        
        init(viewType: ViewType) {
            self.viewType = viewType
            if viewType == .fireDispatchView {
                self.menuItems = ["지역", "상태"]
            } else {
                self.menuItems = ["지역"]
            }
        }
    }
    
    enum Action {
        case regionOptionSelected(String)
        case stateOptionSelected(String)
        case delegate(Delegate)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .regionOptionSelected(let option):
                state.regionSelectedOption = option
                return .run { send in
                    await send(.delegate(.selectedOption))
                }
            case .stateOptionSelected(let option):
                state.stateSelectedOption = option
                return .run { send in
                    await send(.delegate(.selectedOption))
                }
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Delegate

extension FilterFeature {
    enum Delegate {
        case selectedOption
    }
}

// MARK: - FilterType

extension FilterFeature {
    enum ViewType {
        case fireDispatchView
        case pushSettingView
    }
}
