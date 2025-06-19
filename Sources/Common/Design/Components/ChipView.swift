//
//  ChipView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 06/02/25.
//

import SwiftUI

struct ImageSize {
  let width: CGFloat
  let height: CGFloat
}

struct ChipView: View {
  let selectionId: Int
  let title: String
  let image: UIImage?
  let imageSize: ImageSize?
  let isSelected: Bool
  let onTap: (Int) -> Void
  
  init(
    selectionId: Int,
    title: String,
    image: UIImage? = nil,
    imageSize: ImageSize? = ImageSize(width: 12, height: 12),
    isSelected: Bool,
    onTap: @escaping (Int) -> Void
  ) {
    self.selectionId = selectionId
    self.title = title
    self.image = image
    self.imageSize = imageSize
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
            .scaledToFit()
            .frame(width: imageSize?.width, height: imageSize?.height, alignment: .center)
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(isSelected ? Color.blue : Color.white)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.gray.opacity(0.5), lineWidth: isSelected ? 0 : 1)
      )
      .cornerRadius(8)
    }
    .buttonStyle(.plain)
  }
}
