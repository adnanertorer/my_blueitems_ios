//
//  DeviceTableViewCell.swift
//  ProtectMyPhone
//
//  Created by Adnan Ertorer on 7.03.2020.
//  Copyright © 2020 Adnan Ertorer. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var imgDeviceConnection: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
