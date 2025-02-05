import SwiftUI

enum DocumentFilterType: String, CaseIterable, Identifiable {
  case labReport = "Lab report"
  case prescription = "Prescription"
  case insurance = "Insurance"
  case vaccines = "Vaccines"
  
  var id: String { self.rawValue }
}

struct EditBottomSheetView: View {

  // MARK: - Properties
  
  @State private var selectedDocumentType: DocumentFilterType?
  @State private var documentDate: Date = Date()
  @State private var showAlert: Bool = false // Alert state
  @Binding var isEditBottomSheetPresented: Bool
  
  // MARK: - Init
  
  init(isEditBottomSheetPresented: Binding<Bool>) {
    _isEditBottomSheetPresented = isEditBottomSheetPresented
  }
  
  // MARK: - Body
  
  var body: some View {
    VStack {
      List {
        TypeOfDocumentPickerView()
        DocumentDatePickerView()
      }
      .listStyle(.insetGrouped)
    }
    .background(.white)
    .navigationTitle("Edit Document Details")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Save") {
          if selectedDocumentType == nil {
            showAlert = true // Show alert if document type is not selected
          } else {
            saveDocumentDetails()
          }
        }
      }
    }
    .alert("Error", isPresented: $showAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("Document type is mandatory.")
    }
  }
  
  // MARK: - Functions
  
  private func saveDocumentDetails() {
    // Handle save logic
  }
}

// MARK: - Subviews

extension EditBottomSheetView {
  private func TypeOfDocumentPickerView() -> some View {
    HStack {
      Text("Type of document")
        .textStyle(ekaFont: .bodyRegular, color: UIColor(resource: .neutrals1000))
      
      Text("*")
        .foregroundColor(.red) // Red asterisk
      
      Spacer()
      
      Picker("", selection: $selectedDocumentType) {
        Text("Select").tag(nil as DocumentFilterType?) // Empty selection
        ForEach(DocumentFilterType.allCases, id: \.self) { type in
          Text(type.rawValue).tag(type as DocumentFilterType?)
            .font(.footnote)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .tint(.black)
    }
  }
  
  private func DocumentDatePickerView() -> some View {
    HStack {
      Text("Document Date")
        .textStyle(ekaFont: .bodyRegular, color: UIColor(resource: .neutrals1000))
      
      Spacer()
      
      DatePicker("", selection: $documentDate, displayedComponents: .date)
        .labelsHidden()
        .foregroundColor(.gray)
    }
  }
}

#Preview {
  EditBottomSheetView(isEditBottomSheetPresented: .constant(true))
}
