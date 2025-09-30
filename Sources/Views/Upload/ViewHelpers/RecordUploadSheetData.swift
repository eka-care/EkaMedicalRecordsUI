// Created on 14/05/24. Copyright © 2022 Orbi Health Private Limited. All rights reserved.

import UIKit

// MARK: - Records Images Struct

struct RecordUploadImageData: Identifiable {
  let id = UUID()
  var selectedImageNumber: Int? /// The selection number of the image once its selected
  let image: UIImage
  let imageData: Data
  
  init(
    selectedImageNumber: Int? = nil,
    image: UIImage,
    imageData: Data = Data()
  ) {
    self.selectedImageNumber = selectedImageNumber
    self.image = image
    self.imageData = imageData
  }
}

// MARK: - Record Upload Row Items Type

enum RecordUploadItemType: CaseIterable, Identifiable {
  case camera
  case gallery
  case pdf
  
  /// Use the enum case itself as the identifier
  var id: Self { self }
  
  var title: String {
    switch self {
    case .camera:
      return "Take photo"
    case .gallery:
      return "Choose photo"
    case .pdf:
      return "Upload record"
    }
  }
  
  var icon: UIImage? {
    switch self {
    case .camera:
      UIImage(systemName: "camera")
    case .gallery:
      UIImage(systemName: "photo")
    case .pdf:
      UIImage(systemName: "square.and.arrow.up")
    }
  }
}

struct RecordUploadSheetData {
  var uploadItemType: [RecordUploadItemType]
}

extension RecordUploadSheetData {
  static func formRecordUploadSheetItems(hasUserGalleryPermission: Bool) -> RecordUploadSheetData {
    RecordUploadSheetData(uploadItemType: [.camera, .gallery, .pdf])
  }
}
