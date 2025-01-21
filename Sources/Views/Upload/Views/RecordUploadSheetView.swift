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
  @State private var images: [UIImage] = []
  @State private var selectedPDFData: Data? = nil
  @State var photoAccessStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
  @State private var showSettingsAlert = false
    
  init(
    hasUserGalleryPermission: Bool,
    isUploadBottomSheetPresented: Binding<Bool>
  ) {
    self.hasUserGalleryPermission = hasUserGalleryPermission
    _isUploadBottomSheetPresented = isUploadBottomSheetPresented
    _recordUploadSheetData = State(initialValue: RecordUploadSheetData.formRecordUploadSheetItems(hasUserGalleryPermission: hasUserGalleryPermission))
  }
  
  // MARK: - Body
  
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack(alignment: .leading, spacing: 0) {
        Text("Recent images")
          .textStyle(ekaFont: .calloutBold, color: UIColor(resource: .neutrals600))
          .padding([.top,.leading], EkaSpacing.spacingM)
        
        /// Gallery View
        VStack(spacing: 0) {
          if !galleryPhotos.isEmpty {
            UserGalleryView()
          } else if !hasUserGalleryPermission {
            UserGalleryGivePermissionView()
          } else {
            ProgressView().frame(maxWidth: .infinity, alignment: .center)
          }
        }
        .padding(.vertical, EkaSpacing.spacingS)
        
        Spacer().frame(height: EkaSpacing.spacingM)
        
        Text(NSLocalizedString("Other options", comment: ""))
          .textStyle(ekaFont: .calloutRegular, color: UIColor(resource: .neutrals600))
          .padding(.leading, EkaSpacing.spacingM)
        
        Spacer().frame(height: EkaSpacing.spacingM)
        
        List {
          ForEach(recordUploadSheetData.uploadItemType, id: \.self) { itemType in
            UploadSheetRowView(itemType: itemType)
              .contentShape(Rectangle())
              .onTapGesture {
                //              isUploadBottomSheetPresented = false
                selectedUploadOption = itemType
                //              delegate?.onTapRecordOption(option: itemType, isViewGalleryTap: false)
              }
          }
        }
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        
        Spacer()
      }
      .edgesIgnoringSafeArea(.all)
      
      if currentlySelectedImageNumber > 0 {
        ButtonView(
          title: "Upload (\(currentlySelectedImageNumber))",
          size: .medium
        ) {
//          delegate?.onTapAttachGalleryItems(imagesData: galleryPhotos)
        }
        //        ButtonView(
        //          buttonSize: .medium,
        //          buttonText: "Upload (\(currentlySelectedImageNumber))"
        //        ) {
        //          delegate?.onTapAttachGalleryItems(imagesData: galleryPhotos)
        //        }
        .padding(.horizontal, EkaSpacing.spacingM)
        .padding(.bottom, EkaSpacing.spacingL)
        .transition(.move(edge: .bottom))
      }
    }
    .edgesIgnoringSafeArea(.all)
    .animation(.easeInOut, value: currentlySelectedImageNumber)
    .onAppear {
      fetchUserPhotos()
    }
    .alert("Photo Library Access Required", isPresented: $showSettingsAlert) {
      Button("Cancel", role: .cancel) {}
      Button("Settings") {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
      }
    } message: {
      Text("Please enable access to your photo library in Settings to use this feature.")
    }
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
    //    .onChange(of: viewModel.photoAccessStatus) { _ in
    //      fetchUserPhotos()
    //    }
  }
}

// MARK: - Subviews

extension RecordUploadSheetView {
  
  // Photos View
  
  private func UserGalleryView() -> some View {
    VStack(alignment: .leading) {
      
      RecordsUserGalleryView(
        currentlySelectedImageNumber: $currentlySelectedImageNumber,
        galleryPhotos: $galleryPhotos,
        shouldShowSelectionLimitMessage: $shouldShowSelectionLimitMessage) {
          /// On tap camera view
          //          delegate?.onTapRecordOption(option: .camera, isViewGalleryTap: false)
        }
      
      if shouldShowSelectionLimitMessage {
        Text(NSLocalizedString("Maximum 6 photos can be uploaded at once!", comment: ""))
          .textStyle(ekaFont: .calloutRegular, color: UIColor(resource: .red600))
          .padding(.leading, EkaSpacing.spacingM)
      }
    }
  }
  
  private func UserGalleryGivePermissionView() -> some View {
    HStack {
      VStack(alignment: .leading) {
        HStack {
          Text(NSLocalizedString("Give permission", comment: ""))
            .textStyle(ekaFont: .calloutRegular, color: UIColor(resource: .neutrals800))
          Image(systemName: "exclamationmark.circle.fill")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 12, height: 12)
            .foregroundColor(Color(.orange400))
        }
        Text(NSLocalizedString("To add existing photos, allow access to the photo library from your iOS setting", comment: ""))
          .textStyle(ekaFont: .calloutRegular, color: UIColor(resource: .neutrals800))
      }
      Spacer()
      Image(systemName: "chevron.right")
        .resizable()
        .scaledToFit()
        .frame(width: 10, height: 10)
        .foregroundColor(Color(.blue))
    }
//    .frame(height: 70)
    .padding([.horizontal, .vertical], EkaSpacing.spacingM)
    .background(Color(.sunYellow100))
    .cornerRadius(16)
    .contentShape(Rectangle())
    .onTapGesture {
      requestGalleryPermissionAndShowPickerIfAuthorized()
      //      delegate?.onTapRecordOption(option: .gallery, isViewGalleryTap: false)
    }
    .padding(.horizontal, EkaSpacing.spacingM)
  }
  
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
  
  private func onTapRecordOption(option: RecordUploadItemType) {
    //    switch option {
    //    case .camera:
    //      <#code#>
    //    case .gallery:
    //      <#code#>
    //    case .pdf:
    //      <#code#>
    //    }
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
    hasUserGalleryPermission: true,
    isUploadBottomSheetPresented: .constant(true)
  )
}
