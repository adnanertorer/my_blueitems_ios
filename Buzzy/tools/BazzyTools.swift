//
//  BazzyTools.swift
//  Buzzy
//
//  Created by Ozum Ertorer on 8.08.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import Foundation
import UIKit
class BazzyTools{
    func getApiAddress() -> String {
        return "https://bazzyapi.qonkapp.com/MobileService/"
    }
    func getAlert(withName title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        return alert;
    }
}
