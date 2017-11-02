//
//  BuyView.swift
//  CurrencyX
//
//  Created by Kha on 10/15/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

struct PurchaseInfo
{
    var amountPurchased: Double
    var pricePurchase: Double
    var datePurchase: String
    var purchaseCurrency: String
    var usedCurrency: String
    init() {
        amountPurchased = 0.0
        pricePurchase = 0.0
        datePurchase = ""
        purchaseCurrency = ""
        usedCurrency = ""
    }
}


class BuyView: UIViewController, UITextFieldDelegate {
    
    // UI Variable Initailize
    @IBOutlet weak var buyInput: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var fromCurrency: UILabel!
    @IBOutlet weak var toCurrency: UILabel!
    
    // Data Variable Initialize
    let date = Date()
    let calendar = Calendar.current
    var purchaseHist = [PurchaseInfo]()
    var purchaseItem = PurchaseInfo()
    var buyData = worldCoinIndex()
    //var currenyPassItem = worldCoinIndex()
    
    // Firebase Variable Initailize
    var refPurchase: DatabaseReference!
    var user = Auth.auth().currentUser
    
    // Process
    override func viewDidLoad()
    {
        super.viewDidLoad()
        buyInput.delegate = self
        totalLabel.text = "0.0"
        fromCurrency.text = String(buyData.Price_usd)
        toCurrency.text = String(buyData.Price_btc)
        //FirebaseApp.configure()
        //refPurchase = Database.database().reference()
        
    }

    func addPurchase()
    {
        refPurchase = Database.database().reference()
        

        let purchase = ["date": purchaseItem.datePurchase as String,
                        "purchasedCurrency": purchaseItem.purchaseCurrency as String,
                        "usedCurrency": purchaseItem.usedCurrency as String,
                        "purchasedAmount": String(purchaseItem.amountPurchased) as String,
                        "priceTotal": String(purchaseItem.pricePurchase) as String]

        refPurchase.child("Purchase").child((user?.uid)!).childByAutoId().setValue(purchase)
        
        print("Purchase added to database")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        buyInput.resignFirstResponder()
        ConvertCurrency()
        return true
    }
    
    @IBAction func clearButton(_ sender: Any)
    {
        buyInput.text = ""
        totalLabel.text = "0.0"
    }
    
    @IBAction func acceptButton(_ sender: Any)
    {
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        purchaseItem.amountPurchased = Double(buyInput.text!)!
        purchaseItem.pricePurchase = Double(totalLabel.text!)!
        purchaseItem.purchaseCurrency = toCurrency.text!
        purchaseItem.usedCurrency = fromCurrency.text!
        purchaseItem.datePurchase = "Date: \(day) - \(month) - \(year)"
        
        addPurchase()
        
        purchaseHist.append(purchaseItem)
        
        if(purchaseHist.isEmpty == false)
        {
            for item in purchaseHist
            {
                print(item.datePurchase)
                print("Currency Purchased: ",item.purchaseCurrency)
                print("Currency Used: ", item.usedCurrency)
                print("Purchase currency amount: ",item.amountPurchased)
                print("Currency's Price: ", item.pricePurchase)
            }
        }
    }
    
    func ConvertCurrency()
    {
        totalLabel.text = String((Double(buyInput.text!)! * Double(buyData.Price_usd))/Double(buyData.Price_btc))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
