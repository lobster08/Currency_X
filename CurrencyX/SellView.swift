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
    
    // Data Variables
    var sellDataCrypCurr = CryptoCurrency()
    var sellDataRegCurr = currency()
    var sellItem = SellInfo()
    var totalSellValue: Double = 0.0
    var cryptoCurr: String?
    var regularCurr: String?
    
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
        setSellCurrencyName(crytoStr: sellDataCrypCurr.symbol, regStr: sellDataRegCurr.symbol)
        setSellValueLbl(cryptoStr: sellDataCrypCurr.price_usd, regStr: String(sellDataRegCurr.price))
        
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
        let cryptoSell = Double(sellDataCrypCurr.price_usd)
        let regularSell = Double(sellDataRegCurr.price)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
