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
    GridItem(.flexible()), // First column
    GridItem(.flexible())  // Second column
  ]
  let recordPresentationState: RecordPresentationState
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Record.uploadDate, ascending: false)],
    predicate: PredicateHelper.equals("oid", value: CoreInitConfigurations.shared.filterID),
    animation: .easeIn
  ) var records: FetchedResults<Record>
  /// Upload bottom sheet bool
  @State private var isUploadBottomSheetPresented = false
  /// Images that are selected for upload
  @State private var uploadedImages: [UIImage] = []
  /// PDF data that is selected for upload
  @State private var selectedPDFData: Data?
  /// Records that are selected in records picker state
  @State private var pickerSelectedRecords: [Record] = []
  /// Used to display uploading loader in view
  @State private var isUploading: Bool = false
  /// Edit bottom sheet bool
  @State private var isEditBottomSheetPresented: Bool = false
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
        /// Grid
        ScrollView {
          LazyVGrid(columns: columns, spacing: EkaSpacing.spacingL) {
            ForEach(records, id: \.id) { item in
              switch recordPresentationState {
              case .dashboard, .displayAll:
                /// Put navigation in this case
                NavigationLink(
                  destination: RecordView(
                    record: item
                  )
                ) {
                  ItemView(item: item)
                }
              case .picker:
                /// Put picker tap in this case
                ItemView(item: item)
              }
            }
          }
          .padding()
        }
        
        /// Button
        ButtonView(
          title: "Add record",
          imageName: UIImage(systemName: "plus"),
          size: .large,
          imagePosition: .leading,
          style: .outline,
          isFullWidth: false
        ) {
          isUploadBottomSheetPresented = true
        }
        .shadow(color: .black.opacity(0.3), radius: 50, x: 0, y: 10)
        .padding(.trailing, EkaSpacing.spacingM)
      }
      .background(Color(.neutrals50))
      .refreshable {
        refreshRecords()
      }
      .navigationTitle(recordPresentationState.title) // Add a navigation title
      .toolbar { /// Toolbar item
        ToolbarItem(placement: .topBarTrailing) {
          if pickerSelectedRecords.count > 0 {
            Button("Done") {
              onDoneButtonPressed()
            }
          }
        }
      }
      .uploadingOverlay(isUploading: $isUploading)
      .sheet(isPresented: $isUploadBottomSheetPresented) {
        RecordUploadSheetView(
          images: $uploadedImages,
          selectedPDFData: $selectedPDFData,
          hasUserGalleryPermission: PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized,
          isUploadBottomSheetPresented: $isUploadBottomSheetPresented
        ) // The content of the sheet
        .presentationDetents([.medium]) // Set medium detent
        .presentationBackground(Color(.neutrals100)) // Set background
        .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $isEditBottomSheetPresented) {
        NavigationStack {
          EditBottomSheetView()
            .presentationDragIndicator(.visible)
        }
      }
      .onAppear {
        refreshRecords()
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
  private func ItemView(item: Record) -> some View {
    RecordItemView(
      itemData: RecordItemViewData.formRecordItemViewData(from: item),
      recordPresentationState: recordPresentationState,
      pickerSelectedRecords: $pickerSelectedRecords
    )
    .frame(width: 160)
    .contextMenu {
      Button(role: .destructive) {
        deleteItem(record: item)
      } label: {
        Text("Delete")
      }
    }
  }
}

// MARK: - Helper Functions

extension RecordsGridListView {
  
  /// Used to add record in database and upload
  private func addRecord(
    data: [Data],
    contentType: FileType
  ) {
    isUploading = true /// Show uploading loader
    isUploadBottomSheetPresented = false /// Dismiss the sheet
    let recordModel = recordsRepo.databaseAdapter.formRecordModelFromAddedData(data: data, contentType: contentType)
    recordsRepo.addSingleRecord(record: recordModel) {
      isEditBottomSheetPresented = true /// Show edit bottom sheet
      isUploading = false
    }
  }
  
  /// Used to refresh records
  private func refreshRecords() {
    recordsRepo.getUpdatedAtAndStartFetchRecords()
  }
  
  /// Used to delete a grid item
  private func deleteItem(record: Record) {
    recordsRepo.deleteRecord(record: record)
  }
  
  /// On press of done button in picker state
  private func onDoneButtonPressed() {
    let pickedRecords = setPickerSelectedObjects(selectedRecords: pickerSelectedRecords)
    didSelectPickerDataObjects?(pickedRecords)
  }
  
  /// Get picker selected images from records
  private func setPickerSelectedObjects(
    selectedRecords: [Record]
  ) -> [RecordPickerDataModel] {
    var pickerObjects: [RecordPickerDataModel] = []
    selectedRecords.forEach { record in
      pickerObjects.append(
        RecordPickerDataModel(
          image: record.thumbnail,
          documentID: record.documentID
        )
      )
    }
    return pickerObjects
  }
}

#Preview {
  RecordsGridListView(recordPresentationState: .displayAll)
}
