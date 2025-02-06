//
//  VitalReadingRowView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 05/02/25.
//

import SwiftUI
import EkaMedicalRecordsCore

enum LabParameterResultType: String {
  case criticallyHigh = "sm-4067205096"
  case veryHigh = "sm-2631712380"
  case high = "sm-1420480405"
  case borderlineHigh = "sm-5279215230"
  case normal = "sm-8146614980"
  case borderlineLow = "sm-5279274814"
  case low = "sm-1220479757"
  case veryLow = "sm-2631771970"
  case criticallyLow = "sm-4067860500"
  case abnormal = "sm-5379306527"
  case undetermined = "sm-5612225938"
  
  var textColor: UIColor {
    switch self {
    case .high, .criticallyHigh, .veryHigh, .borderlineHigh:
      return .red
    case .low, .borderlineLow, .veryLow, .criticallyLow, .abnormal:
      return .red
    case .undetermined, .normal:
      return UIColor(resource: .neutrals600)
    }
  }
}

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
          .textStyle(ekaFont: .bodyRegular, color: .black)
      }
      
      /// Vital Range
      if let range = itemData.range, let unit = itemData.unit {
        Text("\(range) \(unit)")
          .textStyle(ekaFont: .calloutRegular, color: UIColor(resource: .neutrals400))
      }
    }
  }
  
  private func RightStackView() -> some View {
    VStack(alignment: .trailing, spacing: EkaSpacing.spacingXxxs) {
      /// Vital Interpretation Eg: High, Low
      if let displayResult = itemData.displayResult {
        Text(displayResult)
          .textStyle(ekaFont: .calloutRegular, color: getInterpretationColor() ?? .black)
      }
      
      /// Vital Value
      if let value = itemData.value {
        Text(value)
          .textStyle(ekaFont: .bodyBold, color: .black)
      }
    }
  }
  
  private var rightArrowImage: some View {
    Image(systemName: "chevron.right")
      .resizable()
      .scaledToFit()
      .frame(height: 12)
      .foregroundColor(Color(.black))
  }
}

// MARK: - Helper functions

extension VitalReadingRowView {
  func getInterpretationColor() -> UIColor? {
    guard let interpretationID = itemData.resultID else { return nil }
    let interpretationType = LabParameterResultType(rawValue: interpretationID)
    return interpretationType?.textColor
  }
}

// TODO: - To be added later

//#Preview {
//  VitalReadingRowView(itemData: <#Verified#>)
//}
