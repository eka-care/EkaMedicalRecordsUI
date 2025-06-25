//
//  RecordItemView.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import SwiftUI
import SDWebImageSwiftUI
import EkaMedicalRecordsCore
import Combine

typealias Record = EkaMedicalRecordsCore.Record

enum RecordsDocumentSize {
  static let thumbnailHeight: CGFloat = 110
  static let itemWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 180 : 170
  static let itemHorizontalSpacing: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? EkaSpacing.spacingS : EkaSpacing.spacingXxxs
}

struct RecordItemView: View {
  
  // MARK: - Properties
  
  let recordPresentationState: RecordPresentationState
  @State var itemData: RecordItemViewData
  @Binding var pickerSelectedRecords: [Record]
  @Binding var selectedFilterOption: RecordSortOptions?
  var onTapEdit: (Record) -> Void
  var onTapDelete: (Record) -> Void
  var onTapRetry: (Record) -> Void
  @State private var isNetworkAvailable = true
  @State var cancellable: AnyCancellable?
  
  // MARK: - Init
  
  init(
    itemData: RecordItemViewData,
    recordPresentationState: RecordPresentationState,
    pickerSelectedRecords: Binding<[Record]>,
    selectedFilterOption: Binding<RecordSortOptions?>,
    onTapEdit: @escaping (Record) -> Void,
    onTapDelete: @escaping (Record) -> Void,
    onTapRetry: @escaping (Record) -> Void
  ) {
    self._itemData = State(initialValue: itemData)
    self.recordPresentationState = recordPresentationState
    self._pickerSelectedRecords = pickerSelectedRecords
    self._selectedFilterOption = selectedFilterOption
    self.onTapEdit = onTapEdit
    self.onTapDelete = onTapDelete
    self.onTapRetry = onTapRetry
  }
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        /// Thumbnail Image
        if let documentImage = itemData.record?.thumbnail, !documentImage.isEmpty {
          ThumbnailImageView(thumbnailImageUrl: FileHelper.getDocumentDirectoryURL().appendingPathComponent(documentImage))
            .background(.black.opacity(isThumbnailBlurred() ? 2 : 0))
            .blur(radius: isThumbnailBlurred() ? 2 : 0)
          
          /// Show retry upload view
          if let record = itemData.record,
             let syncState = RecordSyncState(from: record.syncState ?? ""),
             syncState == .upload(success: false), isNetworkAvailable {
            RetryUploadingView()
              .contentShape(Rectangle())
              .onTapGesture {
                onTapRetry(record)
              }
          }
        } else {
          ThumbnailImageLoadingView()
        }
        
        if let record = itemData.record {
          VStack {
            HStack {
              /// Sync State
              if let syncState = RecordSyncState(from: record.syncState ?? ""),
                 syncState != .upload(success: true) {
                TopLeftStateTileView(syncState: syncState)
              } else if record.isSmart {
                SmartReportView()
              }
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
    .frame(width: RecordsDocumentSize.itemWidth)
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
    .onAppear {
      cancellable = NetworkMonitor.shared.publisher
        .receive(on: DispatchQueue.main)
        .assign(to: \.isNetworkAvailable, on: self)
    }
    .onDisappear {
      cancellable?.cancel()
    }
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
            .textStyle(
              ekaFont: .calloutBold,
              color: .black
            )
        }
        /// Date
        if let record = itemData.record {
          let filterOption = selectedFilterOption ?? .dateOfUpload(sortingOrder: .newToOld)
          let dateText = record[keyPath: filterOption.keyPath]?.formatted(as: "dd MMM ‘yy") ?? "NA"
          
          Text(dateText)
            .textStyle(ekaFont: .calloutRegular, color: UIColor(resource: .neutrals600))
        }
      }
      
      Spacer()
      
      MenuView()
    }
    .padding(.horizontal, EkaSpacing.spacingXs)
    .frame(width: RecordsDocumentSize.itemWidth, height: 50)
  }
  
  private func TopLeftStateTileView(syncState: RecordSyncState) -> some View {
    HStack {
      if !isNetworkAvailable {
        NoNetworkStateView()
      } else if syncState == .uploading {
        UploadingStateView()
      }
    }
  }
  
  private func UploadingStateView() -> some View {
    HStack(alignment: .bottom) {
      ProgressView()
        .frame(width: 10, height: 10)
        .tint(Color(.yellow500))
      
      Text("Uploading")
        .textStyle(ekaFont: .labelBold, color: UIColor(resource: .neutrals800))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, EkaSpacing.spacingXxs)
    .background(.white)
    .cornerRadiusModifier(6, corners: [.bottomRight])
  }
  
  private func NoNetworkStateView() -> some View {
    HStack {
      Image(systemName: "icloud.slash.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 13, height: 13)
        .foregroundStyle(Color(.neutrals600))
      
      Text("Waiting for network")
        .textStyle(ekaFont: .labelBold, color: UIColor(resource: .neutrals600))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, EkaSpacing.spacingXxs)
    .background(.white)
    .cornerRadiusModifier(6, corners: [.bottomRight])
  }
  
  private func RetryUploadingView() -> some View {
    HStack {
      Image(systemName: "arrow.clockwise")
        .resizable()
        .scaledToFit()
        .frame(width: 13, height: 13)
        .foregroundStyle(Color(.primary500))
      
      Text("Retry uploading")
        .textStyle(ekaFont: .labelBold, color: UIColor(resource: .primary500))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, EkaSpacing.spacingXxs)
    .background(.white)
    .cornerRadius(6)
  }
  
  /// Thumbnail
  private func ThumbnailImageView(thumbnailImageUrl: URL) -> some View {
    ZStack {
      WebImage(url: thumbnailImageUrl)
        .resizable()
        .scaledToFill()
      Color.black.opacity(0.2).layoutPriority(-1)
    }
    .frame(width: RecordsDocumentSize.itemWidth, height: RecordsDocumentSize.thumbnailHeight, alignment: .top)
    .cornerRadiusModifier(12, corners: .topLeft.union(.topRight))
  }
  
  private func ThumbnailImageLoadingView() -> some View {
    Color.black.opacity(0.6)
      .frame(width: RecordsDocumentSize.itemWidth, height: RecordsDocumentSize.thumbnailHeight, alignment: .top)
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
        .frame(width: 13, height: 13)
        .foregroundStyle(Color(.yellow500))
      
      Text("Smart")
        .textStyle(ekaFont: .labelBold, color: UIColor(resource: .neutrals800))
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
//
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
  
  private func isThumbnailBlurred() -> Bool {
    guard let recordState = RecordSyncState(from: itemData.record?.syncState ?? "") else { return false }
    return recordState == .upload(success: false) && !isNetworkAvailable || recordState == .upload(success: false)
  }
}

#Preview {
  RecordItemView(
    itemData: RecordItemViewData.formRecordItemPreviewData(),
    recordPresentationState: .displayAll,
    pickerSelectedRecords: .constant([]),
    selectedFilterOption: .constant(.documentDate(sortingOrder: .newToOld)),
    onTapEdit: {_ in},
    onTapDelete: {_ in},
    onTapRetry: {_ in}
  )
}
