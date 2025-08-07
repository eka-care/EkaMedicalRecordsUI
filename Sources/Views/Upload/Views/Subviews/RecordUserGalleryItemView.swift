// Created on 15/05/24. Copyright © 2022 Orbi Health Private Limited. All rights reserved.

import SwiftUI

struct RecordUserGalleryItemView: View {
  // MARK: - Properties
  @State var imageData: RecordUploadImageData
  @Binding var currentlySelectedImageNumber: Int
  @Binding var galleryPhotos: [RecordUploadImageData]
  @Binding var shouldShowSelectionLimitMessage: Bool
  let selectionLimit: Int
  let itemMaxHeight: CGFloat = 105
  // MARK: - Init
  init(
    imageData: RecordUploadImageData,
    currentlySelectedImageNumber: Binding<Int>,
    galleryPhotos: Binding<[RecordUploadImageData]>,
    selectionLimit: Int,
    shouldShowSelectionLimitMessage: Binding<Bool>
  ) {
    _imageData = State(initialValue: imageData)
    _currentlySelectedImageNumber = currentlySelectedImageNumber
    _galleryPhotos = galleryPhotos
    self.selectionLimit = selectionLimit
    _shouldShowSelectionLimitMessage = shouldShowSelectionLimitMessage
  }
  // MARK: - Body
  var body: some View {
    ZStack(alignment: .top) {
      if imageData.selectedImageNumber != nil { /// If image is in selected state
        Image(uiImage: imageData.image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 100, height: 100)
          .cornerRadius(16)
          .addBorderWithCornerRadiusModifier(
            cornerRadius: 16,
            borderColor: UIColor(resource: .primary500),
            strokeWidth: 2
          )
          .padding(2)
      } else { /// If image is in unselected state
        Image(uiImage: imageData.image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 100, height: 100)
          .cornerRadius(16)
          .padding(2)
          .addBorderWithCornerRadiusModifier(
            cornerRadius: 16,
            borderColor: UIColor(resource: .grey200),
            strokeWidth: 2
          )
      }
      selectionRadioView()
        .padding([.top], EkaSpacing.spacingXs)
    }
    .frame(height: itemMaxHeight)
    .animation(.easeInOut, value: imageData.selectedImageNumber)
    .contentShape(Rectangle())
    .onTapGesture {
      onTapItemView()
    }
  }
}

// MARK: - Subviews

extension RecordUserGalleryItemView {
  private func selectionRadioView() -> some View {
    return VStack {
      HStack {
        Spacer()
        /// Circle with number
        ZStack {
          Circle()
            .foregroundColor(imageData.selectedImageNumber != nil ? Color(.primary500) : Color.black)
            .frame(width: 18, height: 18)
          if let selectedImageNumber = imageData.selectedImageNumber {
            Text("\(selectedImageNumber)")
              .textStyle(ekaFont: .calloutRegular, color: .white)
          }
        }
      }
      Spacer()
    }
    .padding([.trailing, .top], EkaSpacing.spacingS)
  }
}

extension RecordUserGalleryItemView {
  private func onTapItemView() {
    if let selectedImageNumber = imageData.selectedImageNumber {
      unselectImage(selectedImageNumber: selectedImageNumber)
    } else {
      selectImage()
    }
  }
  // Unselection
  private func unselectImage(selectedImageNumber: Int) {
    imageData.selectedImageNumber = nil /// If image was already selected unselect it
    /// Recuce the count of all the items which have a number greater than this number
    resetHigherNumberedImagesCount(selectedImageNumber: selectedImageNumber)
    /// Also reduce the currently selected index by 1
    currentlySelectedImageNumber -= 1
  }
  private func resetHigherNumberedImagesCount(selectedImageNumber: Int) {
    for (index, traversedImage) in galleryPhotos.enumerated() {
      /// Update the data source with nil if the image is unselected
      if traversedImage.id == imageData.id {
        galleryPhotos[index] = RecordUploadImageData(
          selectedImageNumber: nil,
          image: traversedImage.image
        )
      }
      /// Search for images having selected image number higher than this items selected image number
      if let traversedImageNumber = traversedImage.selectedImageNumber,
         traversedImageNumber > selectedImageNumber {
        /// Reduce the selected image number of these items by 1 and update data source
        galleryPhotos[index] = RecordUploadImageData(
          selectedImageNumber: traversedImageNumber - 1,
          image: traversedImage.image
        )
      }
    }
  }
  // Selection
  private func selectImage() {
    guard currentlySelectedImageNumber < selectionLimit else {
      shouldShowSelectionLimitMessage = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) { /// Dismiss the message after 2 sec
        shouldShowSelectionLimitMessage = false
      }
      return
    } /// Don't select an image if selection limit is reached
    currentlySelectedImageNumber += 1 // Increase the image count number by 1 when you select an image
    imageData.selectedImageNumber = currentlySelectedImageNumber // Select the image with number if image is unselected
    // Update the original data source with currently selected image data
    for (index, galleryPhoto) in galleryPhotos.enumerated() where imageData.id == galleryPhoto.id {
      galleryPhotos[index] = imageData
      break
    }
  }
}

#Preview {
  RecordUserGalleryItemView(
    imageData: RecordUploadImageData(image: UIImage(systemName: "camera")!),
    currentlySelectedImageNumber: .constant(3),
    galleryPhotos: .constant([]),
    selectionLimit: 6, 
    shouldShowSelectionLimitMessage: .constant(false)
  )
}
