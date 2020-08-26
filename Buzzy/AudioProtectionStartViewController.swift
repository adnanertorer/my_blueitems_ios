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
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.startAuido()
        
        let alert = UIAlertController(title: "Bazzy", message: "Device added to protected device list. ", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil);
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsView") as? SettingsViewController
            vc?.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
            
        }))
        self.present(alert, animated: true, completion: nil);
        
    }
    @IBOutlet weak var imgAudio: UIImageView!
    @IBOutlet weak var txtDescription: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioProtected {
            self.btnStartProtection.isHidden = true
        }else{
            self.btnStartProtection.isHidden = false
        }
        
        
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
        if item.tag == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "deviceTableView") as? ViewController
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
        }
        if item.tag == 1{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsView") as? SettingsViewController
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
        }
        if item.tag == 2{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sendMailView") as? SendMailViewController
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
        }
    }
}
