//
//  WalletView.swift
//  CurrencyX
//
//  Created by Quang Tran on 10/22/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase
import FirebaseAuth

class Balance : NSObject {
    var type: String
    var amount : String
    init(type1: String, amount1: String){
        type = type1
        amount = amount1
    }
}

class WalletView: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var actionList: UITextField!
    @IBOutlet weak var moneyList: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    var action = ["Deposit", "Withdraw"]
    var moneyType = ["USD", "CAD", "YEN", "EUR"]
    
    let actionPicker = UIPickerView()
    let moneyPicker = UIPickerView()
    var balanceView = UITableView()
    
    var handle: DatabaseHandle!
    var ref: DatabaseReference!
    var user = Auth.auth().currentUser
    var numbOfBalance : Int = 0
//    var balanceList : NSDictionary!
    var balanceList = [Balance]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageName = "Background4.png"
        setBackgroundImage()
        self.title = "Wallet"
        createActionListPicker()
        createMoneyListPicker()
        loadBalance()
        actionPicker.delegate = self
        moneyPicker.delegate = self
        // Do any additional setup after loading the view.
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
    
    // detect device orientation changes
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation.isLandscape {
            print("rotated device to landscape")
            setBackgroundImage()
        } else {
            print("rotated device to portrait")
            setBackgroundImage()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count: Int = 0
        if pickerView == actionPicker{
            count = action.count
        }
        else if pickerView == moneyPicker{
            count = moneyType.count
        }
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title : String = ""
        if pickerView == actionPicker {
            title = action[row]
        }
        else if pickerView == moneyPicker{
            title = moneyType[row]
        }
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == actionPicker{
             actionList.text = action[row]
        }
        else if pickerView == moneyPicker{
            moneyList.text = moneyType[row]
        }
    }
    
    func createActionListPicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        actionList.inputAccessoryView = toolbar
        actionList.inputView = actionPicker
    }
    
    func createMoneyListPicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        moneyList.inputAccessoryView = toolbar
        moneyList.inputView = moneyPicker
    }
    
    func loadBalance(){
        self.balanceList = [Balance]()
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.numbOfBalance = Int(snapshot.childrenCount)
            if let dictionary = snapshot.value as? NSDictionary {
                for (key, value) in dictionary {
                    var balance = Balance(type1: "\(key)", amount1: "\(value)")
                    self.balanceList.append(balance)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbOfBalance
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let amountLbl = cell?.viewWithTag(1) as! UILabel
        let typeLbl = cell?.viewWithTag(2) as! UILabel

        amountLbl.text = balanceList[indexPath.row].amount
        typeLbl.text = balanceList[indexPath.row].type
        return cell!
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
    func alert(msg: String){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func validateInput() -> Bool {
        if (actionList.text == "" || amount.text == "" || moneyList.text == ""){
            alert(msg: "Please pick up an option/enter a valid amount!")
            return false
        }
        else if let value = Double(amount.text!){
            if value == nil {
                alert(msg: "Please enter a valid number!")
                return false
            }
            else if value <= 0 {
                alert(msg: "The ammount must be greater than 0!")
                return false
            }
        }
        return true
    }
    
    func deposit(){
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.moneyList.text!){
                var amount : Double = 0.0
                if let balance = snapshot.value as? NSDictionary {
                    var currentAmount : Double = Double(balance[self.moneyList.text!] as! String) as! Double
                    amount = currentAmount + (Double(self.amount.text!) as! Double)
                    DispatchQueue.main.async {
                        self.ref = Database.database().reference()
                        self.ref.child("Balance").child((self.user?.uid)!).updateChildValues([self.moneyList.text!: String(amount)])
   //                     self.tableView.reloadData()
                        self.loadBalance()
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    self.ref = Database.database().reference().child("Balance").child((self.user?.uid)!)
                    self.ref.updateChildValues([self.moneyList.text!: self.amount.text!])
 //                   self.tableView.reloadData()
                    self.loadBalance()
                }
            }
        })
    }
    func withdraw(){
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.moneyList.text!){
                var amount : Double = 0.0
                if let balance = snapshot.value as? NSDictionary{
                    var currentAmount : Double = Double(balance[self.moneyList.text!] as! String) as! Double
                    if (currentAmount < (Double(self.amount.text!) as! Double)){
                        self.alert (msg: "Insufficient amount to withdraw! You current balance do not have enough!")
                    }
                    else{
                        amount = currentAmount - (Double(self.amount.text!) as! Double)
                        DispatchQueue.main.async {
                            self.ref = Database.database().reference()
                            self.ref.child("Balance").child((self.user?.uid)!).updateChildValues([self.moneyList.text!: String(amount)])
  //                         self.tableView.reloadData()
                            self.loadBalance()
                        }
                    }
                }
            }
            else{
                self.alert(msg: "You do not have this currency's type to withdraw!")
            }
        })
    }
    @IBAction func acceptBtn(_ sender: Any) {
        if (validateInput()) {
            if (actionList.text == "Deposit"){
                deposit()
            }
            else{
                withdraw()
            }
        }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        actionList.text = ""
        amount.text = ""
        moneyList.text = ""
    }
    /*
     @IBAction func cancelBtn(_ sender: Any) {
     }
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
