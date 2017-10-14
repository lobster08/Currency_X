//
//  RegisterView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/13/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

protocol registerDelegate {
    
    func addingUser(newUser: String, newPass: String)
}

class RegisterView: UIViewController {

    @IBOutlet weak var newUserText: UITextField!
    @IBOutlet weak var newPassText: UITextField!
    @IBOutlet weak var confirmPassText: UITextField!
    
    var delegate: registerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpBtn(_ sender: Any) {
        
        if (newPassText.text != confirmPassText.text || newPassText.text == "" ) {
            let alert = UIAlertController(title: "Alert!", message: "Password is incorrect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //Validate email address
            if isValidEmail(emailAddress: newUserText.text!) {
                
                //Send user data back to add into dictionary
                if delegate != nil {
                    let userText = newUserText.text
                    let passText = newPassText.text
                    delegate?.addingUser(newUser: userText!, newPass: passText!)
                }
                print("Register Success!")
                
                
                let alert = UIAlertController(title: "Register", message: "Register Success!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Alert!", message: "Invalid email address", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
    
    //Function to validate email address
    func isValidEmail(emailAddress: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: emailAddress)
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
