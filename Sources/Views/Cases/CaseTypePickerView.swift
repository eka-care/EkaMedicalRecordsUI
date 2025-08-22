//
//  CaseTypePickerView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 21/07/25.
//

import SwiftUI

struct CaseTypePickerView: View {
  @Environment(\.dismiss) var dismiss
  @Binding var selectedType: String
  
  var body: some View {
    NavigationView {
      List {
        ForEach(["General", "Surgery", "Check-up", "Emergency", "Other"], id: \.self) { type in
          Button {
            selectedType = type
            dismiss()
          } label: {
            HStack {
              Text(type)
              if selectedType == type {
                Spacer()
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
      .navigationTitle("Select Case Type")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
  }
}
