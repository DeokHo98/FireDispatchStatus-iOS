//
//  FireDispatchStatusAppApp.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import SwiftUI
import Firebase
import UserNotifications

// MARK: - App

@main
struct FireDispatchStatusAppApp: App {
    
    @State private var selectedTab = 0
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                FireDispatchView()
                    .tag(0)
                    .tabItem {
                        Label("화재 출동 현황", systemImage: "flame.fill")
                    }
                
                PushSettingView()
                    .tag(1)
                    .tabItem {
                        Label("알림 설정", systemImage: "bell.fill")
                    }
                
                MoreView()
                    .tag(2)
                    .tabItem {
                        Label("더보기", systemImage: "ellipsis")
                    }
            }
            .tint(.appText)
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .selectedTabView
                )
            ) { notification in
                guard let tabIndex = notification.object as? Int else { return }
                selectedTab = tabIndex
            }
        }
    }
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    private let networkService = NetworkService()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        DeviceIDManager().saveToKeyChain()
        initPushData()
        
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        setNotificationObserver()
        return true
    }
}

// MARK: - AppDelegate - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
        ) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            handleFCMPushNotification(userInfo)
        }
    }
}

// MARK: - AppDelegate - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        updateFCMTokenIfChanged(fcmToken: fcmToken)
    }
}

// MARK: - AppDelegate - Helper Function

extension AppDelegate {
    private func initPushData() {
        guard let swiftDataManager = try? SwiftDataManager<PushData>() else { return }
        guard (try? swiftDataManager.get()) == nil else {
            return
        }
        try? swiftDataManager.save(item: .init(fcmToken: "", centerName: "", isOn: false))
    }
    
    private func updateFCMTokenIfChanged(fcmToken: String) {
        guard let swiftDataManager = try? SwiftDataManager<PushData>(),
              let pushData = try? swiftDataManager.get() else { return }
        guard fcmToken != pushData.fcmToken else { return }
        guard pushData.isOn, pushData.centerName != "" else { return }
        Task {
            do {
                guard let deviceID = DeviceIDManager().getToKeyChain() else { return }
                let request = FCMRegisterRequest(
                    token: fcmToken,
                    centerName: pushData.centerName,
                    deviceID: deviceID
                )
                let _: FCMTokenResponse = try await self.networkService.request(request)
                try swiftDataManager.save(item: pushData.copy(fcmToken: fcmToken))
                print("DEBUG: FCM토큰이 새로 저장되었습니다. \(fcmToken)")
            } catch {
                print("DEBUG: FCM토큰 저장에 실패했습니다. \(error)")
            }
        }
    }
    
    private func setNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func didBecomeActive() {
        UNUserNotificationCenter.current().setBadgeCount(0)
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            guard let swiftDataManager = try? SwiftDataManager<PushData>(),
                  let pushData = try? swiftDataManager.get() else { return }
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                guard !pushData.isOn else { return }
                pushOn(pushData: pushData, swiftDataManager: swiftDataManager)
            case .denied, .notDetermined:
                guard pushData.isOn else { return }
                self.pushOff(pushData: pushData, swiftDataManager: swiftDataManager)
            @unknown default:
                break
            }
        }
    }
    
    private func pushOn(pushData: PushData, swiftDataManager: SwiftDataManager<PushData>) {
        try? swiftDataManager.save(item: pushData.copy(isOn: true))
        print("DEBUG: 푸시 알림을 활성화 했습니다.")
    }
    
    private func pushOff(pushData: PushData, swiftDataManager: SwiftDataManager<PushData>) {
        Task {
            do {
                guard let deviceID = DeviceIDManager().getToKeyChain() else { return }
                let request = FCMTokenDeleteRequest(deviceId: deviceID)
                let _: FCMTokenResponse = try await self.networkService.request(request)
                try swiftDataManager.save(item: pushData.copy(centerName: "", isOn: false))
                print("DEBUG: 푸시 알림을 비활성화 했습니다.")
            } catch {
                print("DEBUG: 푸시 알림을 비활성화에 실패 했습니다. \(error)")
            }
        }
    }
    
    private func handleFCMPushNotification(_ userInfo: [String: Any]) {
        let sidoOvrNum = userInfo["sidoOvrNum"] ?? ""
        NotificationCenter.default.post(name: .selectedTabView, object: 0)
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            NotificationCenter.default.post(name: .fireDispatchPushTap, object: sidoOvrNum)
        }
    }
}
 
