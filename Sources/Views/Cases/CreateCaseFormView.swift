//
//  CreateCaseFormView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 21/07/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

struct CaseFormRoute: Hashable {
  let prefilledName: String
}

struct CreateCaseFormView: View {
  @State private var caseType: String = ""
  @State private var date: Date = Date()
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.dismiss) private var dismiss
  @State private var showDatePicker: Bool = false
  @State private var showCaseTypeSheet = false
  private let caseName: String
  private let recordsRepo: RecordsRepo = RecordsRepo.shared
  private let showCancelButton: Bool
  
  init(
    caseName: String,
    showCancelButton: Bool = true
  ) {
    self.caseName = caseName
    self.showCancelButton = showCancelButton
    // For preview to work
    EkaUI.registerFonts()
  }
  
  var body: some View {
      Form {
        Section {
          caseNameView()
          caseTypeView()
          caseDateView()
        }
        
        caseInformationSection()
      }
      .background(Color(.fillsTertiary))
      .navigationTitle("Create Encounter")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        // Only show cancel button when explicitly enabled (for modal presentation)
        if showCancelButton {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
              dismiss()
            }
            .foregroundStyle(Color(.ascent))
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Create") {
            addCase()
            dismiss()
          }
          .foregroundStyle(Color(.ascent))
        }
      }
      .sheet(isPresented: $showCaseTypeSheet) {
        CaseTypeSelectionView(selectedCase: $caseType)
          .environment(\.managedObjectContext, viewContext)
      }
      .sheet(isPresented: $showDatePicker) {
        DatePicker("Select Date", selection: $date, displayedComponents: .date)
          .datePickerStyle(.wheel)
          .labelsHidden()
          .presentationDetents([.medium])
          .padding()
      }
  }
  private var dateFormatted: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy"
    return formatter.string(from: date)
  }
}

// MARK: - Subviews

extension CreateCaseFormView {
  /// Case Name VIew
  /// - Returns: View which has case name text field
  private func caseNameView() -> some View {
    HStack {
      Text("Encounter name")
      Text("*")
        .foregroundStyle(.red)
      Spacer()
      
      Text(caseName)
        .newTextStyle(ekaFont: .bodyRegular, color: UIColor(resource: .ascent))
    }
  }
  private func caseTypeView() -> some View {
    HStack {
      Text("Encounter type")
      Spacer()
      Text(caseType.isEmpty ? "Select/add" : caseType)
        .foregroundColor(caseType.isEmpty ? .gray : Color(.ascent))
    }
    .contentShape(Rectangle())
    .onTapGesture {
      showCaseTypeSheet = true
    }
  }
  private func caseDateView() -> some View {
    HStack {
      Text("Date")
      Spacer()
      Text(dateFormatted)
        .foregroundColor(Color(.ascent))
    }
    .contentShape(Rectangle())
    .onTapGesture {
      showDatePicker = true
    }
  }
  private func caseInformationSection() -> some View {
    Section {
      HStack(alignment: .top, spacing: 10) {
        Image(systemName: "info.circle")
          .foregroundColor(.gray)
        Text("Use a “Encounter” to organize all documents related to a medical event, whether it’s a doctor visit, hospital admission, illness, or surgery. For easy access in one place.")
          .font(.footnote)
          .foregroundColor(.gray)
      }
      .padding(.vertical, 8)
    }
    .listRowBackground(Color(.fillsTertiary))
  }
}

// MARK: - Helper Functions

extension CreateCaseFormView {
  private func addCase() {
    let caseModel = CaseArguementModel(
      caseId: UUID().uuidString,
      caseType: caseType,
      oid: CoreInitConfigurations.shared.primaryFilterID,
      name: caseName,
      occuredAt: date,
      status: .active
    )
    recordsRepo.addCase(caseArguementModel: caseModel)
  }
}

#Preview {
  CreateCaseFormView(caseName: "")
}
