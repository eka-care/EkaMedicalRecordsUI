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

  var body: some View {
    HStack(spacing: 0) {
      Menu {
        // Dynamic list from documentTypeIds state
        ForEach(documentTypeIds, id: \.self) { typeId in
          if let type = documentTypesList.first(where: { $0.id == typeId }) {
            Button {
              selectedDocType = type.id
            } label: {
              HStack {
                Text(type.filterName)
                  .textStyle(ekaFont: .bodyRegular, color: .black)
                if selectedDocType == type.id {
                  checkMarkView()
                }
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
    .onChange(of: caseId) { _, _ in
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
    if let selectedDocType,
       let displayName = documentTypesList.first(where: { $0.id == selectedDocType })?.filterName {
      return displayName
    }
    return "File Type"
  }
  
  private func refreshDocumentTypes() {
    documentTypeIds = []
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      documentTypeIds =  recordsRepo.getDocumentTypesList(caseID: caseId)
    }
  }
}
