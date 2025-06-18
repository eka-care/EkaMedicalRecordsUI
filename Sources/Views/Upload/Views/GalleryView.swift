//
//  GalleryView.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 20/01/25.
//

import SwiftUI
import PhotosUI

struct GalleryView: UIViewControllerRepresentable {
  @Binding var selectedImages: [UIImage]
  var selectionLimit: Int = 6 // Adjust the selection limit
  
  func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration()
    configuration.selectionLimit = selectionLimit
    configuration.filter = .images // Restrict to images only
    
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    // No need to update the picker
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, PHPickerViewControllerDelegate {
    var parent: GalleryView
    
    init(_ parent: GalleryView) {
      self.parent = parent
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      picker.dismiss(animated: true)
      
      var images = [UIImage]()
      let dispatchGroup = DispatchGroup()  /// Track async operations
      
      for result in results {
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
          dispatchGroup.enter()  /// Enter group before async operation
          
          result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
            defer { dispatchGroup.leave() }  /// Leave group after completion
            
            if let image = object as? UIImage {
              images.append(image)
            } else if let error = error {
              print("Error loading image: \(error.localizedDescription)")
            }
          }
        }
      }
      
      dispatchGroup.notify(queue: .main) { [parent] in
        parent.selectedImages = images  /// Update only after all images are loaded
      }
    }
  }
}
