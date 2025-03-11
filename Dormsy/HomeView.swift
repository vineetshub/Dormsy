import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// First, let's define our color scheme at the top of the file
extension Color {
    static let dormsyOrangeLight = Color(uiColor: UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1))  // Orange
    static let dormsyOrangeDark = Color(uiColor: UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1))   // Darker Orange
    static let dormsyPrimary = Color.red  // For swipe left
    static let dormsySecondary = Color.green  // For swipe right
    static let dormsyBackground = Color(.systemGray6) // Light gray background
    static let dormsyText = Color.black
    static let dormsyGray = Color.gray
}

// Add this new struct for the custom tab bar button
struct TabBarButton: View {
    let iconName: String
    let label: String
    let action: () -> Void
    let isSpecial: Bool // For the Dormsy "D" button
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if isSpecial {
                    // Special "D" button
                    Text("D")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.dormsyOrangeLight, Color.dormsyOrangeDark]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(radius: 5)
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
        }
    }
}

// Add this new struct for the swipe buttons
struct SwipeButton: View {
    let isLike: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.white)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: isLike ? "checkmark" : "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.dormsyOrangeLight)
                )
                .shadow(radius: 2)
        }
    }
}

// First, create a new struct for the expanded profile view
struct PromptView: View {
    let prompt: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(prompt)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Text(answer)
                .font(.system(size: 24, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct ExpandedProfileView: View {
    let profile: UserProfile
    let onDismiss: () -> Void
    let onLike: () -> Void
    let onDislike: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Basic info at top
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(profile.name), \(profile.age)")
                        .font(.system(size: 28, weight: .bold))
                    Text(profile.university)
                        .font(.body)
                        .foregroundColor(.gray)
                    Text(profile.location)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Fun prompts
                PromptView(
                    prompt: "My ideal roommate would be...",
                    answer: "someone who understands the importance of both Netflix marathons AND cleaning schedules 😌"
                )
                
                PromptView(
                    prompt: "You'll know it's my room when you see...",
                    answer: "a perfectly organized desk setup with enough RGB lights to signal aliens 👽💻"
                )
                
                PromptView(
                    prompt: "My typical Sunday involves...",
                    answer: "meal prep music blasting, laundry spinning, and trying to convince myself to start homework before 8pm 😅"
                )
                
                PromptView(
                    prompt: "Let's bond over...",
                    answer: "late night coding sessions, basketball games, and deciding whose turn it is to clean the bathroom 🏀🧹"
                )
                
                PromptView(
                    prompt: "My controversial opinion about dorm life is...",
                    answer: "ramen should NOT be the only food group in your diet (yes, I said it!) 🍜"
                )
                
                PromptView(
                    prompt: "Fair warning...",
                    answer: "I'm that person who sets 5 alarms but somehow still needs all of them ⏰😴"
                )
                
                // Space for bottom buttons
                Spacer(minLength: 100)
            }
            .padding(.top, 20)
        }
        .background(Color(uiColor: .systemGray6))
        
        // Bottom buttons overlay
        .overlay(
            HStack(spacing: 100) {
                Button(action: onDislike) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.dormsyOrangeLight)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 2)
                }
                
                Button(action: onLike) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.dormsyOrangeLight)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 2)
                }
            }
            .padding(.bottom, 20)
            , alignment: .bottom
        )
    }
}

// Helper view for profile sections
struct ProfileSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            Text(content)
                .font(.body)
                .lineSpacing(8)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// Update the CardView to handle tapping
struct CardView: View {
    let profile: UserProfile
    @Binding var isExpanded: Bool
    let offset: CGSize
    let swipeThreshold: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Profile Image or placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Text(profile.name.prefix(1))
                        .font(.system(size: 80))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Profile Info
            VStack(alignment: .leading, spacing: 8) {
                Text("\(profile.name), \(profile.age)")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(profile.university)
                    .font(.headline)
                
                Text(profile.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(profile.bio)
                    .font(.body)
                    .lineLimit(3)
            }
            .padding(.horizontal)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .offset(x: offset.width, y: offset.height)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            TapGesture()
                .onEnded { _ in
                    withAnimation(.spring()) {
                        isExpanded = true
                    }
                }
        )
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1), value: offset)
    }
}

struct HomeView: View {
    @State private var profiles: [UserProfile] = []
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var nextCardPosition: CGFloat = UIScreen.main.bounds.width // Start offscreen
    @State private var selectedTab = 2 // Start with home tab selected
    @State private var isProfileExpanded = false
    
    private let db = Firestore.firestore()
    private let userID = Auth.auth().currentUser?.uid
    private let swipeThreshold: CGFloat = 120
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.dormsyOrangeLight, Color.dormsyOrangeDark]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let error = errorMessage {
                    VStack {
                        Text("Error loading profiles")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Button("Retry") {
                            createTestProfiles()
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                } else if profiles.isEmpty {
                    VStack {
                        Text("No more profiles")
                            .font(.title)
                            .foregroundColor(.white)
                        Button("Start Over") {
                            createTestProfiles()
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                } else {
                    // Current card
                    if currentIndex < profiles.count {
                        CardView(
                            profile: profiles[currentIndex],
                            isExpanded: $isProfileExpanded,
                            offset: offset,
                            swipeThreshold: swipeThreshold
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if !isProfileExpanded {
                                        offset = gesture.translation
                                    }
                                }
                                .onEnded { gesture in
                                    if !isProfileExpanded {
                                        let width = gesture.translation.width
                                        let height = gesture.translation.height
                                        let shouldSwipe = abs(width) > swipeThreshold
                                        
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if shouldSwipe {
                                                offset = CGSize(
                                                    width: width > 0 ? 500 : -500,
                                                    height: height
                                                )
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    if currentIndex < profiles.count - 1 {
                                                        currentIndex += 1
                                                        offset = .zero
                                                    } else {
                                                        profiles = []
                                                        createTestProfiles()
                                                    }
                                                }
                                            } else {
                                                offset = .zero
                                            }
                                        }
                                    }
                                }
                        )
                    }
                    
                    // Swipe Buttons
                    if !isProfileExpanded {
                        HStack {
                            SwipeButton(isLike: false) {
                                withAnimation {
                                    handleSwipe(-swipeThreshold - 1)
                                }
                            }
                            .padding(.leading, 40)
                            
                            Spacer()
                            
                            SwipeButton(isLike: true) {
                                withAnimation {
                                    handleSwipe(swipeThreshold + 1)
                                }
                            }
                            .padding(.trailing, 40)
                        }
                        .padding(.vertical, 20)
                    }
                }
                
                Spacer()
                
                // Custom Tab Bar
                if !isProfileExpanded {
                    HStack(spacing: 30) {
                        TabBarButton(
                            iconName: "person.fill",
                            label: "Profile",
                            action: { selectedTab = 0 },
                            isSpecial: false
                        )
                        
                        TabBarButton(
                            iconName: "message.fill",
                            label: "Messages",
                            action: { selectedTab = 1 },
                            isSpecial: false
                        )
                        
                        TabBarButton(
                            iconName: "d.circle.fill",
                            label: "Home",
                            action: { selectedTab = 2 },
                            isSpecial: true
                        )
                        
                        TabBarButton(
                            iconName: "cart.fill",
                            label: "Shop",
                            action: { selectedTab = 3 },
                            isSpecial: false
                        )
                        
                        TabBarButton(
                            iconName: "gearshape.fill",
                            label: "Settings",
                            action: { selectedTab = 4 },
                            isSpecial: false
                        )
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity) // Makes the tab bar stretch full width
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.dormsyOrangeLight, Color.dormsyOrangeDark]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            
            // Expanded Profile View
            if isProfileExpanded, currentIndex < profiles.count {
                ExpandedProfileView(
                    profile: profiles[currentIndex],
                    onDismiss: { isProfileExpanded = false },
                    onLike: {
                        isProfileExpanded = false
                        handleSwipe(swipeThreshold + 1)
                    },
                    onDislike: {
                        isProfileExpanded = false
                        handleSwipe(-swipeThreshold - 1)
                    }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            createTestProfiles()
        }
    }
    
    private func handleSwipe(_ offsetX: CGFloat) {
        let swipedRight = offsetX > swipeThreshold
        let swipedLeft = offsetX < -swipeThreshold
        
        if swipedRight || swipedLeft {
            let direction = swipedRight ? 1 : -1
            withAnimation(.easeOut(duration: 0.2)) {
                offset.width = CGFloat(direction) * UIScreen.main.bounds.width
            }
            
            // Move to next profile after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if currentIndex < profiles.count - 1 {
                    currentIndex += 1
                    offset = .zero
                } else {
                    profiles = []
                    createTestProfiles()
                }
            }
        } else {
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }
    
    private func createTestProfiles() {
        let testProfiles = [
            UserProfile(
                id: "1",
                name: "Rishab Sanjay",
                age: "20",
                imageURL: nil,
                university: "University of Washington",
                location: "Seattle, WA",
                bio: "Computer Science major looking for a roommate who's clean and organized. I enjoy coding and playing basketball."
            ),
            UserProfile(
                id: "2",
                name: "Alex Chen",
                age: "21",
                imageURL: nil,
                university: "University of Washington",
                location: "Seattle, WA",
                bio: "Engineering student seeking quiet roommate. Early riser, neat and tidy."
            ),
            UserProfile(
                id: "3",
                name: "Sarah Johnson",
                age: "19",
                imageURL: nil,
                university: "University of Washington",
                location: "Seattle, WA",
                bio: "Art major, love keeping my space organized. Looking for a responsible roommate."
            )
        ]
        
        profiles = testProfiles
        currentIndex = 0
        offset = .zero
        nextCardPosition = UIScreen.main.bounds.width
        isLoading = false
    }
}

struct UserProfile: Identifiable {
    let id: String
    let name: String
    let age: String
    let imageURL: String?
    let university: String
    let location: String
    let bio: String
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 
