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
import Firebase
import Alamofire
import SwiftyJSON
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure();
        
        Messaging.messaging().delegate = self;
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications();
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.allowBluetooth,.allowAirPlay,.allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {}
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
      // [START receive_message]
      func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
          // If you are receiving a notification message while your app is in the background,
          // this callback will not be fired till the user taps on the notification launching the application.
          // TODO: Handle data of notification
          // With swizzling disabled you must let Messaging know about the message, for Analytics
          // Messaging.messaging().appDidReceiveMessage(userInfo)
          // Print message ID.
          if let messageID = userInfo[gcmMessageIDKey] {
              print("Message ID: \(messageID)")
          }
          
          // Print full message.
          print(userInfo)
      }
      
      func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
          // If you are receiving a notification message while your app is in the background,
          // this callback will not be fired till the user taps on the notification launching the application.
          // TODO: Handle data of notification
          // With swizzling disabled you must let Messaging know about the message, for Analytics
          // Messaging.messaging().appDidReceiveMessage(userInfo)
          // Print message ID.
          if let messageID = userInfo[gcmMessageIDKey] {
              print("Message ID: \(messageID)")
          }
          // Print full message.
          print(userInfo)
          
          completionHandler(UIBackgroundFetchResult.newData)
      }
      // [END receive_message]
      func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
          print("Unable to register for remote notifications: \(error.localizedDescription)")
      }
      
      // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
      // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
      // the FCM registration token.
      func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          print("APNs token retrieved: \(deviceToken)")
          
          // With swizzling disabled you must set the APNs token here.
          // Messaging.messaging().apnsToken = deviceToken
      }
    
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Track: Background \(Thread.current)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Track: Enter Background DispatchQueue\(Thread.current)")
            for index in 1...10 {
                sleep(1)
                print("Track: After Background DispatchQueue \(index)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        UserDefaults.standard.set(fcmToken, forKey: "notifyToken")
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
}
class audioProtectionThread: Thread{
    var counter = 0;
    override func main() {
        if !audioStopProtected{
           
            /*DispatchQueue.background(delay: 3.0, background: {
                while audioProtected {
                    self.counter = self.counter+1;
                    print(self.counter);
                    let availableInputs = AVAudioSession.sharedInstance().availableInputs
                    for input in availableInputs!{
                        if input.portType.rawValue.starts(with: "Bluetooth"){
                            print(input.channels as Any)
                            print(input.portName)
                            print(input.portType)
                            print(input.uid)
                            print(input.dataSources ?? "");
                        }
                    }
                    print("-------------------------------");
                    if UserDefaults.standard.double(forKey: "notificationDelay") != 0{
                        Thread.sleep(forTimeInterval: UserDefaults.standard.double(forKey: "notificationDelay"));
                    }else{
                        Thread.sleep(forTimeInterval: 4);
                    }
                }
            }, completion: {
                print("tarama bitti");
            })*/
           /* while audioProtected {
                self.counter = self.counter+1;
                print(self.counter);
                
                if UserDefaults.standard.double(forKey: "notificationDelay") != 0{
                    Thread.sleep(forTimeInterval: UserDefaults.standard.double(forKey: "notificationDelay"));
                }else{
                    Thread.sleep(forTimeInterval: 4);
                }
            }*/
        }
    }
    func checkAudioDevice() -> Bool {
        var status = false;
        let availableInputs = AVAudioSession.sharedInstance().availableInputs
        for input in availableInputs!{
            if input.portType.rawValue.starts(with: "Bluetooth"){
                status = true;
                print(input.channels as Any)
                print(input.portName)
                print(input.portType)
                print(input.uid)
                print(input.dataSources ?? "");
            }
        }
        return status;
    }
}
class myThread: Thread, CBPeripheralDelegate
{
    var rssiValue = "";
    var peripheral:CBPeripheral!
    var centralManager:CBCentralManager!
    var isConnect = false
    var counter = 0;
    var counterAudio = 0;
    var sumRssi = 0;
    var scanAudioDevice = false;
    var scanBluetoothDevice = false;
    
    override func main() {
        if !stopProtect{
            if peripheral != nil{
                peripheral.delegate = self;
                centralManager.connect(peripheral, options: nil);
            }
                
            
            while(!stopProtect) {
                print(rssiValue);
                if scanAudioDevice{
                    counterAudio = counterAudio+1;
                    print(counterAudio);
                    
                    if self.checkAudioDevice(){
                        print("kulaklik bagli")
                    }else{
                        print("kulaklik bagli degil")
                    }
                }
                if scanBluetoothDevice{
                    if !isConnect{
                        if peripheral != nil{
                            centralManager.connect(peripheral, options: nil)
                        }
                        peripheral.readRSSI()
                        
                    }
                }
                
                if UserDefaults.standard.double(forKey: "notificationDelay") != 0{
                    Thread.sleep(forTimeInterval: UserDefaults.standard.double(forKey: "notificationDelay"));
                }else{
                    Thread.sleep(forTimeInterval: 4);
                }
            }
        }
    }
    func checkAudioDevice() -> Bool {
        var status = false;
        let availableInputs = AVAudioSession.sharedInstance().availableInputs
        for input in availableInputs!{
            if input.portType.rawValue.starts(with: "Bluetooth"){
                status = true;
                print(input.channels as Any)
                print(input.portName)
                print(input.portType)
                print(input.uid)
                print(input.dataSources ?? "");
            }
        }
        return status;
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print(RSSI.stringValue)
        if UserDefaults.standard.double(forKey: "scanFrequency") != 0{
            
            if(RSSI.doubleValue < UserDefaults.standard.double(forKey: "scanFrequency")){
                let bazzyTool = BazzyTools();
                counter = counter+1;
                if(counter <= bazzyTool.TotalLimit()){
                    sumRssi = sumRssi+RSSI.intValue;
                    print(sumRssi)
                }else{
                    counter = 0;
                    let valueProximitly = sumRssi / bazzyTool.TotalLimit();
                    sumRssi = 0;
                    print("uzakta")
                    self.Notification(signal: valueProximitly){ responseObject, error in
                        // use responseObject and error here
                        print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
                        return
                    };
                }
                //SendNotifyToServer(signal: RSSI.intValue);
            }
        }else{
            if(RSSI.intValue < -90){
                print("uzakta")
                 self.Notification(signal: RSSI.intValue){ responseObject, error in
                                   // use responseObject and error here

                                   print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
                                   return
                               };
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Baglandi")
        isConnect = true
        //self.centralManager.stopScan()
        peripheral.readRSSI()
    }
    func SendNotifyToServer(signal: Int){
        let userId = UserDefaults.standard.integer(forKey: "userId");
        let bazzyTool = BazzyTools();
        let apiAddres = bazzyTool.getApiAddress();
        let parameters: [String: Int] = [
            "userId":userId,
            "signal":signal
        ];
        AF.request(apiAddres+"AddNotifyRequest", method: .post, parameters: parameters, encoding:
        JSONEncoding.default).validate().responseJSON{
            response in
            switch response.result{
            case .success(let value):
                let json = JSON(value);
                
                print(json);
                
            case .failure(let error):
                print(error);
            }
        }
    }
    
    func Notification(signal:Int, completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        makeCall("AddNotifyRequest", signal: signal, completionHandler: completionHandler)
    }

    func makeCall(_ section: String, signal:Int, completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        let userId = UserDefaults.standard.integer(forKey: "userId");
        let bazzyTool = BazzyTools();
        let apiAddres = bazzyTool.getApiAddress();
        let parameters: [String: Int] = [
            "userId":userId,
            "signal":signal
        ];
        AF.request(apiAddres+section, method: .post, parameters: parameters as Parameters).validate().responseJSON{
            response in
            switch response.result{
            case .success(let value):
                print(value)
                completionHandler(value as? NSDictionary, nil);
                
            case .failure(let error):
                print(error);
            }
        }
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

