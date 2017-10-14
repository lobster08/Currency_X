//
//  LoginView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/13/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

class LoginView: UIViewController, registerDelegate {

    var userDictionary: [String: [String]] = ["admin": ["admin"]]
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passText: UITextField!
    
    var newUsername: String = ""
    var newPass: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function from Register View protocol delegate
    func addingUser(newUser: String, newPass: String) {
        userDictionary[newUser] = [newPass]
        print(userDictionary)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToRegister" {
            
            let dvc: RegisterView = segue.destination as! RegisterView
            dvc.delegate = self
        }
    }
    
    @IBAction func signinBtn(_ sender: Any) {
        
        //Check if either box is empty
        if (usernameText.text == "" || passText.text == "") {
            let alert = UIAlertController(title: "Alert!", message: "Username/Password is not correct", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        //Check if user exists in dictionary
        else if let message = userDictionary[usernameText.text!]?[0] {
            if message == (passText.text!){
               // performSegue(withIdentifier: "XXXXXXXXXXX", sender: self)
                print("Login success!")
            }
            else{
                let alert1 = UIAlertController(title: "Alert!", message: "Username/Password is not correct", preferredStyle: .alert)
                alert1.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                }))
                self.present(alert1, animated: true, completion: nil)
            }
        }    }
    @IBAction func registerBtn(_ sender: Any) {
        performSegue(withIdentifier: "LoginToRegister", sender: self)
    }
    
    @IBAction func forgotPassBtn(_ sender: Any) {
        performSegue(withIdentifier: "LoginToForgot", sender: self)
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
