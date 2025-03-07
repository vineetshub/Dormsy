import SwiftUI
import FirebaseFirestore

public struct MatchesView: View {
    public init() {}
    
    public var body: some View {
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
                            MatchCard()
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
    }
}

struct MatchCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Profile Image
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

public struct MarketplaceView: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(1...10, id: \.self) { _ in
                        ProductCard()
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
    }
}

struct ProductCard: View {
    var body: some View {
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

public struct MessagesView: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(1...10, id: \.self) { _ in
                    MessageRow()
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Messages")
        }
    }
}

struct MessageRow: View {
    var body: some View {
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