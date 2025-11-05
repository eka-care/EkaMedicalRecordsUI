//
//  RecordItemView.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import SwiftUI
import EkaMedicalRecordsCore
import Combine
import SDWebImageSwiftUI

public typealias Record = EkaMedicalRecordsCore.Record

public enum RecordsDocumentSize {
  static let thumbnailHeight: CGFloat = 110
  static let bottomMetaDataHeight: CGFloat = 50
  static let itemWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 180 : 170
  static let itemHorizontalSpacing: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? EkaSpacing.spacingS : EkaSpacing.spacingXxxs
  static func getItemHeight() -> CGFloat {
    return thumbnailHeight + bottomMetaDataHeight
  }
}

public struct RecordItemView: View {
  // MARK: - Properties
  let recordPresentationState: RecordPresentationState
  @State var itemData: RecordItemViewData
  @Binding var pickerSelectedRecords: [Record]
  @Binding var selectedFilterOption: RecordSortOptions?
  var onTapEdit: (Record) -> Void
  var onTapDelete: (Record) -> Void
  var onTapRetry: (Record) -> Void
  var onTapDelinkCCase: (Record, String) -> Void
  var onTapRecord: (Record) -> Void
  @State var isNetworkAvailable = true
  @State var cancellable: AnyCancellable?
  var allowLongPress: Bool = true
  var haveMenu: Bool = true
  // MARK: - Init
  public init(
    itemData: RecordItemViewData,
    recordPresentationState: RecordPresentationState,
    pickerSelectedRecords: Binding<[Record]>,
    selectedFilterOption: Binding<RecordSortOptions?>,
    onTapEdit: @escaping (Record) -> Void,
    onTapDelete: @escaping (Record) -> Void,
    onTapRetry: @escaping (Record) -> Void,
    onTapDelinkCCase: @escaping (Record, String) -> Void,
    onTapRecord: @escaping (Record) -> Void,
    allowLongPress: Bool = true,
    haveMenu: Bool = true
  ) {
    self._itemData = State(initialValue: itemData)
    self.recordPresentationState = recordPresentationState
    self._pickerSelectedRecords = pickerSelectedRecords
    self._selectedFilterOption = selectedFilterOption
    self.onTapEdit = onTapEdit
    self.onTapDelete = onTapDelete
    self.onTapRetry = onTapRetry
    self.onTapDelinkCCase = onTapDelinkCCase
    self.onTapRecord = onTapRecord
    self.allowLongPress = allowLongPress
    self.haveMenu = haveMenu
  }
  // MARK: - Body
  public var body: some View {
    VStack(spacing: 0) {
      ZStack {
        /// Thumbnail Image
        thumbnailImageView(thumbnailImageUrl: FileHelper.getDocumentDirectoryURL().appendingPathComponent(itemData.record?.thumbnail ?? ""))
          .background(.black.opacity(isThumbnailBlurred() ? 2 : 0))
          .blur(radius: isThumbnailBlurred() ? 2 : 0)
          .frame(width: RecordsDocumentSize.itemWidth)
        /// Show retry upload view
        if let record = itemData.record,
           let syncState = RecordSyncState(from: record.syncState ?? ""),
           syncState == .upload(success: false), isNetworkAvailable {
          retryUploadingView()
            .contentShape(Rectangle())
            .onTapGesture {
              onTapRetry(record)
            }
            .frame(width: RecordsDocumentSize.itemWidth)
        }
        if let record = itemData.record {
          VStack {
            HStack {
              /// Sync State
              if let syncState = RecordSyncState(from: record.syncState ?? ""),
                 syncState != .upload(success: true) {
                topLeftStateTileView(syncState: syncState)
              } else if record.isSmart {
                smartReportView()
              }
              Spacer()
            }
            Spacer()
          }
        }
        /// Show tick view only in picker state
        if recordPresentationState.isPicker {
          /// Selection Tick View at Top-Right
          VStack {
            HStack {
              Spacer()
              selectionTickView().foregroundStyle(Color.yellow)
                .padding(.top, EkaSpacing.spacingM)
                .padding(.trailing, EkaSpacing.spacingM)
            }
            Spacer()
          }
        }
      }
      /// Bottom Meta Data View 
      bottomMetaDataView()
    }
    .frame(width: RecordsDocumentSize.itemWidth, height: RecordsDocumentSize.thumbnailHeight + RecordsDocumentSize.bottomMetaDataHeight)
    .background(Color.white)
    .cornerRadius(12)
    .contentShape(Rectangle())
    .if(recordPresentationState.isPicker || UIDevice.current.isIPad) { view in
      view.onTapGesture {
        onSelectingRecord()
      }
    }
    .if(allowLongPress) { view in
      view.contextMenu {
        if let record = itemData.record , !CoreInitConfigurations.shared.blockedFeatureTypes.contains(.uploadRecords) {
          Button {
            onTapEdit(record)
          } label: {
            Text("Edit")
          }
        }
        
        if let record = itemData.record,
           let caseId = recordPresentationState.associatedCaseID {
          Button {
            onTapDelinkCCase(record, caseId)
          } label: {
            Text("Unassign encounter")
          }
        }
        
        if let record = itemData.record {
          Button(role: .destructive) {
            onTapDelete(record)
          } label: {
            Text("Delete")
          }
        }
      }
    }
//    .contextMenu {
//      Button {
//        if let record = itemData.record {
//          onTapEdit(record)
//        }
//      } label: {
//        Text("Edit")
//      }
//      
//      if let record = itemData.record, let caseId = recordPresentationState.associatedCaseID {
//        Button {
//          onTapDelinkCCase(record , caseId)
//        } label: {
//          Text("Unassign encounter")
//        }
//      }
//      
//      Button(role: .destructive) {
//        if let record = itemData.record {
//          onTapDelete(record)
//        }
//      } label: {
//        Text("Delete")
//      }
//    }
//    .simultaneousGesture(TapGesture().onEnded {
//      onTapRecord()
//    })
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
  private func bottomMetaDataView() -> some View {
    HStack {
      VStack(alignment: .leading) {
        /// Document type
        if let record = itemData.record,
           let recordType = record.documentType  {
          Text(documentTypesList.first(where: { data in
            data.id == recordType
          })?.filterName ?? "Other")
            .textStyle(
              ekaFont: .calloutBold,
              color: .black
            )
        }
        /// Date
        if let record = itemData.record {
          let filterOption = selectedFilterOption ?? .dateOfUpload(sortingOrder: .newToOld)
          let date = record[keyPath: filterOption.keyPath]?.formatted(as: "dd MMM ‘yy, hh:mm a") ?? "NA"
          Text(date)
            .textStyle(ekaFont: .labelRegular, color: UIColor(resource: .neutrals600))
        }
      }
      Spacer()
      if haveMenu {
        menuView()
      }
    }
    .padding(.horizontal, EkaSpacing.spacingXs)
    .frame(width: RecordsDocumentSize.itemWidth, height: RecordsDocumentSize.bottomMetaDataHeight)
  }
  private func topLeftStateTileView(syncState: RecordSyncState) -> some View {
    HStack {
      if !isNetworkAvailable {
        noNetworkStateView()
      } else if syncState == .uploading {
        uploadingStateView()
      }
    }
  }
  private func uploadingStateView() -> some View {
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
  private func noNetworkStateView() -> some View {
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
  
  private func retryUploadingView() -> some View {
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
  private func thumbnailImageView(thumbnailImageUrl: URL?) -> some View {
    ZStack {
      if let url = thumbnailImageUrl,
         let _ = itemData.record?.thumbnail {
        // Show only the thumbnail
        WebImage(url: url)
          .resizable()
          .placeholder {
            Color.gray.opacity(0.2)
              .frame(width: RecordsDocumentSize.itemWidth,
                     height: RecordsDocumentSize.thumbnailHeight)
          }
          .scaledToFill()
          .frame(width: RecordsDocumentSize.itemWidth,
                 height: RecordsDocumentSize.thumbnailHeight)
          .clipped()
        
      } else {
        // No thumbnail → gray background + centered icon
        ZStack {
          Color(hex: "#EBEDF0")
            .frame(width: RecordsDocumentSize.itemWidth,
                   height: RecordsDocumentSize.thumbnailHeight)
          
          if itemData.record != nil {
            Image(uiImage: UIImage(resource: .docWithPlus))
              .resizable()
              .scaledToFit()
              .frame(width: 40, height: 40)
          }
        }
      }
    }
    .cornerRadiusModifier(12, corners: [.topLeft, .topRight])
  }

  
  private func thumbnailImageLoadingView() -> some View {
    Color.black.opacity(0.6)
      .frame(width: RecordsDocumentSize.itemWidth, height: RecordsDocumentSize.thumbnailHeight, alignment: .top)
      .cornerRadiusModifier(12, corners: .topLeft.union(.topRight))
  }
  
  private func selectionTickView() -> some View {
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
  
  private func smartReportView() -> some View {
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
  
  private func menuView() -> some View {
    // Menu that opens on tap (instead of long press)
    Menu {
      if !CoreInitConfigurations.shared.blockedFeatureTypes.contains(.uploadRecords) {
        Button {
          if let record = itemData.record {
            onTapEdit(record)
          }
        } label: {
          Text("Edit")
        }
      }
      
      if let record = itemData.record, let caseId = recordPresentationState.associatedCaseID {
        Button {
          onTapDelinkCCase(record , caseId)
        } label: {
          Text("Unassign encounter")
        }
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
  private func onSelectingRecord() {
    switch recordPresentationState.mode {
    case .displayAll, .copyVitals, .dashboard, .viewTrends:
      onTapDocument()
    case .picker:
      updateItemDataOnPickerSelection()
    }
  }
  
  /// On tap of document we open document viewer
  /// Note: - This is not being used. We use navigation link.
  private func onTapDocument() {
    guard let record = itemData.record else { return }
    onTapRecord(record)
  }
  
  /// Update item data on picker selection
  private func updateItemDataOnPickerSelection() {
      guard let record = itemData.record else { return }
      
      // Check if we're in picker mode and get max count
      guard case .picker(let maxCount) = recordPresentationState.mode else { return }
      
      // If trying to select and already at max capacity, don't allow selection
      if !itemData.isSelected && pickerSelectedRecords.count >= maxCount {
          return // Don't allow selection beyond max count
      }
      
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
    recordPresentationState: RecordPresentationState(mode: .displayAll),
    pickerSelectedRecords: .constant([]),
    selectedFilterOption: .constant(.documentDate(sortingOrder: .newToOld)),
    onTapEdit: {_ in},
    onTapDelete: {_ in},
    onTapRetry: {_ in},
    onTapDelinkCCase: {_, _ in},
    onTapRecord: {_ in}
  )
}
