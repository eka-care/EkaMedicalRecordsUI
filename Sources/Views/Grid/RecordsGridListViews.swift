//
//  RecordsListViews.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import SwiftUI
import PhotosUI

public struct RecordsGridListView: View {
  // MARK: - Properties
  
  let title = "All"
  // Define grid columns
  let columns = [
    GridItem(.flexible()), // First column
    GridItem(.flexible())  // Second column
  ]
  
  let items = Array(1...100) // Sample data for the grid (infinite rows possible)
  @State private var isUploadBottomSheetPresented = false // State to control sheet presentation

  // MARK: - View
  
  public var body: some View {
    NavigationView { // Wrap the content in a NavigationView
      ZStack(alignment: .bottomTrailing) {
        /// Grid
        ScrollView { // Enable vertical scrolling
          LazyVGrid(columns: columns, spacing: EkaSpacing.spacingL) { // Vertical grid layout
            ForEach(items, id: \.self) { item in
              RecordItemView(itemData: RecordItemViewData.formRecordItemPreviewData())
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
          hasUserGalleryPermission: PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized,
          isUploadBottomSheetPresented: $isUploadBottomSheetPresented
        ) // The content of the sheet
        .presentationDetents([.medium]) // Set medium detent
        .presentationBackground(Color(.neutrals100)) // Set background
        .presentationDragIndicator(.visible)
      }
    }
  }
}

#Preview {
  RecordsGridListView()
}
