//
//  RecordsCommunicator.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 28/01/25.
//

import EkaMedicalRecordsCore
import UIKit

public final class RecordsCommunicator: ObservableObject {
  @Published var pickerSelectedImages: [UIImage] = []
  
  public init() {}
  
  func setPickerSelectedImagesFromRecords(selectedRecords: [RecordItemViewData]) {
    selectedRecords.forEach { record in
      if let image = FileHelper.getImageFromLocalPath(fileURL: record.documentImage) {
        pickerSelectedImages.append(image)
      }
    }
  }
}
