//
//  RegisterView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/13/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterView: UIViewController, UITextFieldDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var newUserText: UITextField!
    @IBOutlet weak var newPassText: UITextField!
    @IBOutlet weak var confirmPassText: UITextField!
    
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backgroundImageName = "Background4.png"
        setBackgroundImage()
        newPassText.delegate = self
        confirmPassText.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        //Check current orientation of the device
        if UIDevice.current.orientation.isLandscape {
            
            //Check if textfield is editing
            if (confirmPassText.isEditing){

                self.mainView.frame.origin.y = -160
            }
            else if (newPassText.isEditing) {

                self.mainView.frame.origin.y = -90
            }
        }
        
    }
    
//    @objc func keyboardDidShow(notification: NSNotification) {
//
//        if UIDevice.current.orientation.isLandscape {
//
//            if self.mainView.frame.origin.y != 0 {
//
//                self.mainView.frame.origin.y = 0
//            }
//        }
//    }
    
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if UIDevice.current.orientation.isLandscape {
            if self.mainView.frame.origin.y != 0 {

                self.mainView.frame.origin.y = 0
            }
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to create a new user account to Firebase
    func createUser(email: String, pass: String) {
        
        Auth.auth().createUser(withEmail: email, password: pass, completion: { user, error in
            if error != nil {
                
                //Handle errors
                if let firebaseError = AuthErrorCode(rawValue: error!._code) {
                    
                    switch firebaseError {

                    case .networkError:
                        let alert = UIAlertController(title: "Alert", message: "No Internet connection", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    case .emailAlreadyInUse:
                        let alert = UIAlertController(title: "Alert", message: "Email already exists", preferredStyle: .alert)
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
