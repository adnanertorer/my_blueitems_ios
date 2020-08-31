//
//  InAppPurchaseViewController.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 28.08.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import UIKit
import StoreKit

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
}

class InAppPurchaseViewController: UIViewController {
    
    private var purchasedProductIdentifiers: Set<String> = []
    
    var products = [SKProduct]()
    
    let paymentQueue = SKPaymentQueue.default()
    
    override func viewDidAppear(_ animated: Bool) {
        let purchased = UserDefaults.standard.bool(forKey: IAppProduct.autoRenewingSubcrible.rawValue)
        if purchased {
            purchasedProductIdentifiers.insert(IAppProduct.autoRenewingSubcrible.rawValue)
            print("Previously purchased: \(IAppProduct.autoRenewingSubcrible.rawValue)")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! LoginViewController;
            vc.modalPresentationStyle = .fullScreen;
            self.present(vc, animated: true, completion: nil);
        } else {
            print("Not purchased: \(IAppProduct.autoRenewingSubcrible.rawValue)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let products:Set = [IAppProduct.autoRenewingSubcrible.rawValue, IAppProduct.counsumable.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
        
        
        // Do any additional setup after loading the view.
    }
    
    public func isProductPurchased(_ productIdentifier: String) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    @IBAction func purchase(_ sender: Any) {
        if SKPaymentQueue.canMakePayments(){
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = IAppProduct.autoRenewingSubcrible.rawValue
            paymentQueue.add(paymentRequest)
        }else{
            let alert = UIAlertController(title: "Buzzy", message: "Not available", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Okey", style: .default, handler: { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil);
            }))
            self.present(alert, animated: true, completion: nil);
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

extension InAppPurchaseViewController: SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        print(response.products)
        for product in response.products{
            print(product.localizedTitle)
        }
    }
    
    
}

extension InAppPurchaseViewController:SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            print(transaction.transactionState)
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            if transaction.transactionState.status() == "failed"{
                fail(transaction: transaction)
                //paymentQueue.finishTransaction(transaction)
            }
            if transaction.transactionState.status() == "purchased"{
                complete(transaction: transaction)
                // paymentQueue.finishTransaction(transaction)
            }
            if transaction.transactionState.status() == "restored"{
                restore(transaction: transaction)
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! LoginViewController;
        vc.modalPresentationStyle = .fullScreen;
        self.present(vc, animated: true, completion: nil);
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! LoginViewController;
        vc.modalPresentationStyle = .fullScreen;
        self.present(vc, animated: true, completion: nil);
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}

extension SKPaymentTransactionState{
    func status() -> String {
        switch self {
        case .deferred:
            return "deferred"
        case .failed:
            print()
            return "failed"
        case .purchased:
            return "purchased"
        case .restored:
            return "restored"
        case .purchasing:
            return "purchasing"
        @unknown default:
            return "unknow"
        }
    }
}
