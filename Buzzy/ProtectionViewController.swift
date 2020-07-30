//
//  ProtectionViewController.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 14.07.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit

class ProtectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func stopProtection(_ sender: Any) {
        stopProtect = true
        protected = false
        let alert = UIAlertController(title: "Buzzy", message: "Protection has been terminated", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil);
            exit(0)
        }))
        self.present(alert, animated: true, completion: nil);
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
