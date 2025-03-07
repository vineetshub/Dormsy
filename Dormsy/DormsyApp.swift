import SwiftUI
import FirebaseCore
import UIKit  // Import UIKit to access UIApplicationDelegate and UIApplication
import FirebaseAuth
import FirebaseFirestore

// Define the AppDelegate to configure Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Basic Firebase configuration
        FirebaseApp.configure()
        
        // Disable App Check for development
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.set(false, forKey: "FIRAppCheckDebugEnabled_\(bundleId)")
        }
        
        return true
    }
}

@main
struct DormsyApp: App {
    // Register AppDelegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}


