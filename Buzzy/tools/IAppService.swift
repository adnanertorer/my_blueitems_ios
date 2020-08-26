//
//  IAppService.swift
//  Buzzy
//
//  Created by Adnan Ertorer on 26.08.2020.
//  Copyright © 2020 Almula Yazılım. All rights reserved.
//

import Foundation
import StoreKit

class IAppService:NSObject{
    private override init() {
        
    }
    static let shared = IAppService()
    
    var products = [SKProduct]()
    
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts(){
        let products:Set = [IAppProduct.autoRenewingSubcrible.rawValue, IAppProduct.counsumable.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product: IAppProduct){
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else {
            return
        }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
}

extension IAppService: SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        print(response.products)
        for product in response.products{
            print(product.localizedTitle)
        }
    }
    
    
}

extension IAppService:SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            print(transaction.transactionState)
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            paymentQueue.finishTransaction(transaction)
        }
    }
    
    
}

extension SKPaymentTransactionState{
    func status() -> String {
        switch self {
        case .deferred:
            return "deferred"
        case .failed:
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

