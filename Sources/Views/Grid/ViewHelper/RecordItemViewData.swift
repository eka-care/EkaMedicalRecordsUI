//
//  RecordItemViewData.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import Foundation
import UIKit

struct RecordItemViewData {
  var isSmart: Bool
  var uploadedDate: String?
  let documentImage: UIImage?
  
  init(
    isSmart: Bool,
    uploadedDate: String? = nil,
    documentImage: UIImage? = nil
  ) {
    self.isSmart = isSmart
    self.uploadedDate = uploadedDate
    self.documentImage = documentImage
  }
}

extension RecordItemViewData {
  static func formRecordItemPreviewData() -> RecordItemViewData {
    RecordItemViewData(
      isSmart: true,
      uploadedDate: "24 July 2024 ",
      documentImage: UIImage(resource: .recordSample)
    )
  }
}
