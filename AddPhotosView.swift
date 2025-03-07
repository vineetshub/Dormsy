import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

struct AddPhotosView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let maxPhotos = 6
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add photos")
                    .font(.custom("Avenir-Heavy", size: 24))
                    .padding(.top, 20)
                
                Text("Add at least 2 photos to continue")
                    .font(.custom("Avenir-Medium", size: 16))
                    .foregroundColor(.gray)
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(0..<6) { index in
                        ZStack {
                            if index < selectedImages.count {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        Button(action: {
                                            selectedImages.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .padding(8)
                                        }
                                        .offset(x: 35, y: -55),
                                        alignment: .topTrailing
                                    )
                            } else {
                                PhotosPicker(selection: $selectedItems,
                                           maxSelectionCount: maxPhotos - selectedImages.count,
                                           matching: .images) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 100, height: 140)
                                        .overlay(
                                            Image(systemName: "plus.circle.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.orange)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: savePhotos) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("CONTINUE")
                            .font(.custom("Avenir-Heavy", size: 16))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedImages.count >= 2 ? Color.orange : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(selectedImages.count < 2 || isLoading)
            }
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.orange))
            .onChange(of: selectedItems) { _ in
                Task {
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                if selectedImages.count < maxPhotos {
                                    selectedImages.append(image)
                                }
                            }
                        }
                    }
                    selectedItems.removeAll()
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func savePhotos() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "User not found"
            showAlert = true
            return
        }
        
        isLoading = true
        let storage = Storage.storage()
        let db = Firestore.firestore()
        var photoUrls: [String] = []
        
        let group = DispatchGroup()
        
        for (index, image) in selectedImages.enumerated() {
            group.enter()
            
            let imageRef = storage.reference().child("users/\(userId)/photo\(index).jpg")
            
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                group.leave()
                continue
            }
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                    group.leave()
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let url = url {
                        photoUrls.append(url.absoluteString)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            db.collection("users").document(userId).updateData([
                "photos": photoUrls
            ]) { error in
                isLoading = false
                if let error = error {
                    alertMessage = "Error saving photos: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    dismiss()
                }
            }
        }
    }
}

struct AddPhotosView_Previews: PreviewProvider {
    static var previews: some View {
        AddPhotosView()
    }
} 