import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var isLoggedIn = false
    @State private var navigateToHome = false
    @State private var rememberMe = false
    @AppStorage("savedEmail") private var savedEmail = ""
    @AppStorage("isRemembered") private var isRemembered = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange.opacity(0.7),
                        Color.orange
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo and Title
                    VStack(spacing: 25) {
                        Image(systemName: "bed.double")
                            .resizable()
                            .frame(width: 80, height: 50)
                            .foregroundColor(.black)
                        
                        Text("dormsy")
                            .font(.custom("Avenir-Heavy", size: 42))
                            .foregroundColor(.white)
                    }
                    
                    // Login Form
                    VStack(spacing: 20) {
                        // Email Field
                        TextField("", text: $email)
                            .placeholder(when: email.isEmpty) {
                                Text(email.isEmpty ? email : "Email")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .font(.custom("Avenir-Medium", size: 16))
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        // Password Field
                        SecureField("", text: $password)
                            .placeholder(when: password.isEmpty) {
                                Text("Password")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .font(.custom("Avenir-Medium", size: 16))
                            .textContentType(.password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.custom("Avenir-Medium", size: 14))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        // Remember Me Checkbox
                        HStack {
                            Button(action: {
                                rememberMe.toggle()
                            }) {
                                HStack {
                                    Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                        .foregroundColor(rememberMe ? .white : .white.opacity(0.6))
                                    Text("Remember Me")
                                        .font(.custom("Avenir-Medium", size: 14))
                                        .foregroundColor(.white)
                                }
                            }
                            Spacer()
                        }
                        
                        // Login Button
                        Button(action: login) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .frame(height: 50)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                } else {
                                    Text("Login")
                                        .font(.custom("Avenir-Heavy", size: 16))
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Create Account Link
                    HStack {
                        Text("New User?")
                            .foregroundColor(.white)
                        NavigationLink("Create account here", destination: SignUpView())
                            .foregroundColor(.white)
                            .underline()
                    }
                    .font(.custom("Avenir-Medium", size: 16))
                    .padding(.bottom, 30)
                    
                    NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                        EmptyView()
                    }
                }
            }
            .onAppear {
                if isRemembered, !savedEmail.isEmpty {
                    email = savedEmail
                    rememberMe = true
                }
            }
        }
    }

    private func login() {
        isLoading = true
        errorMessage = "" // Clear any previous error message
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error as NSError? {
                switch error.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    errorMessage = "Incorrect password"
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Invalid email address"
                case AuthErrorCode.userNotFound.rawValue:
                    errorMessage = "No account found with this email"
                default:
                    errorMessage = "Unable to sign in"
                }
            } else {
                if rememberMe {
                    savedEmail = email
                    isRemembered = true
                } else {
                    savedEmail = ""
                    isRemembered = false
                }
                isLoggedIn = true
                navigateToHome = true
            }
        }
    }
}

struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: AnyView

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                placeholder
                    .padding(.leading, 15)
            }
            content
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            modifier(PlaceholderStyle(showPlaceHolder: shouldShow,
                                    placeholder: AnyView(placeholder())))
    }
}

struct SignUpView: View {
    var body: some View {
        Text("Sign Up View")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
} 