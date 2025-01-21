//
//  Untitled.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 20/01/25.
//

import SwiftUI

struct DocumentPickerView: UIViewControllerRepresentable {
  @Binding var selectedPDFData: Data?
  @Environment(\.presentationMode) var presentationMode
  
  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UIDocumentPickerDelegate {
    let parent: DocumentPickerView
    
    init(_ parent: DocumentPickerView) {
      self.parent = parent
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
      defer { url.stopAccessingSecurityScopedResource() }
      
      if let data = try? Data(contentsOf: url) {
        parent.selectedPDFData = data
      }
      parent.presentationMode.wrappedValue.dismiss()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}
