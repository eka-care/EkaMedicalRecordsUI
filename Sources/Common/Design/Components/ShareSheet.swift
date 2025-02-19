//
//  ShareSheet.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 19/02/25.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
  var activityItems: [Any]
  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
  }
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
