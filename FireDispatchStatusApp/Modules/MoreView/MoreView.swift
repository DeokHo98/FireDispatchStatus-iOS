//
//  MoreView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/28/24.
//

import SwiftUI
import MessageUI

struct MoreView: View {
    
    @State private var isShowingMailView = false
    @State private var isMailAvailable = MFMailComposeViewController.canSendMail()
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Color.appTheme
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10) {
                makeSection(title: "피드백", content: {
                    Button(action: {
                        if isMailAvailable {
                            isShowingMailView = true
                        } else {
                            showAlert = true
                        }
                    }, label: {
                        makeSectionButtonContent(
                            leadingImage: "pencil",
                            title: "피드백 보내기",
                            trailingImage: "chevron.right"
                        )
                    })
                })
                makeSection(title: "정보", content: {
                    HStack {
                        if let appVersion = Bundle.main.infoDictionary?[
                            "CFBundleShortVersionString"
                        ] as? String {
                            makeSectionButtonContent(
                                leadingImage: "tag",
                                title: "앱 버전",
                                trailingContent: Text(appVersion)
                            )
                        }
                    }
                })
                Spacer()
            }
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(
                isShowing: $isShowingMailView,
                subject: "[피드백 이메일]",
                recipients: ["aoao1216@naver.com"]
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("스마트폰에 메일이 설정되어 있지 않습니다."),
                message: Text("기기의 Mail 앱에서 이메일 계정을 추가할 수 있습니다."),
                dismissButton: .default(Text("확인"))
            )
        }
        .padding(.vertical)
    }
    
    private func makeSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(Color.appText.opacity(0.8))
                .font(.system(size: 13, weight: .medium))
                .padding(.leading, 25)
            
            content()
                .frame(minHeight: 20)
                .padding()
                .contentShape(Rectangle())
                .background(Color.appBackground)
                .cornerRadius(15)
                .padding(.horizontal)
        }
    }
    
    private func makeSectionButtonContent(
        leadingImage: String? = nil,
        title: String,
        trailingImage: String? = nil,
        trailingContent: Text? = nil
    ) -> some View {
        HStack {
            if let leadingImage = leadingImage {
                Image(systemName: leadingImage)
                    .foregroundStyle(Color.appText)
            }
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.appText)
            
            Spacer()
            
            if let trailingImage = trailingImage {
                Image(systemName: trailingImage)
                    .foregroundStyle(Color.appText)
            }
            
            if let trailingContent = trailingContent {
                trailingContent
                    .foregroundStyle(Color.appText)
            }
        }
    }
}
