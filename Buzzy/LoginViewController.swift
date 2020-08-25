//
//  LoginViewController.swift
//  Buzzy
//
//  Created by Ozum Ertorer on 7.08.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var btnAppleSign: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSignInAppleButton();
        
        let isLogin = UserDefaults.standard.object(forKey: "loginStatus");
        
        if let login = isLogin as? Bool{
            if(login){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "deviceTableView")
                self.show(vc!, sender: nil)
            }
        }

        // Do any additional setup after loading the view.
    }
    
    func setUpSignInAppleButton() {
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        btnAppleSign.addSubview(appleButton)
        NSLayoutConstraint.activate([
            appleButton.topAnchor.constraint(equalTo: self.btnAppleSign.topAnchor, constant: 0.0),
            appleButton.leadingAnchor.constraint(equalTo: self.btnAppleSign.leadingAnchor, constant: 0.0),
            appleButton.trailingAnchor.constraint(equalTo: self.btnAppleSign.trailingAnchor, constant: 0.0),
            appleButton.bottomAnchor.constraint(equalTo: self.btnAppleSign.bottomAnchor, constant: 0.0),
        ])
    }
    @objc func handleAppleIdRequest() {
       let appleIDProvider = ASAuthorizationAppleIDProvider()
       let request = appleIDProvider.createRequest()
       request.requestedScopes = [.fullName, .email]
       let authorizationController = ASAuthorizationController(authorizationRequests: [request])
       authorizationController.delegate = self
       authorizationController.performRequests()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func login(username: String, token: String){
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        var statusModels = [StatusModel]()
        let bazzyTool = BazzyTools();
        let apiAddres = bazzyTool.getApiAddress();
        let parameters: [String: String] = [
            "username":username,
            "token":token
        ];
        AF.request(apiAddres+"LoginUser", method: .post, parameters: parameters as Parameters).validate().responseJSON{
            response in
            switch response.result{
            case .success(let value):
                loadingNotification.hide(animated: true)
                let json = JSON(value);
                for index in 0...json.count{
                    let status = StatusModel(status: json[index]["status"].intValue, message: json[index]["message"].stringValue);
                    statusModels.append(status);
                }
                if statusModels.count > 0 {
                    print(statusModels[0].message);
                    if statusModels[0].status != 0 {
                        UserDefaults.standard.set(statusModels[0].status, forKey: "userId");
                        UserDefaults.standard.set(true, forKey: "loginStatus");
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "deviceTableView");
                        vc?.modalPresentationStyle = .fullScreen;
                        self.show(vc!, sender: nil);
                    }else{
                        let alert = bazzyTool.getAlert(withName: "Bazzy", message: statusModels[0].message);
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                            alert.dismiss(animated: true, completion: nil);
                        }))
                        self.present(alert, animated: true, completion: nil);
                    }
                }
                
            case .failure(let error):
                print(error);
                loadingNotification.hide(animated: true)
            }
        }
        
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            
            
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userId = appleIDCredential.user;
            let token = UserDefaults.standard.string(forKey: "notifyToken");
            self.login(username: userId, token: token!);
            
            break
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            let token = UserDefaults.standard.string(forKey: "notifyToken");
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.login(username: username, token: token!);
            }
        default:
            break
        }
    }
}
