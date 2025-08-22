//
//  UIDevice+Extension.swift
//  EkaMedicalRecordsUI
//
//  Created by shekhar gupta on 07/08/25.
//

import SwiftUI

extension UIDevice {
  var isIPad: Bool {
    return userInterfaceIdiom == .pad
  }
}
