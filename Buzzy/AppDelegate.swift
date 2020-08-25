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
import FirebaseMessaging
import FirebaseCore

import Alamofire
import SwiftyJSON
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    var window: UIWindow?
    var audioPlayer:AVAudioPlayer!
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        player.currentTime = 0
        player.setVolume(0.0, fadeDuration: .zero)
        
        player.play()
        print("tekrar basliyor**********")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: - FirebaseConfiguration
        FirebaseApp.configure();
        
        Messaging.messaging().delegate = self;
        
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
        
         // MARK: - AudioSessionConfiguration
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.moviePlayback, options: [.allowBluetooth,.allowAirPlay,.allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            setInputGain(gain: 0, audioSession: audioSession)
        } catch let error as NSError {
            print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        
        return true
    }
    
    func setInputGain(gain: Float, audioSession:AVAudioSession) {
      if audioSession.isInputGainSettable {
        do {
            try audioSession.setInputGain(gain)
        }catch let error as NSError{
            print("Input gain error: \(error)")
        }
      }
    }
    
    func startAuido() {
        do {
            let url = Bundle.main.url(forResource: "metallica", withExtension: "mp3")
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer.delegate = self;
            audioPlayer.setVolume(0.0, fadeDuration: .zero)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("sessiz mp3 basladi")
        } catch let error as NSError {
            print("Failed to init audio player: \(error)")
        }
    }
    // MARK: - HandleAudioInterruption
    @objc func handleAudioInterruption(notification: Notification) {
        print("interruption start")
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        // Switch over the interruption type.
        switch type {

        case .began:
            // An interruption began. Update the UI as needed.
            print("began audio")
            return
        case .ended:
           // An interruption ended. Resume playback, if appropriate.
            print("ended audio")
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                audioPlayer.currentTime = 0
                audioPlayer.play()
                print("sessiz mp3 basladi")
            } else {
                do {
                    let url = Bundle.main.url(forResource: "metallica", withExtension: "mp3")
                    audioPlayer = try AVAudioPlayer(contentsOf: url!)
                    audioPlayer.delegate = self;
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                    print("sessiz mp3 basladi")
                } catch let error as NSError {
                    print("Failed to init audio player: \(error)")
                }
                // Interruption ended. Playback should not resume.
            }

        default: ()
        }
    }
     // MARK: - AudioDeviceConnectDisconnect
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
        case .categoryChange:
            print("categoryChange")
            break
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            let portList = session.currentRoute.outputs
            for port in portList{
                if port.portType == AVAudioSession.Port.bluetoothA2DP || port.portType == AVAudioSession.Port.airPlay || port.portType == AVAudioSession.Port.bluetoothHFP || port.portType == AVAudioSession.Port.bluetoothLE ||  port.portType == AVAudioSession.Port.headphones ||  port.portType == AVAudioSession.Port.headsetMic {
                    print("ses aygıtı bağlandı")
                    break
                }
            }
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                print(previousRoute.outputs)
                let portList = previousRoute.outputs
                for port in portList{
                    if port.portType == AVAudioSession.Port.bluetoothA2DP || port.portType == AVAudioSession.Port.airPlay || port.portType == AVAudioSession.Port.bluetoothHFP || port.portType == AVAudioSession.Port.bluetoothLE ||  port.portType == AVAudioSession.Port.headphones ||  port.portType == AVAudioSession.Port.headsetMic {
                        // MARK: -SendNotification
                        print("ses aygıtı ile bağlantı koptu")
                        if audioProtected {
                            self.Notification(signal: 0, deviceName: port.portName){ responseObject, error in
                                print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
                                return
                            };
                        }
                        break
                    }
                }
            }
        default: ()
        }
    }
    // MARK: -ServerOperations
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
    
    func Notification(signal:Int, deviceName: String, completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        makeCall("AddNotifyRequest", signal: signal, deviceName: deviceName, completionHandler: completionHandler)
    }
    
    func makeCall(_ section: String, signal:Int, deviceName:String, completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        let userId = UserDefaults.standard.integer(forKey: "userId");
        let bazzyTool = BazzyTools();
        let apiAddres = bazzyTool.getApiAddress();
        let parameters: [String: Any] = [
            "userId":userId,
            "signal":signal,
            "deviceName": deviceName
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
     // MARK: - StartReceiveMessage
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
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
     // MARK: - EndReceiveMessage
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
        completionHandler([[.alert, .sound]])
        
        // Change this to your preferred presentation option
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
     // MARK: - StartRefreshToken
    // [START refresh_token]
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        UserDefaults.standard.set(fcmToken, forKey: "notifyToken")
        //NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
}



