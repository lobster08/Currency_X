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

struct BuyInfo
{
    var buyAmount: Double
    var buyTotalPrice: String
    var buyDate: String
    var buyCost: String
    //var usedCurrency: String
    init() {
        buyAmount = 0.0
        buyTotalPrice = ""
        buyDate = ""
        buyCost = ""
        //usedCurrency = ""
    }
}

// Extension for Price Stack View's Background Setup
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
    
    // UI Variable
    @IBOutlet weak var priceStackView: UIStackView!
    @IBOutlet weak var buyInput: UITextField!
    @IBOutlet weak var buyTotalPriceLbl: UILabel!
    @IBOutlet weak var buyCurrNameLbl: UILabel!
    @IBOutlet weak var buyCostLbl: UILabel!
    @IBOutlet weak var buyButtonLbl: UIButton!
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    // Currency's Cost Update Variables
    var default_data: UserDefaults!
    var currentValue: Double!
    var updateTimer : Timer!
    var currSymbol : String!
    
    // Date Variables
    let date = Date()
    let calendar = Calendar.current
    
    // Data Variables
    var buyItem = BuyInfo()
    var buyCryptoData = CryptoCurrency()
    var buyRegularData = currency()
    var currencyName = ""
    var currencyAmount = 0
    var totalPrice : Double = 0.0
    
    // Firebase Variable Initailize
    var ref : DatabaseReference!
    var refPurchase: DatabaseReference!
    var user = Auth.auth().currentUser
    
//---------------- PROCESS -----------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setup view's background
        backgroundImageName = "background6.png"
        setBackgroundImage()
        pinBackground(backgroundView, to: priceStackView)
        
        // Setup UI labels
        buyInput.delegate = self
        buyTotalPriceLbl.text = "0.0"
        buyCurrNameLbl.text = buyCryptoData.symbol
        buyCostLbl.text = "$" + String(buyCryptoData.price_usd)
        
        // Setup Buy Cost Update variables
//        default_data = UserDefaults.init(suiteName: "Fetch Data API")
//        updateTimer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(BuyView.updateCurrentValue), userInfo: nil, repeats: true)
        
        // Setup currencyAmount for upload to Database
        currencyAmount = DetailView.amount
       
        
        // Setup Keyboard type for TextInput and TapRecognizer
        buyInput.keyboardType = UIKeyboardType.decimalPad
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(BuyView.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        buyButtonLbl.isHidden = true
    }
    
    // ---- Stack View's Background Setup functions ----
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
    
    // ---- Buy Cost Update function ----
//    @objc func updateCurrentValue(){
//        print(self.default_data?.double(forKey: currSymbol) as Any)
//    }
    
    // ---- TapRecognizer Setup functions ----
    @objc func didTapView()
    {
        self.view.endEditing(true)
        if(buyInput.text != "")
        {
            calcualateBuyCost()
        }
        buyButtonLbl.isHidden = false
    }

    // ---- View's Background Setup functions ----
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
    
    // ---- Database Upload functions ----
    func addBuyInfoToDB()
    {
        if(MainView.isCryptoSelect == true)
        {
            currencyName = buyCryptoData.name
        }
        else
        {
            currencyName = buyRegularData.symbol
        }
        ref = Database.database().reference()
        
        let info = [ "data: " :  buyItem.buyDate as String, "buyAmount" :  String(buyItem.buyAmount) as String, "buyCost" : buyCostLbl.text, "buyTotalPrice": String(buyItem.buyTotalPrice) as String, "Type" : "Buy" ]
 
        if(info.isEmpty){
            buyingAlert(buyAlert: "Purchase not succesful!")
        }else{
            buyingAlert(buyAlert: "Purchase completes successfully!")
        }
        ref.child("PurchasedInfo").child((user?.uid)!).child(currencyName).childByAutoId().updateChildValues(info)

    }

    func addOwnCurrAmountToDB(amountInput : String)
    {
        
        if(MainView.isCryptoSelect == true)
        {
            currencyName = buyCryptoData.name
        }
        else
        {
            currencyName = buyRegularData.symbol
        }
        ref = Database.database().reference()
        
        currencyAmount = currencyAmount + Int(amountInput)!

        let amount = [ "Amount: " : String(currencyAmount) as String]
        ref.child("PurchasedAmount").child((user?.uid)!).child(currencyName).updateChildValues(amount)

    }
    
    // ---- Alert Setup function ----
    func buyingAlert(buyAlert:String){
        let alert = UIAlertController(title: buyAlert, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // ---- Buy Button Setup function ----
    @IBAction func buyButton(_ sender: Any)
    {
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        if Double(buyInput.text!) != nil{
            buyItem.buyAmount = Double(buyInput.text!)!
        }else{
            print("Double(buyInput.text) = nil")
        }
        
        if (buyTotalPriceLbl.text != nil){
            buyItem.buyTotalPrice = buyTotalPriceLbl.text!
        } else{
            print("totalPrice = nil")
        }
        
        buyItem.buyCost = buyCostLbl.text!
        buyItem.buyDate = "\(day) - \(month) - \(year)"
        
        addOwnCurrAmountToDB(amountInput: buyInput.text!)
        addBuyInfoToDB()
    }
    
    // ---- Buy Currency Cost function ----
    func calcualateBuyCost(){
        let toCurr = Double(buyCryptoData.price_usd)
        totalPrice = Double(buyInput.text!)! * toCurr!
        buyTotalPriceLbl.text = "$" + String(totalPrice)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
