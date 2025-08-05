//
//  TagListView.swift
//  EkaMedicalRecordsUI
//
//  Created by shekhar gupta on 30/07/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

struct TagListView: View {
  // MARK: - Bindings and State
  @Binding var selectedTag: String?
  @State private var selectedFilter: RecordDocumentType = .typeAll
  @State private var selectedSortFilter: RecordSortOptions? = .dateOfUpload(sortingOrder: .newToOld)
  @State
  // MARK: - Dependencies
  var recordPresentationState: RecordPresentationState = .displayAll
  let recordsRepo: RecordsRepo
  @Environment(\.managedObjectContext) private var viewContext

  // MARK: - Body
  var body: some View {
    QueryResponderView(
      predicate: generatePredicate(
        for: selectedFilter,
        caseID: recordPresentationState.associatedCaseID
      ),
      sortDescriptors: generateSortDescriptors(for: selectedSortFilter)
    ) { (records: FetchedResults<Record>) in
      content(for: records)
    }
  }

  // MARK: - Content Builder
  @ViewBuilder
  private func content(for records: FetchedResults<Record>) -> some View {
    if records.isEmpty {
      emptyStateView
    } else {
      VStack(alignment: .leading, spacing: 0) {
//        RecordsFilterListView(
//          recordsRepo: recordsRepo,
//          selectedChip: $selectedFilter,
//          selectedSortFilter: $selectedSortFilter
//        )
        Text("testi")
        .padding([.leading, .vertical], EkaSpacing.spacingM)
//        .environment(\.managedObjectContext, viewContext)

        VStack {
          List {
            ForEach(records, id: \.objectID) { record in
              tagRow(for: record)
            }
          }
          .listStyle(.insetGrouped)
          .padding(.horizontal, EkaSpacing.spacingS)
        }
      }
    }
  }

  // MARK: - Empty State
  private var emptyStateView: some View {
    VStack(spacing: 16) {
      Spacer(minLength: 100)
      ContentUnavailableView(
        "No documents found",
        systemImage: "doc",
        description: Text("Upload documents to see them here")
      )
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }

  // MARK: - Record Row
  @ViewBuilder
  private func tagRow(for record: Record) -> some View {
    let isSelected = selectedTag == record.documentID

    EkaListView(
      title: record.documentID ?? "Untitled",
      subTitle: "15 record", // Replace with actual logic if needed
      image: UIImage(named: "allTagImage") ?? UIImage(),
      symbolImage: "chevron.right",
      style: .tall,
      isSelected: isSelected
    )
    .onTapGesture {
      selectedTag = isSelected ? nil : record.documentID
    }
  }

  // MARK: - Predicate Generator
  private func generatePredicate(for filter: RecordDocumentType, caseID: String?) -> NSPredicate {
    guard let filterIDs = CoreInitConfigurations.shared.filterID else {
      return NSPredicate(value: false)
    }

    var predicates: [NSPredicate] = [NSPredicate(format: "oid IN %@", filterIDs)]

    if filter != .typeAll {
      predicates.append(PredicateHelper.equals("documentType", value: Int64(filter.intValue)))
    }

    if let caseID = caseID {
      predicates.append(NSPredicate(format: "ANY toCaseModel.caseID == %@", caseID))
    }

    return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
  }

  // MARK: - Sort Descriptor Generator
  private func generateSortDescriptors(for sortType: RecordSortOptions?) -> [NSSortDescriptor] {
    switch sortType {
    case .dateOfUpload(let order):
      return [NSSortDescriptor(keyPath: \Record.uploadDate, ascending: order == .oldToNew)]
    case .documentDate(let order):
      return [NSSortDescriptor(keyPath: \Record.documentDate, ascending: order == .oldToNew)]
    case .none:
      return [NSSortDescriptor(keyPath: \Record.uploadDate, ascending: false)]
    }
  }
  
}

