//
//  AppDelegate.swift
//  test-gtm-swift
//
//  Created by Dmitry Klymenko on 26/3/20.
//  Copyright © 2020 Capibara. All rights reserved.
//

import UIKit
import Firebase

private extension OpaquePointer {
    
    func isNil() -> Bool {
        
        return !self.debugDescription.contains {"123456789abcdef".contains($0.lowercased())}
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func silenceTAGJSClass() {
        
        let tagClass: AnyClass? = NSClassFromString("TAGJSExportedInstructions")
        guard
            var properties = class_copyMethodList(tagClass, nil)
            else {return }
        
        let detourSelector = #selector(AppDelegate.detour_logMessage(with:message:))
        var pointed = properties.pointee
        while( !pointed.isNil() ) {
            
            let methodName = String(cString: sel_getName(method_getName(pointed)))
            if methodName.contains("logMessage") {
                //print(methodName)
                guard let detourMethod = class_getClassMethod(AppDelegate.self, detourSelector)
                    else { return }
                
                class_replaceMethod(tagClass,
                                    method_getName(pointed),
                                    method_getImplementation(detourMethod),
                                    method_getTypeEncoding(pointed))
            }
            
            properties = properties.advanced(by: 1)
            pointed = properties.pointee
        }
    }
    
    func silenceTAGLoggerClass() {
        
        let tagClass: AnyClass? = NSClassFromString("TAGLogger")
        let selectorsToHook = ["info:", "debug:", "warning:", "error:"]
        let detourSelector = #selector(AppDelegate.detour_generic(message:))
        
        for selector in selectorsToHook {
            
            let originalSelector = NSSelectorFromString(selector)
            
            //this will only work for the static methods (type methods)
            guard let originalMethod = class_getClassMethod(tagClass, originalSelector),
                let detourMethod = class_getClassMethod(AppDelegate.self, detourSelector)
                else { return }
            
            class_addMethod(tagClass,
                            detourSelector,
                            method_getImplementation(detourMethod),
                            method_getTypeEncoding(detourMethod)
            )
            
            method_exchangeImplementations(originalMethod, detourMethod)
        }
    }
    
    func silenceGTMLogs() {
        
        self.silenceTAGJSClass()
        self.silenceTAGLoggerClass()
    }

    @objc
    static func detour_generic(message: String) {
        
        //if MY CONDITIONS - LOG MESSAGE OR DUMP ANYWHERE ELSE
        return
    }
    
    @objc
    func detour_logMessage(with: Int, message: String) {
        
        return
    }
    
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        //do best efforts to silence it
        self.silenceGTMLogs()
        
        //send some test events
        Analytics.logEvent("test_event", parameters: ["image_name": "test image", "full_txt":"text"])
        Analytics.logEvent("test_event2", parameters: ["image_name2": "test image", "full_txt2":"text"])
        Analytics.setUserProperty("test", forName:"userProp")

        
        
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

