//
//  SmartReportView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 03/02/25.
//

import SwiftUI
import EkaMedicalRecordsCore

enum ChipType: Int, CaseIterable {
  case all
  case outOfRange

  func formChipTitle(count: Int) -> String {
    switch self {
    case .all:
      return "All lab vital (\(count))"
    case .outOfRange:
      return "Out of range (\(count))"
    }
  }
}

struct SmartReportView: View {
  
  // MARK: - Properties
  
  @State private var selectedChip: ChipType = .all {
    didSet {
      formSmartReportListData(verifiedData: smartReportInfo?.verified)
    }
  }
  @State private var listData: [Verified] = []
  @Binding var smartReportInfo: SmartReportInfo?
  
  // MARK: - Init
  
  init(
    smartReportInfo: Binding<SmartReportInfo?>
  ) {
    _smartReportInfo = smartReportInfo
  }
  
  // MARK: - Body
  
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ChipsView()
        if let verified = smartReportInfo?.verified, verified.isEmpty {
          HStack {
            Spacer() /// For aligning towards center horizontally
            SmartReportVitalListEmptyView()
            Spacer() /// For aligning towards center horizontally
          }
        } else {
          SmartReportVitalListView(vitalsData: listData)
        }
      }
      .frame(maxHeight: .infinity)
      .onAppear {
        formSmartReportListData(verifiedData: smartReportInfo?.verified)
      }
    }
    .background(Color(.neutrals50))
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
      }
    }
  }
}

extension SmartReportView {
  private func ChipsView() -> some View {
    HStack {
      ForEach(ChipType.allCases, id: \.self) { chip in
        ChipView(
          selectionId: chip.rawValue,
          title: chip.formChipTitle(count: getCount(chip: chip)),
          isSelected: selectedChip == chip
        ) { id in
          if let chipType = ChipType(rawValue: id) {
            selectedChip = chipType
          }
        }
      }
      Spacer()
    }
    .padding()
  }
}

extension SmartReportView {
  /// Used to form smart report list data
  func formSmartReportListData(verifiedData: [Verified]?) {
    guard let verifiedData else { return }
    switch selectedChip {
    case .all:
      listData = verifiedData
    case .outOfRange:
      listData = verifiedData.filter { data in
        if let resultID = data.resultID,
           let interpretationType = LabParameterResultType(rawValue: resultID) {
          return interpretationType != .normal && interpretationType != .undetermined
        }
        return false
      }
    }
  }
  
  /// Used to form smart report list count
  func getCount(chip: ChipType) -> Int {
    switch chip {
    case .all:
      return smartReportInfo?.verified?.count ?? 0
    case .outOfRange:
      /// Out of range is one which is neither normal nor undetermined
      let outOfRangeCount = smartReportInfo?.verified?.filter { data in
        if let resultID = data.resultID,
           let interpretationType = LabParameterResultType(rawValue: resultID) {
          return interpretationType != .normal && interpretationType != .undetermined
        }
        return false
      }.count ?? 0
      return outOfRangeCount
    }
  }
}

#Preview {
  SmartReportView(smartReportInfo: .constant(nil))
}
