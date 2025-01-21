//
//  RoundedCornerModifier.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 19/01/25.
//

import Foundation
import SwiftUI

extension View {
  public func cornerRadius(
    _ radius: CGFloat,
    corners: UIRectCorner,
    viewHasKeyboard: Bool = false
  ) -> some View {
    clipShape( RoundedCorner(radius: radius, corners: corners) )
      .edgesIgnoringSafeArea(viewHasKeyboard ? .top : .all)
  }
}

public struct RoundedCorner: Shape {
  
  private var radius: CGFloat
  private var corners: UIRectCorner
  
  public init(
    radius: CGFloat = .infinity,
    corners: UIRectCorner = .allCorners
  ) {
    self.radius = radius
    self.corners = corners
  }
  
  public func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
