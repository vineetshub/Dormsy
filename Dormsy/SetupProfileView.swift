import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PhotosUI
import CoreLocation

public struct SetupProfileView: View {
    @State private var currentStep = 0
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedAge: Int = 18
    @State private var selectedGender: Gender?
    @State private var selectedSchool: String = ""
    @State private var searchText = ""
    @State private var selectedInterests: Set<String> = []
    @State private var showImagePicker = false
    @State private var profileImage: UIImage?
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var navigateToHome = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var displayedImages: [UIImage] = []
    
    public init() {}
    
    enum Gender: String, CaseIterable {
        case male = "Male"
        case female = "Female"
    }
    
    public var body: some View {
        VStack(spacing: 25) {
            // Progress bar
            ProgressView(value: Double(currentStep), total: 6)
                .progressViewStyle(.linear)
                .tint(.pink)
                .padding(.horizontal)
            
            // Content for each step
            switch currentStep {
            case 0:
                nameInputView
            case 1:
                ageSelectionView
            case 2:
                genderSelectionView
            case 3:
                schoolSelectionView
            case 4:
                interestsView
            case 5:
                photoUploadView
            default:
                EmptyView()
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 20) {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .font(.custom("Avenir-Medium", size: 18))
                    .foregroundColor(.pink)
                }
                
                Button(action: handleNextStep) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(currentStep == 5 ? "Finish" : "Next")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canProceed ? Color.pink : Color.gray.opacity(0.5))
                .cornerRadius(12)
                .disabled(!canProceed || isLoading)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Step Views
    
    private var nameInputView: some View {
        VStack(spacing: 25) {
            Text("What's your name?")
                .font(.custom("Avenir-Heavy", size: 32))
            
            TextField("First Name", text: $firstName)
                .textFieldStyle(CustomTextFieldStyle())
                .textInputAutocapitalization(.words)
                .font(.custom("Avenir-Medium", size: 16))
            
            TextField("Last Name", text: $lastName)
                .textFieldStyle(CustomTextFieldStyle())
                .textInputAutocapitalization(.words)
                .font(.custom("Avenir-Medium", size: 16))
        }
    }
    
    private var ageSelectionView: some View {
        VStack(spacing: 25) {
            Text("How Old Are You?")
                .font(.custom("Avenir-Heavy", size: 32))
                .multilineTextAlignment(.center)
            
            Text("Please provide your age in years")
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Picker("Age", selection: $selectedAge) {
                ForEach(18...100, id: \.self) { age in
                    Text("\(age)")
                        .font(.custom("Avenir-Medium", size: 20))
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
        }
    }
    
    private var genderSelectionView: some View {
        VStack(spacing: 25) {
            Text("What's Your Gender?")
                .font(.custom("Avenir-Heavy", size: 32))
                .multilineTextAlignment(.center)
            
            Text("Tell us about your gender")
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 30) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button(action: { selectedGender = gender }) {
                        VStack(spacing: 10) {
                            Circle()
                                .fill(selectedGender == gender ? Color.pink : Color.gray.opacity(0.1))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Text(gender == .male ? "♂" : "♀")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                )
                            
                            Text(gender.rawValue)
                                .font(.custom("Avenir-Medium", size: 20))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding(.top, 20)
        }
        .background(Color.white)
    }
    
    private var schoolSelectionView: some View {
        VStack(spacing: 25) {
            Text("What school do you attend?")
                .font(.custom("Avenir-Heavy", size: 32))
                .multilineTextAlignment(.center)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for your school", text: $searchText)
                    .font(.custom("Avenir-Medium", size: 16))
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            // School list
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(filteredSchools, id: \.self) { school in
                        Button(action: { selectedSchool = school }) {
                            HStack {
                                Text(school)
                                    .font(.custom("Avenir-Medium", size: 16))
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedSchool == school {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.pink)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedSchool == school ? Color.pink.opacity(0.1) : Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedSchool == school ? Color.pink : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding(.horizontal)
    }
    
    private var interestsView: some View {
        VStack(spacing: 25) {
            Text("What are your interests?")
                .font(.custom("Avenir-Heavy", size: 32))
                .multilineTextAlignment(.center)
            
            Text("Select up to 10 interests")
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundColor(.gray)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search interests", text: $searchText)
                    .font(.custom("Avenir-Medium", size: 16))
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            // Selected interests
            if !selectedInterests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(selectedInterests), id: \.self) { interest in
                            HStack {
                                Text(interest)
                                    .font(.custom("Avenir-Medium", size: 14))
                                Button(action: { selectedInterests.remove(interest) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.pink)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.pink.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Interest list
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(filteredInterests, id: \.self) { interest in
                        Button(action: { toggleInterest(interest) }) {
                            HStack {
                                Text(interest)
                                    .font(.custom("Avenir-Medium", size: 16))
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedInterests.contains(interest) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.pink)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedInterests.contains(interest) ? Color.pink.opacity(0.1) : Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedInterests.contains(interest) ? Color.pink : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    // Add custom interest if not found
                    if !searchText.isEmpty && !allInterests.contains(where: { $0.lowercased() == searchText.lowercased() }) {
                        Button(action: { addCustomInterest() }) {
                            HStack {
                                Text("Add \"\(searchText)\" as new interest")
                                    .font(.custom("Avenir-Medium", size: 16))
                                    .foregroundColor(.pink)
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.pink)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.pink, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding(.horizontal)
    }
    
    private var photoUploadView: some View {
        VStack(spacing: 25) {
            Text("Add some photos")
                .font(.custom("Avenir-Heavy", size: 32))
                .multilineTextAlignment(.center)
            
            Text("Choose your best photos to show on your profile")
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Photo grid container
            VStack(spacing: 12) {
                // First row
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        photoCell(at: index)
                    }
                }
                
                // Second row
                HStack(spacing: 12) {
                    ForEach(3..<6) { index in
                        photoCell(at: index)
                    }
                }
            }
            .padding(.horizontal)
            
            if !displayedImages.isEmpty {
                Text("\(displayedImages.count)/6 photos selected")
                    .font(.custom("Avenir-Medium", size: 14))
                    .foregroundColor(.gray)
            }
        }
        .onChange(of: selectedPhotos) { _ in
            Task {
                displayedImages = []
                for item in selectedPhotos {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            displayedImages.append(image)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func photoCell(at index: Int) -> some View {
        let cellSize: CGFloat = (UIScreen.main.bounds.width - 60) / 3 // Account for padding and spacing
        
        if index < displayedImages.count {
            // Display uploaded photo
            ZStack(alignment: .topTrailing) {
                Image(uiImage: displayedImages[index])
                    .resizable()
                    .scaledToFill()
                    .frame(width: cellSize, height: cellSize)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Delete button
                Button(action: { removePhoto(at: index) }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(8)
            }
        } else if index == displayedImages.count {
            // Add photo button
            PhotosPicker(selection: $selectedPhotos,
                        maxSelectionCount: 6,
                        matching: .images) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.pink)
                    Text(displayedImages.isEmpty ? "Add Photos" : "Add More")
                        .font(.custom("Avenir-Medium", size: 14))
                        .foregroundColor(.pink)
                }
                .frame(width: cellSize, height: cellSize)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(12)
            }
        } else {
            // Empty cell
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: cellSize, height: cellSize)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Properties
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !firstName.trim().isEmpty && !lastName.trim().isEmpty
        case 1:
            return selectedAge >= 18
        case 2:
            return selectedGender != nil
        case 3:
            return !selectedSchool.isEmpty
        case 4:
            return !selectedInterests.isEmpty
        case 5:
            return true // Can proceed even without photo
        default:
            return false
        }
    }
    
    private var filteredSchools: [String] {
        let schools = [
            "Rutgers University - New Brunswick",
            "Rutgers University - Camden",
            "Rutgers University - Newark"
        ]
        
        if searchText.isEmpty {
            return schools
        }
        return schools.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    private var allInterests: [String] {
        [
            // Sports
            "Basketball", "Football", "Soccer", "Tennis", "Volleyball", "Baseball",
            "Swimming", "Running", "Gym", "CrossFit", "Boxing", "Martial Arts",
            "Rugby", "Cricket", "Hockey", "Badminton", "Golf", "Rock Climbing",
            
            // Arts & Culture
            "Photography", "Painting", "Drawing", "Music", "Dance", "Theater",
            "Film", "Writing", "Poetry", "Fashion", "Design", "Architecture",
            
            // Technology
            "Programming", "Gaming", "AI", "Robotics", "Web Development",
            "Mobile Apps", "Cybersecurity", "Data Science", "Virtual Reality",
            
            // Lifestyle
            "Cooking", "Baking", "Travel", "Yoga", "Meditation", "Fitness",
            "Reading", "Gardening", "DIY", "Photography", "Blogging",
            
            // Academic
            "Mathematics", "Physics", "Chemistry", "Biology", "History",
            "Philosophy", "Psychology", "Literature", "Economics", "Political Science",
            
            // Entertainment
            "Movies", "TV Shows", "Anime", "Comics", "Board Games",
            "Video Games", "Podcasts", "Stand-up Comedy",
            
            // Music
            "Classical", "Rock", "Jazz", "Hip Hop", "Electronic", "Pop",
            "Singing", "Guitar", "Piano", "Drums",
            
            // Outdoor Activities
            "Hiking", "Camping", "Fishing", "Surfing", "Skiing",
            "Snowboarding", "Mountain Biking", "Kayaking",
            
            // Social Causes
            "Environmental", "Social Justice", "Animal Rights", "Education",
            "Healthcare", "Mental Health", "Community Service"
        ]
    }
    
    private var filteredInterests: [String] {
        if searchText.isEmpty {
            return allInterests
        }
        return allInterests.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    // MARK: - Actions
    
    private func handleNextStep() {
        if currentStep < 5 {
            withAnimation {
                currentStep += 1
            }
        } else {
            saveProfile()
        }
    }
    
    private func saveProfile() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "Not logged in"
            showError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let db = Firestore.firestore()
                let storage = Storage.storage()
                var photoURLs: [String] = []
                
                // First upload photos if any
                if !displayedImages.isEmpty {
                    for (index, image) in displayedImages.enumerated() {
                        guard let imageData = image.jpegData(compressionQuality: 0.7) else { continue }
                        
                        let timestamp = Int(Date().timeIntervalSince1970)
                        let filename = "photo_\(index)_\(timestamp).jpg"
                        let photoRef = storage.reference().child("users/\(userID)/photos/\(filename)")
                        
                        // Create metadata
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                        
                        // Upload the photo with metadata
                        _ = try await photoRef.putData(imageData, metadata: metadata)
                        
                        // Get download URL
                        let downloadURL = try await photoRef.downloadURL()
                        photoURLs.append(downloadURL.absoluteString)
                    }
                }
                
                // Create user data with photo URLs
                let userData: [String: Any] = [
                    "firstName": firstName.trim(),
                    "lastName": lastName.trim(),
                    "age": selectedAge,
                    "gender": selectedGender?.rawValue ?? "",
                    "school": selectedSchool,
                    "interests": Array(selectedInterests),
                    "isProfileComplete": true,
                    "lastUpdated": Timestamp(date: Date()),
                    "photoURLs": photoURLs,
                    "createdAt": Timestamp(date: Date())
                ]
                
                // Save all user data at once
                try await db.collection("users").document(userID).setData(userData, merge: true)
                
                await MainActor.run {
                    isLoading = false
                    navigateToHome = true
                }
            } catch {
                print("Error saving profile: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else if selectedInterests.count < 10 {
            selectedInterests.insert(interest)
        }
    }
    
    private func addCustomInterest() {
        let newInterest = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !newInterest.isEmpty && selectedInterests.count < 10 {
            selectedInterests.insert(newInterest)
            searchText = ""
        }
    }
    
    private func removePhoto(at index: Int) {
        displayedImages.remove(at: index)
        selectedPhotos.remove(at: index)
    }
    
    // MARK: - Navigation
    
    private var mainTabView: some View {
        TabView {
            // MARK: - Matches Tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Stories/Recent Activity
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                // Add Story Button
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.pink.opacity(0.1))
                                            .frame(width: 70, height: 70)
                                        Image(systemName: "plus")
                                            .foregroundColor(.pink)
                                            .font(.system(size: 30))
                                    }
                                    Text("Add Story")
                                        .font(.custom("Avenir-Medium", size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                // Sample Stories
                                ForEach(1...5, id: \.self) { _ in
                                    VStack {
                                        Circle()
                                            .stroke(Color.pink, lineWidth: 2)
                                            .frame(width: 72, height: 72)
                                            .overlay(
                                                Circle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(width: 70, height: 70)
                                            )
                                        Text("User")
                                            .font(.custom("Avenir-Medium", size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Potential Matches
                        VStack(spacing: 15) {
                            ForEach(1...5, id: \.self) { _ in
                                // Match Card
                                VStack(alignment: .leading, spacing: 10) {
                                    ZStack(alignment: .bottomLeading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 400)
                                            .cornerRadius(20)
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Name, 23")
                                                .font(.custom("Avenir-Heavy", size: 24))
                                                .foregroundColor(.white)
                                            Text("Rutgers University • 2 miles away")
                                                .font(.custom("Avenir-Medium", size: 16))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.black.opacity(0.5), .clear]),
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .cornerRadius(20)
                                    }
                                    
                                    // Action Buttons
                                    HStack(spacing: 30) {
                                        Spacer()
                                        Button(action: {}) {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 25))
                                                .foregroundColor(.gray)
                                                .padding(20)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 5)
                                        }
                                        
                                        Button(action: {}) {
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 25))
                                                .foregroundColor(.white)
                                                .padding(20)
                                                .background(Color.pink)
                                                .clipShape(Circle())
                                                .shadow(radius: 5)
                                        }
                                        
                                        Button(action: {}) {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 25))
                                                .foregroundColor(.white)
                                                .padding(20)
                                                .background(Color.yellow)
                                                .clipShape(Circle())
                                                .shadow(radius: 5)
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, -30)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Find Matches")
                .navigationBarItems(
                    leading: Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.pink)
                    },
                    trailing: Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(.pink)
                    }
                )
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Matches")
            }
            
            // MARK: - Marketplace Tab
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(1...10, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 8) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 150)
                                    .cornerRadius(12)
                                
                                Text("Textbook Title")
                                    .font(.custom("Avenir-Heavy", size: 16))
                                
                                Text("$50")
                                    .font(.custom("Avenir-Medium", size: 14))
                                    .foregroundColor(.pink)
                                
                                Text("Condition: Like New")
                                    .font(.custom("Avenir-Medium", size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Marketplace")
                .navigationBarItems(
                    leading: Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.pink)
                    },
                    trailing: Button(action: {}) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.pink)
                    }
                )
            }
            .tabItem {
                Image(systemName: "cart.fill")
                Text("Marketplace")
            }
            
            // MARK: - Messages Tab
            NavigationView {
                List {
                    ForEach(1...10, id: \.self) { _ in
                        HStack(spacing: 15) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("User Name")
                                    .font(.custom("Avenir-Heavy", size: 16))
                                Text("Last message preview...")
                                    .font(.custom("Avenir-Medium", size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("2m ago")
                                .font(.custom("Avenir-Medium", size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Messages")
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Messages")
            }
            
            // MARK: - Profile Tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        VStack(spacing: 12) {
                            // Profile Photos Placeholder
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 400)
                            
                            // Name and Basic Info
                            VStack(spacing: 8) {
                                Text("\(firstName) \(lastName)")
                                    .font(.custom("Avenir-Heavy", size: 24))
                                
                                Text("\(selectedAge) years old")
                                    .font(.custom("Avenir-Medium", size: 16))
                                    .foregroundColor(.gray)
                                
                                Text(selectedSchool)
                                    .font(.custom("Avenir-Medium", size: 16))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Interests
                        if !selectedInterests.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Interests")
                                    .font(.custom("Avenir-Heavy", size: 18))
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(selectedInterests), id: \.self) { interest in
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
                        Button(action: {}) {
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
                .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
