//
//  RecordSortData.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 19/06/25.
//

import Foundation

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
      return "Created at (\(order.rawValue))"
    case .documentDate(let order):
      return "Document Date (\(order.rawValue))"
    }
  }
}
