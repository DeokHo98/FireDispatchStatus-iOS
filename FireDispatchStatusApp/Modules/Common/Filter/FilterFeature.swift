//
//  FilterFeature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/27/24.
//

import SwiftUI
import Combine

@MainActor
struct FilterFeature {
    
    private var swiftDataManager: SwiftDataManager<PushData>?
    
    init(
        filters: [FilterType],
        swiftDataManager: SwiftDataManager<PushData>? = nil
    ) {
        if let swiftDataManager {
            self.swiftDataManager = swiftDataManager
        } else {
            self.swiftDataManager = try? SwiftDataManager<PushData>()
        }
        if let pushData = try? self.swiftDataManager?.get(), !pushData.centerName.isEmpty {
            self.state = State(filters: filters, pushFilterButtonText: pushData.centerName)
        } else {
            self.state = State(filters: filters)
        }
    }
    
    private(set) var state: State
    private(set) var delegatePublisher = PassthroughSubject<Delegate, Never>()
    
    @Observable
    final class State {
        var filters: [FilterType]
        var selectedItems: [FilterType: String]
        var pushFilterButtonText: String
        var isSelectedPushFilterButton = false
        
        func labelText(filter: FilterType) -> String {
            let selectedItem = selectedItems[filter] ?? "전체"
            return "\(filter.rawValue): \(selectedItem)"
        }
        
        func defaultColor(filter: FilterType) -> Color {
            let selected = selectedItems[filter] ?? "전체"
            return selected == "전체" ? .appText : .appBackground
        }
        
        func backgroundColor(filter: FilterType) -> Color {
            let selected = selectedItems[filter] ?? "전체"
            return selected == "전체" ? .appBackground : .appText
        }
        
        init(filters: [FilterType], pushFilterButtonText: String = "") {
            self.filters = filters
            self.selectedItems = Dictionary(
                uniqueKeysWithValues: filters.map { ($0, "전체") }
            )
            self.pushFilterButtonText = pushFilterButtonText
        }
    }
    
    enum Action {
        case selectedFilter(filterType: FilterType, selectedItem: String)
        case pushFilterButtonTap
    }
    
    func send(_ action: Action) {
        switch action {
        case .selectedFilter(let filterType, let selectedItem):
            state.selectedItems[filterType] = selectedItem
            delegatePublisher.send(
                .selectedOption(filterType: filterType, selectedItem: selectedItem)
            )
        case .pushFilterButtonTap:
            guard let pushData = try? swiftDataManager?.get(),
                  pushData.centerName != "" else {
                return
            }
            state.isSelectedPushFilterButton.toggle()
            delegatePublisher.send(
                .selectedPushFilterButton(
                    state.isSelectedPushFilterButton ? pushData.centerName : ""
                )
            )
        }
    }
}

// MARK: - Delegate

extension FilterFeature {
    enum Delegate {
        case selectedOption(filterType: FilterType, selectedItem: String)
        case selectedPushFilterButton(String)
    }
}
