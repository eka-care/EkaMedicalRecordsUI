//
//  RecordSortData.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 19/06/25.
//

import Foundation
import EkaMedicalRecordsCore

enum SortingOrder: String, CaseIterable, Hashable {
  case newToOld = "New to Old"
  case oldToNew = "Old to New"
}

enum RecordSortOptions: Hashable {
  case dateOfUpload(sortingOrder: SortingOrder)
  case documentDate(sortingOrder: SortingOrder)
  
  static var allCases: [RecordSortOptions] {
    let orders = SortingOrder.allCases
    return orders.map { .dateOfUpload(sortingOrder: $0) } + orders.map { .documentDate(sortingOrder: $0) }
  }
  
  var title: String {
    switch self {
    case .dateOfUpload(let order):
      return "Uploaded at (\(order.rawValue))"
    case .documentDate(let order):
      return "Document Date (\(order.rawValue))"
    }
  }
  
  /// Key Path for the record date
  var keyPath: KeyPath<Record, Date?> {
    switch self {
    case .dateOfUpload:
      return \Record.uploadDate
    case .documentDate:
      return \Record.documentDate
    }
  }
}
