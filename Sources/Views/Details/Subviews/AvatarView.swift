//
//  AvatarView.swift
//  EkaMedicalRecordsUI
//
//  Created by shekhar gupta on 21/08/25.
//


import SwiftUI

struct AvatarView: View {
  var caseTypeEnum: CaseTypesEnum
  
  var body: some View {
    ZStack {
      Circle()
        .fill(caseTypeEnum.backgroundColor)
        .frame(width: 40, height: 40)
      
      if let icon = caseTypeEnum.iconImage {
        icon
          .resizable()
          .scaledToFit()
          .frame(width: 22, height: 22)
          .foregroundColor(.white)
      } else {
        Text(caseTypeEnum.typeString)
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(.white)
      }
    }
  }
}
