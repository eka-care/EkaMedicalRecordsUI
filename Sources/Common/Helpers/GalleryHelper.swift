//
//  GalleryHelper.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 20/01/25.
//

import Foundation
import PhotosUI

final class GalleryHelper {
  static func convertImagesToData(images: [UIImage], compressionQuality: CGFloat = 1.0) -> [Data] {
    return images.compactMap { image in
      image.jpegData(compressionQuality: compressionQuality)
    }
  }
  
  static func fetchUserPhotos(completion: @escaping ([RecordUploadImageData]?) -> Void) {
    // Request authorization to access photo library
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    if status == .authorized || status == .limited {
      // Fetch photos from user's gallery
      let fetchOptions = PHFetchOptions()
      fetchOptions.fetchLimit = 30
      fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] // Sort by creation date in descending order
      let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
      var fetchedPhotos: [RecordUploadImageData] = []
      
      result.enumerateObjects { (asset, _, _) in
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        manager.requestImageDataAndOrientation(
          for: asset,
          options: requestOptions) { imageData, _, _, _ in
            guard let imageData else { return }
            if let uiImage = UIImage(data: imageData) {
              fetchedPhotos.append(RecordUploadImageData(image: uiImage, imageData: imageData))
            }
          }
      }
      
      DispatchQueue.main.async {
        completion(fetchedPhotos)
      }
    } else {
      completion(nil)
      debugPrint("Access to photo library denied.")
    }
  }
}
