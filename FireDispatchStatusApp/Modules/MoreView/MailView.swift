//
//  MailView.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/28/24.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var subject: String
    var recipients: [String]
    var body: String?
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = context.coordinator
        mailVC.setSubject(subject)
        mailVC.setToRecipients(recipients)
        
        if let body = body {
            mailVC.setMessageBody(body, isHTML: false)
        }
        
        return mailVC
    }
    
    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: Context
    ) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            parent.isShowing = false
            controller.dismiss(animated: true)
        }
    }
}
