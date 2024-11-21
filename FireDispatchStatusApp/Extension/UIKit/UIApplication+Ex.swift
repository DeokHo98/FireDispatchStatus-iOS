//
//  UIApplication+Ex.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/21/24.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
            return (connectedScenes.first as? UIWindowScene)?.keyWindow
    }
    
   static func hideKeyBoard() {
        shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
