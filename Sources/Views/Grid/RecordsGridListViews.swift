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
  
  let title = "All"
  let recordsRepo = RecordsRepo()
  let columns = [
    GridItem(.flexible()), // First column
    GridItem(.flexible())  // Second column
  ]
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Record.uploadDate, ascending: false)],
    animation: .easeIn
  )
  var records: FetchedResults<Record>
  @State private var isUploadBottomSheetPresented = false // State to control sheet presentation
  @State private var images: [UIImage] = []
  @State private var selectedPDFData: Data?

  public init() {}
  
  // MARK: - View
  
  public var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing) {
        /// Grid
        ScrollView {
          LazyVGrid(columns: columns, spacing: EkaSpacing.spacingL) {
            ForEach(records, id: \.id) { item in
              RecordItemView(itemData: RecordItemViewData.formRecordItemViewData(from: item))
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
      .navigationTitle(title) // Add a navigation title
      .sheet(isPresented: $isUploadBottomSheetPresented) {
        RecordUploadSheetView(
          images: $images,
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
      .onChange(of: images) { oldValue, newValue in
        let data = GalleryHelper.convertImagesToData(images: newValue)
        let recordModel = recordsRepo.databaseAdapter.formRecordModelFromAddedData(data: data, contentType: .image)
        recordsRepo.addSingleRecord(record: recordModel)
      }
    }
  }
}

#Preview {
  RecordsGridListView()
}
