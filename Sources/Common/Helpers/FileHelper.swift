//
//  FileHelper.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 18/01/25.
//

import Foundation
import UIKit
import EkaMedicalRecordsCore

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
  
  static func getImageFromLocalPath(fileURL: URL?) -> UIImage? {
    guard let fileURL else { return nil }
    /// Check if the file exists at the given path
    if FileManager.default.fileExists(atPath: fileURL.path) {
      /// Try to load the image from the URL
      if let image = UIImage(contentsOfFile: fileURL.path) {
        return image
      } else {
        print("Error: Unable to create UIImage from file.")
        return nil
      }
    } else {
      print("Error: File does not exist at the specified path.")
      return nil
    }
  }
  
  // TODO: - Improve this method to not do extension check
  static func createDocumentTypes(from paths: [String]) -> [DocumentMimeType] {
    var documentTypes: [DocumentMimeType] = []
    
    for path in paths {
      let fullPath = FileHelper.getDocumentDirectoryURL().appendingPathComponent(path).path
      let url = URL(fileURLWithPath: fullPath)
      
      // Check if the file is a PDF or image based on its file extension
      if path.lowercased().hasSuffix(FileType.pdf.fileExtension) {
        if let pdfData = try? Data(contentsOf: url) {
          documentTypes.append(.pdf(data: pdfData))
        }
      } else if path.lowercased().hasSuffix(".jpg") || path.lowercased().hasSuffix(".jpeg") || path.lowercased().hasSuffix(".png") {
        if let image = UIImage(contentsOfFile: fullPath) {
          documentTypes.append(.image(uiImage: image))
        }
      }
    }
    return documentTypes
  }
}
