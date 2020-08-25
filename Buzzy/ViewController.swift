//
//  ViewController.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 9.07.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications
import AVFoundation


class ViewController: UIViewController{
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    var peripherals:Array<CBPeripheral>!
    var myPeriperals:Array<MyPeripheral>!
    var uuid = ""
    var isConnect = false;
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    var devices = [String:CBPeripheral]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
         // MARK: - AddRefreshControl
        // Add Refresh Control to Table View
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Getting connected devices ...", attributes: nil)
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshDevices(_:)), for: .valueChanged)
        
        // MARK: -AudioSessionConfiguration
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.allowBluetooth,.allowAirPlay,.allowBluetoothA2DP, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {}
        
        
        let protectPhoneCategory = UNNotificationCategory(identifier: "protectPhoneCategory", actions: [], intentIdentifiers: [], options: []);
        UNUserNotificationCenter.current().setNotificationCategories([protectPhoneCategory]);
        
        // MARK: -InitConfig
        self.peripherals = Array<CBPeripheral>.init();
        self.myPeriperals = Array<MyPeripheral>.init();
        centralManager = CBCentralManager(delegate: self, queue: nil);
    }
    
    // MARK: -RefreshDevice
    @objc private func refreshDevices(_ sender: Any) {
        
        // MARK: -GetAudioDevices
        let availableInputs = AVAudioSession.sharedInstance().availableInputs
        for input in availableInputs!{
            if input.portType.rawValue.starts(with: "Bluetooth"){
                let perAudioClass = MyPeripheral(name: input.portName, perp: nil, uuid: input.uid, type: "Audio");
                if myPeriperals.count == 0 {
                    myPeriperals.append(perAudioClass);
                }else{
                    var status = false;
                    for per in myPeriperals{
                        if per.uuid == perAudioClass.uuid{
                            status = true;
                        }
                    }
                    if !status{
                        myPeriperals.append(perAudioClass);
                    }
                }
                print(input.channels as Any)
                print(input.portName)
                print(input.portType)
                print(input.uid)
                print(input.dataSources ?? "");
            }
            
        }
        
        print(availableInputs as Any);
        
        // MARK: -GetBluetoothConnectionDevices
        
        let connectedDevices = centralManager.retrieveConnectedPeripherals(withServices: [infoServiceId])
        print(connectedDevices);
        for device in connectedDevices {
            let perpClass = MyPeripheral(name:device.name ?? "unnamed decive", perp: device, uuid: device.identifier.uuidString, type: "Peripheral");
            if myPeriperals.count == 0 {
                myPeriperals.append(perpClass);
            }else{
                var status = false;
                for per in myPeriperals{
                    if per.uuid == perpClass.uuid{
                        status = true;
                    }
                }
                if !status{
                    myPeriperals.append(perpClass);
                }
            }
        }
        self.refreshControl.endRefreshing();
        tableView.reloadData();
    }
}

extension ViewController: UITableViewDataSource,
UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return myPeriperals.count;
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell:DeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! DeviceTableViewCell
           //let peripheral = Array(myPeriperals)[indexPath.row].peripheral;
           
           var deviceName = "unnamed device";
        // MARK: -BluetoothDeviceCell
           if Array(myPeriperals)[indexPath.row].type == "Peripheral"{
               deviceName = Array(myPeriperals)[indexPath.row].peripheral?.name ?? "unnamed device";
               let imageBluetooth = UIImage(systemName: "personalhotspot")
               cell.imgDeviceConnection.image = imageBluetooth;
               cell.imgDeviceConnection.tintColor = UIColor.green;
           }
        // MARK: -AudiDeviceCell
           if Array(myPeriperals)[indexPath.row].type == "Audio"{
               deviceName = Array(myPeriperals)[indexPath.row].peripheralName;
               let imageAudio = UIImage(systemName: "speaker.3.fill")
               cell.imgDeviceConnection.image = imageAudio;
               cell.imgDeviceConnection.tintColor = UIColor.green;
           }
           
           cell.lblDeviceName.text = deviceName;
           
           return cell;
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           centralManager.stopScan();
        // MARK: -SelectBluetoothDevice
           if Array(myPeriperals)[indexPath.row].type == "Peripheral"{
               selectedPeripheral = Array(myPeriperals)[indexPath.row].peripheral;
               uuid = selectedPeripheral.identifier.uuidString;
               let vc = self.storyboard?.instantiateViewController(withIdentifier: "peripheralView") as? PeripheralViewController
               vc?.mySelectedCustomPeripheral = Array(myPeriperals)[indexPath.row];
               self.show(vc!, sender: nil)
           }else{
            // MARK: -SelectAudioDevice
               let vc = self.storyboard?.instantiateViewController(withIdentifier: "audioProtectionView") as? AudioProtectionStartViewController
               vc?.mySelectedCustomPeripheral = Array(myPeriperals)[indexPath.row];
               self.show(vc!, sender: nil)
           }
       }
}

extension ViewController:CBPeripheralDelegate, CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
        } else {
            if selectedPeripheral != nil{
                central.retrievePeripherals(withIdentifiers: [selectedPeripheral.identifier])
                let alert = UIAlertController(title: "Buzzy", message: "Device already selected. Redirecting to device screen.", preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil);
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "peripheralView") as? PeripheralViewController
                    self.show(vc!, sender: nil)
                }))
                self.present(alert, animated: true, completion: nil);
                
                
            }else{
               // MARK: -GetAudioDevices
                let availableInputs = AVAudioSession.sharedInstance().availableInputs
                for input in availableInputs!{
                    if input.portType.rawValue.starts(with: "Bluetooth"){
                        let perAudioClass = MyPeripheral(name: input.portName, perp: nil, uuid: input.uid, type: "Audio");
                        if myPeriperals.count == 0 {
                            myPeriperals.append(perAudioClass);
                        }else{
                            var status = false;
                            for per in myPeriperals{
                                if per.uuid == perAudioClass.uuid{
                                    status = true;
                                }
                            }
                            if !status{
                                myPeriperals.append(perAudioClass);
                            }
                        }
                        print(input.channels as Any)
                        print(input.portName)
                        print(input.portType)
                        print(input.uid)
                        print(input.dataSources ?? "");
                    }
                    
                    
                }
                
                print(availableInputs as Any);
                
                // MARK: -GetBluetoothDevices
                let aryUUID = ["180A","1800","1811","1815","180F","183B","1810","181B","181E","181F","1805","1818","1816","180A","183C","181A","1826","1801",
                               "1808","1809","180D","1823","1812","1802","1821","183A","1820","1803","1819","1827","1828","1807","1825","180E","1822","1829","1806",
                               "1814","1813","1824","1804","181C","181D", "2A00", "2A29", "2A23"]
                var aryCBUUIDS = [CBUUID]()
                
                for uuid in aryUUID{
                    let uuids = CBUUID(string: uuid)
                    aryCBUUIDS.append(uuids)
                }
                let connectedDevices = centralManager.retrieveConnectedPeripherals(withServices: aryCBUUIDS)
                for device in connectedDevices {
                    let perpClass = MyPeripheral(name:device.name ?? "unnamed decive", perp: device, uuid: device.identifier.uuidString,
                                                 type: "Peripheral");
                    if myPeriperals.count == 0 {
                        myPeriperals.append(perpClass);
                    }else{
                        var status = false;
                        for per in myPeriperals{
                            if per.uuid == perpClass.uuid{
                                status = true;
                            }
                        }
                        if !status{
                            myPeriperals.append(perpClass);
                        }
                    }
                }
                self.refreshControl.endRefreshing();
                tableView.reloadData();
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let peripheralName = peripheral.name ?? "isimsiz cihaz";
        print(RSSI.intValue);
        print(advertisementData);
        // if peripheralName != "isim yok"{
        let perpClass = MyPeripheral(name:peripheralName, perp: peripheral, uuid: peripheral.identifier.uuidString, type: "Peripheral")
        print(myPeriperals.count)
        
        if myPeriperals.count == 0 {
            myPeriperals.append(perpClass)
        }else{
            var status = false;
            for per in myPeriperals{
                if per.uuid == perpClass.uuid{
                    status = true
                }
            }
            if !status{
                myPeriperals.append(perpClass)
                print(peripheral)
            }
        }
        
        tableView.reloadData();
        // }
    }
}

extension ViewController:UITabBarDelegate{
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

class MyPeripheral{
    
    var peripheralName:String!
    var peripheral: CBPeripheral?
    var uuid:String!
    var type:String!
    init(name :String, perp :CBPeripheral?, uuid: String, type: String) {
        self.peripheral = perp
        self.peripheralName = name
        self.uuid = uuid
        self.type = type
    }
}
