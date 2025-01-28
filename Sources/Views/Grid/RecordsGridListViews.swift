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
    animation: .easeIn
  ) var records: FetchedResults<Record>
  @State private var isUploadBottomSheetPresented = false // State to control sheet presentation
  /// Images that are selected for upload
  @State private var uploadedImages: [UIImage] = []
  /// PDF data that is selected for upload
  @State private var selectedPDFData: Data?
  /// Images that are selected in records picker state
  @State private var pickerSelectedRecords: [RecordItemViewData] = []

  // MARK: - Init
  
  public init(
    recordsRepo: RecordsRepo = RecordsRepo(),
    recordPresentationState: RecordPresentationState
  ) {
    self.recordsRepo = recordsRepo
    self.recordPresentationState = recordPresentationState
  }
  
  // MARK: - View
  
  public var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing) {
        /// Grid
        ScrollView {
          LazyVGrid(columns: columns, spacing: EkaSpacing.spacingL) {
            ForEach(records, id: \.id) { item in
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
        .padding(.trailing, EkaSpacing.spacingM)
      }
      .background(Color(.neutrals50))
      .navigationTitle(recordPresentationState.title) // Add a navigation title
      .navigationBarTitleDisplayMode(.inline)
      .toolbar { /// Toolbaar item
        ToolbarItem(placement: .topBarTrailing) {
          if pickerSelectedRecords.count > 0 {
            Button("Done") {
              onDoneButtonPressed()
            }
          }
        }
      }
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
      .onAppear {
        recordsRepo.fetchRecordsFromServer {}
      }
      /// On selection of images add a record to the storage
      .onChange(of: uploadedImages) { oldValue, newValue in
        let data = GalleryHelper.convertImagesToData(images: newValue)
        let recordModel = recordsRepo.databaseAdapter.formRecordModelFromAddedData(data: data, contentType: .image)
        recordsRepo.addSingleRecord(record: recordModel)
      }
    }
  }
}

// MARK: - Helper Functions

extension RecordsGridListView {
  /// Used to delete a grid item
  private func deleteItem(record: Record) {
    recordsRepo.deleteRecord(record: record)
  }
  
  private func onDoneButtonPressed() {
    print("Done button pressed")
  }
}

#Preview {
  RecordsGridListView(recordPresentationState: .displayAll)
}
