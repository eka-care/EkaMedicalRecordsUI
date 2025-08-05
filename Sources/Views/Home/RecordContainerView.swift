//
//  RecordContainerView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 18/07/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

public enum RecordPresentationState: Equatable {
  case dashboard /// Full medical records dashboard state
  case displayAll /// Display All medical records state
  case picker /// Medical records picker state
  case caseRelatedRecordsView(caseID: String?) /// Medical records related to a case
  
  var title: String {
    switch self {
    case .dashboard:
      return ""
    case .displayAll:
      return InitConfiguration.shared.recordsTitle ?? "All"
    case .picker:
      return InitConfiguration.shared.recordsTitle ?? "Select"
    case .caseRelatedRecordsView:
      return "Documents"
    }
  }
  
  var isCaseRelated: Bool {
    if case .caseRelatedRecordsView = self {
      return true
    }
    return false
  }
  
  var associatedCaseID: String? {
    if case let .caseRelatedRecordsView(caseID) = self {
      return caseID
    }
    return nil
  }
}

public typealias RecordItemsCallback = (([RecordPickerDataModel]) -> Void)?

enum RecordTab: CaseIterable, Hashable {
  case records
  case cases
  
  var title: String {
    switch self {
    case .records:
      return "All files"
    case .cases:
      return "Medical Cases"
    }
  }
  
  var systemImage: String {
    switch self {
    case .records:
      return "doc.fill"
    case .cases:
      return "folder.fill"
    }
  }
}

enum FullScreenModal: Identifiable {
    case record(Record)
    case newCase(String)

    var id: String {
        switch self {
        case .record(let record):
            return "record-\(record.id)"
        case .newCase(let name):
            return "newCase-\(name)"
        }
    }

    var record: Record? {
        if case .record(let record) = self {
            return record
        }
        return nil
    }

    var caseName: String? {
        if case .newCase(let name) = self {
            return name
        }
        return nil
    }
}

// MARK: - Main Container View
public struct RecordContainerView: View {
  // MARK: - State Management
  @StateObject private var viewModel = RecordContainerViewModel()
  @Environment(\.dismiss) private var dismiss
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.verticalSizeClass) private var verticalSizeClass
  
  // MARK: - Properties
  private let recordsRepo = RecordsRepo()
  private let didSelectPickerDataObjects: RecordItemsCallback
  private let recordPresentationState: RecordPresentationState
  
  // MARK: - Computed Properties
  private var isCompact: Bool {
    horizontalSizeClass == .compact
  }
  
  private var isRegular: Bool {
    horizontalSizeClass == .regular
  }
  
  private var shouldUseTabView: Bool {
    isCompact || verticalSizeClass == .compact
  }
  
  // MARK: - Initializer
  public init(
    didSelectPickerDataObjects: RecordItemsCallback = nil,
    recordPresentationState: RecordPresentationState = .displayAll
  ) {
    self.didSelectPickerDataObjects = didSelectPickerDataObjects
    self.recordPresentationState = recordPresentationState
    EkaUI.registerFonts()
  }
  
  // MARK: - Body
  public var body: some View {
    Group {
      if shouldUseTabView {
        compactLayout
      } else {
        regularLayout
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }
    .navigationDestination(for: CaseModel.self, destination: caseDestination)
    .navigationDestination(for: CaseFormRoute.self, destination: caseFormDestination)
    .navigationDestination(for: Record.self, destination: recordDestination)
   
    .fullScreenCover(item: $viewModel.activeModal) { modal in
      if case let .record(record) = modal {
        NavigationStack{
          RecordView(record: record)
        }
      }
      if case let .newCase(name) = modal {
          CreateCaseFormView(
              caseName: name,
              recordsRepo: recordsRepo
          )
          .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
      }
    }

    .onChange(of: viewModel.isSearchFocused, { oldValue, newValue in
      handleSearchFocusChange(oldValue,newValue)
    })
    .onChange(of: viewModel.selectedTab, { oldValue, newValue in
      handleTabChange(oldValue, newValue)
    })
    
    .onChange(of: viewModel.selectedRecord) {oldValue, newValue in
        if let record = newValue {
          viewModel.activeModal = .record(record)
        }
    }

    .onChange(of: viewModel.createNewCase) { oldValue, newValue in
        if let name = newValue {
          viewModel.activeModal = .newCase(name)
        }
    }
    
    .onAppear {
      viewModel.configure(
        recordsRepo: recordsRepo,
        presentationState: recordPresentationState
      )
    }
    
  }
}

// MARK: - Layout Views
extension RecordContainerView {
  @ViewBuilder
  private var compactLayout: some View {
    VStack(spacing: 0) {
      segmentedControl
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.bottom, 16)
      contentView
    }
  }
  
  @ViewBuilder
  private var regularLayout: some View {
    NavigationSplitView(columnVisibility: $viewModel.columnVisibility) {
      sidebarContent
    } detail: {
      Group {
      if viewModel.isSearchFocused {
        CasesListViewOutSideSearch(
          recordsRepo: recordsRepo,
          isSearchActive: false,
          isSearchEnabled: false,
          caseSearchText: $viewModel.searchText,
          createNewCase: $viewModel.createNewCase,
          selectedCase: $viewModel.selectedCase,
          shouldSelectDefaultCase: viewModel.isSearchFocused ? false : true,
          
          onSelectCase: { caseModel in
            viewModel.isSearchFocused = false
            viewModel.selectedTab = .cases
            viewModel.selectedCase = caseModel
          }
        )
        .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
      } else {
        detailContent
      }
    }
    .searchable(
      text: $viewModel.searchText,
      isPresented: $viewModel.isSearchFocused,
      placement: searchPlacement,
      prompt: searchPrompt
    )}
  }
  
  @ViewBuilder
  private var sidebarContent: some View {
    VStack(spacing: 0) {
      segmentedControl
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.bottom, 16)
      sidebarMainContent
    }
    .background(Color(.systemGroupedBackground))
  }
  
  @ViewBuilder
  private var sidebarMainContent: some View {
    switch viewModel.selectedTab {
    case .records:
      ContentUnavailableView(
        "All Records files ",
        systemImage: "righ",
        description: Text("check out in right panel")
      )
      Spacer()
      
    case .cases:
      CasesListViewOutSideSearch(
        recordsRepo: recordsRepo,
        isSearchActive: false,
        isSearchEnabled: false,
        selectedCase: $viewModel.selectedCase,
        shouldSelectDefaultCase: viewModel.isSearchFocused ? false : true,
        onSelectCase: { caseModel in
          viewModel.selectedCase = caseModel
        }
      )
      .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
    }
  }
  
  @ViewBuilder
  private var detailContent: some View {
    
    if viewModel.selectedCase == nil && viewModel.selectedTab == .cases {
      Text("A case needs to be created first.")
    } else {
      RecordsGridListView(
        recordsRepo: recordsRepo,
        recordPresentationState: {
          if let caseId = viewModel.selectedCase?.caseID {
            return .caseRelatedRecordsView(caseID: caseId)
          } else {
            return .displayAll
          }
        }(),
        title: "Documents",
        selectedRecord: $viewModel.selectedRecord,
      )
      .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
      .navigationDestination(for: Record.self, destination: recordDestination)
    }
  }
  
  @ViewBuilder
  private var contentView: some View {
    switch viewModel.selectedTab {
    case .records:
      RecordsGridListView(
        recordsRepo: recordsRepo,
        recordPresentationState: recordPresentationState,
        title: recordPresentationState.title,
        pickerSelectedRecords: $viewModel.pickerSelectedRecords
      )
      .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
      
    case .cases:
      CasesListView(recordsRepo: recordsRepo)
        .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
    }
  }
}

// MARK: - UI Components
extension RecordContainerView {
  @ViewBuilder
  private var segmentedControl: some View {
    Picker("Tab Selection", selection: $viewModel.selectedTab) {
      ForEach(RecordTab.allCases, id: \.self) { tab in
        Label(tab.title, systemImage: tab.systemImage)
          .labelStyle(.titleOnly)
          .tag(tab)
      }
    }
    .pickerStyle(.segmented)
  }
  
  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button("Close") {
        dismiss()
      }
      .foregroundStyle(Color(.systemBlue))
    }
    
    ToolbarItem(placement: .principal) {
      Text(InitConfiguration.shared.recordsTitle ?? recordPresentationState.title)
        .font(.headline)
    }
    
    ToolbarItem(placement: .topBarTrailing) {
      if viewModel.pickerSelectedRecords.count > 0 {
        Button("Done") {
          handleDoneButtonPressed()
        }
        .fontWeight(.semibold)
      }
    }
  }
}

// MARK: - Computed Properties for UI
extension RecordContainerView {
  private var searchPlacement: SearchFieldPlacement {
    if isRegular {
      return .navigationBarDrawer(displayMode: .always)
    } else {
      return .automatic
    }
  }
  
  private var searchPrompt: String {
    switch viewModel.selectedTab {
    case .records:
      return "Search records"
    case .cases:
      return "Search or add new case"
    }
  }
}

// MARK: - Navigation Destinations
extension RecordContainerView {
  @ViewBuilder
  private func caseDestination(for model: CaseModel) -> some View {
    RecordsGridListView(
      recordsRepo: recordsRepo,
      recordPresentationState: .caseRelatedRecordsView(caseID: model.caseID),
      title: model.caseName ?? "Documents"
    )
    .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
  }
  
  @ViewBuilder
  private func caseFormDestination(for route: CaseFormRoute) -> some View {
    CreateCaseFormView(
      caseName: route.prefilledName,
      recordsRepo: recordsRepo
    )
    .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
  }
  
  @ViewBuilder
  private func recordDestination(for record: Record) -> some View {
    RecordView(record: record)
  }
}

// MARK: - Event Handlers
extension RecordContainerView {
  private func handleSearchFocusChange(_ oldValue: Bool, _ newValue: Bool) {
    if isRegular {
      viewModel.columnVisibility = newValue ? .detailOnly : .doubleColumn
    }
  }
  
  private func handleTabChange(_ oldValue: RecordTab, _ newValue: RecordTab) {
    viewModel.refreshData.toggle()
    switch newValue {
      case .records:
      viewModel.selectedCase = nil
    default:
      break
    }
  }
  
  private func handleDoneButtonPressed() {
    viewModel.isDownloading = true
    dismiss()
    
    setPickerSelectedObjects(selectedRecords: viewModel.pickerSelectedRecords) { pickedRecords in
      viewModel.isDownloading = false
      didSelectPickerDataObjects?(pickedRecords)
    }
  }
  
  private func setPickerSelectedObjects(
    selectedRecords: [Record],
    completion: RecordItemsCallback
  ) {
    var pickerObjects: [RecordPickerDataModel] = []
    recordsRepo.fetchRecordsMetaData(for: selectedRecords) { documentURIs in
      for (index, record) in selectedRecords.enumerated() {
        pickerObjects.append(
          RecordPickerDataModel(
            image: record.thumbnail,
            documentID: record.documentID,
            documentPath: documentURIs[index]
          )
        )
      }
      completion?(pickerObjects)
    }
  }
}

// MARK: - View Model
@MainActor
final class RecordContainerViewModel: ObservableObject {
  @Published var selectedTab: RecordTab = .records
  @Published var pickerSelectedRecords: [Record] = []
  @Published var isDownloading: Bool = false
  @Published var searchText: String = ""
  @Published var columnVisibility = NavigationSplitViewVisibility.doubleColumn
  @Published var selectedTag: String?
  @Published var selectedCase: CaseModel?
  @Published var isSearchFocused: Bool = false
  @Published var refreshData: Bool = false
  @Published var selectedRecord: Record?
  @Published var createNewCase: String? = nil
  @Published var activeModal: FullScreenModal?
  private var recordsRepo: RecordsRepo?
  private var presentationState: RecordPresentationState = .displayAll
  
  func configure(recordsRepo: RecordsRepo, presentationState: RecordPresentationState) {
    self.recordsRepo = recordsRepo
    self.presentationState = presentationState
  }
}
