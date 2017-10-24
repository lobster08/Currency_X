//
//  BuyView.swift
//  CurrencyX
//
//  Created by Kha on 10/15/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

struct PurchaseInfo
{
    var currencyPurchased: Double
    var pricePurchase: Double
    var datePurchase: String
    init() {
        currencyPurchased = 0.0
        pricePurchase = 0.0
        datePurchase = ""
    }
}


class BuyView: UIViewController, UITextFieldDelegate {

    // Initialize
    @IBOutlet weak var buyInput: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    let price: Double = 0.000044
    let date = Date()
    let calendar = Calendar.current
    var purchaseHist = [PurchaseInfo]()
    
    
    // Process
    override func viewDidLoad()
    {
        super.viewDidLoad()
        buyInput.delegate = self
        totalLabel.text = "0.0"
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
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        var purchaseItem = PurchaseInfo()
        purchaseItem.currencyPurchased = Double(buyInput.text!)!
        purchaseItem.pricePurchase = Double(totalLabel.text!)!
        purchaseItem.datePurchase = "Date: \(day) - \(month) - \(year) at \(hour):\(minute)"
        
        purchaseHist.append(purchaseItem)
        
        if(purchaseHist.isEmpty == false)
        {
            for item in purchaseHist
            {
                print(item.datePurchase)
                print("Purchase currency amount: ",item.currencyPurchased)
                print("Currency's Price: ", item.pricePurchase)
            }
        }
    }
    
    func ConvertCurrency()
    {
        totalLabel.text = String((Double(buyInput.text!)! * price))
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
