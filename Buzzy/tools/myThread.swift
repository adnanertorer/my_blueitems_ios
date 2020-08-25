//
//  myThread.swift
//  Buzzy
//
//  Created by Ozum Ertorer on 24.08.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import Foundation
import CoreBluetooth
import Alamofire
import SwiftyJSON

class myThread: Thread, CBPeripheralDelegate
{
    var rssiValue = "";
    var peripheral:CBPeripheral!
    var centralManager:CBCentralManager!
    var isConnect = false
    var counter = 0;
    var counterAudio = 0;
    var sumRssi = 0;
    var scanAudioDevice = false;
    var scanBluetoothDevice = false;
    
    override func main() {
        if !stopProtect{
            if peripheral != nil{
                peripheral.delegate = self;
                centralManager.connect(peripheral, options: nil);
            }
            while(!stopProtect) {
                print(rssiValue);
                if scanBluetoothDevice{
                    if !isConnect{
                        if peripheral != nil{
                            centralManager.connect(peripheral, options: nil)
                        }
                        peripheral.readRSSI()
                        
                    }
                }
                if UserDefaults.standard.double(forKey: "notificationDelay") != 0{
                    Thread.sleep(forTimeInterval: UserDefaults.standard.double(forKey: "notificationDelay"));
                }else{
                    Thread.sleep(forTimeInterval: 4);
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print(RSSI.stringValue)
        if UserDefaults.standard.double(forKey: "scanFrequency") != 0{
            
            if(RSSI.doubleValue < UserDefaults.standard.double(forKey: "scanFrequency")){
                let bazzyTool = BazzyTools();
                counter = counter+1;
                if(counter <= bazzyTool.TotalLimit()){
                    sumRssi = sumRssi+RSSI.intValue;
                    print(sumRssi)
                }else{
                    counter = 0;
                    let valueProximitly = sumRssi / bazzyTool.TotalLimit();
                    sumRssi = 0;
                    print("uzakta")
                    self.Notification(signal: valueProximitly, deviceName: peripheral.name ?? "unnamed device"){ responseObject, error in
                        // use responseObject and error here
                        print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
                        return
                    };
                }
            }
        }else{
            if(RSSI.intValue < -90){
                print("uzakta")
                // MARK: -SendNotification
                self.Notification(signal: RSSI.intValue, deviceName: peripheral.name ?? "unnamed device"){ responseObject, error in
                    // use responseObject and error here,
                    
                    print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
                    return
                };
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Baglandi")
        isConnect = true
        //self.centralManager.stopScan()
        peripheral.readRSSI()
    }
    // MARK: -ServerOperations
    
    func Notification(signal:Int, deviceName:String, completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        makeCall("AddNotifyRequest", deviceName: deviceName, signal: signal, completionHandler: completionHandler)
    }
    
    func makeCall(_ section: String, deviceName:String, signal:Int, completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        let userId = UserDefaults.standard.integer(forKey: "userId");
        let bazzyTool = BazzyTools();
        let apiAddres = bazzyTool.getApiAddress();
        let parameters: [String: Int] = [
            "userId":userId,
            "signal":signal
        ];
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
   /* func sendNotification(){
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = "debitOverdraftNotification"
            content.title = "Device!"
            content.subtitle = "Are you forget?"
            content.body = "Did you take your device with you?"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        }
    }*/
}
