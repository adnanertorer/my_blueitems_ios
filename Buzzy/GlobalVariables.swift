//
//  GlobalVariables.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 9.07.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import Foundation
import CoreBluetooth


var selectedPeripheral:CBPeripheral!
var infoServiceId = CBUUID(string: "180A")
var audioVideoRemoteTarget = CBUUID(string: "110C")
var audioVideoRemote = CBUUID(string: "110E")
var headset = CBUUID(string: "0x111F")
var heartRate = CBUUID(string: "180D")
var AVCTP = CBUUID(string: "0017")
var AVDTP = CBUUID(string: "0019")
var L2CAP = CBUUID(string: "L2CAP")
var HSP = CBUUID(string: "1108")
var A2DP = CBUUID(string: "110A")
var A2DP_B = CBUUID(string: "110B")
var A2DP_C = CBUUID(string: "110D")
var HSP_ = CBUUID(string: "1112")
var HFP = CBUUID(string: "0x111E")
var FFF0 = CBUUID(string: "FFF0")
var battery = CBUUID(string: "2A19")
var manifacturer = CBUUID(string: "2A29")

var serviceId = CBUUID(string: "9FA480E0-4967-4542-9390-D343DC5D04AE")
var jabraId = CBUUID(string: "2d29bbaf-c5df-412f-b3a3-e11019020647")
var charId = CBUUID(string: "8667556C-9A37-4C91-84ED-54EE27D90049")
var protected = false
var stopProtect = false
var audioProtected = false
var audioStopProtected = false

var deviceArray:[MyPeripheral] = [];
