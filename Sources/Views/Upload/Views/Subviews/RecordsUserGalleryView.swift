// Created on 16/05/24. Copyright © 2022 Orbi Health Private Limited. All rights reserved.

import SwiftUI

struct RecordsUserGalleryView: View {
  
  // MARK: - Properties
  
  @Binding var currentlySelectedImageNumber: Int
  @Binding var galleryPhotos: [RecordUploadImageData]
  var selectionLimit: Int = 6
  var cameraUploadAction: (() -> Void)?
  @Binding var shouldShowSelectionLimitMessage: Bool
  
  // MARK: - Init
  
  init(
    currentlySelectedImageNumber: Binding<Int>,
    galleryPhotos: Binding<[RecordUploadImageData]>,
    selectionLimit: Int = 6,
    shouldShowSelectionLimitMessage: Binding<Bool>,
    cameraUploadAction: (() -> Void)? = nil
  ) {
    _currentlySelectedImageNumber = currentlySelectedImageNumber
    _galleryPhotos = galleryPhotos
    self.selectionLimit = selectionLimit
    _shouldShowSelectionLimitMessage = shouldShowSelectionLimitMessage
    self.cameraUploadAction = cameraUploadAction
  }
  
  // MARK: - Body
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: EkaSpacing.spacingS) {
        ForEach(galleryPhotos) { imageData in
          RecordUserGalleryItemView(
            imageData: imageData,
            currentlySelectedImageNumber: $currentlySelectedImageNumber,
            galleryPhotos: $galleryPhotos,
            selectionLimit: selectionLimit,
            shouldShowSelectionLimitMessage: $shouldShowSelectionLimitMessage
          )
        }
      }
      .padding(.leading, EkaSpacing.spacingM)
    }
  }
}

#Preview {
  RecordsUserGalleryView(
    currentlySelectedImageNumber: .constant(3),
    galleryPhotos: .constant([]),
    shouldShowSelectionLimitMessage: .constant(false)
  )
}
