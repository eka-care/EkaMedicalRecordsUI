//
//  BorderCornerRadiusModifier.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 19/01/25.
//

import SwiftUI

/*
 Note: - Ensure that the Parent View is giving the view, on which you are applying corner radius, some vertical breathing space. Try adding vertical padding to resolve if the stroke is being cut.
 */

struct BorderWithCornerRadius: ViewModifier {
  let cornerRadius: CGFloat
  let borderColor: UIColor
  let strokeWidth: CGFloat
  
  func body(content: Content) -> some View {
    content
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(Color(borderColor), lineWidth: strokeWidth)
      )
  }
}

extension View {
  public func addBorderWithCornerRadiusModifier(
    cornerRadius: CGFloat,
    borderColor: UIColor,
    strokeWidth: CGFloat = 1
  ) -> some View {
    modifier(
      BorderWithCornerRadius(
        cornerRadius: cornerRadius,
        borderColor: borderColor,
        strokeWidth: strokeWidth
      )
    )
  }
}
