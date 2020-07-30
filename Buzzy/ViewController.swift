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

class ViewController: UIViewController, UITableViewDataSource,
UITableViewDelegate, CBPeripheralDelegate, CBCentralManagerDelegate, UITabBarDelegate  {

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    var peripherals:Array<CBPeripheral>!
    var myPeriperals:Array<MyPeripheral>!
    var uuid = ""
    var isConnect = false;
    @IBOutlet weak var tableView: UITableView!
    var devices = [String:CBPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        let protectPhoneCategory = UNNotificationCategory(identifier: "protectPhoneCategory", actions: [], intentIdentifiers: [], options: []);
        UNUserNotificationCenter.current().setNotificationCategories([protectPhoneCategory]);
        self.peripherals = Array<CBPeripheral>.init();
        self.myPeriperals = Array<MyPeripheral>.init();
        centralManager = CBCentralManager(delegate: self, queue: nil);
    }
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
             //   let connecteds = centralManager.retrievePeripherals(withIdentifiers: <#T##[UUID]#>)
                let connectedDevices = centralManager.retrieveConnectedPeripherals(withServices: [infoServiceId])
                
                for device in connectedDevices {
                    let perpClass = MyPeripheral(name:device.name ?? "isimsiz cihaz", perp: device, uuid: device.identifier.uuidString)
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
                        }
                    }
                }
                
                tableView.reloadData();
            /*centralManager.scanForPeripherals(withServices: nil,
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true]);*/
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let peripheralName = peripheral.name ?? "isimsiz cihaz";
       // if peripheralName != "isim yok"{
            let perpClass = MyPeripheral(name:peripheralName, perp: peripheral, uuid: peripheral.identifier.uuidString)
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
                }
            }
        
            tableView.reloadData();
       // }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPeriperals.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! DeviceTableViewCell
        //let peripheral = Array(myPeriperals)[indexPath.row].peripheral;
        if Array(myPeriperals)[indexPath.row].peripheral.state == .connected{
            cell.imgDeviceConnection.tintColor = UIColor.green;
        }else{
            cell.imgDeviceConnection.tintColor = UIColor.red;
        }
        let deviceName = Array(myPeriperals)[indexPath.row].peripheral.name ?? "isimsiz cihaz";
        cell.lblDeviceName.text = deviceName;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        centralManager.stopScan();
        selectedPeripheral = Array(myPeriperals)[indexPath.row].peripheral;
        uuid = selectedPeripheral.identifier.uuidString;
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "peripheralView") as? PeripheralViewController
        self.show(vc!, sender: nil)
    }
    
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
    var peripheral: CBPeripheral!
    var uuid:String!
    init(name :String, perp :CBPeripheral, uuid: String) {
        self.peripheral = perp
        self.peripheralName = name
        self.uuid = uuid
    }
}
