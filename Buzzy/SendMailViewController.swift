//
//  SendMailViewController.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 9.07.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit
import MessageUI


class SendMailViewController: UIViewController, UITabBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var txtMessage: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtMessage.delegate = self
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func sendMessage(_ sender: Any) {
        showMailComposer()
    }
    func showMailComposer(){
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Buzzy", message: "Your device does not support sending mail", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil);
            }))
            self.present(alert, animated: true, completion: nil);
            return
        }
        if txtMessage.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 > 0 {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients(["prnelektrik@gmail.com"])
            composer.setSubject("Hello")
            composer.setMessageBody(self.txtMessage.text!, isHTML: false)
            present(composer, animated: true)
        }else{
            let alert = UIAlertController(title: "Buzzy", message: "Message cannot be empty.", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil);
            }))
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.tag == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "deviceTableView") as? ViewController
            vc!.modalPresentationStyle = .fullScreen;
            self.show(vc!, sender: nil)
        }
        if item.tag == 1 {
            if selectedPeripheral != nil {
                if protected {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "protectionView") as? ProtectionViewController
                    vc!.modalPresentationStyle = .fullScreen;
                    self.show(vc!, sender: nil)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "peripheralView") as? PeripheralViewController
                    vc!.modalPresentationStyle = .fullScreen;
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
        if item.tag == 2 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsView") as? SettingsViewController
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
extension SendMailViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error{
            controller.dismiss(animated: true) {
                let alert = UIAlertController(title: "Buzzy", message: "There was an error sending mail", preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil);
                }))
                self.present(alert, animated: true, completion: nil);
            }
        }
        var alertMessage = ""
        switch result {
        case .cancelled:
            alertMessage = "You stopped sending mail"
        case .failed:
            alertMessage = "There was an error sending mail"
        case .saved:
            alertMessage = "Mail saved"
        case .sent:
            alertMessage = "Thank you! Your message has been sent. We will contact you as soon as possible."
        @unknown default:
            alertMessage = "There was an unknow error sending mail"
        }
        controller.dismiss(animated: true) {
            let alert = UIAlertController(title: "Buzzy", message: alertMessage, preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil);
            }))
            self.present(alert, animated: true, completion: nil);
        }
    }
}
