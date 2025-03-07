import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct OnboardingView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var navigateToProfile = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.custom("Avenir-Heavy", size: 32))
                    .fontWeight(.bold)
                    .padding(.top, 100)
                
                TextField("Email Address", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .foregroundColor(.black)
                    .font(.custom("Avenir-Medium", size: 16))
                    .padding(.horizontal, 40)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                
                SecureField("Create Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .foregroundColor(.black)
                    .font(.custom("Avenir-Medium", size: 16))
                    .padding(.horizontal, 40)

                Button(action: createAccount) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Create Account")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? Color.orange : Color.gray.opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .disabled(!isValid || isLoading)
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }

                Spacer()
                
                NavigationLink(destination: SetupProfileView(), isActive: $navigateToProfile) {
                    EmptyView()
                }
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private var isValid: Bool {
        !email.isEmpty && email.contains("@") && email.contains(".") && password.count >= 6
    }

    private func createAccount() {
        guard !isLoading else { return }
        isLoading = true
        
        print("🔍 Starting account creation process...")
        print("📧 Creating account with email: \(email)")
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("❌ Account creation failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Error creating account: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
                return
            }
            
            guard let user = authResult?.user else {
                print("❌ Failed to get user data after account creation")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to get user data after account creation"
                    self.showErrorAlert = true
                }
                return
            }
            
            print("✅ Account created successfully for user: \(user.uid)")
            
            // Create initial user document in Firestore
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "email": self.email,
                "isProfileComplete": false,
                "createdAt": Timestamp(date: Date())
            ]
            
            db.collection("users").document(user.uid).setData(userData) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        print("❌ Failed to save initial user data: \(error.localizedDescription)")
                        self.errorMessage = "Account created but failed to save profile. Please try again."
                        self.showErrorAlert = true
                        // Clean up: Delete the created auth user if Firestore save fails
                        try? Auth.auth().signOut()
                        user.delete { _ in }
                    } else {
                        print("✅ Initial user data saved successfully!")
                        self.navigateToProfile = true
                    }
                }
            }
        }
    }
}

