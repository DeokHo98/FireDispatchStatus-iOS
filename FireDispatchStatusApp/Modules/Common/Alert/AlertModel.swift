//
//  AlertModel.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 12/2/24.
//

import Foundation
import SwiftUI

struct AlertModel {
    var isShow = false
    var title = ""
    var confirmText = "확인"
    var cancelText = "취소"
}

extension View {
    func defaultAlert(
        _ alertModel: AlertModel,
        onDismiss: (() -> Void)?,
        action: (() -> Void)? = nil
    ) -> some View {
        self.alert(
            alertModel.title,
            isPresented: Binding(
                get: { alertModel.isShow },
                set: { (_, _) in
                    onDismiss?()
                }
            )) {
                Button(alertModel.confirmText, role: .cancel) {
                    action?()
                }
            }
    }
    
    func confirmAlert(
        _ alertModel: AlertModel,
        onDismiss: (() -> Void)? = nil,
        onConfirm: (() -> Void)? = nil
    ) -> some View {
        self.alert(
            alertModel.title,
            isPresented: Binding(
                get: { alertModel.isShow },
                set: { (_, _) in
                    onDismiss?()
                }
            )
        ) {
            Button(alertModel.confirmText, role: .destructive) {
                onConfirm?()
            }
            Button(alertModel.cancelText, role: .cancel) {
                onDismiss?()
            }
        }
    }
}
