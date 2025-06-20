//
//  RecordDocumentTypeHelper.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 18/06/25.
//

import EkaMedicalRecordsCore
import UIKit

extension RecordDocumentType {
  var imageIcon: UIImage {
    switch self {
    case .typeAll:
      return UIImage()
    case .typeLabReport:
      return UIImage(resource: .labReportDocumentIcon)
    case .typePrescription:
      return UIImage(resource: .prescriptionDocumentIcon)
    case .typeDischargeSummary:
      return UIImage(resource: .dischargeSummaryDocumentIcon)
    case .typeVaccineCertificate:
      return UIImage(resource: .vaccineCertificateDocumentIcon)
    case .typeInsurance:
      return UIImage(resource: .slipDocumentIcon)
    case .typeInvoice:
      return UIImage(resource: .slipDocumentIcon)
    case .typeScan:
      return UIImage(resource: .scanDocumentIcon)
    case .typeOther:
      return UIImage(resource: .othersDocumentIcon)
    }
  }
  
  var imageIconForegroundColor: UIColor {
    switch self {
    case .typeAll:
      return .clear
    case .typeLabReport:
      return UIColor(resource: .green500)
    case .typePrescription:
      return UIColor(resource: .red500)
    case .typeDischargeSummary:
      return UIColor(resource: .green500)
    case .typeVaccineCertificate:
      return UIColor(resource: .primary500)
    case .typeInsurance:
      return UIColor(resource: .primary500)
    case .typeInvoice:
      return UIColor(resource: .red500)
    case .typeScan:
      return UIColor(resource: .red500)
    case .typeOther:
      return UIColor(resource: .green500)
    }
  }
  
  var imageIconBackgroundColor: UIColor {
    switch self {
    case .typeAll:
      return .clear
    case .typeLabReport:
      return UIColor(resource: .green50)
    case .typePrescription:
      return UIColor(resource: .red50)
    case .typeDischargeSummary:
      return UIColor(resource: .green50)
    case .typeVaccineCertificate:
      return UIColor(resource: .primary50)
    case .typeInsurance:
      return UIColor(resource: .red50)
    case .typeInvoice:
      return UIColor(resource: .red50)
    case .typeScan:
      return UIColor(resource: .red50)
    case .typeOther:
      return UIColor(resource: .green50)
    }
  }
}
