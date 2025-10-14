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

public struct RecordItemViewData {
  public let record: Record?
  public var isSelected: Bool
  
  public init(
    record: Record?,
    isSelected: Bool = false
  ) {
    self.record = record
    self.isSelected = isSelected
  }
}

extension RecordItemViewData {
  public static func formRecordItemPreviewData() -> RecordItemViewData {
    RecordItemViewData(
      record: nil
    )
  }
  
  public static func formRecordItemViewData(from model: Record, isSelected: Bool = false) -> RecordItemViewData {
    RecordItemViewData(record: model, isSelected: isSelected)
  }
}
