//
//  UploadingViewModifier.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 04/02/25.
//

import SwiftUI

struct UploadingOverlayModifier: ViewModifier {
  @Binding var isUploading: Bool
  
  func body(content: Content) -> some View {
    ZStack {
      content
      
      if isUploading {
        Color.black.opacity(0.4) // Dim the background
          .edgesIgnoringSafeArea(.all)
        
        VStack(spacing: 12) {
          ProgressView("Uploading...")
            .progressViewStyle(CircularProgressViewStyle())
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .shadow(radius: 10)
        }
      }
    }
    .animation(.easeInOut, value: isUploading)
  }
}

extension View {
  func uploadingOverlay(isUploading: Binding<Bool>) -> some View {
    self.modifier(UploadingOverlayModifier(isUploading: isUploading))
  }
}
