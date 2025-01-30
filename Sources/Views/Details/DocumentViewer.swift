//
//  DocumentViewer.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 24/01/25.
//

import SwiftUI
import PDFKit
//import EkaMedicalRecordsCore
 
/**
 Used to display only the contents of the document.
 Dont expose any API here or make decisions of smart report
 */

enum DocumentType: Hashable {
  case image(uiImage: UIImage)
  case pdf(data: Data)
}

struct DocumentViewer: View {
  @State var documents: [DocumentType] = []
  
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        ForEach(documents, id: \.self) { document in
          switch document {
          case .image(let uiImage):
            Image(uiImage: uiImage)
              .resizable()
              .scaledToFit()
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.gray.opacity(0.2))
              .cornerRadius(10)
          case .pdf(let data):
            PDFDocumentView(pdfData: data)
              .frame(height: 400) // Adjust height for PDF rendering
              .padding()
              .background(Color.gray.opacity(0.1))
              .cornerRadius(10)
          }
        }
      }
      .padding()
    }
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
