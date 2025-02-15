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
  let record: Record?
  var isSelected: Bool
  
  init(
    record: Record?,
    isSelected: Bool = false
  ) {
    self.record = record
    self.isSelected = isSelected
  }
}

extension RecordItemViewData {
  static func formRecordItemPreviewData() -> RecordItemViewData {
    RecordItemViewData(
      record: nil
    )
  }
  
  static func formRecordItemViewData(from model: Record) -> RecordItemViewData {
    RecordItemViewData(record: model)
  }
}
