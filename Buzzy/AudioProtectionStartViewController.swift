//
//  AudioProtectionStartViewController.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 17.08.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit
import AVFoundation

class AudioProtectionStartViewController: UIViewController {

    let t = audioProtectionThread();
    var timer = Timer()
    var counter = 0;
    @IBOutlet weak var btnStartProtection: UIButton!
    @IBAction func startProtection(_ sender: Any) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.allowBluetooth,.allowAirPlay,.allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {}
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            while true{
               self.counter = self.counter+1;
               print(self.counter);
               print("Timer Fired")
                if UserDefaults.standard.double(forKey: "notificationDelay") != 0{
                    Thread.sleep(forTimeInterval: UserDefaults.standard.double(forKey: "notificationDelay"));
                }else{
                    Thread.sleep(forTimeInterval: 4);
                }
            }
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
            }
        }
        
        /*let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
        dispatchQueue.async{
            while true{
               self.counter = self.counter+1;
               print(self.counter);
               print("Timer Fired")
                if UserDefaults.standard.double(forKey: "notificationDelay") != 0{
                    Thread.sleep(forTimeInterval: UserDefaults.standard.double(forKey: "notificationDelay"));
                }else{
                    Thread.sleep(forTimeInterval: 4);
                }
            }
        }
        self.txtDescription.text = "Your device is protected. You can throw the app into the background. But do not close the application.";
        self.btnStartProtection.isHidden = true*/
        
    }
    @IBOutlet weak var imgAudio: UIImageView!
    @IBOutlet weak var txtDescription: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @objc func delayedAction() {
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
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AudioProtectionStartViewController: UITabBarDelegate{
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.tag == 1{
            if selectedPeripheral != nil {
                if protected {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "protectionView") as? ProtectionViewController
                    self.show(vc!, sender: nil)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "peripheralView") as? PeripheralViewController
                    self.show(vc!, sender: nil)
                }
            }else{
                let alert = UIAlertController(title: "Buzzy", message: "Please select a device firts", preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil);
                }))
                self.present(alert, animated: true, completion: nil);
            }
            
        }
        if item.tag == 2{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsView") as? SettingsViewController
            self.show(vc!, sender: nil)
        }
        if item.tag == 3{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sendMailView") as? SendMailViewController
            self.show(vc!, sender: nil)
        }
    }
}
