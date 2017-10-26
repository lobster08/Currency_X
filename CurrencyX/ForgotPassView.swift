//
//  ForgotPassView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/14/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPassView: UIViewController {

    
    @IBOutlet weak var emailText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to send password reset email through firebase
    func resetPass(email: String!) {
        
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            if error != nil {
                //Handle errors
                if let firebaseError = AuthErrorCode(rawValue: error!._code) {
                    
                    switch firebaseError {
                        
                    case .networkError:
                        let alert = UIAlertController(title: "Alert", message: "No Internet connection", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    case .userNotFound:
                        let alert = UIAlertController(title: "Alert", message: "Email not found", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    case .invalidEmail:
                        let alert = UIAlertController(title: "Alert", message: "Invalid Email", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    default:
                        print("Error: \(firebaseError)")
                    }
                    
                }
            }
            else {
                //print("Email reset password sent!")
                let alert = UIAlertController(title: "Alert", message: "Email reset password sent", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        })
    }
    
    
    @IBAction func sendBtn(_ sender: Any) {
        
        if emailText.text == "" {
            let alert = UIAlertController(title: "Alert!", message: "Please enter your email!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            resetPass(email: emailText.text!)
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
