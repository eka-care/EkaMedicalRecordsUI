//
//  VitalReadingRowView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 05/02/25.
//

import SwiftUI
import EkaMedicalRecordsCore

struct VitalReadingRowView: View {
  // MARK: - Properties
  
  let itemData: Verified
  
  // MARK: - Body
  
  var body: some View {
    VStack {
      HStack {
        LeftStackView()
        Spacer()
        RightStackView()
        rightArrowImage
      }
      .padding(.top, EkaSpacing.spacingXs)
      .padding(.horizontal, EkaSpacing.spacingM)
      
      Divider()
    }
    .background(Color.white)
  }
}

extension VitalReadingRowView {
  private func LeftStackView() -> some View {
    VStack(alignment: .leading, spacing: EkaSpacing.spacingXxxs) {
      /// Vital Name
      if let name = itemData.name {
        Text(name)
          .textStyle(ekaFont: .calloutRegular, color: .black)
      }
      
      /// Vital Range
      if let range = itemData.range, let unit = itemData.unit {
        Text("\(range) \(unit)")
          .textStyle(ekaFont: .calloutRegular, color: .black)
      }
    }
  }
  
  private func RightStackView() -> some View {
    VStack(alignment: .trailing, spacing: EkaSpacing.spacingXxxs) {
      /// Vital Interpretation Eg: High, Low
      if let displayResult = itemData.displayResult {
        Text(displayResult)
          .textStyle(ekaFont: .calloutRegular, color: .black)
//          .textStyle(
//            ekaFont: .body3SemiBold,
//            color: viewModel.setInterpretationColorForVital(itemData: itemData) ?? .text01
//          )
      }
      
      /// Vital Value
      if let value = itemData.value {
        Text(value)
          .textStyle(ekaFont: .calloutRegular, color: .black)
//          .textStyle(ekaFont: .body1Regular, color: .text01)
      }
    }
  }
  
  private var rightArrowImage: some View {
    Image(systemName: "chevron.right")
      .resizable()
      .scaledToFit()
      .frame(height: 12)
      .foregroundColor(Color(.primary500))
  }
}

// TODO: - To be added later

//#Preview {
//  VitalReadingRowView(itemData: <#Verified#>)
//}
