//
//  DocumentViewer.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 24/01/25.
//

import SwiftUI
import PDFKit
import EkaMedicalRecordsCore
 
/**
 Used to display only the contents of the document.
 Dont expose any API here or make decisions of smart report
 */

enum DocumentMimeType: Hashable, Equatable {
  case image(uiImage: UIImage)
  case pdf(data: Data)
  
  var activityItem: Any {
    switch self {
    case .image(let uiImage):
      return uiImage
    case .pdf(let data):
      return data
    }
  }
}

struct DocumentViewer: View {
  
  // MARK: - Properties
  
  @Binding var documents: [DocumentMimeType]

  // MARK: - Init
  
  init(documents: Binding<[DocumentMimeType]>) {
    _documents = documents
    setupPageIndicatorColor()
  }
  
  // MARK: - Body
  
  var body: some View {
    TabView {
      ForEach(documents, id: \.self) { document in
        switch document {
        case .image(let uiImage):
          ZoomableImageView(image: uiImage)
            .padding()
        case .pdf(let data):
          if let document = PDFDocument(data: data) {
            PDFKitView(pdfDocument: document)
          }
        }
      }
    }
    .tabViewStyle(PageTabViewStyle()) // Enables swipe navigation
    .indexViewStyle(.page(backgroundDisplayMode: .always)) // Dots indicator
    .gesture(DragGesture()) // Prevents parent TabView from interfering
  }
}

// A simple wrapper for PDFKit's PDFView
struct PDFKitView: UIViewRepresentable {
  let pdfDocument: PDFDocument
  
  init(pdfDocument: PDFDocument) {
    self.pdfDocument = pdfDocument
  }
  
  func makeUIView(context: Context) -> PDFView {
      let pdfView = PDFView()
      pdfView.autoScales = true
      return pdfView
  }
  
  func updateUIView(_ uiView: PDFView, context: Context) {
    DispatchQueue.main.async {
      uiView.document = pdfDocument
    }
  }
}

extension DocumentViewer {
  private func setupPageIndicatorColor() {
    // Change the color of the page indicator (UIPageControl)
    UIPageControl.appearance().currentPageIndicatorTintColor = .purple
    UIPageControl.appearance().pageIndicatorTintColor = UIColor.purple.withAlphaComponent(0.3)
  }
}
