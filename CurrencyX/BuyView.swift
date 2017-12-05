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

// Adding background to Price Stack View
public extension UIView {
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

class BuyView: UIViewController, UITextFieldDelegate {
    
    // UI Variable Initailize
    @IBOutlet weak var priceStackView: UIStackView!
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
        pinBackground(backgroundView, to: priceStackView)
        buyInput.delegate = self
        totalLabel.text = "0.0"
        currNameLbl.text = buyData.symbol
        toCurrency.text = "$" + String(buyData.price_usd)
       // buyInput.keyboardType = UIKeyboardType.decimalPad
        
//        let tapRecognizer = UITapGestureRecognizer()
//        tapRecognizer.addTarget(self, action: #selector(BuyView.didTapView))
//        self.view.addGestureRecognizer(tapRecognizer)
//        buyButtonLbl.isHidden = true
        
        //FirebaseApp.configure()
        //refPurchase = Database.database().reference()
        
    }
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 30.0
        return view
    }()
    
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
    }
    
//    @objc func didTapView()
//    {
//        self.view.endEditing(true)
//        if(buyInput.text != "")
//        {
//            convertCurrency()
//        }
//        buyButtonLbl.isHidden = false
//    }

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
    
    func addPurchaseToDatabase()
    {
        refPurchase = Database.database().reference()
        

        let purchase = ["date": purchaseItem.datePurchase as String,
                        "purchasedCurrency": purchaseItem.purchaseCurrency as String,
                        //"usedCurrency": purchaseItem.usedCurrency as String,
                        "purchasedAmount": String(purchaseItem.amountPurchased) as String,
                        "priceTotal": String(purchaseItem.pricePurchase) as String]

        refPurchase.child("Purchase").child((user?.uid)!).childByAutoId().setValue(purchase)
        
        print("Purchase added to database")
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        buyInput.resignFirstResponder()
        convertCurrency()
        return true
    }
    
    
    @IBAction func acceptButton(_ sender: Any)
    {
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        purchaseItem.amountPurchased = Double(buyInput.text!)!
        if(totalLabel.text != nil){
             purchaseItem.pricePurchase = Double(totalLabel.text!)!
        }else{
            print("totaLabel not found")
        }
       
        purchaseItem.purchaseCurrency = toCurrency.text!
        //purchaseItem.usedCurrency = fromCurrency.text!
        purchaseItem.datePurchase = "Date: \(day) - \(month) - \(year)"
        
        //addPurchaseToDatabase()
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
    
//    func addToPurchaseList()
//    {
//
//    }
    
    func convertCurrency()
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
