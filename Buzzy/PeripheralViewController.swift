//
//  PeripheralViewController.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 9.07.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import Alamofire
import SwiftyJSON

class PeripheralViewController: UIViewController, CBPeripheralDelegate, CBPeripheralManagerDelegate,
CBCentralManagerDelegate, UITabBarDelegate {
    
    private var peripheral: CBPeripheral!
    var counter = 0;
    var sumRssi = 0;
    var devices = [String:String]()
    var peripherals:Array<CBPeripheral>!
    var timer = Timer()
    public var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var selectedUuıd:String!
    var isConnect = false;
    var rssiStr = ""
    var isFirstConnection = true
    var mySelectedCustomPeripheral: MyPeripheral!
    
    let t = myThread();
    
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var signalBarView: SignalBarView!
    @IBOutlet weak var lblSignal: UILabel!
    @IBOutlet weak var btnProtected: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if protected{
            self.lblDeviceName.text = "Device";
            //centralManager.scanForPeripherals(withServices: nil, options: nil)
            centralManager = CBCentralManager(delegate: self, queue: nil);
            self.peripherals = Array<CBPeripheral>.init();
            let name = selectedPeripheral.name ?? "Non Name"
            self.lblDeviceName.text = name
            self.btnProtected.isHidden = true
            lblDescription.text = "Your device is protected. You can throw the app into the background. But do not close the application.";
            signalBarView.signal = SignalBarView.SignalStrength(rawValue: convertToSignalStrength(value: Float(20)))!
            lblSignal.isHidden = true
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "protectionView") as? ProtectionViewController
            self.show(vc!, sender: nil)
        }else{
            self.lblDeviceName.text = "Cihaz";
            //centralManager.scanForPeripherals(withServices: nil, options: nil)
            centralManager = CBCentralManager(delegate: self, queue: nil);
            self.peripherals = Array<CBPeripheral>.init();
            let name = selectedPeripheral.name ?? "Non Name"
            btnProtected.isHidden = false
            lblSignal.isHidden = false
            self.lblDeviceName.text = name
            peripheralManager = CBPeripheralManager(delegate: self as CBPeripheralManagerDelegate, queue: .global(), options: .none)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        peripheral.services?.filter { $0.uuid == serviceId }.forEach {
            service in
            peripheral.discoverCharacteristics(.none, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        service.characteristics?.forEach { char in
            peripheral.readValue(for: char)
            peripheral.discoverDescriptors(for: char)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        characteristic.descriptors?.forEach { desc in
            print("SERVICE \(desc.characteristic.service.uuid.uuidString), DESC: \(desc)")
        }
    }
    // MARK: -ServerOperations
    func Notification(signal:Int, deviceName:String, completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
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
        print(parameters);
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
    
    func convertToSignalStrength(value: Float) -> Int{
        
        if value < -100 {
            return 1
        }else if value > -100 && value <= -80 {
            return 2
        }else if value > -80 && value <= -75 {
            return 3
        }else if value > -70 && value <= 20 {
            return 4
        }else{
            return 0
        }
    }
    
    func advertise(message:String) {
        let char = CBMutableCharacteristic(type: charId, properties: [.read], value: message.data(using: .utf8), permissions: [.readable]);
        let service = CBMutableService(type: serviceId, primary: true);
        service.characteristics = [char];
        peripheralManager.add(service);
        
        print("advertising service: \(service.uuid), char value: \(String(describing: char.value?.base64EncodedString()))");
        
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceId],
            CBAdvertisementDataLocalNameKey: "Durum"
        ])
        peripheralManager.stopAdvertising();
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // central.stopScan()
        // MARK: -ConnectToPeripheral
        isConnect = true
        if !protected{
            peripheral.delegate = self
            if isFirstConnection{
                isFirstConnection = false
                lblDescription.text = "A connection has been established with your device. You can protect your device."
                let alert = UIAlertController(title: "Connection is ok", message: "You can protect your device!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okey", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
        peripheral.readRSSI()
        //selectedPeripheral.readRSSI()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // MARK: -ReadRSSI
        self.rssiStr = RSSI.stringValue
        let bazzyTool = BazzyTools();
        print(self.rssiStr)
        
        signalBarView.signal = SignalBarView.SignalStrength(rawValue: convertToSignalStrength(value: Float(RSSI.intValue)))!
        self.lblSignal.text = self.rssiStr;
        if(RSSI.intValue < -85){
            // MARK: -DeviceAway
            counter = counter+1;
            print(counter);
            if(counter <= bazzyTool.TotalLimit()){
                sumRssi = sumRssi+RSSI.intValue;
                print("-----toplam-----");
                print(sumRssi);
            }else{
                
                counter = 0;
                let valueProximitly = sumRssi / bazzyTool.TotalLimit();
                print("-----ortalama-----");
                print(valueProximitly);
                sumRssi = 0;
                // MARK: -SendNotification
                self.Notification(signal: valueProximitly, deviceName: peripheral.name ?? "unnamed device"){ responseObject, error in
                    // use responseObject and error here
                    
                    print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
                    return
                };
            }
            
            
        }
        self.advertise(message: self.rssiStr)
        // centralManager.stopScan()
        //timer.invalidate()
        
    }
    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        peripheral.readRSSI()
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
            centralManager?.stopScan()
        case .poweredOn:
           print("poweredOn")
                let connectedDevices = centralManager.retrieveConnectedPeripherals(withServices: [infoServiceId])
                for device in connectedDevices {
                    if !peripherals.contains(device){
                        self.peripherals.append(device)
                    }
                    if device.identifier.uuidString == selectedPeripheral.identifier.uuidString{
                        centralManager.connect(device, options: .none)
                    }
                }
            // centralManager?.scanForPeripherals(withServices: nil, options: nil)
        @unknown default:
            print("Fatal errr")
        }
    }
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if !peripherals.contains(peripheral){
            self.peripherals.append(peripheral)
        }
        
        if peripheral.identifier.uuidString == selectedPeripheral.identifier.uuidString {
            centralManager.connect(peripheral, options: .none)
        }
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            if selectedPeripheral != nil{
                // MARK: -StartTimerForReadRSSI
                timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(delayedAction), userInfo: nil, repeats: true)
            }
        case .poweredOff, .unknown, .unsupported, .resetting, .unauthorized:
            break
        @unknown default:
            break
        }
    }
    
    @objc func delayedAction() {
        if isConnect{
            if selectedPeripheral.state == .connected{
                selectedPeripheral.readRSSI()
            }
        }
    }
    // MARK: -StartProtection
    @IBAction func startPotection(_ sender: Any) {
        if !protected {
            stopProtect = false
            t.scanBluetoothDevice = true
            t.rssiValue = rssiStr;
            t.peripheral = selectedPeripheral;
            t.centralManager = centralManager;
            t.start()
            protected = true
            lblDescription.text = "Your device is protected. You can throw the app into the background. But do not close the application.";
            self.btnProtected.isHidden = true
            deviceArray.append(mySelectedCustomPeripheral);
            let alert = UIAlertController(title: "Bazzy", message: "Device added to protected device list. ", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsView") as? SettingsViewController
                vc!.modalPresentationStyle = .fullScreen;
                self.show(vc!, sender: nil)
            }))
            self.present(alert, animated: true, completion: nil);
            
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsView") as? SettingsViewController
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.tag == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "deviceTableView") as? ViewController
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
        }
        if item.tag == 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsView") as? SettingsViewController
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
        }
        if item.tag == 2 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sendMailView") as? SendMailViewController
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
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
