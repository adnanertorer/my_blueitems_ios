//
//  AudioProtectionStartViewController.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 17.08.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit
import AVFoundation

class AudioProtectionStartViewController: UIViewController, AVAudioPlayerDelegate {

    
    var mySelectedCustomPeripheral: MyPeripheral!
    @IBOutlet weak var btnStartProtection: UIButton!
    var audioPlayer:AVAudioPlayer!
    
    @IBAction func startProtection(_ sender: Any) {
        deviceArray.append(mySelectedCustomPeripheral);
        audioProtected = true;
       // get a reference to the app delegate
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

        // call didFinishLaunchWithOptions ... why?
        appDelegate?.startAuido()
        
        let alert = UIAlertController(title: "Bazzy", message: "Device added to protected device list. ", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil);
        }))
        self.present(alert, animated: true, completion: nil);
        
    }
    @IBOutlet weak var imgAudio: UIImageView!
    @IBOutlet weak var txtDescription: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - AudioSessionConfiguration
       
        
        // Do any additional setup after loading the view.
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
