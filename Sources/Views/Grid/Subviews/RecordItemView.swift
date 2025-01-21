//
//  RecordItemView.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 16/01/25.
//

import SwiftUI

struct RecordItemView: View {
  let itemWidth: CGFloat = 160
  let itemData: RecordItemViewData
  
  var body: some View {
    VStack(spacing: 0) {
      /// Document Image View
      ZStack {
        /// Thumbnail Image
        Image(.recordSample)
          .resizable()
          .scaledToFill()
          .cornerRadius(8)
          .padding([.horizontal, .top], EkaSpacing.spacingXs)
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
}

#Preview {
  RecordItemView(itemData: RecordItemViewData.formRecordItemPreviewData())
}
