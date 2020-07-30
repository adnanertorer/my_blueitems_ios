//
//  AppDelegate.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 9.07.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit
import UserNotifications
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            UNUserNotificationCenter.current().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
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

class myThread: Thread, CBPeripheralDelegate
{
    var rssiValue = "";
    var peripheral:CBPeripheral!
    var centralManager:CBCentralManager!
    var isConnect = false
    
    override func main() {
        if !stopProtect{
            peripheral.delegate = self;
            centralManager.connect(peripheral, options: nil);
            while(!stopProtect) {
                print(rssiValue);
                if !isConnect{
                    centralManager.connect(peripheral, options: nil)
                }
                peripheral.readRSSI()
                if UserDefaults.standard.double(forKey: "notificationDelay") != 0{
                    Thread.sleep(forTimeInterval: UserDefaults.standard.double(forKey: "notificationDelay"));
                }else{
                    Thread.sleep(forTimeInterval: 4);
                }
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print(RSSI.stringValue)
        if UserDefaults.standard.double(forKey: "scanFrequency") != 0{
            if(RSSI.doubleValue < UserDefaults.standard.double(forKey: "scanFrequency")){
                print("uzakta")
                sendNotification()
            }
        }else{
            if(RSSI.intValue < -90){
                print("uzakta")
                sendNotification()
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Baglandi")
        isConnect = true
        //self.centralManager.stopScan()
        peripheral.readRSSI()
    }
    func sendNotification(){
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = "debitOverdraftNotification"
            content.title = "Device!"
            content.subtitle = "Are you forget?"
            content.body = "Did you take your device with you?"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } 
    }
}

