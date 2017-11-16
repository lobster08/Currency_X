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
    @IBOutlet weak var currNameLbl: UILabel!
    @IBOutlet weak var toCurrency: UILabel!
    @IBOutlet weak var buyButtonLbl: UIButton!
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    // Data Variable Initialize
    let date = Date()
    let calendar = Calendar.current
    var purchaseHist = [PurchaseInfo]()
    var purchaseItem = PurchaseInfo()
    var buyData = CryptoCurrency()
    
    
    // Firebase Variable Initailize
    var refPurchase: DatabaseReference!
    var user = Auth.auth().currentUser
    
    // Process
    override func viewDidLoad()
    {
        super.viewDidLoad()
        backgroundImageName = "background6.png"
        setBackgroundImage()
        buyInput.delegate = self
        totalLabel.text = "0.0"
        currNameLbl.text = buyData.symbol
        toCurrency.text = "$" + String(buyData.price_usd)
        buyInput.keyboardType = UIKeyboardType.decimalPad
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(BuyView.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        buyButtonLbl.isHidden = true
        
        //FirebaseApp.configure()
        //refPurchase = Database.database().reference()
        
    }
    
    @objc func didTapView()
    {
        self.view.endEditing(true)
        ConvertCurrency()
        buyButtonLbl.isHidden = false
    }

    func setBackgroundImage() {
        if backgroundImageName > "" {
            backgroundImageView.removeFromSuperview()
            backgroundImage = UIImage(named: backgroundImageName)!
            backgroundImageView = UIImageView(frame: self.view.bounds)
            backgroundImageView.image = backgroundImage
            self.view.addSubview(backgroundImageView)
            self.view.sendSubview(toBack: backgroundImageView)
        }
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
        //purchaseItem.usedCurrency = fromCurrency.text!
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
        //var fromCurr = Double(buyData.price_usd)
        var toCurr = Double(buyData.price_usd)
        totalLabel.text = "$" + String((Double(buyInput.text!)! * toCurr!))
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
