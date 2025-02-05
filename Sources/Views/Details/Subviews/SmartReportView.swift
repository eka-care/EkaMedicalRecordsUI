//
//  SmartReportView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 03/02/25.
//

import SwiftUI
import EkaMedicalRecordsCore

struct SmartReportView: View {
  
  // MARK: - Properties
  
  @State var smartReportInfo: SmartReportInfo?
  
  // MARK: - Init
  
  init(
    smartReportInfo: SmartReportInfo? = nil
  ) {
    _smartReportInfo = State(initialValue: smartReportInfo)
  }
  
  // MARK: - Body
  
  var body: some View {
    VStack {
      if let verified = smartReportInfo?.verified, verified.isEmpty {
        HStack {
          Spacer() /// For aligning towards center horizontally
          SmartReportVitalListEmptyView()
          Spacer() /// For aligning towards center horizontally
        }
        .padding(.top, 100)
      } else {
        if let verified = smartReportInfo?.verified {
          SmartReportVitalListView(vitalsData: verified)
            .padding(.top, EkaSpacing.spacingM)
        }
      }
    }
  }
}

// MARK: - Subviews

extension SmartReportView {
  private func SmartReportVitalListEmptyView() -> some View {
    ContentUnavailableView {
      Label("No out of range vitals found", image: "healthyPerson")
    } description: {
      Text("Take care of your health and stay healthly")
    }
  }
  
  private func SmartReportVitalListView(vitalsData: [Verified]) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(vitalsData) { data in
        VitalReadingRowView(itemData: data)
          .animation(.easeInOut, value: vitalsData)
          .transition(.opacity.animation(.easeInOut).combined(with: .move(edge: .bottom)))
      }
    }
  }
}

#Preview {
  SmartReportView()
}
