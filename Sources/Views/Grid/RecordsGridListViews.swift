//
//  RecordsListViews.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import SwiftUI
import PhotosUI
import CoreData
import EkaMedicalRecordsCore

public struct RecordsGridListView: View {
  // MARK: - Properties
  
  let recordsRepo: RecordsRepo
  let columns = [
    GridItem(
      .adaptive(
        minimum: RecordsDocumentSize.itemWidth
      ),
      spacing: RecordsDocumentSize.itemHorizontalSpacing
    )
  ]
  let recordPresentationState: RecordPresentationState
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.dismiss) private var dismiss
  /// Upload bottom sheet bool
  @State private var isUploadBottomSheetPresented = false
  /// Images that are selected for upload
  @State private var uploadedImages: [UIImage] = []
  /// PDF data that is selected for upload
  @State private var selectedPDFData: Data?
  /// Records that are selected in records picker state
  @State private var pickerSelectedRecords: [Record] = []
  /// Used to display downloading loader in view
  @State private var isDownloading: Bool = false
  /// Edit bottom sheet bool
  @State private var isEditBottomSheetPresented: Bool = false
  /// Currently uploaded record
  @State private var recordSelectedForEdit: Record?
  /// Bool to check if records is loading data from server
  @State private var isLoadingRecordsFromServer: Bool = false
  /// Alert to confirm delete
  @State private var isDeleteAlertPresented = false
  /// Item to be deleted
  @State private var itemToBeDeleted: Record?
  /// Selected filter
  @State private var selectedFilter: RecordDocumentType = .typeAll
  /// Selected sort type
  @State private var selectedSortFilter: RecordSortOptions?
  @StateObject private var networkMonitor = NetworkMonitor.shared
  /// Used for callback when picker does select images
  var didSelectPickerDataObjects: RecordItemsCallback
  
  // MARK: - Init
  
  public init(
    recordsRepo: RecordsRepo = RecordsRepo(),
    recordPresentationState: RecordPresentationState,
    didSelectPickerDataObjects: RecordItemsCallback = nil
  ) {
    self.recordsRepo = recordsRepo
    self.recordPresentationState = recordPresentationState
    self.didSelectPickerDataObjects = didSelectPickerDataObjects
  }
  
  // MARK: - View
  
  public var body: some View {
    ZStack(alignment: .bottomTrailing) {
      if isLoadingRecordsFromServer {
        ProgressView()
      } else {
        FilteredRecordsView(
          predicate: generatePredicate(for: selectedFilter),
          sortDescriptors: generateSortDescriptors(for: selectedSortFilter)
        ) { (records: FetchedResults<Record>) in
          Group {
            if records.isEmpty {
              ContentUnavailableView(
                "No documents found",
                systemImage: "doc",
                description: Text("Upload documents to see them here")
              )
              RecordUploadMenuView(
                images: $uploadedImages,
                selectedPDFData: $selectedPDFData,
                hasUserGalleryPermission: PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
              )
            } else {
              ScrollView {
                // Filter chips
                RecordsFilterListView(
                  recordsRepo: recordsRepo,
                  selectedChip: $selectedFilter,
                  selectedSortFilter: $selectedSortFilter
                )
                .padding([.leading, .vertical], EkaSpacing.spacingM)
                .environment(\.managedObjectContext, viewContext)
                
                // Grid
                LazyVGrid(columns: columns, spacing: EkaSpacing.spacingM) {
                  ForEach(records, id: \.id) { item in
                    switch recordPresentationState {
                    case .dashboard, .displayAll:
                      NavigationLink(destination: RecordView(record: item)) {
                        ItemView(item: item)
                          .frame(width: RecordsDocumentSize.itemWidth, height: RecordsDocumentSize.getItemHeight(), alignment: .center)
                      }
                    case .picker:
                      ItemView(item: item)
                        .frame(width: RecordsDocumentSize.itemWidth, height: RecordsDocumentSize.getItemHeight(), alignment: .center)
                    }
                  }
                }
                .padding(.horizontal, EkaSpacing.spacingS)
                .padding(.vertical)
                .padding(.bottom, 140)
              }
              
              RecordUploadMenuView(
                images: $uploadedImages,
                selectedPDFData: $selectedPDFData,
                hasUserGalleryPermission: PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
              )
            }
          }
        }
      }
    }
    .background(Color(.neutrals50))
    .refreshable {
      refreshRecords()
    }
    .navigationTitle(recordPresentationState.title) // Add a navigation title
    .toolbar { /// Toolbar item
      /// Close button on the top left
      ToolbarItem(placement: .topBarLeading) {
        Button(action: {
          /// Dismiss or handle close action
          dismiss()
        }) {
          Text("Close")
            .textStyle(ekaFont: .bodyRegular, color: UIColor(resource: .primary500))
        }
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        // Sync button
        Button(action: {
          /// refresh action
          refreshRecords()
        }) {
          Image(systemName: "arrow.triangle.2.circlepath")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24, alignment: .center)
            .foregroundStyle(Color(.primary500))
        }
        // Done
        if pickerSelectedRecords.count > 0 {
          Button("Done") {
            onDoneButtonPressed()
          }
        }
      }
    }
    // alert box
    .alert("Confirm Delete", isPresented: $isDeleteAlertPresented) { [itemToBeDeleted] in
      Button("Yes", role: .destructive) {
        if let record = itemToBeDeleted {
          deleteItem(record: record)
        }
      }
      Button("No", role: .cancel) {}
    } message: {
      Text("Are you sure you want to delete this record?")
    }
    .sheet(isPresented: $isEditBottomSheetPresented) {
      NavigationStack {
        EditBottomSheetView(
          isEditBottomSheetPresented: $isEditBottomSheetPresented,
          record: $recordSelectedForEdit
        )
        .presentationDragIndicator(.visible)
      }
    }
    .onAppear {
      refreshRecords()
      syncRecords()
    }
    /// On selection of PDF add a record to the storage
    .onChange(of: selectedPDFData) { oldValue, newValue in
      if let newValue {
        addRecord(
          data: [newValue],
          contentType: .pdf
        )
      }
    }
    /// On selection of images add a record to the storage
    .onChange(of: uploadedImages) { oldValue, newValue in
      let data = GalleryHelper.convertImagesToData(images: newValue)
      addRecord(
        data: data,
        contentType: .image
      )
    }
  }
}

// MARK: - Subviews

extension RecordsGridListView {
  private func ItemView(
    item: Record
  ) -> some View {
    RecordItemView(
      itemData: RecordItemViewData.formRecordItemViewData(from: item),
      recordPresentationState: recordPresentationState,
      pickerSelectedRecords: $pickerSelectedRecords,
      selectedFilterOption: $selectedSortFilter,
      onTapEdit: editItem(record:),
      onTapDelete: onTapDelete(record:),
      onTapRetry: onTapRetry(record:)
    )
  }
}

// MARK: - Helper Functions

extension RecordsGridListView {
  
  /// Used to add record in database and upload
  private func addRecord(
    data: [Data],
    contentType: FileType
  ) {
    isUploadBottomSheetPresented = false /// Dismiss the sheet
    let recordModel = recordsRepo.databaseAdapter.formRecordModelFromAddedData(data: data, contentType: contentType)
    recordsRepo.addSingleRecord(record: recordModel) { uploadedRecord in
      recordSelectedForEdit = uploadedRecord
      isEditBottomSheetPresented = true /// Show edit bottom sheet
    }
  }
  
  /// To sync unuploaded records
  private func syncRecords() {
    recordsRepo.syncUnuploadedRecords()
  }
  
  /// Used to refresh records
  private func refreshRecords() {
    isLoadingRecordsFromServer = true
    recordsRepo.getUpdatedAtAndStartFetchRecords { success in
      isLoadingRecordsFromServer = false
    }
  }
  
  /// On tap delete open
  private func onTapDelete(record: Record) {
    itemToBeDeleted = record
    isDeleteAlertPresented = true
  }
  
  /// On tap retry upload
  private func onTapRetry(record: Record) {
    recordsRepo.uploadRecord(record: record) { record in }
  }
  
  /// Used to delete a grid item
  private func deleteItem(record: Record) {
    recordsRepo.deleteRecord(record: record)
  }
  
  /// Used to edit an item
  private func editItem(record: Record) {
    recordSelectedForEdit = record
    isEditBottomSheetPresented = true
  }
  
  /// On press of done button in picker state
  private func onDoneButtonPressed() {
    isDownloading = true
    setPickerSelectedObjects(selectedRecords: pickerSelectedRecords) { pickedRecords in
      isDownloading = false
      didSelectPickerDataObjects?(pickedRecords)
    }
  }
  
  /// Get picker selected images from records
  private func setPickerSelectedObjects(
    selectedRecords: [Record],
    completion: RecordItemsCallback
  ) {
    var pickerObjects: [RecordPickerDataModel] = []
    recordsRepo.fetchRecordsMetaData(for: selectedRecords) { documentURIs in
      for (index, value) in selectedRecords.enumerated() {
        pickerObjects.append(
          RecordPickerDataModel(
            image: value.thumbnail,
            documentID: value.documentID,
            documentPath: documentURIs[index]
          )
        )
      }
      completion?(pickerObjects)
    }
  }
}

// TODO: - Arya - to be moved to core layer
extension RecordsGridListView {
  func generatePredicate(for filter: RecordDocumentType) -> NSPredicate {
    guard let filterIDs = CoreInitConfigurations.shared.filterID else { return NSPredicate(value: false) }
    let oidPredicate = NSPredicate(format: "oid IN %@", filterIDs)
    switch filter {
    case .typeAll:
      return oidPredicate
    default:
      let typePredicate = PredicateHelper.equals("documentType", value: Int64(filter.intValue))
      return NSCompoundPredicate(andPredicateWithSubpredicates: [oidPredicate, typePredicate])
    }
  }
  
  func generateSortDescriptors(for sortType: RecordSortOptions?) -> [NSSortDescriptor] {
    guard let sortType else { return [NSSortDescriptor(keyPath: \Record.uploadDate, ascending: false)] }
    switch sortType {
    case .dateOfUpload(let order):
      return [NSSortDescriptor(keyPath: \Record.uploadDate, ascending: order == .oldToNew)]
    case .documentDate(let order):
      return [NSSortDescriptor(keyPath: \Record.documentDate, ascending: order == .oldToNew)]
    }
  }
}

#Preview {
  RecordsGridListView(recordPresentationState: .displayAll)
}
