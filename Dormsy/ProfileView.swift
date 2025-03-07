import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI
import FirebaseStorage

public struct ProfileView: View {
    public let userID: String
    @State private var userData: [String: Any]?
    @State private var photoURLs: [String] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    public init(userID: String) {
        self.userID = userID
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.top, 50)
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Profile Header
                    VStack(spacing: 12) {
                        // Profile Photos
                        if !photoURLs.isEmpty {
                            TabView {
                                ForEach(photoURLs, id: \.self) { urlString in
                                    AsyncImage(url: URL(string: urlString)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            .frame(height: 400)
                            .tabViewStyle(PageTabViewStyle())
                        }
                        
                        // Name and Basic Info
                        VStack(spacing: 8) {
                            Text("\(userData?["firstName"] as? String ?? "") \(userData?["lastName"] as? String ?? "")")
                                .font(.custom("Avenir-Heavy", size: 24))
                            
                            if let age = userData?["age"] as? Int {
                                Text("\(age) years old")
                                    .font(.custom("Avenir-Medium", size: 16))
                                    .foregroundColor(.gray)
                            }
                            
                            if let school = userData?["school"] as? String {
                                Text(school)
                                    .font(.custom("Avenir-Medium", size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Interests
                    if let interests = userData?["interests"] as? [String], !interests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Interests")
                                .font(.custom("Avenir-Heavy", size: 18))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(interests, id: \.self) { interest in
                                        Text(interest)
                                            .font(.custom("Avenir-Medium", size: 14))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.pink.opacity(0.1))
                                            .foregroundColor(.pink)
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Edit Profile Button
                    Button(action: {
                        // Handle edit profile action
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Profile")
                        }
                        .font(.custom("Avenir-Medium", size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            fetchUserData()
        }
    }
    
    private func fetchUserData() {
        let db = Firestore.firestore()
        isLoading = true
        
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                self.userData = document.data()
                self.photoURLs = document.data()?["photoURLs"] as? [String] ?? []
                self.isLoading = false
            } else {
                self.errorMessage = "User not found"
                self.isLoading = false
            }
        }
    }
}

#Preview {
    ProfileView(userID: "preview_user_id")
} 