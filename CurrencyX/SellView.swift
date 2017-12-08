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
        cryptoCurr = crytoStr
        regularCurr = regStr
        if (cryptoCurr != nil){
            sellCurrencyNameLbl.text = cryptoCurr!
        } else if (regularCurr != nil){
            sellCurrencyNameLbl.text = regularCurr!
        }
    }
    
    func setSellValueLbl(cryptoStr:String, regStr:String){
        cryptoCurr = cryptoStr
        regularCurr = regStr
        if (cryptoCurr != nil){
            sellValueLbl.text = "$" + cryptoCurr!
        }else if (regularCurr != nil){
            sellValueLbl.text = "$" + regularCurr!
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
        }
        sellButtonLbl.isHidden = false
    }
    
    // ---- Sell Currency Value function ----
    func calculateSellTotal(){
        let cryptoSell = Double(sellCryptoData.price_usd)
        let regularSell = Double(sellRegularData.price)
        
        if(cryptoSell != nil){
            totalSellValue = Double(sellInput.text!)! * cryptoSell!
        }else if (regularSell != nil){
            totalSellValue = Double(sellInput.text!)! * regularSell
        }
        
        sellTotalValueLbl.text = "$" + String(totalSellValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
