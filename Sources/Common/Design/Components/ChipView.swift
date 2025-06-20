//
//  ChipView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 06/02/25.
//

import SwiftUI

struct ImageConfig {
  let width: CGFloat
  let height: CGFloat
  let color: UIColor
}

struct ChipView: View {
  let selectionId: Int
  let title: String
  let image: UIImage?
  let imageConfig: ImageConfig?
  let isSelected: Bool
  let onTap: (Int) -> Void
  
  init(
    selectionId: Int,
    title: String,
    image: UIImage? = nil,
    imageConfig: ImageConfig? = ImageConfig(width: 12, height: 12, color: .white),
    isSelected: Bool,
    onTap: @escaping (Int) -> Void
  ) {
    self.selectionId = selectionId
    self.title = title
    self.image = image
    self.imageConfig = imageConfig
    self.isSelected = isSelected
    self.onTap = onTap
  }
  
  var body: some View {
    Button(action: { onTap(selectionId) }) {
      HStack {
        Text(title)
          .textStyle(ekaFont: .calloutRegular, color: isSelected ? .white : UIColor(resource: .neutrals600))
        
        if let image {
          Image(uiImage: image)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: imageConfig?.width, height: imageConfig?.height, alignment: .center)
            .foregroundStyle(Color(uiColor: imageConfig?.color ?? .white))
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(isSelected ? Color(uiColor: UIColor(resource: .primary500)) : Color.white)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.gray.opacity(0.5), lineWidth: isSelected ? 0 : 1)
      )
      .cornerRadius(8)
    }
    .buttonStyle(.plain)
  }
}
