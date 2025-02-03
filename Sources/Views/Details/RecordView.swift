//
//  SwiftUIView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 03/02/25.
//

import SwiftUI

struct RecordView: View {
  // MARK: - Properties
  
  var documents: [DocumentType]
  @State private var selectedTab: Tab = .smartReport
  
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
  
  init(documents: [DocumentType]) {
    self.documents = documents
  }
  
  // MARK: - Body
  
  var body: some View {
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
          SmartReportView()
        case .documents:
          DocumentViewer(documents: documents)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .transition(.opacity) // Smooth transition effect
    }
  }
}

#Preview {
  RecordView(documents: [])
}
