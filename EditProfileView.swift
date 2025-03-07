import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userData: [String: Any]
    @State private var firstName: String
    @State private var lastName: String
    @State private var school: String
    @State private var birthday: String
    @State private var interests: [String]
    @State private var showInterestPicker = false
    @State private var showPhotoPicker = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showAlert = false
    
    init(userData: [String: Any]) {
        _userData = State(initialValue: userData)
        _firstName = State(initialValue: userData["firstName"] as? String ?? "")
        _lastName = State(initialValue: userData["lastName"] as? String ?? "")
        _school = State(initialValue: userData["school"] as? String ?? "")
        _birthday = State(initialValue: userData["birthday"] as? String ?? "")
        _interests = State(initialValue: userData["interests"] as? [String] ?? [])
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Photos Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Photos")
                            .font(.custom("Avenir-Heavy", size: 18))
                        
                        Button(action: { showPhotoPicker = true }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Edit Photos")
                            }
                            .font(.custom("Avenir-Medium", size: 16))
                            .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Basic Info Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Basic Info")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Medium", size: 16))
                            
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Medium", size: 16))
                            
                            TextField("School", text: $school)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Medium", size: 16))
                            
                            TextField("Birthday (MM/DD/YYYY)", text: $birthday)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("Avenir-Medium", size: 16))
                                .keyboardType(.numberPad)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Interests Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Interests")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .padding(.horizontal)
                        
                        if interests.isEmpty {
                            Button(action: { showInterestPicker = true }) {
                                Text("Add Interests")
                                    .font(.custom("Avenir-Medium", size: 16))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(interests, id: \.self) { interest in
                                        Text(interest)
                                            .font(.custom("Avenir-Medium", size: 14))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.orange.opacity(0.2))
                                            .foregroundColor(.orange)
                                            .cornerRadius(20)
                                    }
                                    
                                    Button(action: { showInterestPicker = true }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 24))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.custom("Avenir-Medium", size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Button(action: saveChanges) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange)
                                .frame(height: 50)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save Changes")
                                    .font(.custom("Avenir-Heavy", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .disabled(isLoading)
                }
                .padding(.vertical)
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.orange)
            )
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPhotoPicker) {
                AddPhotosView()
            }
            .sheet(isPresented: $showInterestPicker) {
                InterestSelectionView(selectedInterests: $interests)
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveChanges() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "No user logged in"
            showAlert = true
            return
        }
        
        isLoading = true
        let db = Firestore.firestore()
        
        let updatedData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "school": school,
            "birthday": birthday,
            "interests": interests,
            "lastUpdated": Date()
        ]
        
        db.collection("users").document(userId).updateData(updatedData) { error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                dismiss()
            }
        }
    }
} 