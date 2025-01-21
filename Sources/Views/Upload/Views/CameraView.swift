//
//  CameraView.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 20/01/25.
//

import SwiftUI
import VisionKit

struct CameraView: UIViewControllerRepresentable {
  @Binding var capturedImages: [UIImage]
  @Environment(\.presentationMode) var presentationMode
  
  func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
    let cameraVC = VNDocumentCameraViewController()
    cameraVC.delegate = context.coordinator
    return cameraVC
  }
  
  func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    let parent: CameraView
    
    init(_ parent: CameraView) {
      self.parent = parent
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
      var images: [UIImage] = []
      for i in 0..<scan.pageCount {
        let image = scan.imageOfPage(at: i)
        images.append(image)
      }
      parent.capturedImages = images
      parent.presentationMode.wrappedValue.dismiss()
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
      parent.presentationMode.wrappedValue.dismiss()
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
      debugPrint("Camera error: \(error.localizedDescription)")
      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}
