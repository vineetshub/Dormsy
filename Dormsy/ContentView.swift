import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Logod
                Image("DormsyLogo") // Use the name you assigned in Assets
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 60)

                // Welcome Text
                Text("dormsy")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 0)

                Text("Your all-in-one app for dorm life")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 40)

                Spacer()

                // Arrow Button
                NavigationLink(destination: LoginView()) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                        Image(systemName: "arrow.right")
                            .foregroundColor(.yellow)
                            .font(.title)
                    }
                }
                .padding(.bottom, 50)
            }
            .multilineTextAlignment(.center)
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
