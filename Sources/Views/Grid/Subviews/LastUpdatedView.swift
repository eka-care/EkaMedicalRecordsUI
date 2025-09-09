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
  @State private var progress: Double = 0.0
  @State private var progressTimer: Timer?
  
  let progressDuration: Double
  
  init(isRefreshing: Binding<Bool>, lastUpdated: Binding<Date?>, progressDuration: Double = 15.0) {
    self._isRefreshing = isRefreshing
    self._lastUpdated = lastUpdated
    self.progressDuration = progressDuration
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if isRefreshing {
        ProgressView(value: progress)
          .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#215FFF") ?? .blue))
          .frame(height: 4)
          .background(Color(hex: "#215FFF0D"))
      }
      
      HStack {
        HStack {
          if lastUpdated != nil {
            Text("Last updated:")
              .newTextStyle(ekaFont: .subheadlineRegular, color: UIColor(resource: .grey600))
            
            Text(formattedDate(lastUpdated))
              .newTextStyle(ekaFont: .subheadlineRegular, color: UIColor(resource: .labelsPrimary))
          } else {
            Text("Refresh")
              .newTextStyle(ekaFont: .subheadlineRegular, color: UIColor(resource: .labelsPrimary))
          }
          
          Spacer()
          
          if isRefreshing {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#215FFF") ?? .blue))
          } else {
            Button(action: {
              startRefresh()
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
    .onChange(of: isRefreshing) { _ ,newValue in
      if newValue {
        startProgress()
      } else {
        stopProgress()
      }
    }
    .onDisappear {
      stopProgress()
    }
  }
  
  private func startRefresh() {
    isRefreshing = true
  }
  
  private func startProgress() {
    progress = 0.0
    progressTimer = Timer(timeInterval: 0.1, repeats: true) { _ in
      withAnimation(.linear(duration: 0.1)) {
        progress += 0.1 / progressDuration
        if progress >= 1.0 {
          progress = 1.0
          stopProgress()
          isRefreshing = false
        }
      }
    }
    
    // Add timer to RunLoop with common mode to prevent pausing during scrolling
    if let timer = progressTimer {
      RunLoop.main.add(timer, forMode: .common)
    }
  }
  
  private func stopProgress() {
    progressTimer?.invalidate()
    progressTimer = nil
    progress = 0.0
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
