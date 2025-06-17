//
//  RecordUploadMenuModifier.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 17/06/25.
//

import SwiftUI
import PhotosUI

struct RecordUploadMenuModifier: ViewModifier {
  @State var selectedUploadOption: RecordUploadItemType?
  @Binding var images: [UIImage]
  @Binding var selectedPDFData: Data?
  let hasUserGalleryPermission: Bool

  func body(content: Content) -> some View {
    Menu {
      ForEach(RecordUploadSheetData.formRecordUploadSheetItems(hasUserGalleryPermission: hasUserGalleryPermission).uploadItemType, id: \.self) { itemType in
        Button {
          selectedUploadOption = itemType
        } label: {
          Label {
            Text(itemType.title)
          } icon: {
            if let icon = itemType.icon {
              Image(uiImage: icon)
                .resizable()
                .frame(width: 16, height: 16)
            }
          }
        }
      }
    } label: {
      content
    }
    .menuStyle(.button)
    .sheet(item: $selectedUploadOption) { option in
      switch option {
      case .camera:
        CameraView(capturedImages: $images)
      case .gallery:
        GalleryView(selectedImages: $images)
      case .pdf:
        DocumentPickerView(selectedPDFData: $selectedPDFData)
      }
    }
  }
}

extension View {
  func recordUploadMenuModifier(
    images: Binding<[UIImage]>,
    selectedPDFData: Binding<Data?>,
    hasUserGalleryPermission: Bool
  ) -> some View {
    self.modifier(RecordUploadMenuModifier(
      images: images,
      selectedPDFData: selectedPDFData,
      hasUserGalleryPermission: hasUserGalleryPermission
    ))
  }
}
