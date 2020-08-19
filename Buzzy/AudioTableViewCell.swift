//
//  AudioTableViewCell.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 19.08.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit

class AudioTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
