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
var serviceId = CBUUID(string: "9FA480E0-4967-4542-9390-D343DC5D04AE")
var charId = CBUUID(string: "8667556C-9A37-4C91-84ED-54EE27D90049")
var protected = false
var stopProtect = false
