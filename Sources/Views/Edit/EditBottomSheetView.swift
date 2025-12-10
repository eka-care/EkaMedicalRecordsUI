import SwiftUI
import EkaMedicalRecordsCore
import EkaUI

enum SheetMode {
  case add
  case edit
}

struct EditFormModel {
  let documentType: MRDocumentType?
  let documentDate: Date?
  let cases: [CaseModel]
  let sheetMode: SheetMode?
  let isAbhaLinked: Bool
}

struct EditBottomSheetView: View {
  
  // MARK: - Properties
  
  @State private var selectedDocumentType: MRDocumentType?
  @State private var documentDate: Date = Date()
  @State private var showAlert: Bool = false // Alert state
  @State private var showDiscardAlert: Bool = false // Discard confirmation alert
  @State private var isAbhaLinked: Bool = true
  @Binding var isEditBottomSheetPresented: Bool
  private let recordsRepo = RecordsRepo.shared
  private let recordPresentationState: RecordPresentationState
  private let sheetMode: SheetMode?
  @State private var assignCaseText: String = "Select"
  @State private var selectedCaseModel: CaseModel?
  
  let isAbhaToggleEnabled: Bool
  
  var shouldLinkWithAbhaToggleAppear: Bool {
    CoreInitConfigurations.shared.enabledFeatures.contains(.abha)
  }
  
  private var shouldDisableAbhaToggle: Bool {
    return sheetMode == .edit && isAbhaToggleEnabled
  }
  
  // Completion handler for save action
  private let onSave: (EditFormModel) -> Void
  // MARK: - Init
  
  init(
    isEditBottomSheetPresented: Binding<Bool>,
    recordPresentationState: RecordPresentationState,
    initialData: EditFormModel,
    onSave: @escaping (EditFormModel) -> Void
  ) {
    _isEditBottomSheetPresented = isEditBottomSheetPresented
    self.recordPresentationState = recordPresentationState
    sheetMode = initialData.sheetMode
    _selectedDocumentType = .init(initialValue: initialData.documentType)
    _documentDate = .init(initialValue: initialData.documentDate ?? Date())
    _selectedCaseModel = .init(initialValue: initialData.cases.first)
    _isAbhaLinked = .init(initialValue: initialData.isAbhaLinked)
    self.isAbhaToggleEnabled = initialData.isAbhaLinked
    self.onSave = onSave
  }
  
  // MARK: - Body
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
          typeOfDocumentPickerView()
          documentDatePickerView()
          if shouldLinkWithAbhaToggleAppear {
            linkWithABHAToggleView()
          }
          
          /// If we are showing this outside the case related flow we show this
          if !recordPresentationState.isCaseRelated {
            Section(header:HStack {
              Text("Assign an encounter")
                .font(.headline)
              Spacer()
              if selectedCaseModel != nil {
                Text("Selected")
                  .font(.headline)
              }
            }
            .textCase(nil)) {
              // Wrap AssignCaseView in NavigationLink
              NavigationLink(value: "SearchableCaseListView") {
                assignCaseView()
              }
            }
          }
        }
        .listStyle(.insetGrouped)
      }
      .navigationTitle("Edit Records Details")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(for: String.self) { destination in
        if destination == "SearchableCaseListView" {
          SearchableCaseListView(
            casesPresentationState: .editRecord,
            isSearchActive: true,
            onSelectCase: { caseModel in
              selectedCaseModel = caseModel
            }
          )
          .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
        }
      }
      .navigationDestination(for: CaseFormRoute.self) { route in
        CaseFormView(
          caseName: route.prefilledName,
          showCancelButton: false
        )
        .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
      }
      .navigationDestination(for: CaseModel.self) { model in
        RecordsGridListView(
          recordPresentationState:RecordPresentationState(
            mode: recordPresentationState.mode,
            filters: RecordFilter(caseID: model.caseID)
          ),
          title: model.caseName ?? "Documents"
        )
        .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") {
            showDiscardAlert = true
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            if selectedDocumentType == nil {
              showAlert = true // Show alert if document type is not selected
            } else {
              // Prepare cases array
              let cases =  selectedCaseModel.map { [$0] } ?? []
              
              // Create result model
              let result = EditFormModel(
                documentType: selectedDocumentType,
                documentDate: documentDate,
                cases: cases,
                sheetMode: sheetMode,
                isAbhaLinked: isAbhaLinked
              )
              
              // Call completion handler with result model
              onSave(result)
              
              // Close the sheet
              isEditBottomSheetPresented = false
            }
          }
        }
      }
    }
    .background(.white)
    .alert("Error", isPresented: $showAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("Document type is mandatory.")
    }
    .alert("Discard Changes", isPresented: $showDiscardAlert) {
      Button("Cancel", role: .cancel) { }
      Button("Discard", role: .destructive) {
        isEditBottomSheetPresented = false
      }
    } message: {
      Text(sheetMode == .add ? 
           "Discard this document and your changes? The document will not be saved." : 
           "Your recent changes will not be saved if discarded.")
    }
  }
}

// MARK: - Subviews

extension EditBottomSheetView {

  private func linkWithABHAToggleView() -> some View {
    Toggle(isOn: $isAbhaLinked) {
      Text("Link with your ABHA")
        .newTextStyle(
        ekaFont: .bodyRegular,
        color: UIColor(resource: .labelsPrimary))
      }
    .disabled(shouldDisableAbhaToggle ? true : false)
    .allowsHitTesting(shouldDisableAbhaToggle ? false : true)
    .opacity(shouldDisableAbhaToggle ? 0.5 : 1.0)
    .tint(Color(UIColor.systemGreen))
  }
    
  private func typeOfDocumentPickerView() -> some View {
    HStack {
      Text("Type of Record")
        .newTextStyle(ekaFont: .bodyRegular, color: UIColor(resource: .labelsPrimary))
      Text("*")
        .foregroundColor(.red) // Red asterisk
      Spacer()
      Picker("", selection: $selectedDocumentType) {
        Text("Select").tag(nil as MRDocumentType?) // Empty selection
        ForEach(documentTypesList.filter { $0 != MRDocumentType.typeAll}, id: \.self) { type in
          Text(type.filterName)
            .tag(type)
            .font(.footnote)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .tint(.black)
    }
  }
  
  private func documentDatePickerView() -> some View {
    HStack {
      Text("Record Date")
        .newTextStyle(ekaFont: .bodyRegular, color: UIColor(resource: .labelsPrimary))
      
      Spacer()
      
      DatePicker("", selection: $documentDate, in: ...Date(), displayedComponents: .date)
        .labelsHidden()
        .foregroundColor(.gray)
        
    }
  }
  
  private func assignCaseView() -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text("Select or create an encounter")
          .newTextStyle(ekaFont: .bodyRegular, color: UIColor(resource: .labelsPrimary))
      }
      
      Spacer()
      
      Text(selectedCaseModel?.caseName ?? "Select")
        .newTextStyle(ekaFont: .bodyRegular, color:  selectedCaseModel == nil ?  UIColor(resource: .labelsQuaternary): UIColor(resource: .ascent))
    }
  }
}
