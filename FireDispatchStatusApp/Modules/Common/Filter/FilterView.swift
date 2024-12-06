//
//  FilterView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/27/24.
//

import SwiftUI

@MainActor
struct FilterView: View {
    
    private let feature: FilterFeature
    
    init(feature: FilterFeature) {
        self.feature = feature
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                if feature.state.filters.count == 2 && !feature.state.pushFilterButtonText.isEmpty {
                    Button(action: {
                        feature.send(.pushFilterButtonTap)
                    }, label: {
                        Text(feature.state.pushFilterButtonText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(
                                feature.state.isSelectedPushFilterButton ? .appBackground : .appText
                            )
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        feature.state.isSelectedPushFilterButton
                                        ? Color.appText
                                        : Color.appBackground
                                    )
                            )
                    })
                }
                ForEach(feature.state.filters, id: \.self) { filter in
                    Menu {
                        ForEach(filter.items, id: \.self) { item in
                            Button(item) {
                                feature.send(.selectedFilter(
                                    filterType: filter,
                                    selectedItem: item)
                                )
                            }
                        }
                    } label: {
                        HStack {
                            Text(feature.state.labelText(filter: filter))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(feature.state.defaultColor(filter: filter))
                                .padding(.leading, 10)
                                .padding(.trailing, 0)
                                .padding(.vertical, 5)
                            Image(systemName: "chevron.down")
                                .resizable()
                                .frame(width: 10, height: 5)
                                .padding(.trailing, 10)
                                .foregroundStyle(feature.state.defaultColor(filter: filter))
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(feature.state.backgroundColor(filter: filter))
                    )
                }
            }
        }
    }

}
