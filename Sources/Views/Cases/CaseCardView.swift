//
//  CaseCardView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 21/07/25.
//

import SwiftUI
import EkaUI

struct CaseCardView: View {
  let caseName: String
  let recordCount: Int
  let date: Date?
  let caseTypeEnum: CaseTypesEnum
  var isSelected: Bool = false
  
  var body: some View {
    HStack(spacing: 0) {
      HStack(spacing: 16) {
        
        AvatarView(caseTypeEnum: caseTypeEnum)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(caseName)
            .font(.system(.body, weight: .semibold))
            .foregroundColor(isSelected ? .white : .black)
          
          Text("\(recordCount) Medical record\(recordCount == 1 ? "" : "s")")
            .font(.footnote)
            .foregroundColor(isSelected ? .white : .gray)
        }
        
        Spacer()
        
        if let date = date {
          Text(formattedDate(date))
            .font(.footnote)
            .foregroundColor(isSelected ? .white : .gray)
        }
      }
    }
    .listRowBackground(isSelected ? EkaColorTheme.primary : Color.white)
  }
  
  private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E d" // e.g. Tue 29
    return formatter.string(from: date)
  }
}
