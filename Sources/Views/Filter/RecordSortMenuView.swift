//
//  RecordSortMenuView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 19/06/25.
//

import SwiftUI

struct RecordSortMenuView: View {
  @Binding var selectedOption: RecordSortOptions?
  
  var body: some View {
    Menu {
      ForEach(RecordSortOptions.allCases, id: \.self) { option in
        Button {
          selectedOption = option
        } label: {
          HStack {
            Text(option.displayTitle)
              .textStyle(ekaFont: .bodyRegular, color: .black)
            if option == selectedOption ?? .dateOfUpload {
                checkMarkView()
            }
          }
        }
      }
    } label: {
      ChipView(
        selectionId: "",
        title: getChipTitle(),
        image: UIImage(systemName: "chevron.down"),
        imageConfig: ImageConfig(
          width: 12,
          height: 12,
          color: UIColor(resource: (selectedOption?.isDefault ?? true) ? .neutrals500 : .neutrals0)
        ),
        isSelected: !(selectedOption?.isDefault ?? true)
      ) {_ in}
    }
  }
}

// MARK: - Subview

extension RecordSortMenuView {
  private func checkMarkView() -> some View {
    Image(systemName: "checkmark")
      .resizable()
      .scaledToFit()
      .frame(width: 12, height: 12, alignment: .center)
  }
}

extension RecordSortMenuView {
  func getChipTitle() -> String {
    "Sort by: \(selectedOption?.title ?? RecordSortOptions.dateOfUpload.title)"
  }
}
