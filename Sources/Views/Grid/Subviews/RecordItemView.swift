//
//  RecordItemView.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import SwiftUI
import SDWebImageSwiftUI
import EkaMedicalRecordsCore

struct RecordItemView: View {
  
  // MARK: - Properties
  
  enum RecordsDocumentThumbnailSize {
    static let height: CGFloat = 104
  }
  let itemWidth: CGFloat = 160
  let recordPresentationState: RecordPresentationState
  @State var itemData: RecordItemViewData
  @Binding var pickerSelectedRecords: [RecordItemViewData]
  
  init(
    itemData: RecordItemViewData,
    recordPresentationState: RecordPresentationState,
    pickerSelectedRecords: Binding<[RecordItemViewData]>
  ) {
    self._itemData = State(initialValue: itemData)
    self.recordPresentationState = recordPresentationState
    self._pickerSelectedRecords = pickerSelectedRecords
  }
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        /// Thumbnail Image
        if let documentImage = itemData.documentImage {
          ThumbnailImageView(thumbnailImageUrl: documentImage)
        } else {
          ThumbnailImageLoadingView()
        }
        
        if recordPresentationState == .picker {
          /// Selection Tick View at Top-Right
          VStack {
            HStack {
              Spacer() // Pushes to the right
              SelectionTickView().foregroundStyle(Color.yellow)
                .padding(.top, EkaSpacing.spacingM)
                .padding(.trailing, EkaSpacing.spacingM)
            }
            Spacer() // Pushes to the top
          }
        }
      }
      
      /// Bottom Meta Data View 
      BottomMetaDataView()
    }
    .frame(width: itemWidth)
    .background(Color.white)
    .cornerRadius(12)
    .contentShape(Rectangle())
    .onTapGesture {
      onTapRecord()
    }
  }
}

// MARK: - Subviews

extension RecordItemView {
  private func BottomMetaDataView() -> some View {
    HStack {
      if let uploadedDate = itemData.uploadedDate {
        Text("Uploaded \(uploadedDate)")
          .textStyle(ekaFont: .calloutRegular, color: UIColor(resource: .neutrals600))
      }
    }
    .frame(width: itemWidth, height: 30)
  }
  
  /// Thumbnail
  private func ThumbnailImageView(thumbnailImageUrl: URL) -> some View {
    ZStack {
      WebImage(url: thumbnailImageUrl)
        .resizable()
        .scaledToFill()
      Color.black.opacity(0.2).layoutPriority(-1)
    }
    .frame(width: itemWidth, height: RecordsDocumentThumbnailSize.height, alignment: .top)
    .cornerRadiusModifier(12, corners: .topLeft.union(.topRight))
  }
  
  private func ThumbnailImageLoadingView() -> some View {
    Color.black.opacity(0.6)
      .frame(width: itemWidth, height: RecordsDocumentThumbnailSize.height, alignment: .top)
      .cornerRadiusModifier(12, corners: .topLeft.union(.topRight))
  }
  
  private func SelectionTickView() -> some View {
    VStack {
      if itemData.isSelected { /// If the item is selected show checkmark
        Image(systemName: "checkmark.circle.fill")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 18, height: 18)
          .background(Color.white)
          .clipShape(Circle())
          .foregroundStyle(Color(.primary500))
          .overlay(
            Circle()
              .stroke(Color.white, lineWidth: 2) // Customize the border color and width
          )
      } else { /// If the item is not selected show empty circle
        Circle()
          .stroke(Color.white, lineWidth: 2) // Customize the border color and width
          .frame(width: 18, height: 18)
      }
    }
  }
}

extension RecordItemView {
  private func onTapRecord() {
    switch recordPresentationState {
    case .dashboard:
      print("Click on record in dashboard state")
    case .displayAll:
      print("Click on record in display all state")
    case .picker:
      updateItemDataOnPickerSelection()
    }
  }
  
  private func updateItemDataOnPickerSelection() {
    itemData.isSelected.toggle()
    /// If item is selected add it in picker selected records
    if itemData.isSelected {
      pickerSelectedRecords.append(itemData)
    } else {
      /// If item is unselected remove it from picker selected records
      if let itemIndex = pickerSelectedRecords.firstIndex(where: { $0.id == itemData.id}) {
        pickerSelectedRecords.remove(at: itemIndex)
      }
    }
  }
}

#Preview {
  RecordItemView(
    itemData: RecordItemViewData.formRecordItemPreviewData(),
    recordPresentationState: .displayAll,
    pickerSelectedRecords: .constant([])
  )
}
