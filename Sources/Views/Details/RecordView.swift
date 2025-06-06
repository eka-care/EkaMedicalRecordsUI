//
//  SwiftUIView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 03/02/25.
//

import SwiftUI
import EkaMedicalRecordsCore

struct RecordView: View {
  
  // MARK: - Properties
  
  private let record: Record
  private let recordsRepo = RecordsRepo()
  @State private var selectedTab: Tab = .smartReport
  @State private var documents: [DocumentMimeType] = []
  @State private var smartReportInfo: SmartReportInfo?
  @State private var isLoading: Bool = false
  @State private var isShareSheetPresented: Bool = false
  
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
    VStack {
      if record.isSmart {
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
      } else {
        DocumentViewer(documents: $documents)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

// TODO: - Preview to be handled as database model cannot be init
//#Preview {
//  RecordView(record: )
//}
