import SwiftUI
import SwiftProtoContracts
import EkaMedicalRecordsCore

typealias DocumentFilterType = Vault_Records_DocumentType

struct EditBottomSheetView: View {

  // MARK: - Properties
  
  @State private var selectedDocumentType: DocumentFilterType?
  @State private var documentDate: Date = Date()
  @State private var showAlert: Bool = false // Alert state
  @Binding var isEditBottomSheetPresented: Bool
  @Binding var record: Record?
  private let recordsRepo = RecordsRepo()
  
  // MARK: - Init
  
  init(
    isEditBottomSheetPresented: Binding<Bool>,
    record: Binding<Record?>
  ) {
    _isEditBottomSheetPresented = isEditBottomSheetPresented
    _record = record
  }
  
  // MARK: - Body
  
  var body: some View {
    VStack {
      List {
        TypeOfDocumentPickerView()
        DocumentDatePickerView()
      }
      .listStyle(.insetGrouped)
    }
    .background(.white)
    .navigationTitle("Edit Document Details")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      updateData()
    }
    .onChange(of: record) { _, _ in
      updateData()
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Save") {
          if selectedDocumentType == nil {
            showAlert = true // Show alert if document type is not selected
          } else {
            saveDocumentDetails()
          }
        }
      }
    }
    .alert("Error", isPresented: $showAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("Document type is mandatory.")
    }
  }
}

// MARK: - Subviews

extension EditBottomSheetView {
  private func TypeOfDocumentPickerView() -> some View {
    HStack {
      Text("Type of document")
        .textStyle(ekaFont: .bodyRegular, color: UIColor(resource: .neutrals1000))
      
      Text("*")
        .foregroundColor(.red) // Red asterisk
      
      Spacer()
      
      Picker("", selection: $selectedDocumentType) {
        Text("Select").tag(nil as DocumentFilterType?) // Empty selection
        ForEach(DocumentFilterType.allCases.filter { $0 != .typeUnspecified}, id: \.self) { type in
          Text(type.title)
            .tag(type)
            .font(.footnote)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .tint(.black)
    }
  }
  
  private func DocumentDatePickerView() -> some View {
    HStack {
      Text("Document Date")
        .textStyle(ekaFont: .bodyRegular, color: UIColor(resource: .neutrals1000))
      
      Spacer()
      
      DatePicker("", selection: $documentDate, displayedComponents: .date)
        .labelsHidden()
        .foregroundColor(.gray)
    }
  }
}

// MARK: - Functions

extension EditBottomSheetView {
  
  /// Used to update data in the sheet
  private func updateData() {
    setupSelectedDocumentType()
    setupDocumentDate()
  }
  
  /// Save document details
  private func saveDocumentDetails() {
    guard let record else {
      debugPrint("Record being uploaded not found for edit")
      return
    }
    /// Update record in database
    recordsRepo.updateRecord(
      recordID: record.objectID,
      documentID: record.documentID,
      documentDate: documentDate,
      documentType: selectedDocumentType?.rawValue
    )
    /// Close edit bottom sheet
    isEditBottomSheetPresented = false
  }
  
  /// Setup document type of document if available
  private func setupSelectedDocumentType() {
    if let documentType = record?.documentType,
       let documentTypeFilter = DocumentFilterType(rawValue: Int(documentType)) {
      if documentTypeFilter != .typeUnspecified { /// dont save unspecified
        selectedDocumentType = documentTypeFilter
      }
    } else {
      selectedDocumentType = nil // Default to "Select"
    }
  }
  
  /// Setup document date of document if available
  private func setupDocumentDate() {
    guard let recordDate = record?.documentDate else { return }
    documentDate = recordDate
  }
}

// TODO: - Fix preview for record database model init
//#Preview {
//  EditBottomSheetView(isEditBottomSheetPresented: .constant(true))
//}
