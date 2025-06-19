// Created on 14/05/24. Copyright © 2022 Orbi Health Private Limited. All rights reserved.

import SwiftUI
import PhotosUI

struct RecordUploadMenuView: View {
  
  // MARK: - Properties
  
  @State var selectedUploadOption: RecordUploadItemType?
  @Binding var images: [UIImage]
  @Binding var selectedPDFData: Data?
  @State private var showDocumentPicker = false // Separate state for document picker
  let hasUserGalleryPermission: Bool
  
  // MARK: - Init
  
  init(
    images: Binding<[UIImage]>,
    selectedPDFData: Binding<Data?>,
    hasUserGalleryPermission: Bool
  ) {
    self._images = images
    self._selectedPDFData = selectedPDFData
    self.hasUserGalleryPermission = hasUserGalleryPermission
  }
  
  // MARK: - Body
  
  public var body: some View {
    Menu {
      ForEach(RecordUploadSheetData.formRecordUploadSheetItems(hasUserGalleryPermission: hasUserGalleryPermission).uploadItemType, id: \.self) { itemType in
        Button {
          if itemType == .pdf {
            showDocumentPicker = true // Use separate state for PDF
          } else {
            selectedUploadOption = itemType
          }
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
      ButtonView(
        title: "Add record",
        imageName: UIImage(systemName: "plus"),
        size: .large,
        imagePosition: .leading,
        isFullWidth: false
      ) {}
    }
    .shadow(color: .black.opacity(0.3), radius: 36, x: 0, y: 0)
    .padding([.trailing, .bottom], EkaSpacing.spacingM)
    .menuStyle(.button)
    .sheet(item: $selectedUploadOption) { option in
      switch option {
      case .camera:
        CameraView(capturedImages: $images)
      case .gallery:
        GalleryView(selectedImages: $images)
      case .pdf:
        EmptyView() // This case won't be reached now
      }
    }
    .fileImporter(
      isPresented: $showDocumentPicker,
      allowedContentTypes: [.pdf],
      allowsMultipleSelection: false
    ) { result in
      handleDocumentSelection(result: result)
    }
  }
  
  private func handleDocumentSelection(result: Result<[URL], Error>) {
    switch result {
    case .success(let urls):
      guard let url = urls.first else {
        print("No URL selected")
        return
      }
      
      print("Selected URL: \(url)")
      
      // Start accessing security scoped resource
      guard url.startAccessingSecurityScopedResource() else {
        print("❌ Failed to access security scoped resource")
        return
      }
      
      defer {
        url.stopAccessingSecurityScopedResource()
        print("🔓 Stopped accessing security scoped resource")
      }
      
      do {
        let data = try Data(contentsOf: url)
        print("✅ Successfully read PDF data: \(data.count) bytes")
        DispatchQueue.main.async {
          self.selectedPDFData = data
        }
      } catch {
        print("❌ Error reading PDF data: \(error)")
      }
      
    case .failure(let error):
      print("❌ Document picker error: \(error)")
    }
  }
}

#Preview {
  RecordUploadMenuView(
    images: .constant([]),
    selectedPDFData: .constant(nil),
    hasUserGalleryPermission: true
  )
}
