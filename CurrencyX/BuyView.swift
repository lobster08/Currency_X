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
    
    // Wallet Variable
    var walletData = WalletView()
    var hasMoney: Bool!
    
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
    var wtbSymbol : String! // wtb: want to buy
    var wtsSymbol: String! // wts: want to sell
    
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
        setBuyCurrencyName(crytoStr: buyCryptoData.symbol, regStr: buyRegularData.symbol)
        setBuyCostLbl(crytoStr: buyCryptoData.price_usd, regStr: String(buyRegularData.price))
        
        // Setup Buy Cost Update variables
        default_data = UserDefaults.init(suiteName: "Fetch Data API")
        updateTimer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(BuyView.updateCurrentValue), userInfo: nil, repeats: true)
        
        // Setup currencyAmount for upload to Database
        currencyAmount = Int(DetailView.amount)!
        
        
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
    
    //---- Buy Cost Update function ----
    @objc func updateCurrentValue(){
        if (buyCryptoData.symbol != ""){
            let crypValue = self.default_data?.double(forKey: buyCryptoData.symbol)
            buyCostLbl.text = "$" + String(crypValue!)
        }
        else{
            let regValue = self.default_data?.double(forKey: buyRegularData.symbol)
            buyCostLbl.text = "$" + String(regValue!)
        }
        
    }
    
    // ---- UI Setup functions ----
    func setBuyCurrencyName(crytoStr:String, regStr:String){
        if(crytoStr != ""){
            buyCurrNameLbl.text = crytoStr
            wtbSymbol = crytoStr
        }else{
            buyCurrNameLbl.text = String(regStr.characters.suffix(3))
            wtbSymbol = regStr
        }
        wtsSymbol = "USD"
    }
    
    func setBuyCostLbl(crytoStr:String, regStr:String){
        if(crytoStr != ""){
            buyCostLbl.text = "$" + crytoStr
        }else{
            buyCostLbl.text = "$" + regStr
        }
    }
    // ---- TapRecognizer Setup functions ----
    @objc func didTapView()
    {
        self.view.endEditing(true)
        if(buyInput.text != "")
        {
            calcualateBuyCost()
            loadBalance()
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
        
        let info = [ "data: " :  buyItem.buyDate as String, "buyAmount" :  String(buyItem.buyAmount) as String, "buyCost" : buyCostLbl.text, "buyTotalPrice": "+" + String(buyItem.buyTotalPrice) as String, "Type" : "Buy" ]
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
    // ---- Wallet -----
    func checkMoneyExist()
    {
        for money in walletData.balanceList{
            if (money.type == "USD"){
                if(money.amount == ""){
                    hasMoney = false
                    buyingAlert(buyAlert: "No Money Found")
                } else if (Double(money.amount)! < totalPrice){
                    hasMoney = false
                    print("Cannot buy item. Insufficient funds")
                } else{
                    print ("Has Money")
                    self.hasMoney = true
                }
            }
        }
    }
    
    func loadBalance(){
        walletData.balanceList = [Balance]()
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.walletData.numbOfBalance = Int(snapshot.childrenCount)
            if let dictionary = snapshot.value as? NSDictionary {
                for (key, value) in dictionary {
                    var balance = Balance(type1: "\(key)", amount1: "\(value)")
                    self.walletData.balanceList.append(balance)
                }
                self.checkMoneyExist()
            }
        })
    }
    
    func buyDeposit(){
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.wtbSymbol){
                var updateAmount : Double = 0.0
                if let balance = snapshot.value as? NSDictionary {
                    var currentAmount : Double = Double(balance[self.wtbSymbol] as! String)!
                    updateAmount = currentAmount + Double(self.buyInput.text!)!
                    DispatchQueue.main.async {
                        self.ref = Database.database().reference()
                        self.ref.child("Balance").child((self.user?.uid)!).updateChildValues([self.wtbSymbol: String(updateAmount)])
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    self.ref = Database.database().reference().child("Balance").child((self.user?.uid)!)
                    self.ref.updateChildValues([self.wtbSymbol: self.buyInput.text!])
                }
            }})
    }
    
    func buyWithdraw(){
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var updateAmount : Double = 0.0
            if let balance = snapshot.value as? NSDictionary {
                var currentAmount : Double = Double(balance[self.wtsSymbol] as! String)!
                updateAmount = currentAmount - self.totalPrice
                DispatchQueue.main.async {
                    self.ref = Database.database().reference()
                    self.ref.child("Balance").child((self.user?.uid)!).updateChildValues([self.wtsSymbol: String(updateAmount)])
                }
            }})
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
        
        if(self.hasMoney == true)
        {
            if Double(self.buyInput.text!) != nil{
                self.buyItem.buyAmount = Double(self.buyInput.text!)!
            }else{
                print("Double(buyInput.text) = nil")
            }
            
            if (self.buyTotalPriceLbl.text != nil){
                self.buyItem.buyTotalPrice = self.buyTotalPriceLbl.text!
            } else{
                print("totalPrice = nil")
            }
            self.buyItem.buyCost = self.buyCostLbl.text!
            self.buyItem.buyDate = "\(day) - \(month) - \(year)"
            self.buyDeposit()
            self.buyWithdraw()
            self.addOwnCurrAmountToDB(amountInput: self.buyInput.text!)
            self.addBuyInfoToDB()
        }
    }
    
    // ---- Buy Currency Cost function ----
    func calcualateBuyCost(){
        if(buyCryptoData.price_usd != "")
        {
            let cryptCost = Double(buyCryptoData.price_usd)
            totalPrice = Double(buyInput.text!)! * cryptCost!
            totalPrice = round(1000*totalPrice) / 1000
            buyTotalPriceLbl.text = "$" + String(totalPrice)
        }else{
            let regCost = Double(buyRegularData.price)
            totalPrice = Double(buyInput.text!)! * regCost
            totalPrice = round(1000*totalPrice) / 1000
            buyTotalPriceLbl.text = "$" + String(totalPrice)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
