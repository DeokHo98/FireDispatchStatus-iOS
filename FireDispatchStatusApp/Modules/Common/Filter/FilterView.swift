//
//  FilterView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/27/24.
//

import SwiftUI
import ComposableArchitecture

struct FilterView: View {
    
    @Bindable var store: StoreOf<FilterFeature>
    
    var body: some View {
        HStack {
            ForEach(store.menuItems, id: \.self) { item in
                Menu {
                    ForEach(
                        item == "지역" ? store.regionItems : store.stateItems, id: \.self
                    ) { option in
                        Button(option) {
                            if item == "지역" {
                                store.send(.regionOptionSelected(option))
                            } else {
                                store.send(.stateOptionSelected(option))
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(
                            item == "지역" ?
                            ("\(item): \(store.regionSelectedOption)") :
                                ("\(item): \(store.stateSelectedOption)")
                        )
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(
                            item == "지역" ?
                            store.regionTextColor :
                                store.stateTextColor
                        )
                        .padding(.leading, 10)
                        .padding(.trailing, 0)
                        .padding(.vertical, 5)
                        Image(systemName: "chevron.down")
                            .resizable()
                            .frame(width: 10, height: 5)
                            .padding(.trailing, 10)
                            .foregroundStyle(
                                item == "지역" ?
                                store.regionImageColor :
                                    store.stateImageColor
                            )
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            item == "지역" ?
                            store.regionBackgroundColor :
                                store.stateBackgroundColor
                        )
                )
            }
        }
    }
}
