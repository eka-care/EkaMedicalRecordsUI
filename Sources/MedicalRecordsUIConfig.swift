//
//  MedicalRecordsConfig.swift
//  EkaMedicalRecordsUI
//
//  Created by shekhar gupta on 29/09/25.
//

import EkaMedicalRecordsCore

public final class MedicalRecordsUIConfig {
  public static let shared = MedicalRecordsUIConfig()
  private init() {}

  /// Optional helper, can be set by the app
  public var helper: MedicalRecordsHelpers?
}

public protocol MedicalRecordsHelpers {
  func getDocumentTypes() async -> [MRDocumentType]
}
