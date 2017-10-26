//
//  LoginView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/13/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginView: UIViewController, UITextFieldDelegate {


    @IBOutlet var mainView: UIView!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passText: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.usernameText.delegate = self
        self.passText.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if UIDevice.current.orientation.isLandscape {
            if (passText.isEditing){
        
//                if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
//                    let keyboardRectangle = keyboardFrame.cgRectValue
//                    let keyboardHeight = keyboardRectangle.height
//
                   self.mainView.frame.origin.y -= 150
//                }
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if UIDevice.current.orientation.isLandscape {
            if self.mainView.frame.origin.y != 0 {
                
//                if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
//                    let keyboardRectangle = keyboardFrame.cgRectValue
//                    let keyboardHeight = keyboardRectangle.height
//
                    self.mainView.frame.origin.y += 150
//                }
            }
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //Clear text fields after going back from navigation controller
    override func viewWillAppear(_ animated: Bool) {
        usernameText.text = ""
        passText.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to login through firebase
    func firebaseLogin(email: String, pass: String) {

        Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, error) in
            
            if let user = Auth.auth().currentUser {
                //Check if email has been verified or not
                if !user.isEmailVerified {
                    let alert = UIAlertController(title: "Alert!", message: "Please verify your email!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else if error != nil {
                    //print(firebaseError.localizedDescription)
                    
                    //Handle errors
                    if let firebaseError = AuthErrorCode(rawValue: error!._code) {
                        
                        switch firebaseError {
                            
                        case .wrongPassword:
                            let alert = UIAlertController(title: "Alert", message: "Password is incorrect", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                            }))
                            self.present(alert, animated: true, completion: nil)
                        
                        case .networkError:
                            let alert = UIAlertController(title: "Alert", message: "No Internet connection", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                        case .userNotFound:
                            let alert = UIAlertController(title: "Alert", message: "Email was not found", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                            }))
                            self.present(alert, animated: true, completion: nil)
                        
                        case .invalidEmail:
                            let alert = UIAlertController(title: "Alert", message: "Invalid Email", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                            }))
                            self.present(alert, animated: true, completion: nil)
                        
                        case .userDisabled:
                            let alert = UIAlertController(title: "Alert", message: "Account is disabled", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                        default:
                            print("Error: \(firebaseError)")
                        }
                        
                    }
                    
                }
                else {
                    print("Login Success!")
                    //GO TO THE NEXT VIEW
                    self.performSegue(withIdentifier: "LoginToMain", sender: self)
                }
            }
        })

    }

    
    @IBAction func signinBtn(_ sender: Any) {
   
        //Check if either box is empty
        if (usernameText.text == "" || passText.text == "") {
            let alert = UIAlertController(title: "Alert!", message: "Please enter username/password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            firebaseLogin(email: usernameText.text!, pass: passText.text!)
        }
    }
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
