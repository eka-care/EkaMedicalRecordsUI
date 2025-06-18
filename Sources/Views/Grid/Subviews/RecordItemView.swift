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
    static let height: CGFloat = 110
  }
  let itemWidth: CGFloat = 180
  let recordPresentationState: RecordPresentationState
  @State var itemData: RecordItemViewData
  @Binding var pickerSelectedRecords: [Record]
  var onTapEdit: (Record) -> Void
  var onTapDelete: (Record) -> Void
  
  // MARK: - Init
  
  init(
    itemData: RecordItemViewData,
    recordPresentationState: RecordPresentationState,
    pickerSelectedRecords: Binding<[Record]>,
    onTapEdit: @escaping (Record) -> Void,
    onTapDelete: @escaping (Record) -> Void
  ) {
    self._itemData = State(initialValue: itemData)
    self.recordPresentationState = recordPresentationState
    self._pickerSelectedRecords = pickerSelectedRecords
    self.onTapEdit = onTapEdit
    self.onTapDelete = onTapDelete
  }
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        /// Thumbnail Image
        if let documentImage = itemData.record?.thumbnail {
          ThumbnailImageView(thumbnailImageUrl: FileHelper.getDocumentDirectoryURL().appendingPathComponent(documentImage))
        } else {
          ThumbnailImageLoadingView()
        }
        
        /// Show smart tag
        if let record = itemData.record, record.isSmart {
          VStack {
            HStack {
              SmartReportView()
              Spacer()
            }
            Spacer()
          }
        }
        
        /// Show tick view only in picker state
        if recordPresentationState == .picker {
          /// Selection Tick View at Top-Right
          VStack {
            HStack {
              Spacer()
              SelectionTickView().foregroundStyle(Color.yellow)
                .padding(.top, EkaSpacing.spacingM)
                .padding(.trailing, EkaSpacing.spacingM)
            }
            Spacer()
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
    .contextMenu {
      Button {
        if let record = itemData.record {
          onTapEdit(record)
        }
      } label: {
        Text("Edit")
      }
      Button(role: .destructive) {
        if let record = itemData.record {
          onTapDelete(record)
        }
      } label: {
        Text("Delete")
      }
    }
    .simultaneousGesture(TapGesture().onEnded {
      onTapRecord()
    })
  }
}

// MARK: - Subviews

extension RecordItemView {
  private func BottomMetaDataView() -> some View {
    HStack {
      /// Icon Image
      VStack {
        if let record = itemData.record,
           let recordType = RecordDocumentType.from(intValue: Int(record.documentType)) {
          Image(uiImage: recordType.imageIcon)
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
            .foregroundStyle(Color(uiColor: recordType.imageIconForegroundColor))
            .padding(4)
            .background(Color(uiColor: recordType.imageIconBackgroundColor))
            .cornerRadius(2)
            .padding(.top, EkaSpacing.spacingXs)
          Spacer()
        }
      }
      
      VStack(alignment: .leading) {
        /// Document type
        if let record = itemData.record,
           let recordType = RecordDocumentType.from(intValue: Int(record.documentType)) {
          Text("\(recordType.filterName)")
            .textStyle(ekaFont: .calloutBold, color: .black)
        }
        /// Date
        if let record = itemData.record,
           let uploadedDate = record.uploadDate {
          Text("\(uploadedDate.formatted(as: "dd MMM ‘yy"))")
            .textStyle(ekaFont: .calloutRegular, color: UIColor(resource: .neutrals600))
        }
      }
      
      Spacer()
      
      MenuView()
    }
    .padding(.horizontal, EkaSpacing.spacingXs)
    .frame(width: itemWidth, height: 50)
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
  
  private func SmartReportView() -> some View {
    HStack(spacing: EkaSpacing.spacingXxs) {
      Image(systemName: "sparkle")
        .resizable()
        .scaledToFit()
        .frame(width: 12, height: 12)
        .foregroundStyle(Color(.primary500))
      
      Text("Smart")
        .textStyle(ekaFont: .labelBold, color: UIColor(resource: .primary500))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, EkaSpacing.spacingXxs)
    .background(.white)
    .cornerRadiusModifier(6, corners: [.bottomRight])
  }
  
  private func MenuView() -> some View {
    // Menu that opens on tap (instead of long press)
    Menu {
      Button {
        if let record = itemData.record {
          onTapEdit(record)
        }
      } label: {
        Text("Edit")
      }
      Button(role: .destructive) {
        if let record = itemData.record {
          onTapDelete(record)
        }
      } label: {
        Text("Delete")
      }
    } label: {
      Image(systemName: "ellipsis")
        .foregroundColor(.gray)
        .padding(.vertical, EkaSpacing.spacingS)
    }
  }
}

extension RecordItemView {
  private func onTapRecord() {
    switch recordPresentationState {
    case .dashboard:
      print("Click on record in dashboard state")
    case .displayAll:
      onTapDocument()
    case .picker:
      updateItemDataOnPickerSelection()
    }
  }
  
  
  /// On tap of document we open document viewer
  private func onTapDocument() {}
  
  /// Update item data on picker selection
  private func updateItemDataOnPickerSelection() {
    guard let record = itemData.record else { return }
    itemData.isSelected.toggle()
    /// If item is selected add it in picker selected records
    if itemData.isSelected {
        pickerSelectedRecords.append(record)
    } else {
      /// If item is unselected remove it from picker selected records
      if let itemIndex = pickerSelectedRecords.firstIndex(where: { $0.objectID == record.objectID}) {
        pickerSelectedRecords.remove(at: itemIndex)
      }
    }
  }
}

#Preview {
  RecordItemView(
    itemData: RecordItemViewData.formRecordItemPreviewData(),
    recordPresentationState: .displayAll,
    pickerSelectedRecords: .constant([]),
    onTapEdit: {_ in},
    onTapDelete: {_ in}
  )
}
