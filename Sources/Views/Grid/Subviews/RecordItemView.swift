//
//  RecordItemView.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecordItemView: View {
  
  enum RecordsDocumentThumbnailSize {
    static let height: CGFloat = 104
  }
  
  let itemWidth: CGFloat = 160
  let itemData: RecordItemViewData
  
  var body: some View {
    VStack(spacing: 0) {
      /// Thumbnail Image
      if let documentImage = itemData.documentImage {
        ThumbnailImageView(thumbnailImageUrl: documentImage)
      } else {
        ThumbnailImageLoadingView()
      }
      
      /// Bottom Meta Data View 
      BottomMetaDataView()
    }
    .frame(width: itemWidth)
    .background(Color.white)
    .cornerRadius(12)
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
        .frame(maxWidth: .infinity)
      Color.black.opacity(0.2).layoutPriority(-1)
    }
    .frame(height: RecordsDocumentThumbnailSize.height, alignment: .top)
    .cornerRadius(12, corners: .topLeft.union(.topRight))
  }
  
  private func ThumbnailImageLoadingView() -> some View {
    Color.black.opacity(0.6)
      .frame(height: RecordsDocumentThumbnailSize.height, alignment: .top)
      .cornerRadius(12, corners: .topLeft.union(.topRight))
  }
}

#Preview {
  RecordItemView(itemData: RecordItemViewData.formRecordItemPreviewData())
}
