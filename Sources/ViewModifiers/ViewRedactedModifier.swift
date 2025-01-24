//
//  ViewRedactedModifier.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 23/01/25.
//

import SwiftUI

struct ViewRedactedLoader: ViewModifier {
  var hasShimmer: Bool
  var isLoading: Bool
//  var gradient: Gradient
  @State var isShimmering: Bool = false
  
  func body(content: Content) -> some View {
    if isLoading {
      if hasShimmer {
        content
          .redacted(reason: .placeholder)
//          .shimmering(
//            animation: .easeInOut(duration: 1).delay(0.2).repeatForever(autoreverses: false),
//            gradient: gradient
//          )
          .cornerRadius(12)
      } else {
        content
          .redacted(reason: .placeholder)
      }
    } else {
      content
    }
  }
}

extension View {
  public func viewRedactedLoader(
    hasShimmer: Bool = false,
    isLoading: Bool
//    gradient: Gradient = Shimmer.defaultGradient
  ) -> some View {
    modifier(ViewRedactedLoader(
      hasShimmer: hasShimmer,
      isLoading: isLoading
//      gradient: gradient
    ))
  }
}
