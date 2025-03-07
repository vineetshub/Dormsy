import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Network

struct InterestsSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedInterests: Set<String> = []
    @State private var searchText = ""
    @State private var showErrorAlert = false
    @State private var navigateToProfile = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    let interests = [
        // Sports & Fitness
        "Basketball", "Football", "Soccer", "Tennis", "Volleyball", "Baseball", "Swimming",
        "Running", "Gym", "CrossFit", "Boxing", "Martial Arts", "Rugby", "Cricket", 
        "Hockey", "Badminton", "Golf", "Rock Climbing", "Hiking", "Cycling",
        "Skateboarding", "Surfing", "Snowboarding", "Skiing", "Ice Skating", "Figure Skating",
        "Cheerleading", "Weightlifting", "Parkour", "Ultimate Frisbee", "Rowing",
        
        // Wellness & Fitness
        "Yoga", "Pilates", "Meditation", "Mindfulness", "Mental Health", "Self Care",
        "Skincare", "Aromatherapy", "Traditional Medicine", "Nutrition",
        
        // Arts & Culture
        "Photography", "Painting", "Drawing", "Sculpture", "Poetry", "Creative Writing",
        "Theater", "Broadway", "Opera", "Ballet", "Contemporary Dance", "Hip Hop Dance",
        "Choir", "Singing", "Karaoke", "Guitar", "Piano", "Drums",
        "Music Production", "DJing", "Film Making", "Acting", "Stand-up Comedy", "Improv",
        "Cosplay", "Anime", "Manga", "Comic Books", "Graphic Design"
    ]

    var body: some View {
        VStack {
            // Header
            HStack {
                Spacer()
                
                Text("Interests")
                    .font(.custom("Avenir-Heavy", size: 32))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(selectedInterests.count) of 5")
                    .font(.custom("Avenir-Medium", size: 16))
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            .padding(.top, 40)
            
            Text("Select your interests")
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundColor(.gray)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchText)
                    .font(.custom("Avenir-Medium", size: 16))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            // Interests Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(filteredInterests, id: \.self) { interest in
                        Button(action: { toggleInterest(interest) }) {
                            Text(interest)
                                .font(.custom("Avenir-Medium", size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(minWidth: 80, maxWidth: .infinity)
                                .background(selectedInterests.contains(interest) ? Color.orange : Color(.systemGray6))
                                .foregroundColor(selectedInterests.contains(interest) ? .white : .black)
                                .cornerRadius(20)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                }
                .padding()
            }

            // Continue Button
            Button(action: saveInterests) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedInterests.count == 5 ? Color.orange : Color.gray.opacity(0.5))
                        .frame(height: 50)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Done")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            .disabled(selectedInterests.count != 5 || isLoading)
            
            NavigationLink(destination: SetupProfileView(), isActive: $navigateToProfile) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var filteredInterests: [String] {
        if searchText.isEmpty {
            return interests
        }
        return interests.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else if selectedInterests.count < 5 {
            selectedInterests.insert(interest)
        }
    }
    
    private func saveInterests() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "Not logged in. Please log in and try again."
            showErrorAlert = true
            return
        }
        
        // Check network connectivity
        guard let reachability = try? Reachability() else {
            errorMessage = "Unable to check network connectivity"
            showErrorAlert = true
            return
        }
        
        guard reachability.connection != .unsatisfied else {
            errorMessage = "No internet connection. Please check your network settings and try again."
            showErrorAlert = true
            return
        }
        
        isLoading = true
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        let userData: [String: Any] = [
            "interests": Array(selectedInterests),
            "lastUpdated": Timestamp(date: Date())
        ]
        
        userRef.updateData(userData) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error saving interests: \(error.localizedDescription)"
                    self.showErrorAlert = true
                } else {
                    self.navigateToProfile = true
                }
            }
        }
    }
}

struct InterestsSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        InterestsSelectionView()
    }
}

class Reachability {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private(set) var connection: NWPath.Status = .requiresConnection
    
    init() throws {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            self?.connection = path.status
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

    


    
