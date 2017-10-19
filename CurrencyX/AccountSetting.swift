//
//  AccountSetting.swift
//  CurrencyX
//
//  Created by Quang Tran on 10/16/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AccountSetting: UIViewController {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    //Function to upload data to Database
    func uploadData() {
        
        
    }
    
    //Function to pull data from Database
    func getData() {
        
        
    }
    
    @IBAction func acceptBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func cancelBtn(_ sender: Any) {
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
