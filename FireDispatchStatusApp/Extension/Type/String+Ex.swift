//
//  String+Ex.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/20/24.
//

import Foundation
import CryptoKit

extension String {
    func decryptBaseURL() -> String? {
        guard let base64 = Data(base64Encoded: "7x2K9mZ4fP8QcX5jvNnLhR3wTyBsVqAu+kDgE6WpYbM="),
              let data = Data(base64Encoded: self),
              let sealedBox = try? AES.GCM.SealedBox(combined: data) else {
            return nil
        }
        do {
            let key = SymmetricKey(data: base64)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            return nil
        }
    }

}
