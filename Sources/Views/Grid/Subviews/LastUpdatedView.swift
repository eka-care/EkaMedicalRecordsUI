//
//  LastUpdatedView.swift
//  EkaMedicalRecordsUI
//
//  Created by shekhar gupta on 21/08/25.
//

import SwiftUI

struct LastUpdatedView: View {
  @Binding var isRefreshing: Bool
  @Binding var lastUpdated: Date?
  
  var body: some View {
    HStack {
      HStack {
        Text("Last updated:")
          .newTextStyle(ekaFont: .subheadlineRegular, color: UIColor(resource: .grey600))
        
        Text(formattedDate(lastUpdated))
          .newTextStyle(ekaFont: .subheadlineRegular, color: UIColor(resource: .labelsPrimary))
        
        Spacer()
        
        if isRefreshing {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#215FFF") ?? .blue))
        } else {
          Button(action: {
            isRefreshing = true
          }) {
            Image(systemName: "arrow.clockwise")
              .foregroundColor(Color(hex: "#215FFF"))
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(Color(hex: "#215FFF0D"))
      .cornerRadius(12)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .background(Color.white)
  }
  
  private func formattedDate(_ date: Date?) -> String {
    guard let date = date else { return "" } 
    
    let calendar = Calendar.current
    let timeFormatter = DateFormatter()
    timeFormatter.timeStyle = .short
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    
    if calendar.isDateInToday(date) {
      return "Today, \(timeFormatter.string(from: date))"
    } else if calendar.isDateInYesterday(date) {
      return "Yesterday, \(timeFormatter.string(from: date))"
    } else {
      return dateFormatter.string(from: date)
    }
  }
}
