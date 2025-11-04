//
//  CaseTypePreloadData.swift
//  EkaMedicalRecordsUI
//
//  Created by Shekhar Gupta on 24/07/25.
//

import EkaMedicalRecordsCore
import SwiftUI

public struct CaseTypePreloadData {
  public static var all: [CaseTypeModel] = [
    CaseTypeModel(name: "EM"),
    CaseTypeModel(name: "IP"),
    CaseTypeModel(name: "OP"),
    CaseTypeModel(name: "DC"),
    CaseTypeModel(name: "Other")
  ]
}


enum CaseTypesEnum {
  case daycare
  case inpatient      // In-patient Department
  case outpatient     // Out-patient Department
  case emergency
  case custom(title: String)
  
  var typeString: String {
    switch self {
    case .daycare:
      return "DC"
    case .inpatient:
      return "IP"
    case .outpatient:
      return "OP"
    case .emergency:
      return "EM"
    case .custom(let title):
      return title
    }
  }
  
  var name: String {
    switch self {
    case .daycare:
      return "DC"
    case .inpatient:
      return "IP"
    case .outpatient:
      return "OP"
    case .emergency:
      return "EM"
    case .custom(title: let title):
      return title
    }
  }
  
  static func getCaseType(for caseTypeString: String) -> CaseTypesEnum {
    switch caseTypeString {
    case CaseTypesEnum.daycare.name:
      return .daycare
    case CaseTypesEnum.inpatient.name:
      return .inpatient
    case CaseTypesEnum.outpatient.name:
      return .outpatient
    case CaseTypesEnum.emergency.name:
      return .emergency
    default:
      return .custom(title: caseTypeString)
    }
  }
  
  var initialsString: String? {
    switch self {
    case .daycare, .inpatient, .outpatient, .emergency:
      return typeString
    case .custom(let title):
      return title
    }
  }
  
  var backgroundColor: Color {
    switch self {
    case .daycare:
      return Color(hex: "#C2D08E") ?? .yellow
    case .inpatient:
      return Color(hex: "#C792E7") ?? .yellow
    case .outpatient:
      return Color(hex: "#83CDA1") ?? .yellow
    case .emergency:
      return Color(hex: "#FF8D77") ?? .yellow
    case .custom:
      return Color(hex: "#F6DA6D") ?? .yellow
    }
  }
  
  var iconImage: Image? {
    switch self {
    case .custom:
      return Image(systemName: "folder.fill")
    default:
      return nil
    }
  }
}
