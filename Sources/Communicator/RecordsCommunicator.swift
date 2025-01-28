//
//  RecordsCommunicator.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 28/01/25.
//

import EkaMedicalRecordsCore
import UIKit

@Observable public final class RecordsCommunicator {
  public var pickerSelectedImages: [UIImage] = []
  
  public static var shared = RecordsCommunicator()
  
  public init() {}
  
  func setPickerSelectedImagesFromRecords(selectedRecords: [RecordItemViewData]) {
    selectedRecords.forEach { record in
      if let image = FileHelper.getImageFromLocalPath(fileURL: record.documentImage) {
        pickerSelectedImages.append(image)
      }
    }
  }
}
