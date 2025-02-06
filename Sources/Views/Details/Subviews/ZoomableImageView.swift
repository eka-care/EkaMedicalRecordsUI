//
//  ZoomableImageView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 06/02/25.
//

import SwiftUI

struct ZoomableImageView: View {
  let image: UIImage
  @State private var currentZoom: CGFloat = 0.0
  @State private var totalZoom: CGFloat = 1.0
  
  var body: some View {
    Image(uiImage: image)
      .resizable()
      .scaledToFit()
      .scaleEffect(currentZoom + totalZoom) // Apply Zoom
      .gesture(
        MagnifyGesture()
          .onChanged { value in
            currentZoom = value.magnification - 1
          }
          .onEnded { _ in
            totalZoom += currentZoom
            currentZoom = 0
          }
      )
      .accessibilityZoomAction { action in
        if action.direction == .zoomIn {
          totalZoom += 0.2
        } else {
          totalZoom = max(1.0, totalZoom - 0.2) // Prevent shrinking too much
        }
      }
      .animation(.easeInOut, value: totalZoom) // Smooth animation
  }
}
