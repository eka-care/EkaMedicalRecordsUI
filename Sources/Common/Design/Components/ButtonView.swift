//
//  ButtonView.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 17/01/25.
//

import SwiftUI

enum ButtonSize {
  case small, medium, large
}

enum ButtonStyle {
  case filled, outline
}

struct ButtonView: View {
  let title: String
  let imageName: UIImage?
  let size: ButtonSize
  let imagePosition: Edge.Set? // Can be `.leading` or `.trailing`
  var style: ButtonStyle
  var isFullWidth: Bool // Determines whether the button should expand to full width
  let action: () -> Void
  
  init(
    title: String,
    imageName: UIImage? = nil,
    size: ButtonSize = .medium,
    imagePosition: Edge.Set? = nil,
    style: ButtonStyle = .filled,
    isFullWidth: Bool = true,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.imageName = imageName
    self.size = size
    self.imagePosition = imagePosition
    self.style = style
    self.isFullWidth = isFullWidth
    self.action = action
  }
  
  var body: some View {
    Button(action: action) {
      HStack {
        if imagePosition == .leading, let imageName = imageName {
          Image(uiImage: imageName.withRenderingMode(.alwaysTemplate))
            .foregroundColor(foregroundColor) // Set image color
        }
        Text(title)
          .textStyle(ekaFont: buttonFont, color: UIColor(foregroundColor))
        if imagePosition == .trailing, let imageName = imageName {
          Image(uiImage: imageName.withRenderingMode(.alwaysTemplate))
            .foregroundColor(foregroundColor) // Set image color
        }
      }
      .padding(buttonPadding)
      .frame(maxWidth: isFullWidth ? .infinity : nil) // Full width or compact
      .foregroundColor(foregroundColor)
      .background(backgroundColor)
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(borderColor, lineWidth: borderWidth)
      )
      .buttonStyle(PlainButtonStyle())
    }
  }
  
  // Computed properties for sizes
  private var buttonFont: EkaFont {
    switch size {
    case .small:
      return .bodyRegular
    case .medium:
      return .bodyRegular
    case .large:
      return .bodyRegular
    }
  }
  
  private var buttonPadding: EdgeInsets {
    switch size {
    case .small:
      return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
    case .medium:
      return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    case .large:
      return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
    }
  }
  
  private var borderWidth: CGFloat {
    return style == .outline ? 1 : 0
  }
  
  private var backgroundColor: Color {
    switch style {
    case .filled:
      return Color(.primary500)
    case .outline:
      return Color.white
    }
  }
  
  private var borderColor: Color {
    return style == .outline ? Color(.primary500) : Color.clear
  }
  
  private var foregroundColor: Color {
    switch style {
    case .filled:
      return Color.white
    case .outline:
      return Color(.primary500)
    }
  }
}
