//
//  RecordContainerView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 18/07/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

public struct RecordPresentationState: Equatable {
  public var mode: RecordMode
  public var filters: RecordFilter

  public init(mode: RecordMode, filters: RecordFilter = RecordFilter()) {
    self.mode = mode
    self.filters = filters
  }

  public var title: String {
    switch mode {
    case .dashboard:
      return ""
    case .displayAll, .copyVitals:
      return InitConfiguration.shared.recordsTitle ?? "All"
    case .picker(let maxCount):
      let baseTitle = InitConfiguration.shared.recordsTitle ?? "Select"
      return "\(baseTitle) (Max: \(maxCount))"
    }
  }

  public var associatedCaseID: String? {
    filters.caseID
  }

  public var isPicker: Bool {
    if case .picker = mode {
      return true
    }
    return false
  }
  
  public var isCopyVitals: Bool {
    if case .copyVitals = mode {
      return true
    }
    return false
  }
  
  public var pickerMaxCount: Int? {
    if case .picker(let maxCount) = mode {
      return maxCount
    }
    return nil
  }

  public var isCaseRelated: Bool {
    filters.caseID != nil
  }

  public var isDashboard: Bool {
    if case .dashboard = mode {
      return true
    }
    return false
  }

  public var isDisplayAll: Bool {
    if case .displayAll = mode {
      return true
    }
    return false
  }
}

/// document Type list - initialized properly in RecordContainerView
public var documentTypesList: [MRDocumentType] = []

public struct RecordFilter: Equatable {
  public var caseID: String?
  public var tags: [String]?

  public init(caseID: String? = nil,tags: [String]? = nil) {
    self.caseID = caseID
    self.tags = tags
  }
}

public enum RecordMode: Equatable {
  case dashboard
  case displayAll
  case copyVitals
  case picker(maxCount: Int)
}

// MARK: - Convenience Initializers
extension RecordPresentationState {
  /// Creates a picker state with a maximum selection count
  public static func picker(maxCount: Int, filters: RecordFilter = RecordFilter()) -> RecordPresentationState {
    return RecordPresentationState(mode: .picker(maxCount: maxCount), filters: filters)
  }
}

public typealias RecordItemsCallback = (([RecordPickerDataModel]) -> Void)?
public typealias CopyVitalsCallback = (([Verified]) -> Void)?

public enum RecordTab: CaseIterable, Hashable {
  case records
  case cases
  
  var title: String {
    switch self {
    case .records:
      return "All Records"
    case .cases:
      return "All Encounters"
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
  private let recordsRepo: RecordsRepo = RecordsRepo.shared
  private let didSelectPickerDataObjects: RecordItemsCallback
  private let onCopyVitals: CopyVitalsCallback
  private let initialRecordPresentationState: RecordPresentationState
  private var selectedFilterInAllRecords: [String] = []
  private var selectedDocTypeInAllRecords: String? = nil
  @StateObject private var networkMonitor = NetworkMonitor.shared
  @State private var refreshProgress: Double = 0.0
  @State private var showProgress = false
  @State private var progressTimer: Timer?
  
  // MARK: - Initializer
  public init(
    recordPresentationState: RecordPresentationState = RecordPresentationState(mode: .displayAll),
    didSelectPickerDataObjects: RecordItemsCallback = nil,
    onCopyVitals: CopyVitalsCallback = nil,
    selectedTags: [String] = [],
    selectedRecordType: MRDocumentType? = nil
  ) {
    self.didSelectPickerDataObjects = didSelectPickerDataObjects
    self.onCopyVitals = onCopyVitals
    self.initialRecordPresentationState = recordPresentationState
    self.selectedFilterInAllRecords = selectedTags
    self.selectedDocTypeInAllRecords = selectedRecordType?.id
    EkaUI.registerFonts()
    try? Fonts.registerAllFonts()
  }
  
  // MARK: - Body

  public var body: some View {
    VStack(spacing: 0) {
      if viewModel.documentTypeReceived && viewModel.databaseReady {
        Group {
          if viewModel.shouldUseTabView(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass) {
            compactLayout
          } else {
            regularLayout
          }
        }
      } else {
        ProgressView()
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }
    .navigationDestination(for: CaseModel.self, destination: caseDestination)
    .navigationDestination(for: CaseFormRoute.self, destination: caseFormDestination)
    .navigationDestination(for: Record.self, destination: recordDestination)
    .onChange(of: viewModel.isForceRefreshing) { _, newValue in
      if newValue {
        recordsRepo.requestForceRefresh { respnonse, apiCode in
          if apiCode != 202 {
//            viewModel.isForceRefreshing = false
          }
        }
      } else {
        recordsRepo.getUpdatedAtAndStartCases { _ in
          recordsRepo.getUpdatedAtAndStartFetchRecords { _, lastSourceRefreshedTime in
            DispatchQueue.main.async {
              if let dateAndTime = lastSourceRefreshedTime {
                self.viewModel.lastSourceRefreshedAt = Date(timeIntervalSince1970: Double(dateAndTime))
              } else {
                self.viewModel.lastSourceRefreshedAt = nil
              }
            }
          }
        }
      }
    }
   
    .fullScreenCover(item: $viewModel.activeModal, onDismiss: {
      viewModel.activeModal = nil
      viewModel.selectedRecord = nil
    }) { modal in
      if case let .record(record) = modal {
        NavigationStack{
          RecordView(record: record, recordPresentationState: viewModel.recordPresentationState ,onCopyVitals: onCopyVitals)
        }
      }
      if case let .newCase(name) = modal {
        NavigationStack{
          CreateCaseFormView(
            caseName: name,
            showCancelButton: true
          )
          .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
        }
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
    
    .onChange(of: viewModel.selectedCase) { oldValue, newValue in
      let currentMode = self.viewModel.recordPresentationState.mode
      let newCaseID = newValue?.caseID
      self.viewModel.recordPresentationState = RecordPresentationState(mode: currentMode, filters: RecordFilter(caseID: newCaseID))
      self.viewModel.selectedDocTypeInEncounters = nil
    }

    .onChange(of: viewModel.createNewCase) { oldValue, newValue in
        if let name = newValue {
          viewModel.activeModal = .newCase(name)
        }
    }
    .onChange(of: networkMonitor.isOnline) { _ , _ in
      recordsRepo.syncUnsyncedCases { _ in
        recordsRepo.syncUnuploadedRecords {  _ in
        }
      }
    }
    .onReceive(
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextObjectsDidChange,
            object: recordsRepo.databaseManager.container.viewContext
        ).debounce(for: .milliseconds(200), scheduler: RunLoop.main)
    ) { _ in
        viewModel.updateDocumentCount()
    }
    
     .onAppear {
      viewModel.configure(presentationState: initialRecordPresentationState, selectedFilterInAllRecords: selectedFilterInAllRecords, selectedDocTypeInAllRecords: selectedDocTypeInAllRecords)
      viewModel.loadData()
    }
    .onDisappear {
      // Clean up timer to prevent memory leaks
      showProgress = false
      progressTimer?.invalidate()
      progressTimer = nil
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
      if showProgress {
        ProgressView(value: refreshProgress, total: 1.0)
          .progressViewStyle(LinearProgressViewStyle())
          .padding(2)
          .transition(.opacity)
      }
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
        CasesListView(
          caseSearchText: $viewModel.searchText,
          createNewCase: $viewModel.createNewCase,
          selectedCase: $viewModel.selectedCase,
          shouldSelectDefaultCase: viewModel.isSearchFocused ? false : true,
          
          onSelectCase: { caseModel in
            viewModel.isSearchFocused = false
            viewModel.selectedCase = caseModel
            viewModel.selectedTab = .cases
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
    VStack(spacing: 10) {
      segmentedControl
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.bottom, 16)
      sidebarMainContent
      LastUpdatedView(isRefreshing: $viewModel.isForceRefreshing, lastUpdated: $viewModel.lastSourceRefreshedAt)
    }
    .background(Color(.systemGroupedBackground))
  }
  
  @ViewBuilder
  private var sidebarMainContent: some View {
    switch viewModel.selectedTab {
    case .records:
      ContentUnavailableView(
        "All Medical Records ",
        systemImage: "righ",
        description: Text("See on the right panel")
      )
      Spacer()
      
    case .cases:
      CasesListView(
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
        recordPresentationState: viewModel.recordPresentationState,
        title: "Documents",
        pickerSelectedRecords: $viewModel.pickerSelectedRecords,
        selectedRecord: $viewModel.selectedRecord,
        selectFilter: $viewModel.selectedFilterInAllRecords,
        selectedDocType: $viewModel.selectedDocTypeInAllRecords
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
        recordPresentationState: viewModel.recordPresentationState,
        title: viewModel.recordPresentationState.title,
        pickerSelectedRecords: $viewModel.pickerSelectedRecords,
        selectFilter: $viewModel.selectedFilterInAllRecords,
        selectedDocType: $viewModel.selectedDocTypeInAllRecords
      )
      .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
      
    case .cases:
      SearchableCaseListView()
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
    if !viewModel.recordPresentationState.isDashboard && !viewModel.recordPresentationState.isCopyVitals {
      if !viewModel.isSearchFocused {
        ToolbarItem(placement: .topBarLeading) {
          Button("Close") {
            dismiss()
          }
        }
      }
    }
    ToolbarItem(placement: .principal) {
      Text(titleWithSelectionInfo)
        .font(.headline)
    }
    
    
    if !UIDevice.current.isIPad || !viewModel.pickerSelectedRecords.isEmpty {
      ToolbarItem(placement: .topBarTrailing) {
        HStack {
          // Refresh button (only on iPhone)
          refreshButton

          // Done button (only when records are selected)
          doneButton
        }
      }
    }
  }
  
  @ViewBuilder
  private var refreshButton: some View {
    if !UIDevice.current.isIPad {
      Button(action: startRefreshWithProgress) {
        Image(systemName: "arrow.clockwise")
      }
      .disabled(showProgress)
    }
  }

  @ViewBuilder
  private var doneButton: some View {
    if !viewModel.pickerSelectedRecords.isEmpty {
      Button("Done", action: handleDoneButtonPressed)
        .fontWeight(.semibold)
    }
  }
  
  private var titleWithSelectionInfo: String {
    if viewModel.recordPresentationState.isPicker,
       case .picker(let maxCount) = viewModel.recordPresentationState.mode {
      let baseTitle = "Select Records"
      return "\(baseTitle) (\(viewModel.pickerSelectedRecords.count)/\(maxCount))"
    }
    
    // Show count next to title for non-picker modes
    let title = viewModel.recordPresentationState.title
    if !title.isEmpty {
      return "\(title) (\(viewModel.recordsCount))"
    }
    return title
  }
}

// MARK: - Computed Properties for UI
extension RecordContainerView {
  private var searchPlacement: SearchFieldPlacement {
    if viewModel.isRegular(horizontalSizeClass: horizontalSizeClass) {
      return .navigationBarDrawer(displayMode: .always)
    } else {
      return .automatic
    }
  }
  
  private var searchPrompt: String {
      return "Search or add an encounter"
    }
}

// MARK: - Navigation Destinations
extension RecordContainerView {
  @ViewBuilder
  private func caseDestination(for model: CaseModel) -> some View {
    RecordsGridListView(
      recordPresentationState: RecordPresentationState(mode: viewModel.recordPresentationState.mode, filters: RecordFilter(caseID: model.caseID)),
      title: model.caseName ?? "Documents",
      pickerSelectedRecords: $viewModel.pickerSelectedRecords,
      selectFilter: $viewModel.selectedFilterInEncounters,
      selectedDocType: $viewModel.selectedDocTypeInEncounters
    )
    .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
    .onAppear {
      viewModel.selectedDocTypeInEncounters = nil
    }
  }
  
  @ViewBuilder
  private func caseFormDestination(for route: CaseFormRoute) -> some View {
    CreateCaseFormView(
      caseName: route.prefilledName,
      showCancelButton: false
    )
    .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
  }
  
  @ViewBuilder
  private func recordDestination(for record: Record) -> some View {
    RecordView(record: record,recordPresentationState: viewModel.recordPresentationState ,onCopyVitals: onCopyVitals)
  }
}

// MARK: - Event Handlers
extension RecordContainerView {
  private func startRefreshWithProgress() {
    // Start the refresh process
    viewModel.isForceRefreshing = true
    
    // Reset and show progress
    refreshProgress = 0.0
    showProgress = true
    
    // Cancel any existing timer
    progressTimer?.invalidate()
    
    // Create incremental progress updates
    let totalDuration: Double = 10.0 // 10 seconds
    let updateInterval: Double = 0.1 // Update every 100ms
    let increment = 1.0 / (totalDuration / updateInterval) // Progress increment per update
    
    progressTimer = Timer(timeInterval: updateInterval, repeats: true) { timer in
      withAnimation(.easeInOut(duration: updateInterval)) {
        refreshProgress = min(refreshProgress + increment, 1.0)
      }
      
      // Check if we've reached completion
      if refreshProgress >= 1.0 {
        timer.invalidate()
        refreshProgress = 1.0
        
        // Hide progress after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          withAnimation(.easeOut(duration: 0.3)) {
            showProgress = false
            refreshProgress = 0.0
          }
          viewModel.isForceRefreshing = false
        }
      }
    }
    
    // Add timer to RunLoop with common mode to prevent pausing during scrolling
    if let timer = progressTimer {
      RunLoop.main.add(timer, forMode: .common)
    }
  }
  
  private func handleSearchFocusChange(_ oldValue: Bool, _ newValue: Bool) {
    if viewModel.isRegular(horizontalSizeClass: horizontalSizeClass) {
      viewModel.columnVisibility = newValue ? .detailOnly : .doubleColumn
    }
  }
  
  private func handleTabChange(_ oldValue: RecordTab, _ newValue: RecordTab) {
    switch newValue {
      case .records:
      viewModel.selectedCase = nil
      viewModel.selectedDocTypeInEncounters = nil
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
  @Published var selectedCase: CaseModel?
  @Published var isSearchFocused: Bool = false
  @Published var selectedRecord: Record?
  @Published var createNewCase: String? = nil
  @Published var activeModal: FullScreenModal?
  @Published var databaseReady: Bool = false
  @Published var documentTypeReceived: Bool = false
  @Published var lastSourceRefreshedAt: Date?
  @Published var recordsCount: Int = 0
  @Published var recordPresentationState: RecordPresentationState = RecordPresentationState(mode: .displayAll)
  @Published var isForceRefreshing: Bool = false
  @Published var selectedFilterInAllRecords: [String] = []
  @Published var selectedFilterInEncounters: [String] = []
  @Published var selectedDocTypeInAllRecords: String? = nil
  @Published var selectedDocTypeInEncounters: String? = nil
  @Published var recordsRepo = RecordsRepo.shared
  private var filtersInitialized: Bool = false
  
  func configure(presentationState: RecordPresentationState, selectedFilterInAllRecords: [String] = [], selectedDocTypeInAllRecords: String? = nil) {
    self.recordPresentationState = presentationState
    // Only initialize filters once (on first appearance)
    if !filtersInitialized {
      self.selectedFilterInAllRecords = selectedFilterInAllRecords
      self.selectedDocTypeInAllRecords = selectedDocTypeInAllRecords
      self.selectedDocTypeInEncounters = nil
      self.selectedFilterInEncounters = []
      filtersInitialized = true
    }
  }
  
  // MARK: - Size Class Helpers
  func isCompact(horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
    return horizontalSizeClass == .compact
  }
  
  func isRegular(horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
    return horizontalSizeClass == .regular
  }
  
  func shouldUseTabView(horizontalSizeClass: UserInterfaceSizeClass?, verticalSizeClass: UserInterfaceSizeClass?) -> Bool {
    return isCompact(horizontalSizeClass: horizontalSizeClass) || verticalSizeClass == .compact
  }

  // MARK: - Public entrypoint for view
  func loadData() {
    Task {
      initializeDatabase()
      await fetchDocumentTypes()
      await preloadAndSyncData()
      updateDocumentCount()
    }
  }

  private func resetFilters() {
    self.selectedFilterInAllRecords = []
    self.selectedFilterInEncounters = []
    self.selectedDocTypeInAllRecords = nil
    self.selectedDocTypeInEncounters = nil
  }
  
  // MARK: - Private helpers
  private func initializeDatabase() {
    _ = recordsRepo.databaseManager.container.persistentStoreCoordinator
    databaseReady = true
    print("Core Data initialized successfully")
  }

  private func fetchDocumentTypes() async {
    guard let helper = InitConfiguration.shared.helper else {
      documentTypeReceived = true
      return
    }
    let documentTypes = await helper.getDocumentTypes()
    documentTypesList = documentTypes
    documentTypeReceived = true
  }

  private func preloadAndSyncData() async {
    await withCheckedContinuation { continuation in
      recordsRepo.checkAndPreloadCaseTypes(preloadData: CaseTypePreloadData.all) { _ in
        continuation.resume()
      }
    }

    recordsRepo.getUpdatedAtAndStartCases { [weak self] _ in
      self?.recordsRepo.getUpdatedAtAndStartFetchRecords { [weak self] _, lastSourceRefreshedTime in
        guard let self = self else { return }
        DispatchQueue.main.async {
          if let ts = lastSourceRefreshedTime {
            self.lastSourceRefreshedAt = Date(timeIntervalSince1970: Double(ts))
          } else {
            self.lastSourceRefreshedAt = nil
          }
        }
      }
    }

    Task {
      recordsRepo.syncUnsyncedCases { _ in
        self.recordsRepo.syncUnuploadedRecords { _ in }
      }
    }
  }
  func updateDocumentCount() {
    recordsRepo.getAllRecordsCount { [weak self] count in
      guard let self = self else { return }
      DispatchQueue.main.async {
        self.recordsCount = count
      }
    }
  }
}
