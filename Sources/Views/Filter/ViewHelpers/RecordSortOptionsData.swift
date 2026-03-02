//
//  RecordSortData.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 19/06/25.
//

import Foundation
import EkaMedicalRecordsCore

public enum RecordSortOptions: Hashable, CaseIterable {
  case dateOfUpload
  case documentDate
  
   public var title: String {
     switch self {
     case .dateOfUpload:
       return "Upload Date"
     case .documentDate:
       return "Document Date"
     }
   }
  
   public var keyPath: KeyPath<Record, Date?> {
     switch self {
     case .dateOfUpload:
       return \Record.uploadDate
     case .documentDate:
       return \Record.documentDate
     }
   }
  
  public var isDefault: Bool {
    self == .dateOfUpload
  }
  
  public var displayTitle: String {
    isDefault ? "\(title) (Default)" : title
  }
}
