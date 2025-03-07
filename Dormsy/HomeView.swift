import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @State private var name: String = "Terrell"
    @State private var age: String = "28"
    @State private var profileImageURL: String? = nil
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?

    private let db = Firestore.firestore()
    private let userID = Auth.auth().currentUser?.uid

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                VStack {
                    // Profile Image
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 140, height: 140)
                                .overlay(Circle().stroke(Color.orange, lineWidth: 4))

                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: $profileImage)
                    }

                    // Name and Age
                    Text("\(name), \(age)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                // Settings and Profile Buttons
                HStack(spacing: 40) {
                    ProfileButton(icon: "gearshape.fill", label: "Settings")
                    ProfileButton(icon: "pencil.circle.fill", label: "Edit Profile")
                    ProfileButton(icon: "shield.fill", label: "Safety")
                }
                .padding(.top, 20)

                Spacer()

                // Upgrade Section
                VStack(spacing: 10) {
                    Text("Unlock the best features Dormsy has to offer.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))

                    Button(action: {}) {
                        Text("SEE ALL PLANS")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 50)
                }

                Spacer()

                // Bottom Navigation Bar
                HStack {
                    NavigationIcon(icon: "flame.fill", label: "Home")
                    NavigationIcon(icon: "magnifyingglass", label: "Match")
                    NavigationIcon(icon: "star.fill", label: "Marketplace")
                    NavigationIcon(icon: "message.fill", label: "Messages")
                    NavigationIcon(icon: "person.fill", label: "Profile")
                }
                .padding()
                .background(Color.black.opacity(0.2))
            }
            .padding(.top, 50)
        }
        .onAppear(perform: loadProfile)
    }

    // Load profile image from the picker
    func loadImage() {
        if let profileImage = profileImage {
            _ = profileImage.jpegData(compressionQuality: 0.8)
        }
    }

    // Load profile data from Firestore
    func loadProfile() {
        guard let userID = userID else { return }
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.name = data?["name"] as? String ?? "User"
                self.age = data?["age"] as? String ?? "N/A"
                self.profileImageURL = data?["profileImageURL"] as? String
            }
        }
    }
}

// Reusable component for settings buttons
struct ProfileButton: View {
    var icon: String
    var label: String

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
            Text(label)
                .font(.footnote)
                .foregroundColor(.white)
        }
    }
}

// Reusable component for bottom navigation icons
struct NavigationIcon: View {
    var icon: String
    var label: String

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 25))
                .foregroundColor(.white)
            Text(label)
                .font(.footnote)
                .foregroundColor(.white)
        }
    }
}
