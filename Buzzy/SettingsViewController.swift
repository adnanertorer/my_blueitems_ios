//
//  SettingsViewController.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 9.07.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit
import CoreBluetooth

class SettingsViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var sliderNotificationDelay: UISlider!
    @IBOutlet weak var sliderScanFrequency: UISlider!
    @IBOutlet weak var tableViewBleDevices: UITableView!
    @IBOutlet weak var tableViewHeadsetsIpods: UITableView!
    var bleDevices:[CBPeripheral?] = []
    var audioDevices:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.double(forKey: "notificationDelay") != 0{
            self.sliderNotificationDelay.value = Float(UserDefaults.standard.double(forKey:"notificationDelay"))
        }
        if UserDefaults.standard.double(forKey: "scanFrequency") != 0{
            self.sliderScanFrequency.value = Float(UserDefaults.standard.double(forKey:"scanFrequency"))
        }
        for item in deviceArray{
            if item.type == "Peripheral"{
                self.bleDevices.append(item.peripheral)
                // self.bleDevices.append(item.peripheralName!);
            }
            if item.type == "Audio"{
                self.audioDevices.append(item.peripheralName!);
            }
        }
        tableViewBleDevices.reloadData();
        tableViewHeadsetsIpods.reloadData();
    }
    @IBAction func stopBleProtection(_ sender: Any) {
        stopProtect = true
        protected = false
        for item in self.bleDevices{
            if let array1 = deviceArray.firstIndex(where: { $0.peripheral == item }){
                deviceArray.remove(at: array1)
            }
        }
        self.bleDevices = []
        tableViewBleDevices.reloadData();
        let alert = UIAlertController(title: "Buzzy", message: "Protection of bluetooth devices is stopped", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil);
        }))
        self.present(alert, animated: true, completion: nil);
    }
    
    @IBAction func stopHIProtection(_ sender: Any) {
        audioProtected = false
        let list = deviceArray.filter({$0.type == "Audio"})
        print(list)
        for listItem in list{
            if let deviceIndex = list.firstIndex(where: { $0.peripheralName == listItem.peripheralName}){
                deviceArray.remove(at: deviceIndex)
            }
        }
        audioDevices = []
        tableViewHeadsetsIpods.reloadData();
        let alert = UIAlertController(title: "Buzzy", message: "Protection of audio devices is stopped", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil);
        }))
        self.present(alert, animated: true, completion: nil);
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
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
        }
        if item.tag == 2 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sendMailView") as? SendMailViewController
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
        }
    }
    
}
extension SettingsViewController: UITableViewDataSource,
UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1{
            return self.bleDevices.count;
        }else{
            return self.audioDevices.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1{
            let cell:BleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! BleTableViewCell;
            let peripheral = Array(self.bleDevices)[indexPath.row]
            cell.lblDeviceName.text = peripheral?.name ?? "unnamed device";
            return cell;
        }else{
            let cell:AudioTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellAudio")! as! AudioTableViewCell;
            let deviceName = Array(self.audioDevices)[indexPath.row]
            cell.lblDeviceName.text = deviceName;
            return cell;
        }
    }
}
