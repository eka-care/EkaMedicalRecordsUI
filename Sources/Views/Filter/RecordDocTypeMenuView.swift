//
//  RecordDocTypeMenuView.swift
//  EkaMedicalRecordsUI
//
//  Created by Assistant on 25/09/25.
//

import SwiftUI
import EkaMedicalRecordsCore
import EkaUI

struct RecordDocTypeMenuView: View {
  private let recordsRepo: RecordsRepo = RecordsRepo.shared
  @Binding var selectedDocType: String?
  @Binding var caseId: String?
  @Environment(\.managedObjectContext) private var viewContext
  @State private var documentTypeIds: [String] = []

  private var menuItems: [(id: String, displayName: String)] {
    var items: [(id: String, displayName: String)] = []
    var hasUnmatchedTypes = false
    var firstUnmatchedTypeId: String?
    
    for typeId in documentTypeIds {
      if let type = documentTypesList.first(where: { $0.id == typeId }) {
        items.append((typeId, type.filterName))
      } else {
        hasUnmatchedTypes = true
        if firstUnmatchedTypeId == nil {
          firstUnmatchedTypeId = typeId
        }
      }
    }
    
    // Add single "Other" option if there are unmatched types
    if hasUnmatchedTypes, let unmatchedId = firstUnmatchedTypeId {
      items.append((unmatchedId, "Other"))
    }
    
    return items
  }
  
  var body: some View {
    HStack(spacing: 0) {
      Menu {
        // Show unique menu items, grouping unmatched types under "Other"
        ForEach(menuItems, id: \.id) { item in
          Button {
            selectedDocType = item.id
          } label: {
            HStack {
              Text(item.displayName)
                .textStyle(ekaFont: .bodyRegular, color: .black)
              if isItemSelected(item) {
                checkMarkView()
              }
            }
          }
        }
      } label: {
        ChipView(
          selectionId: "",
          title: getChipTitle(),
          image: selectedDocType == nil ? UIImage(systemName: "chevron.down") : nil,
          imageConfig: selectedDocType == nil ? ImageConfig(
            width: 12,
            height: 12,
            color: UIColor(resource: .neutrals500)
          ) : nil,
          isSelected: selectedDocType != nil
        ) { _ in }
      }
      
      // Cross button - only show when something is selected
      if selectedDocType != nil {
        Button {
          selectedDocType = nil
        } label: {
          Image(systemName: "xmark")
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
            .foregroundColor(Color(uiColor: UIColor(resource: .neutrals0)))
        }
        .padding(.leading, EkaSpacing.spacingXs)
        .padding(.trailing, EkaSpacing.spacingS)
        .padding(.vertical, EkaSpacing.spacingXs)
        .background(Color(uiColor: UIColor(resource: .primary500)))
        .cornerRadiusModifier(8, corners: [.topRight, .bottomRight])
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(selectedDocType != nil ? Color(uiColor: UIColor(resource: .primary500)) : Color.white)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.5), lineWidth: selectedDocType != nil ? 0 : 1)
        )
    )
    .onReceive(NotificationCenter.default.publisher(
      for: .NSManagedObjectContextObjectsDidChange,
      object: viewContext
    )) { _ in
      refreshDocumentTypes()
    }
    .onAppear {
      refreshDocumentTypes()
    }
    .onChange(of: caseId) { oldValue, newValue in
      guard oldValue != newValue else { return }
      refreshDocumentTypes()
    }
  }
}

// MARK: - Subview
extension RecordDocTypeMenuView {
  private func checkMarkView() -> some View {
    Image(systemName: "checkmark")
      .resizable()
      .scaledToFit()
      .frame(width: 12, height: 12, alignment: .center)
  }
}

extension RecordDocTypeMenuView {
  func getChipTitle() -> String {
    guard let selectedDocType else {
      return "File Type"
    }
    return getDisplayInfo(for: selectedDocType)
  }
  
  private func isItemSelected(_ item: (id: String, displayName: String)) -> Bool {
    guard let selectedDocType = selectedDocType else { return false }
    
    if item.displayName == "Other" {
      // For "Other", check if selected type is any unmatched type
      return !documentTypesList.contains(where: { $0.id == selectedDocType })
    }
    
    return selectedDocType == item.id
  }
  
  private func getDisplayInfo(for typeId: String) -> String {
    if let type = documentTypesList.first(where: { $0.id == typeId }) {
      return type.filterName
    }
    // If type not found in documentTypesList, treat as "Other"
    return "Other"
  }
  
  private func refreshDocumentTypes() {
    documentTypeIds = []
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      documentTypeIds =  recordsRepo.getDocumentTypesList(caseID: caseId)
    }
  }
}
