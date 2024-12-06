//
//  Feature.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 12/4/24.
//

import Foundation
import MapKit
import CoreLocation
import _MapKit_SwiftUI
import Combine

@MainActor
final class MapFeature {
    
    private var locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init(state: State) {
        self.state = state
        self.sinkLocationManager()
    }
    
    private(set) var state: State
    
    @Observable
    final class State: Identifiable {
        let fireDispatchModel: FireDispatchModel
        var cameraPosition: MapCameraPosition?
        var fireLocation: CLLocationCoordinate2D?
        var userLocation: CLLocationCoordinate2D?
        var alertState: (type: Alert, model: AlertModel) = (.dismiss, AlertModel())
        var moveToLocationButtonState: MoveToLocationButtonType = .userLocation
        
        init(fireDispatchModel: FireDispatchModel) {
            self.fireDispatchModel = fireDispatchModel
        }
    }
    
    enum Action {
        case onAppear
        case moveToLocationButtonTap
        case alertAction(Alert)
    }
    
    func send(_ action: Action) {
        switch action {
        case .onAppear:
            Task {
                guard let coordinate = try? await self.convertAddressToCoordinates(
                    address: state.fireDispatchModel.address
                ) else {
                    state.alertState = (
                        .error,
                        AlertModel(isShow: true, title: "주소정보가 정확하지 않습니다.")
                    )
                    return
                }
                state.fireLocation = coordinate
                moveToFireLocation()
            }
        case .moveToLocationButtonTap:
            if state.moveToLocationButtonState == .userLocation {
                guard locationManager.checkLocationAuthorization() else {
                    showLocationSettingAlert()
                    return
                }
                locationManager.requestLocation()
            } else {
                moveToFireLocation()
                state.moveToLocationButtonState = .userLocation
            }
        case .alertAction(.pushSetting):
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        case .alertAction(.dismiss):
            state.alertState = (.dismiss, AlertModel())
        case .alertAction:
            break
        }
    }
}

// MARK: - Alert

extension MapFeature {
    enum Alert {
        case error
        case pushSetting
        case dismiss
    }
}

// MARK: - Helper Function

extension MapFeature {
    
    private func moveToFireLocation() {
        guard let location = state.fireLocation else { return }
        state.cameraPosition = MapCameraPosition.region(
            MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            )
        )
    }
    
    private func sinkLocationManager() {
        locationManager.locationPublisher
            .sink { [weak self] location in
                self?.state.cameraPosition = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    )
                )
                self?.state.userLocation = location.coordinate
                self?.state.moveToLocationButtonState = .fireLocation
            }
            .store(in: &cancellables)
    }
    
    private func showLocationSettingAlert() {
        state.alertState = (
            .pushSetting,
            AlertModel(
                isShow: true,
                title: "위치설정이 비활성화 되어있습니다.\n설정 > 위치를 확인해주세요.",
                confirmText: "설정으로 가기"
            )
        )
    }
    
    private func convertAddressToCoordinates(
        address: String
    ) async throws -> CLLocationCoordinate2D {
        let geocoder = CLGeocoder()
        guard let placemark = try await geocoder.geocodeAddressString(address).first,
              let location = placemark.location else {
            throw NSError(domain: "GeocodingError", code: -1, userInfo: nil)
        }
        return location.coordinate
    }
}

extension MapFeature {
    enum MoveToLocationButtonType: String {
        case userLocation = "내 위치"
        case fireLocation = "화재 위치"
    }
}
