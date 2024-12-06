//
//  Array+Ex.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 12/5/24.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
