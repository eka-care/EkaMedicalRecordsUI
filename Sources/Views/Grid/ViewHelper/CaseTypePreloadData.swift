//
//  CaseTypePreloadData.swift
//  EkaMedicalRecordsUI
//
//  Created by Shekhar Gupta on 24/07/25.
//

import EkaMedicalRecordsCore

struct CaseTypePreloadData {
  static let all: [CaseTypeModel] = [
    CaseTypeModel(name: "Doctor Visit (OPD)", icon: CaseIcon.doctor.rawValue),
    CaseTypeModel(name: "Hospital Visit (IPD)", icon: CaseIcon.hospital.rawValue),
    CaseTypeModel(name: "Health Checkup", icon: CaseIcon.checkup.rawValue),
    CaseTypeModel(name: "Home Visit", icon: CaseIcon.home.rawValue),
    CaseTypeModel(name: "Teleconsultation", icon: CaseIcon.teleconsult.rawValue),
    CaseTypeModel(name: "Emergency", icon: CaseIcon.emergency.rawValue),
    CaseTypeModel(name: "Dental", icon: CaseIcon.dental.rawValue),
    CaseTypeModel(name: "Other", icon: CaseIcon.other.rawValue)
  ]
}

enum CaseIcon: String {
  case doctor = "doctor_visit"
  case hospital = "hospital_visit"
  case checkup = "health_checkup"
  case home = "home_visit"
  case teleconsult = "teleconsultation"
  case emergency = "emergency"
  case dental = "dental"
  case other = "other"
}
