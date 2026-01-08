//
//  CaseType.swift
//  EkaMedicalRecordsUI
//
//  Created by Shekhar Gupta on 23/07/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

struct CaseTypeSelectionView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.managedObjectContext) private var viewContext
  @Binding var selectedCase: String
  @State private var showingAlert = false
  @State private var newCaseType = ""
  private let recordsRepo: RecordsRepo = RecordsRepo.shared
  
  init(selectedCase: Binding<String>) {
    self._selectedCase = selectedCase
  }
  
  var body: some View {
    NavigationView {
      VStack {
        List {
          // CoreData-driven list
          QueryResponderView(
            predicate: NSPredicate(value: true),
            sortDescriptors: []
          ) { (caseTypes: FetchedResults<CaseType>) in
            ForEach(caseTypes, id: \.self) { type in
              HStack {
                AvatarView(caseTypeEnum: CaseTypesEnum.getCaseType(for: type.name ?? ""))
                
                Text(type.name ?? "")
                  .foregroundColor(.primary)
                Spacer()
                if selectedCase == type.name {
                  Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                }
              }
              .contentShape(Rectangle())
              .onTapGesture {
                selectedCase = type.name ?? ""
                dismiss()
              }
            }
          }
        }
      }
      .navigationTitle("All Encounters")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Back") {
            dismiss()
          }
        }
      }
      .onAppear {
        //check preload data is avaliable in DataBase
        recordsRepo.checkAndPreloadCaseTypes(preloadData: CaseTypePreloadData.defaultCases) { _ in
          
        }
      }
      .alert("Create an encounter Type", isPresented: $showingAlert) {
        TextField("Enter a name", text: $newCaseType)
          .autocapitalization(.words)
        Button("Cancel", role: .cancel) {
          newCaseType = ""
        }
        Button("Add") {
          let newType = CaseTypeModel(
            name: newCaseType          )
          let _ = recordsRepo.createCaseType(caseTypeModel: newType)
          selectedCase = newType.name
          newCaseType = ""
        }
      }
    }
  }
}
