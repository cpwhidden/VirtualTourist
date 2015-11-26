//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Christopher Whidden on 7/8/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let sqlStore = "VirtualTourist.sqlite"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.sqlStore)
        let store = try? coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        if store == nil {
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let url = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOfURL: url)!
        return model
    }()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        return fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    }()
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            try! managedObjectContext.save()
        }
    }
}

func sharedContext() -> NSManagedObjectContext {
    return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
}