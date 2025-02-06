//
//  ChipView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 06/02/25.
//

import SwiftUI

struct ChipView: View {
  let selectionId: Int
  let title: String
  let isSelected: Bool
  let onTap: (Int) -> Void
  
  var body: some View {
    Button(action: { onTap(selectionId) }) {
      Text(title)
        .textStyle(ekaFont: .calloutRegular, color: isSelected ? .white : UIColor(resource: .neutrals600))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue : Color.white)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.5), lineWidth: isSelected ? 0 : 1)
        )
        .cornerRadius(8)
    }
    .buttonStyle(.plain)
  }
}
