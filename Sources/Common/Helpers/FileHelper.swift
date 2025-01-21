//
//  FileHelper.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 18/01/25.
//

import Foundation

final class FileHelper {
  /// Used to get the URL of the document directory
  static func getDocumentDirectoryURL() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  
  static func downloadLocalData(from fileURL: URL, completion: @escaping (Data?, Error?) -> Void) {
    do {
      /// Load the local PDF file into Data
      let data = try Data(contentsOf: fileURL)
      /// Call the completion handler with the PDF data and no error
      completion(data, nil)
    } catch {
      /// Handle any errors that occur during loading
      completion(nil, error)
    }
  }
}
