// Created on 14/05/24. Copyright © 2022 Orbi Health Private Limited. All rights reserved.

import SwiftUI
import PhotosUI

struct RecordUploadSheetView: View {
  
  // MARK: - Properties
  
  @State var recordUploadSheetData = RecordUploadSheetData.formRecordUploadSheetItems(hasUserGalleryPermission: false)
  let hasUserGalleryPermission: Bool
  @State private var currentlySelectedImageNumber: Int = 0
  @State private var shouldShowSelectionLimitMessage: Bool = false
  @State private var galleryPhotos: [RecordUploadImageData] = []
  @Binding var isUploadBottomSheetPresented: Bool
  @State var selectedUploadOption: RecordUploadItemType?
  @Binding private var images: [UIImage]
  @Binding private var selectedPDFData: Data?
  @State var photoAccessStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
  @State private var showSettingsAlert = false
    
  init(
    images: Binding<[UIImage]>,
    selectedPDFData: Binding<Data?>,
    hasUserGalleryPermission: Bool,
    isUploadBottomSheetPresented: Binding<Bool>
  ) {
    _images = images
    _selectedPDFData = selectedPDFData
    self.hasUserGalleryPermission = hasUserGalleryPermission
    _isUploadBottomSheetPresented = isUploadBottomSheetPresented
    _recordUploadSheetData = State(initialValue: RecordUploadSheetData.formRecordUploadSheetItems(hasUserGalleryPermission: hasUserGalleryPermission))
  }
  
  // MARK: - Body
  
  var body: some View {
    Menu {
      ForEach(RecordUploadSheetData.formRecordUploadSheetItems(hasUserGalleryPermission: true).uploadItemType, id: \.self) { itemType in
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
      Label("Add record", systemImage: "plus")
        .foregroundColor(.white)
        .padding()
        .background(Color.blue)
        .cornerRadius(8)
    }
    .menuStyle(.button)
    .padding(.horizontal, EkaSpacing.spacingM)
    .edgesIgnoringSafeArea(.all)
    .animation(.easeInOut, value: currentlySelectedImageNumber)
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

// MARK: - Subviews

extension RecordUploadSheetView {
  // Row View
  private func UploadSheetRowView(itemType: RecordUploadItemType) -> some View {
    return HStack {
      // Icon
      if let image = itemType.icon {
        Image(uiImage: image)
          .resizable()
          .renderingMode(.template)
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundStyle(Color(.primary500))
      }
      // Title
      Text(itemType.title)
        .textStyle(ekaFont: .calloutRegular, color: .black)
      
      Spacer()
      // Chevron
      Image(systemName: "chevron.right")
        .resizable()
        .renderingMode(.template)
        .scaledToFit()
        .frame(width: 14, height: 14)
        .foregroundColor(Color(.neutrals400))
    }
  }
}

extension RecordUploadSheetView {
  private func fetchUserPhotos() {
    GalleryHelper.fetchUserPhotos { galleryPhotos in
      if let galleryPhotos {
        self.galleryPhotos = galleryPhotos
      }
    }
  }
  
  /// Used to set images on tap of upload button
  private func setImagesOnUploadButtonTap() {
    let selectedImages: [UIImage] = galleryPhotos.compactMap { data in
      guard data.selectedImageNumber != nil else {
        return nil
      }
      return data.image
    }
    images = selectedImages
  }
}

// MARK: - Helper Functions

extension RecordUploadSheetView {
  private func requestGalleryPermissionAndShowPickerIfAuthorized() {
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
      // Permission granted
      selectedUploadOption = .gallery
    case .denied, .restricted:
      // Permission denied or restricted
      showSettingsAlert = true
    case .notDetermined:
      // Ask for permission
      PHPhotoLibrary.requestAuthorization { newStatus in
        DispatchQueue.main.async {
          self.photoAccessStatus = newStatus
          if newStatus == .authorized {
            selectedUploadOption = .gallery
          } else {
            self.showSettingsAlert = true
          }
        }
      }
    default:
      break
    }
  }
}

#Preview {
  RecordUploadSheetView(
    images: .constant([]),
    selectedPDFData: .constant(nil),
    hasUserGalleryPermission: true,
    isUploadBottomSheetPresented: .constant(true)
  )
}
