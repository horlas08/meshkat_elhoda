import Flutter
import UIKit
import UserNotifications
import AVFoundation
import BackgroundTasks
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Register for push notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .criticalAlert]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { granted, error in
                    if granted {
                        print("✅ Notification permission granted")
                    } else if let error = error {
                        print("❌ Notification permission error: \(error.localizedDescription)")
                    }
                }
            )
        }
        
        application.registerForRemoteNotifications()
        
        // Register background tasks
        if #available(iOS 13.0, *) {
            registerBackgroundTasks()
        }
        
        // Initialize Google Maps SDK (iOS-specific key from Firebase)
        GMSServices.provideAPIKey("AIzaSyBvhRpDGH8cx71K9CUkF5GUygIzJNJWCCs")
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Background Tasks
    
    /// Register background tasks for iOS 13+.
    @available(iOS 13.0, *)
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.meshkatelhoda.pro.refresh",
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        print("✅ Background tasks registered")
    }
    
    /// Handle background app refresh.
    @available(iOS 13.0, *)
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new refresh task
        scheduleAppRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // The Flutter app will handle the actual refresh logic
        task.setTaskCompleted(success: true)
    }
    
    /// Schedule app refresh.
    @available(iOS 13.0, *)
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.meshkatelhoda.pro.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Scheduled app refresh task")
        } catch {
            print("❌ Could not schedule app refresh: \(error)")
        }
    }
    
    // MARK: - Notification Handling
    
    /// Handle notification when app is in foreground.
    @available(iOS 10.0, *)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    /// Handle notification tap.
    @available(iOS 10.0, *)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
    // MARK: - Remote Notifications
    
    /// Handle remote notification registration.
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Pass token to Flutter
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    /// Handle remote notification registration failure.
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - App Lifecycle
    
    override func applicationWillResignActive(_ application: UIApplication) {
        // App is about to become inactive
        print("📱 App will resign active")
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        // App entered background - schedule background refresh
        if #available(iOS 13.0, *) {
            scheduleAppRefresh()
        }
        print("📱 App entered background")
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        // App is about to enter foreground
        print("📱 App will enter foreground")
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        // App became active
        print("📱 App became active")
    }
}
