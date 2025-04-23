//
//  UploadingViewModifier.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 04/02/25.
//

import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
  @Binding var isUploading: Bool
  @Binding var isDownloading: Bool
  
  func body(content: Content) -> some View {
    ZStack {
      content
      
      if isUploading || isDownloading {
        Color.black.opacity(0.4)
          .edgesIgnoringSafeArea(.all)
        
        VStack(spacing: 12) {
          ProgressView(isUploading ? "Uploading..." : "Downloading...")
            .progressViewStyle(CircularProgressViewStyle())
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .shadow(radius: 10)
        }
      }
    }
    .animation(.easeInOut, value: isUploading || isDownloading)
  }
}

extension View {
  func loadingOverlay(isUploading: Binding<Bool>, isDownloading: Binding<Bool>) -> some View {
    self.modifier(LoadingOverlayModifier(isUploading: isUploading, isDownloading: isDownloading))
  }
}
