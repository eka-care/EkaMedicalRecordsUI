//
//  RecordItemViewData.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import Foundation
import UIKit
import EkaMedicalRecordsCore

struct RecordItemViewData {
  var isSmart: Bool
  var uploadedDate: String?
  let documentImage: URL?
  
  init(
    isSmart: Bool,
    uploadedDate: String? = nil,
    documentImage: URL? = nil
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
      documentImage: URL(string: "")
    )
  }
  
  static func formRecordItemViewData(from model: Record) -> RecordItemViewData {
    RecordItemViewData(
      isSmart: model.isSmart,
      uploadedDate: model.uploadDate?.formatted(as: "MMM d, yyyy"),
      documentImage: FileHelper.getDocumentDirectoryURL().appendingPathComponent(model.thumbnail ?? "")
    )
  }
}
