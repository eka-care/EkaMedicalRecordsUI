import SwiftUI
import EkaMedicalRecordsCore
import EkaUI

struct EditBottomSheetView: View {
  
  // MARK: - Properties
  
  @State private var selectedDocumentType: RecordDocumentType?
  @State private var documentDate: Date = Date()
  @State private var showAlert: Bool = false // Alert state
  @Binding var isEditBottomSheetPresented: Bool
  @Binding var record: Record?
  private let recordsRepo = RecordsRepo()
  private let recordPresentationState: RecordPresentationState
  @State private var assignCaseText: String = "Select"
  @State private var selectedCaseModel: CaseModel?
  
  // MARK: - Init
  
  init(
    isEditBottomSheetPresented: Binding<Bool>,
    record: Binding<Record?>,
    recordPresentationState: RecordPresentationState
  ) {
    _isEditBottomSheetPresented = isEditBottomSheetPresented
    _record = record
    self.recordPresentationState = recordPresentationState
  }
  
  // MARK: - Body
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
          TypeOfDocumentPickerView()
          DocumentDatePickerView()
          /// If we are showing this outside the case related flow we show this
          if !recordPresentationState.isCaseRelated {
            Section(header:HStack {
              Text("Assign a medical case")
                .font(.headline)
              Spacer()
              Text("Selected")
                .font(.headline)
            }
            .textCase(nil)) {
              // Wrap AssignCaseView in NavigationLink
              NavigationLink(value: "SearchableCaseListView") {
                AssignCaseView()
              }
            }
          }
        }
        .listStyle(.insetGrouped)
      }
      .navigationTitle("Edit Document Details")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(for: String.self) { destination in
        if destination == "SearchableCaseListView" {
          SearchableCaseListView(
            recordsRepo: recordsRepo,
            casesPresentationState: .editRecord,
            isSearchActive: true,
            onSelectCase: { caseModel in
              assignCaseText = caseModel.caseName ?? ""
              selectedCaseModel = caseModel
            }
          )
          .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
        }
      }
      .navigationDestination(for: CaseFormRoute.self) { route in
        CreateCaseFormView(
          caseName: route.prefilledName,
          recordsRepo: recordsRepo
        )
        .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
      }
      .navigationDestination(for: CaseModel.self) { model in
        RecordsGridListView(
          recordsRepo: recordsRepo,
          recordPresentationState:RecordPresentationState(
            mode: recordPresentationState.mode,
            filters: RecordFilter(caseID: model.caseID)
          ),
          title: model.caseName ?? "Documents"
        )
        .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
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
    }
    .background(.white)
    .onAppear {
      updateData()
    }
    .onChange(of: record) { _, _ in
      updateData()
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
        .newTextStyle(ekaFont: .bodyRegular, color: UIColor(resource: .labelsPrimary))
      
      Text("*")
        .foregroundColor(.red) // Red asterisk
      
      Spacer()
      
      Picker("", selection: $selectedDocumentType) {
        Text("Select").tag(nil as RecordDocumentType?) // Empty selection
        ForEach(RecordDocumentType.allCases.filter { $0 != .typeAll}, id: \.self) { type in
          Text(type.filterName)
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
        .newTextStyle(ekaFont: .bodyRegular, color: UIColor(resource: .labelsPrimary))
      
      Spacer()
      
      DatePicker("", selection: $documentDate, displayedComponents: .date)
        .labelsHidden()
        .foregroundColor(.gray)
    }
  }
  
  private func AssignCaseView() -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text("Select/Create case")
          .newTextStyle(ekaFont: .bodyRegular, color: UIColor(resource: .labelsPrimary))
      }
      
      Spacer()
      
      Text(assignCaseText)
        .newTextStyle(ekaFont: .bodyRegular, color:  assignCaseText == "Select" ?  UIColor(resource: .labelsQuaternary): UIColor(resource: .ascent))
    }
  }
}

// MARK: - Functions

extension EditBottomSheetView {
  
  /// Used to update data in the sheet
  private func updateData() {
    setupSelectedDocumentType()
    setupDocumentDate()
    setupCaseData()
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
      documentType: selectedDocumentType?.intValue,
      caseModel: selectedCaseModel
    )
    /// Close edit bottom sheet
    isEditBottomSheetPresented = false
  }
  
  /// Setup document type of document if available
  private func setupSelectedDocumentType() {
    if let documentType = record?.documentType,
       let documentTypeFilter = RecordDocumentType.from(intValue: Int(documentType)) {
      if documentTypeFilter != .typeAll { /// dont save unspecified
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
  
  /// Used to setup case data
  private func setupCaseData() {
    guard let record,
          let casesAttached = record.toCaseModel as? Set<CaseModel>,
          casesAttached.count == 1,
          let caseModel = casesAttached.first else {
      return
    }
    
    assignCaseText = caseModel.caseName ?? "Select"
    selectedCaseModel = caseModel
  }
}

// TODO: - Fix preview for record database model init
//#Preview {
//  EditBottomSheetView(isEditBottomSheetPresented: .constant(true))
//}
