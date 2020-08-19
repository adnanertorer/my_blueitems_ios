//
//  SceneDelegate.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 9.07.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit
import AVFoundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("Track: foreground \(Thread.current)")
        var counter = 0;
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            print("Track: Enter foreground DispatchQueue\(Thread.current)")
            while audioProtected {
                counter = counter+1;
                sleep(1)
                let availableInputs = AVAudioSession.sharedInstance().availableInputs
                for input in availableInputs!{
                    if input.portType.rawValue.starts(with: "Bluetooth"){
                        let result = deviceArray.filter({$0.peripheralName == input.portName});
                        if result.count > 0{
                            print(input.channels as Any)
                            print(input.portName)
                            print(input.portType)
                            print(input.uid)
                            print(input.dataSources ?? "");
                            print(input);
                        }else{
                            print("cihaz yok");
                        }
                    }
                    
                }
            }
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("Track: Background \(Thread.current)")
        var counter = 0;
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            print("Track: Enter Background DispatchQueue\(Thread.current)")
            while audioProtected {
                counter = counter+1;
                sleep(1)
                let availableInputs = AVAudioSession.sharedInstance().availableInputs
                for input in availableInputs!{
                    if input.portType.rawValue.starts(with: "Bluetooth"){
                        let result = deviceArray.filter({$0.peripheralName == input.portName && $0.type == "Audio"});
                        if result.count > 0{
                            print(input.channels as Any)
                            print(input.portName)
                            print(input.portType)
                            print(input.uid)
                            print(input.dataSources ?? "");
                            print(input);
                        }else{
                            print("cihaz yok");
                        }
                    }
                    
                }
            }
        }
    }
    
    
}

