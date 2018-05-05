//
//  AppDelegate.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import UserNotifications
import SafariServices
import FirebaseCore
import FirebaseFirestore

enum DeepLink {
  case webView(url: URL)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?
  var firestoreDB: Firestore?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
    // Override point for customization after application launch.

    // Intercept arriving local notifications in
    // userNotificationCenter(_:didReceive:withCompletionHandler) below
    UNUserNotificationCenter.current().delegate = self

    // Setup Firebase
    FirebaseApp.configure()
    firestoreDB = Firestore.firestore()

    // Pick initial view controller depending on if logged in or not
    let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)

    // Get main storyboard from Info.plist
    guard let sbName =
      Bundle.main.object(forInfoDictionaryKey: "UIMainStoryboardFile") as? String
    else { return false }
    let mainStoryboard = UIStoryboard(name: sbName, bundle: nil)

    let startingVC = UserManager.shared.isLoggedIn
      ? mainStoryboard.instantiateInitialViewController()
      : loginStoryboard.instantiateInitialViewController()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = startingVC
    window?.makeKeyAndVisible()
    return true
  }

  /// Presents the appropriate view for a deep link
  func handle(deepLink: DeepLink) {
    let currentVC = window?.rootViewController
    switch deepLink {
    case .webView(let url):
      currentVC?.present(SFSafariViewController(url: url), animated: true)
    }
  }

  // Handle opened local notifications
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
    ) {
    let userInfo = response.notification.request.content.userInfo
    guard
      let str = userInfo["deepLink"] as? String,
      let url = URL(string: str)
    else { return }
    handle(deepLink: DeepLink.webView(url: url))
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an incoming
    // phone call or SMS message) or when the user quits the application and it begins
    // the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics
    // rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough application state information to restore your application to its
    // current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of
    // applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state;
    // here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was
    // inactive. If the application was previously in the background, optionally refresh
    // the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate.
    // See also applicationDidEnterBackground:.
  }

}
