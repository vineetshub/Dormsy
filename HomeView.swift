import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome Message
                        VStack(spacing: 5) {
                            Image(systemName: "bed.double.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.black)
                            
                            Text("dormsy")
                                .font(.custom("Avenir-Heavy", size: 40))
                            
                            Text("Your all-in-one app for dorm life")
                                .font(.custom("Avenir-Medium", size: 18))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Featured Content
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Featured")
                                .font(.custom("Avenir-Heavy", size: 24))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(0..<3) { _ in
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.orange.opacity(0.2))
                                            .frame(width: 280, height: 160)
                                            .overlay(
                                                Text("Coming Soon")
                                                    .font(.custom("Avenir-Medium", size: 16))
                                                    .foregroundColor(.orange)
                                            )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Recent Activity
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recent Activity")
                                .font(.custom("Avenir-Heavy", size: 24))
                                .padding(.horizontal)
                            
                            ForEach(0..<3) { _ in
                                HStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Activity Title")
                                            .font(.custom("Avenir-Medium", size: 16))
                                        Text("Activity Description")
                                            .font(.custom("Avenir-Light", size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                // Bottom Navigation Bar
                HStack(spacing: 60) {
                    NavigationLink(destination: SettingsView()) {
                        VStack {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Settings")
                                .font(.custom("Avenir-Medium", size: 12))
                        }
                        .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Home")
                            .font(.custom("Avenir-Medium", size: 12))
                    }
                    .foregroundColor(.orange)
                    
                    NavigationLink(destination: SafetyView()) {
                        VStack {
                            Image(systemName: "shield.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Safety")
                                .font(.custom("Avenir-Medium", size: 12))
                        }
                        .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
} 