//
//  RecordItemViewData.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import Foundation
import UIKit
import EkaMedicalRecordsCore
import CoreData

struct RecordItemViewData {
  let id: NSManagedObjectID
  var isSmart: Bool
  var uploadedDate: String?
  let documentImage: URL?
  var isSelected: Bool
  let documentID: String?
  
  init(
    id: NSManagedObjectID,
    isSmart: Bool,
    uploadedDate: String? = nil,
    documentImage: URL? = nil,
    isSelected: Bool = false,
    documentID: String?
  ) {
    self.id = id
    self.isSmart = isSmart
    self.uploadedDate = uploadedDate
    self.documentImage = documentImage
    self.isSelected = isSelected
    self.documentID = documentID
  }
}

extension RecordItemViewData {
  static func formRecordItemPreviewData() -> RecordItemViewData {
    RecordItemViewData(
      id: NSManagedObjectID(),
      isSmart: true,
      uploadedDate: "24 July 2024 ",
      documentImage: URL(string: ""),
      documentID: ""
    )
  }
  
  static func formRecordItemViewData(from model: Record) -> RecordItemViewData {
    RecordItemViewData(
      id: model.objectID,
      isSmart: model.isSmart,
      uploadedDate: model.uploadDate?.formatted(as: "MMM d, yyyy"),
      documentImage: FileHelper.getDocumentDirectoryURL().appendingPathComponent(model.thumbnail ?? ""),
      documentID: model.documentID
    )
  }
}
