//
//  MatteProgressOverlayModifier.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 05/02/25.
//

import SwiftUI

struct MatteProgressOverlayModifier: ViewModifier {
  @Binding var isLoading: Bool
  
  func body(content: Content) -> some View {
    ZStack {
      content
      
      if isLoading {
        Color.black.opacity(0.4) // Dim the background
          .edgesIgnoringSafeArea(.all)
        
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle())
          .padding(20)
          .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
          .shadow(radius: 10)
      }
    }
    .animation(.easeInOut, value: isLoading)
  }
}

extension View {
  func matteProgressOverlay(isLoading: Binding<Bool>) -> some View {
    self.modifier(MatteProgressOverlayModifier(isLoading: isLoading))
  }
}
