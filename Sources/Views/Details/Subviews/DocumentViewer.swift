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

enum DocumentType: Hashable {
  case image(uiImage: UIImage)
  case pdf(data: Data)
}

struct DocumentViewer: View {
  
  // MARK: - Properties
  
  @Binding var documents: [DocumentType]

  // MARK: - Init
  
  init(documents: Binding<[DocumentType]>) {
    _documents = documents // Assigning initial value to @State
    setupPageIndicatorColor()
  }
  
  // MARK: - Body
  
  var body: some View {
    TabView {
      ForEach(documents, id: \.self) { document in
        switch document {
        case .image(let uiImage):
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .padding()
            .tag(document)
          
        case .pdf(let data):
          PDFDocumentView(pdfData: data)
            .frame(maxHeight: .infinity) // Adjust height for PDF rendering
            .padding()
            .tag(document)
        }
      }
    }
    .tabViewStyle(PageTabViewStyle()) // Enables swipe navigation
    .indexViewStyle(.page(backgroundDisplayMode: .always)) // Dots indicator
    .gesture(DragGesture()) // Prevents parent TabView from interfering
  }
}

struct PDFDocumentView: UIViewRepresentable {
  let pdfData: Data
  
  func makeUIView(context: Context) -> PDFView {
    let pdfView = PDFView()
    if let document = PDFDocument(data: pdfData) {
      pdfView.document = document
    }
    pdfView.autoScales = true // Automatically scale the PDF to fit
    return pdfView
  }
  
  func updateUIView(_ uiView: PDFView, context: Context) {
    // No updates needed
  }
}

extension DocumentViewer {
  private func setupPageIndicatorColor() {
    // Change the color of the page indicator (UIPageControl)
    UIPageControl.appearance().currentPageIndicatorTintColor = .purple
    UIPageControl.appearance().pageIndicatorTintColor = UIColor.purple.withAlphaComponent(0.3)
  }
}
