//
//  SmartReportView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 03/02/25.
//

import EkaUI
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
  @State var selectedItemData: Set<Verified> = []
  @State private var selectedChip: ChipType = .all {
    didSet {
      formSmartReportListData(verifiedData: smartReportInfo?.verified)
    }
  }
  @State private var listData: [Verified] = []
  @State private var showToast: Bool = false
  @State private var toastMessage: String = ""
  @Binding var smartReportInfo: SmartReportInfo?
  @State var determinedListData: [Verified] = []
  
  private let onCopyVitals: (([Verified]) -> Void)?
  private let recordPresentationState: RecordPresentationState
  // MARK: - Init
  init(
    smartReportInfo: Binding<SmartReportInfo?>,
    recordPresentationState: RecordPresentationState,
    onCopyVitals: (([Verified]) -> Void)? = nil
  ) {
    _smartReportInfo = smartReportInfo
    self.recordPresentationState = recordPresentationState
    self.onCopyVitals = onCopyVitals
  }
  // MARK: - Body
  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(spacing: 0) {
            chipsView()
          if listData.isEmpty {
            HStack {
              Spacer() /// For aligning towards center horizontally
              smartReportVitalListEmptyView()
              Spacer() /// For aligning towards center horizontally
            }
          } else {
            if recordPresentationState.isCopyVitals {
              HStack {
                Text("Selected vitals (\(selectedItemData.count))")
                  .textStyle(ekaFont: .subheadlineRegular, color: .gray)
                Spacer()
              }
              .padding(.horizontal)
            }
            
            smartReportVitalListView(vitalsData: listData)
              .padding()
          }
        }
        .frame(maxHeight: .infinity)
      }
      if recordPresentationState.isCopyVitals {
        CopyButtonsView()
      }
    }
    .background(Color(.neutrals50))
    .overlay(
      // Toast overlay
      VStack {
        if showToast {
          ToastView(toastType: .active(sfSymbolString: "doc.on.doc"), toastDescription: toastMessage)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: showToast)
        }
        Spacer()
      }
      .padding(.top, 50)
    )
    .onAppear {
      initializeDeterminedListData(verifiedData: smartReportInfo?.verified)
      formSmartReportListData(verifiedData: smartReportInfo?.verified)
    }
    .onChange(of: smartReportInfo) { _ , newValue in
      initializeDeterminedListData(verifiedData: newValue?.verified)
      formSmartReportListData(verifiedData: newValue?.verified)
    }
  }
}

// MARK: - Subviews

extension SmartReportView {
  private func smartReportVitalListEmptyView() -> some View {
    ContentUnavailableView {
      Label("No out of range vitals found", image: "")
    } description: {
      Text("Take care of your health and stay healthly")
    }
  }
  private func smartReportVitalListView(vitalsData: [Verified]) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(vitalsData) { data in
        VitalReadingRowView(itemData: data,selectedItemData: $selectedItemData, recordPresentationState: recordPresentationState)
      }
    }
    .cornerRadiusModifier(12, corners: .allCorners)
  }
}

extension SmartReportView {
  private func chipsView() -> some View {
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
  
  private func CopyButtonsView() -> some View {
    HStack(spacing: 0) {
      // Copy All button (Grey style)
        Button("Copy all to Rx (\(determinedListData.count))") {
          handleCopyAllTapped(message: "Copied to Rx Pad")
      }
      .textStyle(ekaFont: .subheadlineRegular, color: .systemBlue)
      .multilineTextAlignment(.center)
      .buttonStyle(.bordered)
      .tint(.gray)
      .disabled(determinedListData.count == 0)
      .frame(maxWidth: .infinity)
      
      // Copy Selected button (Blue style)
      Button("Copy to Rx (\(selectedItemData.count))") {
        handleCopySelectedTapped(message: "Copied to Rx Pad")
      }
      .textStyle(ekaFont: .subheadlineRegular, color: UIColor.white)
      .multilineTextAlignment(.center)
      .buttonStyle(.borderedProminent)
      .tint(.blue)
      .disabled(selectedItemData.count == 0)
      .frame(maxWidth: .infinity)
    }
    .padding(8)
  }
}

extension SmartReportView {
  /// Handles the copy all button tap action
  private func handleCopyAllTapped(message: String) {
    toastMessage = message
    showToast = true
    
    // Call the callback with the determinedListData data
    onCopyVitals?(determinedListData)
    
    // Auto-hide toast after 2 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      showToast = false
    }
  }
  
  /// Handles the copy selected button tap action
  private func handleCopySelectedTapped(message: String) {
    toastMessage = message
    showToast = true
    
    // Call the callback with the selected items
    onCopyVitals?(Array(selectedItemData))
    
    // Auto-hide toast after 2 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      showToast = false
    }
  }
  
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
  
  /// Initialize determinedListData
  private func  initializeDeterminedListData(verifiedData: [Verified]?) {
    guard let verifiedData else { return }
    determinedListData = verifiedData.filter { data in
        if let resultID = data.resultID,
           let interpretationType = LabParameterResultType(rawValue: resultID) {
          return interpretationType != .undetermined
        }
      return false
    }
   print( determinedListData.count)
  }
}

#Preview {
  SmartReportView(smartReportInfo: .constant(nil), recordPresentationState: RecordPresentationState(mode: .dashboard))
}
