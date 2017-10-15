//
//  RegisterView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/13/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterView: UIViewController {

    @IBOutlet weak var newUserText: UITextField!
    @IBOutlet weak var newPassText: UITextField!
    @IBOutlet weak var confirmPassText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to create a new user account to Firebase
    func createUser(email: String, pass: String) {
        
        Auth.auth().createUser(withEmail: email, password: pass, completion: { user, error in
            if let firebaseError = error {
                
                print(firebaseError.localizedDescription)
                return
            }
            else {
                
                print("Created Successful!")
                //Verify email address
                Auth.auth().currentUser!.sendEmailVerification(completion: { error in
                    if let firebaseError = error {
                        print(firebaseError.localizedDescription)
                        return
                    }
                    else {
                        let alert = UIAlertController(title: "Alert", message: "Account created. An email with a link to verify your email has sent. Please verify your email!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                        print("Sent email for verify")
                    }
                    
                })
            }
        })
    }
    
    @IBAction func signUpBtn(_ sender: Any) {
        
        if (newPassText.text != confirmPassText.text || newPassText.text == "" ) {
            let alert = UIAlertController(title: "Alert", message: "Password is incorrect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if (newUserText.text == "") {
            let alert = UIAlertController(title: "Alert", message: "Please enter username", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            createUser(email: newUserText.text!, pass: newPassText.text!)
        }
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
