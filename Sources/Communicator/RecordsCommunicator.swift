//
//  RecordsCommunicator.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 28/01/25.
//

import Observation
import EkaMedicalRecordsCore
import UIKit

public final class RecordsCommunicator: Observable {
  public var pickerSelectedImages: [UIImage] = []
  
  public static let shared = RecordsCommunicator()
  
  func setPickerSelectedImagesFromRecords(selectedRecords: [RecordItemViewData]) {
    selectedRecords.forEach { record in
      if let image = FileHelper.getImageFromLocalPath(fileURL: record.documentImage) {
        pickerSelectedImages.append(image)
      }
    }
  }
}
