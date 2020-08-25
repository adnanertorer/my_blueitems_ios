//
//  AudioControlThread.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 25.08.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import Foundation
import AVFoundation

class AudioControlThread:Thread, AVAudioPlayerDelegate{
    var audioPlayer:AVAudioPlayer!
    override init() {
        super.init()
        // MARK: - AudioSessionConfiguration
       
    }
    func startAudio()  {
        let audioSession = AVAudioSession.sharedInstance()
               do {
                try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.allowBluetooth, .allowAirPlay, .allowBluetoothA2DP, .allowAirPlay, .mixWithOthers])
                   try AVAudioSession.sharedInstance().setActive(true)
               } catch let error as NSError {
                   print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
               }
               
               NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(handleAudioInterruption), name: AVAudioSession.interruptionNotification, object: nil)
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
    }
    override func main() {
        
    }
    // MARK: - WhenCalling
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
                    let url = Bundle.main.url(forResource: "15minutesofsilence", withExtension: "mp3")
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
    
    // MARK: - AudioPlayerStopAndRestart
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("player durdu")
        player.currentTime = 0
        player.play()
    }
    // MARK: - AudioDeviceConnectDisconnect
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
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
                        print("ses aygıtı ile bağlantı koptu")
                        break
                    }
                }
            }
        default: ()
        }
    }
}
