//
//  InitConfiguration.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 28/01/25.
//


public final class InitConfiguration {
  public static let shared = InitConfiguration()
  
  /// Title to be given at top in records screen
  public var recordsTitle: String?
  
  private init() {}

  /// Optional helper, can be set by the app
  public var helper: MedicalRecordsHelpers?
}

public protocol MedicalRecordsHelpers {
  func getDocumentTypes() async -> [MRDocumentType]
}
