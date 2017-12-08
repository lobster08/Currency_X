//
//  SellView.swift
//  CurrencyX
//
//  Created by Sol on 12/7/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

struct SellInfo{
    var sellAmount: Double
    var sellValue: String
    var sellTotalValue: String
    var sellDate: String
    init(){
        sellAmount = 0.0
        sellValue = ""
        sellTotalValue = ""
        sellDate = ""
    }
}
class SellView: UIViewController, UITextFieldDelegate {
    
    //-------------- INITIALIZE ------------------
    
    // UI Variables
    @IBOutlet weak var sellValueLbl: UILabel!
    @IBOutlet weak var sellCurrencyNameLbl: UILabel!
    @IBOutlet weak var sellInput: UITextField!
    @IBOutlet weak var sellTotalValueLbl: UILabel!
    @IBOutlet weak var sellButtonLbl: UIButton!
    
    // Wallet Variable
    var sellWalletData = WalletView()
    var hasSellItem: Bool!
    
    // Currency's Value Update Variables
    var default_data: UserDefaults!
    var currentSellValue: Double!
    var updateTimer: Timer!
    
    // Data Variables
    var sellCryptoData = CryptoCurrency()
    var sellRegularData = currency()
    var sellItem = SellInfo()
    var totalSellValue: Double = 0.0
    var cryptoCurr: String?
    var regularCurr: String?
    var wtbSymbol: String! // wtb: want to buy
    var wtsSymbol: String! // wts: want to sell
    
    // Date Variable
    let date = Date()
    let calendar = Calendar.current
    
    // Background Variables
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    // Firebase Variable Initailize
    var ref : DatabaseReference!
    var refPurchase: DatabaseReference!
    var user = Auth.auth().currentUser
    
    //-------------- PROCESS ------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view's background
        backgroundImageName = "background6.png"
        setBackgroundImage()
        
        // Setup UI labels
        sellInput.delegate = self
        sellTotalValueLbl.text = "0.0"
        setSellCurrencyName(crytoStr: sellCryptoData.symbol, regStr: sellRegularData.symbol)
        setSellValueLbl(cryptoStr: sellCryptoData.price_usd, regStr: String(sellRegularData.price))
        
        // Setup Sell Value Update variables
        default_data = UserDefaults.init(suiteName: "Fetch Data API")
        updateTimer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(SellView.updateCurrentSellValue), userInfo: nil, repeats: true)
        
        // Setup Keyboard type for TextInput and TapRecognizer
        sellInput.keyboardType = UIKeyboardType.decimalPad
        let tapRegcognizer = UITapGestureRecognizer()
        tapRegcognizer.addTarget(self, action: #selector(self.didTapView))
        self.view.addGestureRecognizer(tapRegcognizer)
        
        // Hide the sell button when view loaded
        sellButtonLbl.isHidden = true
    }
    
    // ---- Sell Button function ----
    @IBAction func sellButton(_ sender: Any) {
        let sellDay = calendar.component(.day, from: date)
        let sellMonth = calendar.component(.month, from: date)
        let sellYear = calendar.component(.year, from: date)
        
        if(hasSellItem == true)
        {
            if (sellInput.text != ""){
                sellItem.sellAmount = Double(sellInput.text!)!
            }
            
            if (sellTotalValueLbl.text != ""){
                sellItem.sellTotalValue = sellTotalValueLbl.text!
            }
            
            sellItem.sellValue = sellValueLbl.text!
            sellItem.sellDate = "\(sellDay) - \(sellMonth) - \(sellYear)"
            sellDeposit()
            sellWithdraw()
        }
    }
    
    // ---- Sell Value Update function ----
    @objc func updateCurrentSellValue(){
        if(sellCryptoData.symbol != ""){
            var crypValue = self.default_data?.double(forKey: sellCryptoData.symbol)
            sellValueLbl.text = "$" + String(crypValue!)
        }else{
            var regValue = self.default_data?.double(forKey: sellRegularData.symbol)
            sellValueLbl.text = "$" + String(regValue!)
        }
    }
    
    // ---- UI Setup functions ----
    func setSellCurrencyName(crytoStr:String, regStr:String)
    {
        if (crytoStr != ""){
            sellCurrencyNameLbl.text = crytoStr
            wtsSymbol = crytoStr
        } else{
            sellCurrencyNameLbl.text = String(regStr.characters.suffix(3))
            wtsSymbol = regStr
        }
        wtbSymbol = "USD"
    }
    
    func setSellValueLbl(cryptoStr:String, regStr:String){
        if (cryptoStr != ""){
            sellValueLbl.text = "$" + cryptoStr
        }else{
            sellValueLbl.text = "$" + regStr
        }
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
    
    // ---- TapRecognizer Setup functions ----
    @objc func didTapView()
    {
        self.view.endEditing(true)
        if(sellInput.text != "")
        {
            calculateSellTotal()
            loadBalance()
        }
        sellButtonLbl.isHidden = false
    }
    
    // ---- Sell Wallet ----
    func checkOwnedCurrExist(){
        for item in sellWalletData.balanceList{
            if(item.type == wtsSymbol){
                if(item.amount == "" || Double(item.amount)! < 0.0){
                    hasSellItem = false
                    print(wtsSymbol + "does not exist in your wallet")
                } else{
                    hasSellItem = true
                    print ("Has Sell Item!")
                }
            }
        }
    }
    
    func loadBalance(){
        sellWalletData.balanceList = [Balance]()
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.sellWalletData.numbOfBalance = Int(snapshot.childrenCount)
            if let dictionary = snapshot.value as? NSDictionary {
                for (key, value) in dictionary {
                    var balance = Balance(type1: "\(key)", amount1: "\(value)")
                    self.sellWalletData.balanceList.append(balance)
                }
                self.checkOwnedCurrExist()
            }})
    }
    
    func sellDeposit(){
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.wtbSymbol){
                var updateAmount : Double = 0.0
                if let balance = snapshot.value as? NSDictionary {
                    var currentAmount : Double = Double(balance[self.wtbSymbol] as! String)!
                    updateAmount = currentAmount + Double(self.totalSellValue)
                    DispatchQueue.main.async {
                        self.ref = Database.database().reference()
                        self.ref.child("Balance").child((self.user?.uid)!).updateChildValues([self.wtbSymbol: String(updateAmount)])
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    self.ref = Database.database().reference().child("Balance").child((self.user?.uid)!)
                    self.ref.updateChildValues([self.wtbSymbol: self.totalSellValue])
                }
            }})
    }
    
    func sellWithdraw(){
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var updateAmount : Double = 0.0
            if let balance = snapshot.value as? NSDictionary {
                var currentAmount : Double = Double(balance[self.wtsSymbol] as! String)!
                updateAmount = currentAmount - Double(self.sellInput.text!)!
                DispatchQueue.main.async {
                    self.ref = Database.database().reference()
                    self.ref.child("Balance").child((self.user?.uid)!).updateChildValues([self.wtsSymbol: String(updateAmount)])
                }
            }})
    }
    
    // ---- Sell Currency Value function ----
    func calculateSellTotal(){
        if(sellCryptoData.price_usd != ""){
            let cryptValue = Double(sellCryptoData.price_usd)
            totalSellValue = Double(sellInput.text!)! * cryptValue!
        }else{
            let regValue = Double(sellRegularData.price)
            totalSellValue = Double(sellInput.text!)! * regValue
        }
        sellTotalValueLbl.text = "$" + String(totalSellValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
