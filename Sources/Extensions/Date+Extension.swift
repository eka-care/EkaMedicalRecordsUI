//
//  Date+Extension.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 23/01/25.
//

import Foundation

extension Date {
  func formatted(as format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
}
