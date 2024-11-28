//
//  TutorialView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/27/24.
//

import SwiftUI

struct TutorialView: View {
    @AppStorage("isTutorialShown") private var isTutorialShown: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                Text("주의사항")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Text("꼭 읽어주세요.")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.appText)
                    .padding(.top, -12)
            }
            .padding(.bottom)
            VStack(alignment: .leading, spacing: 16) {
                Text("1. 소방청 공식앱이 아닙니다.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.appText)
                Text("2. 신고가 들어왔다고 무조건 실제화재가 아닙니다. 오인인 경우가 있습니다.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.appText)
                Text("3. 실제 화재신고 시간과 정확하게 일치하지 않습니다.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.appText)
                Text("4. 이 앱에서 제공하는 정보를 참고만 하시고 너무 신뢰하지 마세요.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.appText)
                Spacer()
                Button(action: {
                    isTutorialShown = true
                }, label: {
                    Text("닫기")
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appBackground)
                        .foregroundColor(Color.appText)
                        .cornerRadius(10)
                })
            }
        }
        .padding()
        .background(Color.appBackground)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}
