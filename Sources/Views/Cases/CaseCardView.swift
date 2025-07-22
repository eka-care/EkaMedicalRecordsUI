//
//  CaseCardView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 21/07/25.
//

import SwiftUI

struct CaseCardView: View {
  let caseName: String
  let recordCount: Int
  let date: Date?
  
  var body: some View {
    HStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(Color.yellow)
          .frame(width: 40, height: 40)
        
        Image(systemName: "folder.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 18, height: 18)
          .foregroundColor(.white)
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(caseName)
          .font(.system(.body, weight: .semibold))
        
        Text("\(recordCount) Medical record\(recordCount == 1 ? "" : "s")")
          .font(.footnote)
          .foregroundColor(.gray)
      }
      
      Spacer()
      
      VStack(spacing: 4) {
        if let date = date {
          Text(formattedDate(date))
            .font(.footnote)
            .foregroundColor(.gray)
        }
        
        Image(systemName: "chevron.right")
          .font(.footnote)
          .foregroundColor(.gray)
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
  
  private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E d" // e.g. Tue 29
    return formatter.string(from: date)
  }
}
