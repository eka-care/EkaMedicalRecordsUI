//
//  CaseFormView.swift
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

struct CaseFormView: View {
  @State private var caseType: String = ""
  @State private var date: Date = Date()
  @State private var caseName: String = ""
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.dismiss) private var dismiss
  @State private var showDatePicker: Bool = false
  @State private var showCaseTypeSheet = false
  @State private var showDiscardAlert: Bool = false
  private let recordsRepo: RecordsRepo = RecordsRepo.shared
  private let showCancelButton: Bool
  private let mode: SheetMode
  private let existingCase: CaseModel?
  
  init(
    caseName: String,
    showCancelButton: Bool = true,
    mode: SheetMode = .add,
    existingCase: CaseModel? = nil
  ) {
    _caseName = State(initialValue: caseName)
    self.showCancelButton = showCancelButton
    self.mode = mode
    self.existingCase = existingCase
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
      .navigationTitle(mode == .add ? "Create Encounter" : "Edit Encounter")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        // Only show cancel button when explicitly enabled (for modal presentation)
        if showCancelButton {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
              if mode == .edit {
                showDiscardAlert = true
              } else {
                dismiss()
              }
            }
            .foregroundStyle(Color(.ascent))
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(mode == .add ? "Create" : "Save") {
            saveCase()
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
      .alert("Discard Changes", isPresented: $showDiscardAlert) {
        Button("Cancel", role: .cancel) { }
        Button("Discard", role: .destructive) {
          dismiss()
        }
      } message: {
        Text("Are you sure you want to discard your changes?")
      }
      .onAppear {
        loadExistingCaseData()
      }
  }
  private var dateFormatted: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy"
    return formatter.string(from: date)
  }
}

// MARK: - Subviews

extension CaseFormView {
  /// Case Name VIew
  /// - Returns: View which has case name text field
  private func caseNameView() -> some View {
    HStack {
      Text("Encounter name")
      Text("*")
        .foregroundStyle(.red)
      Spacer()
      
      TextField("", text: $caseName)
        .multilineTextAlignment(.trailing)
        .foregroundColor(Color(.ascent))
        .autocorrectionDisabled()
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

extension CaseFormView {
  private func loadExistingCaseData() {
    if let existingCase = existingCase, mode == .edit {
      // Load existing case type
      if let existingCaseType = existingCase.caseType, !existingCaseType.isEmpty {
        caseType = existingCaseType
      }
      
      // Load existing date
      if let existingDate = existingCase.occuredAt {
        date = existingDate
      }
      
      // Load existing case name
      if let existingCaseName = existingCase.caseName, !existingCaseName.isEmpty {
        caseName = existingCaseName
      }
    }
  }
  
  private func saveCase() {
    if mode == .edit {
      updateCase()
    } else {
      addCase()
    }
  }
  
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
  
  private func updateCase() {
    guard let existingCase = existingCase else { return }
    
    let caseArguementModel = CaseArguementModel(
      caseType: caseType,
      name: caseName,
      updatedAt: nil,
      occuredAt: date,
      isRemoteCreated: true,
      isEdited: true
    )
    recordsRepo.updateCase(caseModel: existingCase, caseArguementModel: caseArguementModel)
  }
}

#Preview {
  CaseFormView(caseName: "")
}
