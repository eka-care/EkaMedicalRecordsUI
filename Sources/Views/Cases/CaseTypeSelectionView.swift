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
                Image(type.icon ?? "other", bundle: .module) // Fallback if nil
                  .resizable()
                  .scaledToFit()
                  .frame(width: 36, height: 36)
                
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
          
          // Create new case type row
          HStack {
            ZStack {
              Circle()
                .fill(Color(hex: "#6B5CE0") ?? .purple)
                .frame(width: 36, height: 36)
              Image(systemName: "plus")
                .foregroundColor(.white)
            }
            Text("Create new case type")
              .foregroundColor(Color(hex: "#6B5CE0") ?? .purple)
          }
          .contentShape(Rectangle())
          .onTapGesture {
            showingAlert = true
          }
        }
      }
      .navigationTitle("All Case Types")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Back") {
            dismiss()
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAlert = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .onAppear {
        //check preload data is avaliable in DataBase
        recordsRepo.checkAndPreloadCaseTypes(preloadData: CaseTypePreloadData.all) { _ in
          
        }
      }
      .alert("Create new Case Type", isPresented: $showingAlert) {
        TextField("Enter a name", text: $newCaseType)
          .autocapitalization(.words)
        Button("Cancel", role: .cancel) {
          newCaseType = ""
        }
        Button("Add") {
          let newType = CaseTypeModel(
            name: newCaseType,
            icon: CaseIcon.other.rawValue
          )
          let _ = recordsRepo.createCaseType(caseTypeModel: newType)
          selectedCase = newType.name
          newCaseType = ""
        }
      }
    }
  }
}
