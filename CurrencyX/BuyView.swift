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
    var buyAmount: Double
    var buyTotalPrice: String
    var buyDate: String
    var buyCost: String
    var usedCurrency: String
    init() {
        buyAmount = 0.0
        buyTotalPrice = ""
        buyDate = ""
        buyCost = ""
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
    @IBOutlet weak var buyTotalPriceLbl: UILabel!
    @IBOutlet weak var buyCurrNameLbl: UILabel!
    @IBOutlet weak var buyCostLbl: UILabel!
    @IBOutlet weak var buyButtonLbl: UIButton!
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    // Fields for updating currency
    var default_data: UserDefaults!
    var currentValue: Double!
    var updateTimer : Timer!
    var currSymbol : String!
    
    
    // Data Variable Initialize
    let date = Date()
    let calendar = Calendar.current
    var purchaseHist = [PurchaseInfo]()
    var purchaseItem = PurchaseInfo()
    var buyData = CryptoCurrency()
    
    //currency declaration
    var cryptoData = CryptoCurrency()
    var currencyData = currency()
    var currencyName = ""
    var currencyAmount = 0
    
    var totalPrice : Double = 0.0
    
    // Firebase Variable Initailize
    var ref : DatabaseReference!
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
        buyTotalPriceLbl.text = "0.0"
        buyCurrNameLbl.text = buyData.symbol
        buyCostLbl.text = "$" + String(buyData.price_usd)
        buyInput.keyboardType = UIKeyboardType.decimalPad
        
        default_data = UserDefaults.init(suiteName: "Fetch Data API")
        updateTimer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(BuyView.updateCurrentValue), userInfo: nil, repeats: true)
        
        currencyAmount = DetailView.amount
        
       // currencyAmount = DetailView.readAmount()
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(BuyView.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        buyButtonLbl.isHidden = true
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
    
    @objc func updateCurrentValue(){
        print(self.default_data?.double(forKey: currSymbol) as Any)
    }
    
    @objc func didTapView()
    {
        self.view.endEditing(true)
        if(buyInput.text != "")
        {
            convertCurrency()
        }
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
    
    func addPurchaseToDatabase()
    {
        refPurchase = Database.database().reference()
        

        let purchase = ["date": purchaseItem.buyDate as String,
                        "buyCurrencyName": buyCurrNameLbl.text,
                        "buyCost": buyCostLbl.text,
                        "buyAmount": String(purchaseItem.buyAmount) as String,
                        "buyTotalPrice": String(purchaseItem.buyTotalPrice) as String]
        
        if(purchase.isEmpty){
            buyingAlert(buyAlert: "Purchase not succesful!")
        }else{
            buyingAlert(buyAlert: "Purchase completes successfully!")
        }
        refPurchase.child("Purchase").child((user?.uid)!).childByAutoId().setValue(purchase)
    }
    
    //add purchase information into database (Nicole's Code)
    func addPurchaseInfo()
    {
        if(MainView.isCryptoSelect == true)
        {
            currencyName = cryptoData.name
        }
        else
        {
            currencyName = currencyData.symbol
        }
        ref = Database.database().reference()
        
        let info = [ "data: " :  purchaseItem.buyDate as String, "buyAmount" :  String(purchaseItem.buyAmount) as String, "buyCost" : buyCostLbl.text, "buyTotalPrice": String(purchaseItem.buyTotalPrice) as String, "Type" : "Buy" ]
 
        ref.child("PurchasedInfo").child((user?.uid)!).child(currencyName).childByAutoId().updateChildValues(info)

    }
    // add total amount of currency user owns (Nicole's code)
    func addPurchaseAmountToDatabase(amountInput : String)
    {
        
        if(MainView.isCryptoSelect == true)
        {
            currencyName = cryptoData.name
        }
        else
        {
            currencyName = currencyData.symbol
        }
        ref = Database.database().reference()
        
        currencyAmount = currencyAmount + Int(amountInput)!

        let amount = [ "Amount: " : String(currencyAmount) as String]
        ref.child("PurchasedAmount").child((user?.uid)!).child(currencyName).updateChildValues(amount)

    }
    
    // Alert user if the purchasing is sucessful or not after buying
    func buyingAlert(buyAlert:String){
        let alert = UIAlertController(title: buyAlert, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buyButton(_ sender: Any)
    {
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        if Double(buyInput.text!) != nil{
            purchaseItem.buyAmount = Double(buyInput.text!)!
        }else{
            print("Double(buyInput.text) = nil")
        }
        
        if (buyTotalPriceLbl.text != nil){
            purchaseItem.buyTotalPrice = buyTotalPriceLbl.text!
        } else{
            print("totalPrice = nil")
        }
        
        purchaseItem.buyCost = buyCostLbl.text!
        purchaseItem.buyDate = "\(day) - \(month) - \(year)"
        
        addPurchaseToDatabase()
        addPurchaseAmountToDatabase(amountInput: buyInput.text!)
        addPurchaseInfo()
        
        //knguyen0713@gmail.com
    }
    
    func convertCurrency()
    {
        //var fromCurr = Double(buyData.price_usd)
        let toCurr = Double(buyData.price_usd)
        totalPrice = Double(buyInput.text!)! * toCurr!
        buyTotalPriceLbl.text = "$" + String(totalPrice)
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
