//
//  FireDispatchHeaderView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/27/24.
//

import SwiftUI

struct FireDispatchHeaderView: View {
    
    @State private var isExpanded = true
    let state: FireDispatchHeaderFeature.State
    
    var body: some View {
        VStack {
            Text("전국 화재 출동 현황")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.appText)
                .padding(.bottom, isExpanded ? 10 : 0)
            if isExpanded {
                HStack(spacing: 0) {
                    Spacer()
                    Text("전체 건수: ")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.appText)
                    Text("\(state.totalCount)건")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.red)
                    Spacer()
                }
                .padding(.bottom, 6)
        
                HStack(spacing: 0) {
                    Text("진행중: ")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.appText)
                    Text("\(state.inProgressCount)건")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.red)
                        .padding(.trailing, 10)
                    Text("종료: ")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.appText)
                    Text("\(state.endCount)건")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.red)
                }
                .padding(.bottom, 6)
                
                HStack(spacing: 0) {
                    Text("전체 사망자: ")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.appText)
                    Text("\(state.deadCount)명")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.red)
                        .padding(.trailing, 10)
                    Text("전체 부상자: ")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.appText)
                    Text("\(state.injuredCount)명")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.red)
                }
            }
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }, label: {
                    HStack {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundStyle(Color.appText)
                    }
                })
            }
        }
        .padding()
        .background(Color.appBackground)
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}
