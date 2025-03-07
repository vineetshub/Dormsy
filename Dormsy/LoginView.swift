import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToInterests = false
    @State private var navigateToHome = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FFB347"),  // Warm yellow
                    Color(hex: "FF8C00")   // Dark orange
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 25) {
                Spacer()
                    .frame(height: 60)
                
                // Logo
                Image("DormsyLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150) // Increased from 120 to 150
                    .padding(.bottom, -5) // Reduced from 10 to -5 to bring closer to text

                // Title
                Text("dormsy")
                    .font(.custom("Avenir-Heavy", size: 48)) // Custom font
                    .foregroundColor(.white)
                    .padding(.bottom, 30)

                // Login fields
                VStack(spacing: 20) {
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("", text: $email)
                            .placeholder(when: email.isEmpty) {
                                Text("Email").foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .font(.custom("Avenir-Medium", size: 16))
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("", text: $password)
                            .placeholder(when: password.isEmpty) {
                                Text("Password").foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .font(.custom("Avenir-Medium", size: 16))
                    }
                }
                .padding([.leading, .trailing], 40)

                // Login button
                Button(action: login) {
                    Text("Login")
                        .font(.custom("Avenir-Heavy", size: 18))
                        .foregroundColor(Color(hex: "FF8C00"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding([.leading, .trailing], 40)
                .padding(.top, 20)

                // Error message
                if showError {
                    Text(errorMessage)
                        .font(.custom("Avenir-Medium", size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // New user link
                HStack(spacing: 4) {
                    Text("New User?")
                        .font(.custom("Avenir-Book", size: 16))
                        .foregroundColor(.white)
                    NavigationLink(destination: OnboardingView()) {
                        Text("Create account here")
                            .font(.custom("Avenir-Heavy", size: 16))
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
            
            // Navigation links
            NavigationLink(destination: SetupProfileView(), isActive: $navigateToInterests) {
                EmptyView()
            }
            NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
    }

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showError = true
            } else {
                // Check if profile is complete
                guard let userID = Auth.auth().currentUser?.uid else { return }
                let db = Firestore.firestore()
                db.collection("users").document(userID).getDocument { document, error in
                    if let document = document, document.exists {
                        let isProfileComplete = document.data()?["isProfileComplete"] as? Bool ?? false
                        if isProfileComplete {
                            self.navigateToHome = true
                        } else {
                            self.navigateToInterests = true
                        }
                    } else {
                        self.navigateToInterests = true
                    }
                }
            }
        }
    }
}

// Helper extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
