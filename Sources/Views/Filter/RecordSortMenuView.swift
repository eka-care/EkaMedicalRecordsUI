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
            Text(option.title)
              .textStyle(ekaFont: .bodyRegular, color: .black)
            /// If no option is selected show checkmark on upload date new to old
            if selectedOption == nil, option == .dateOfUpload(sortingOrder: .newToOld) {
              checkMarkView()
            }
            /// If option is selected show that
            if option == selectedOption {
              checkMarkView()
            }
          }
        }
      }
    } label: {
      ChipView(
        selectionId: 0,
        title: getChipTitle(),
        image: UIImage(systemName: "chevron.down"),
        imageConfig: ImageConfig(
          width: 12,
          height: 12,
          color: UIColor(resource: selectedOption == nil ? .neutrals500 : .neutrals0)
        ),
        isSelected: selectedOption != nil
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
    selectedOption?.title ?? "Sort"
  }
}
