//
//  AppDelegate.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/7/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var launchedShortcutItem: UIApplicationShortcutItem?
    var makeNewNote = false

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        print ("opened with force touch")
        print (shortcutItem)
        if shortcutItem.type == "com.app.newnote" {
            print ("new note")
            self.makeNewNote = true
            let notificationName = Notification.Name("forceTouchNewNote")
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
        completionHandler(handleShortcut(shortcutItem: shortcutItem))

    }
    // Properties
    
    func applicationDidBecomeActive(application: UIApplication) {
        guard let shortcut = launchedShortcutItem else { return }
        handleShortcut(shortcutItem: shortcut)
        launchedShortcutItem = nil
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
            print (launchedShortcutItem)
            
        }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        return true
    }
    
    
    func handleShortcut( shortcutItem:UIApplicationShortcutItem ) -> Bool {
        
        // Construct an alert using the details of the shortcut used to open the application.
//        let alertController = UIAlertController(title: "Shortcut Handled", message: "\"\(shortcutItem.localizedTitle)\"", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        
//        // Display an alert indicating the shortcut selected from the home screen.
//        window!.rootViewController?.present(alertController, animated: true, completion: nil)
        
        return true
        
    }
    

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "pensiveSwift3")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    

}

