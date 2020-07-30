//
//  SettingsViewController.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 9.07.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var sliderNotificationDelay: UISlider!
    @IBOutlet weak var sliderScanFrequency: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.double(forKey: "notificationDelay") != 0{
            self.sliderNotificationDelay.value = Float(UserDefaults.standard.double(forKey:"notificationDelay"))
        }
        if UserDefaults.standard.double(forKey: "scanFrequency") != 0{
            self.sliderScanFrequency.value = Float(UserDefaults.standard.double(forKey:"scanFrequency"))
        }
    }
    
    @IBAction func frequencyChanged(_ sender: Any) {
        print(self.sliderScanFrequency.value)
        let defaults = UserDefaults.standard
        defaults.set(self.sliderScanFrequency.value, forKey: "scanFrequency")
        defaults.synchronize()
    }
    
    @IBAction func notificationDelayChanged(_ sender: Any) {
        print(self.sliderNotificationDelay.value)
        let defaults = UserDefaults.standard
        defaults.set(self.sliderNotificationDelay.value, forKey: "notificationDelay")
        defaults.synchronize()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.tag == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "deviceTableView") as? ViewController
            self.show(vc!, sender: nil)
        }
        if item.tag == 1 {
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
        if item.tag == 3 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sendMailView") as? SendMailViewController
            self.show(vc!, sender: nil)
        }
    }
    
}
