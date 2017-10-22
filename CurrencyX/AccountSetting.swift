//
//  AccountSetting.swift
//  CurrencyX
//
//  Created by Quang Tran on 10/16/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase
import FirebaseAuth

class AccountSetting: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameText: UITextField!
    
    @IBOutlet weak var lastNameText: UITextField!
    
    @IBOutlet weak var dobText: UITextField!
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var addressText: UITextField!
    
    @IBOutlet weak var cityText: UITextField!
    
    @IBOutlet weak var stateText: UITextField!
    
    @IBOutlet weak var zipCodeText: UITextField!
    
    @IBOutlet weak var phoneAreaText: UITextField!
    
    @IBOutlet weak var phoneNumText: UITextField!
    
    @IBOutlet weak var currentPassText: UITextField!
    
    @IBOutlet weak var newPassText: UITextField!
    
    @IBOutlet weak var confirmPassText: UITextField!
    
    var fullName: String = ""
    var fullPhone: String = ""
    
    var handle: DatabaseHandle!
    var ref: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zipCodeText.delegate = self
        phoneNumText.delegate = self
        phoneAreaText.delegate = self
        getData()
        createDatePicker()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to upload data to Database
    func uploadData() {
        
        ref = Database.database().reference()
        ref.child("accInfo").child(userID!).setValue(["address": addressText.text!, "city": cityText.text!, "state": stateText.text!, "zipcode": zipCodeText.text!,"dob": dobText.text!, "name": fullName, "phone": fullPhone])
        
        print("Uploaded data")
    }
    
    //Function to pull data from Database
    func getData() {
        
        ref = Database.database().reference().child("accInfo").child(userID!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userData = snapshot.value as? NSDictionary {
                self.dobText.text = userData["dob"] as? String
                self.addressText.text = userData["address"] as? String
                self.cityText.text = userData["city"] as? String
                self.stateText.text = userData["state"] as? String
                self.zipCodeText.text = userData["zipcode"] as? String
                
                //Split full name
                let fullName = userData["name"] as? String
                let nameArr = fullName?.components(separatedBy: " ")
                let firstN: String = nameArr![0]
                let lastN: String = nameArr![1]
                self.firstNameText.text = firstN
                self.lastNameText.text = lastN
                
                //Split full phone number
                let fullNumber = userData["phone"] as? String
                let numberArr = fullNumber?.components(separatedBy: " ")
                let areaNumber: String = numberArr![0]
                let phoneNumber: String = numberArr![1]
                self.phoneAreaText.text = areaNumber
                self.phoneNumText.text = phoneNumber
            }
        })
        
    }
    
    
    @IBAction func acceptBtn(_ sender: Any) {
        
        //uploadData()
        if firstNameText.text == "" || lastNameText.text == "" {
            displayAlert(message: "Please enter your first/last name")
        }
        else if dobText.text == "" {
            displayAlert(message: "Please enter your birthday")
        }
        else if addressText.text == "" {
            displayAlert(message: "Please enter your address")
        }
        else if cityText.text == "" {
            displayAlert(message: "Please enter your city")
        }
        else if stateText.text == "" {
            displayAlert(message: "Please enter your state")
        }
        else if zipCodeText.text == "" {
            displayAlert(message: "Please enter your zip code")
        }
        else if phoneAreaText.text == "" || phoneNumText.text == "" {
            displayAlert(message: "Please enter your phone number")
        }
        else {
            fullPhone = "\(phoneAreaText.text!) \(phoneNumText.text!)"
            fullName = "\(firstNameText.text!) \(lastNameText.text!)"
            
            uploadData()
        }
    }
    //Function to display alert
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelBtn(_ sender: Any) {        
    }
    
    //Function to limit numbers in zipcode, phone area and phone number
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 1 {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 5
        }
        else if textField.tag == 2 {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 3
        }
        else if textField.tag == 3 {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 7
        }
        
        
        return true
    }
    
    //Function to create day of birth
    func createDatePicker() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let acceptBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([acceptBtn], animated: false)
        
        dobText.inputAccessoryView = toolbar
        dobText.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        dobText.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
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
