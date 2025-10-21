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

//TODO: - Shekhar: commented blocking unnecessay api calls
public struct RecordsGridListView: View {
  // MARK: - Properties
  let recordsRepo: RecordsRepo = RecordsRepo.shared
  let columns = [
    GridItem(
      .adaptive(
        minimum: RecordsDocumentSize.itemWidth
      ),
      spacing: RecordsDocumentSize.itemHorizontalSpacing
    )
  ]
  let recordPresentationState: RecordPresentationState
  let title: String
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.dismiss) private var dismiss
  /// Images that are selected for upload
  @State private var uploadedImages: [UIImage] = []
  /// PDF data that is selected for upload
  @State private var selectedPDFData: Data?
  /// Records that are selected in records picker state
  @Binding var pickerSelectedRecords: [Record]
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
  @Binding private var selectedRecord: Record?
  @Binding private var lastSourceRefreshedAt: Date?
  // MARK: - Init
  @State private var currentCaseID: String?
  @State private var isSyncing = false
  public init(
    recordPresentationState: RecordPresentationState,
    didSelectPickerDataObjects: RecordItemsCallback = nil,
    title: String,
    pickerSelectedRecords: Binding<[Record]> = .constant([]),
    selectedRecord: Binding<Record?> = .constant(nil),
    lastSourceRefreshedAt: Binding<Date?> = .constant(nil),
    ) {
    self.recordPresentationState = recordPresentationState
    self.didSelectPickerDataObjects = didSelectPickerDataObjects
    self._pickerSelectedRecords = pickerSelectedRecords
    self.title = title
    self._selectedRecord = selectedRecord
    self._lastSourceRefreshedAt = lastSourceRefreshedAt
    self.currentCaseID = recordPresentationState.associatedCaseID
  }
  // MARK: - View
  public var body: some View {
    ZStack(alignment: .bottomTrailing) {
      QueryResponderView(
        predicate: generatePredicate(
          for: selectedFilter,
          caseID: recordPresentationState.associatedCaseID
        ),
        sortDescriptors: generateSortDescriptors(for: selectedSortFilter)
      ) { (records: FetchedResults<Record>) in
          ScrollView {
            if records.isEmpty {
              if let lastSourceRefreshedAt = lastSourceRefreshedAt , UIDevice.current.userInterfaceIdiom == .phone{
                Text(formattedDate(lastSourceRefreshedAt))
                  .newTextStyle(ekaFont: .subheadlineRegular, color: UIColor(resource: .labelsPrimary))
              }
              
              VStack(spacing: 16) {
                Spacer(minLength: 100)
                ContentUnavailableView(
                  "No documents found",
                  systemImage: "doc",
                  description: Text("Upload documents to see them here")
                )
                Spacer()
              }
              .frame(maxWidth: .infinity)
            } else {
              RecordsFilterListView(
                selectedChip: $selectedFilter,
                selectedSortFilter: $selectedSortFilter,
                caseID: $currentCaseID
              )
              .padding([.leading, .vertical], EkaSpacing.spacingM)
              .environment(\.managedObjectContext, viewContext)
              if let lastSourceRefreshedAt = lastSourceRefreshedAt , UIDevice.current.userInterfaceIdiom == .phone{
                HStack {
                  Text("Last updated:")
                    .newTextStyle(ekaFont: .subheadlineRegular, color: UIColor(resource: .grey600))
                  
                  Text(formattedDate(lastSourceRefreshedAt))
                    .newTextStyle(ekaFont: .subheadlineRegular, color: UIColor(resource: .labelsPrimary))
                  Spacer()
                }
                .padding(.leading , EkaSpacing.spacingM)
                
              }
               
              // Grid
              LazyVGrid(columns: columns, spacing: EkaSpacing.spacingM) {
                ForEach(records, id: \.objectID) { item in
                  switch recordPresentationState.mode {
                  case .dashboard, .displayAll, .copyVitals:
                    if UIDevice.current.isIPad {
                      itemView(item: item)
                        .frame(
                          width: RecordsDocumentSize.itemWidth,
                          height: RecordsDocumentSize.getItemHeight()
                        )
                    } else {
                      NavigationLink(value: item) {
                        itemView(item: item)
                          .frame(
                            width: RecordsDocumentSize.itemWidth,
                            height: RecordsDocumentSize.getItemHeight()
                          )
                      }
                    }
                  case .picker:
                    itemView(item: item)
                      .frame(
                        width: RecordsDocumentSize.itemWidth,
                        height: RecordsDocumentSize.getItemHeight()
                      )
                  }
                }
              }
              .padding(.horizontal, EkaSpacing.spacingS)
              .padding(.vertical)
              .padding(.bottom, 140) // Space for floating button
            }
          }
          .refreshable {
            refreshRecords()
          }
      }
      // Upload menu floating bottom-right
      RecordUploadMenuView(
        images: $uploadedImages,
        selectedPDFData: $selectedPDFData,
        hasUserGalleryPermission: PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
      )
    }
    .onAppear {
      currentCaseID = recordPresentationState.associatedCaseID
//      refreshRecords()
    }
    .onReceive(networkMonitor.$isOnline) { isOnline in
//      if isOnline {
//        syncRecords()
//      }
    }
    .onChange(of: recordPresentationState.associatedCaseID) { _ , newValue in
      currentCaseID = newValue
      selectedFilter = .typeAll
    }
    .background(Color(.neutrals50))
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
    .sheet(isPresented: $isEditBottomSheetPresented, onDismiss: {
      refreshRecords()
    }) {
      EditBottomSheetView(
        isEditBottomSheetPresented: $isEditBottomSheetPresented,
        record: $recordSelectedForEdit,
        recordPresentationState: recordPresentationState
      )
      .presentationDragIndicator(.visible)
    }
    /// On selection of PDF add a record to the storage
    .onChange(of: selectedPDFData) { _,newValue in
      if let newValue {
        addRecord(
          data: [newValue],
          contentType: .pdf
        )
        // Reset selectedPDFData to prevent duplicate uploads
        selectedPDFData = nil
      }
    }
    /// On selection of images add a record to the storage
    .onChange(of: uploadedImages) { _,newValue in
      if !newValue.isEmpty {
        let data = GalleryHelper.convertImagesToData(images: newValue)
        addRecord(
          data: data,
          contentType: .image
        )
        // Reset uploadedImages to prevent duplicate uploads
        uploadedImages = []
      }
    }
  }
}

// MARK: - Subviews

extension RecordsGridListView {
  private func itemView(
    item: Record
  ) -> some View {
    RecordItemView(
      itemData: RecordItemViewData.formRecordItemViewData(from: item, isSelected: pickerSelectedRecords.firstIndex(where: { $0.objectID == item.objectID}) != nil),
      recordPresentationState: recordPresentationState,
      pickerSelectedRecords: $pickerSelectedRecords,
      selectedFilterOption: $selectedSortFilter,
      onTapEdit: editItem(record:),
      onTapDelete: onTapDelete(record:),
      onTapRetry: onTapRetry(record:),
      onTapDelinkCCase: onTapDelinkCCase(record: delinkCaseId:),
      onTapRecord: selectedRecordItem(record:)
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
    recordsRepo.databaseManager.fetchCase(
      fetchRequest: QueryHelper.fetchCase(
        caseID: recordPresentationState.associatedCaseID
      )
    ) { cases in
      let recordModel = recordsRepo.databaseAdapter.formRecordModelFromAddedData(
        data: data,
        contentType: contentType,
        caseModels: cases
      )
      DispatchQueue.main.async {
        recordsRepo.addSingleRecord(record: recordModel) { uploadedRecord in
          recordSelectedForEdit = uploadedRecord
          isEditBottomSheetPresented = true /// Show edit bottom sheet
        }
      }
    }
  }
  /// To sync unuploaded records
  private func syncRecords() {
    recordsRepo.syncUnuploadedRecords{_ in }
  }
  /// Used to refresh records
  private func refreshRecords() {
    recordsRepo.getUpdatedAtAndStartCases { _ in
      recordsRepo.getUpdatedAtAndStartFetchRecords { _, _ in }
    }
  }
  /// On tap delete open
  private func onTapDelete(record: Record) {
    itemToBeDeleted = record
    isDeleteAlertPresented = true
  }
  /// On tap retry upload
  private func onTapRetry(record: Record) {
    recordsRepo.uploadRecord(record: record) { _ in
    }
  }
  
  private func selectedRecordItem(record: Record) {
    selectedRecord = record
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
  /// Used to delink case an item
  private func onTapDelinkCCase(record: Record, delinkCaseId: String) {
    recordsRepo.delinkCaseFromRecord(record: record, caseId: delinkCaseId) { _ in
    }
  }
}

// TODO: - Arya - to be moved to a common place
extension RecordsGridListView {
  func generatePredicate(
    for filter: RecordDocumentType,
    caseID: String? = nil
  ) -> NSPredicate {
    guard let filterIDs = CoreInitConfigurations.shared.filterID else { return NSPredicate(value: false) }
    let oidPredicate = NSPredicate(format: "oid IN %@", filterIDs)
    var predicates: [NSPredicate] = [oidPredicate]
    if filter != .typeAll {
      let typePredicate = PredicateHelper.equals("documentType", value: Int64(filter.intValue))
      predicates.append(typePredicate)
    }
    if let caseID = caseID {
      let casePredicate = NSPredicate(format: "ANY toCaseModel.caseID == %@", caseID)
      predicates.append(casePredicate)
    }
    return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
  }
  
  func generateSortDescriptors(for sortType: RecordSortOptions?) -> [NSSortDescriptor] {
      let objectIDSort = NSSortDescriptor(keyPath: \Record.objectID, ascending: true)

      guard let sortType else {
          return [
              NSSortDescriptor(keyPath: \Record.uploadDate, ascending: false),
              objectIDSort
          ]
      }

      switch sortType {
      case .dateOfUpload(let order):
          return [
              NSSortDescriptor(keyPath: \Record.uploadDate, ascending: order == .oldToNew),
              objectIDSort
          ]
      case .documentDate(let order):
          return [
              NSSortDescriptor(keyPath: \Record.documentDate, ascending: order == .oldToNew),
              objectIDSort
          ]
      }
  }
  private func formattedDate(_ date: Date?) -> String {
    guard let date = date else { return "" }
    
    let calendar = Calendar.current
    let timeFormatter = DateFormatter()
    timeFormatter.timeStyle = .short
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    
    if calendar.isDateInToday(date) {
      return "Today, \(timeFormatter.string(from: date))"
    } else if calendar.isDateInYesterday(date) {
      return "Yesterday, \(timeFormatter.string(from: date))"
    } else {
      return dateFormatter.string(from: date)
    }
  }
}

#Preview {
  RecordsGridListView(
    recordPresentationState: RecordPresentationState(mode: .displayAll),
    title: RecordPresentationState(mode: .displayAll).title,
    pickerSelectedRecords: .constant([])
  )
}
