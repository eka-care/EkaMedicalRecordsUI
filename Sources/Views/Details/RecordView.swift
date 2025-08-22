import SwiftUI
import EkaMedicalRecordsCore

struct RecordView: View {
  
  // MARK: - Properties
  
  private let record: Record
  private let recordsRepo = RecordsRepo.shared
  @State private var selectedTab: Tab = .smartReport
  @State private var documents: [DocumentMimeType] = []
  @State private var smartReportInfo: SmartReportInfo?
  @State private var isLoading: Bool = false
  @State private var isShareSheetPresented: Bool = false
  @Environment(\.dismiss) private var dismiss
  
  enum Tab: Int {
    case smartReport = 0
    case documents = 1
    
    var title: String {
      switch self {
      case .smartReport:
        return "Smart Report"
      case .documents:
        return "Original Record"
      }
    }
  }
  
  // MARK: - Init
  
  init(record: Record) {
    self.record = record
  }
  
  // MARK: - Body
  
  var body: some View {
    let isIPad = UIDevice.current.userInterfaceIdiom == .pad
    
    VStack {
      if record.isSmart {
        if isIPad {
          // iPad Layout - Side by side view
          iPadLayout
        } else {
          // iPhone Layout - Segmented picker
          iPhoneLayout
        }
      } else {
        // Non-smart records - just show documents
        DocumentViewer(documents: $documents)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

      }
    }
    .toolbar {
      if UIDevice.current.userInterfaceIdiom == .pad {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") {
            dismiss()
          }
        }
      }
    }
    .navigationBarItems(trailing: Button(action: {
      isShareSheetPresented = true
    }) {
      Image(systemName: "square.and.arrow.up")
    })
    .sheet(isPresented: $isShareSheetPresented) { [documents] in
      ShareSheet(activityItems: documents.map { $0.activityItem })
    }
    .matteProgressOverlay(isLoading: $isLoading)
    .onAppear {
      isLoading = true
      /// Fetch record meta data
      recordsRepo.fetchRecordMetaData(for: record) { documentURIs, reportInfo in
        DispatchQueue.main.async {
          print("Received record meta data")
          documents = FileHelper.createDocumentTypes(from: documentURIs)
          smartReportInfo = reportInfo
          isLoading = false
        }
      }
    }
  }
  
  // MARK: - iPad Layout
  
  private var iPadLayout: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        // Left Side - Documents (3/5 of width)
        DocumentViewer(documents: $documents)
          .frame(width: geometry.size.width * 0.7, height: geometry.size.height)
          .background(Color(.systemBackground))
        
        // Right Side - Smart Report (2/5 of width)
        SmartReportView(smartReportInfo: $smartReportInfo)
          .frame(width: geometry.size.width * 0.3, height: geometry.size.height)
          .background(Color(.systemBackground))
      }
      .edgesIgnoringSafeArea(.bottom)
    }
  }
  
  // MARK: - iPhone Layout
  
  private var iPhoneLayout: some View {
    VStack {
      // Segmented Picker
      Picker("Select View", selection: $selectedTab) {
        Text(Tab.smartReport.title).tag(Tab.smartReport)
        Text(Tab.documents.title).tag(Tab.documents)
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding()
      
      // Conditional View Switching
      Group {
        switch selectedTab {
        case .smartReport:
          SmartReportView(smartReportInfo: $smartReportInfo)
        case .documents:
          DocumentViewer(documents: $documents)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}

// TODO: - Preview to be handled as database model cannot be init
//#Preview {
//  RecordView(record: )
//}
