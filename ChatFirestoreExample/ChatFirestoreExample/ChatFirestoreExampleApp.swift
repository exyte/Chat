//
//  ChatFirestoreExampleApp.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {

    static var orientationLock = UIInterfaceOrientationMask.all

    static func lockOrientationToPortrait() {
        AppDelegate.orientationLock = .portrait
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
    }

    static func unlockOrientation() {
        AppDelegate.orientationLock = .all
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let currentOrientation = UIDevice.current.orientation
            let newOrientation: UIInterfaceOrientationMask

            switch currentOrientation {
            case .portrait: newOrientation = .portrait
            case .portraitUpsideDown: newOrientation = .portraitUpsideDown
            case .landscapeLeft: newOrientation = .landscapeLeft
            case .landscapeRight: newOrientation = .landscapeRight
            default: newOrientation = .all
            }

            scene.requestGeometryUpdate(.iOS(interfaceOrientations: newOrientation))
        }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ChatFirestoreExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
