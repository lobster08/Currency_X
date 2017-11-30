//
//  Notification.swift
//  CurrencyX
//
//  Created by Quang Tran on 10/14/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import Foundation
import MessageUI
import UserNotifications

class Notification: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    
    var isSwitch: Bool = false;
    @IBOutlet weak var Switch: UISwitch!
    @IBOutlet weak var SellP: UITextField!
    @IBOutlet weak var BuyP: UITextField!
    @IBOutlet var mainView: UIView!
    
    var currentPriceB : Double = 1.2445
    var currentPriceS : Double = 1.3453
    
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    var currentPrice : Double!
    var symbol : String!
    var timer : Timer!
    
    var setBuyPrice : Double!
    var setSellPrice : Double!
    
    //  Create variable to access User Defaults Data
    var default_data : UserDefaults!
    
    var backgroundTaskIdentifier : UIBackgroundTaskIdentifier!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageName = "Background4.png"
        setBackgroundImage()
        self.SellP.delegate = self
        self.BuyP.delegate = self
        default_data = UserDefaults.init(suiteName: "Fetch Data API")
        
        if isSwitch == false{
            Switch.setOn(false, animated: true)
        }
        else{
            Switch.setOn(true, animated: true)
        }
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, error in})
        checkExpectedPriceReach()
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)})
        timer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(Notification.updateCurrPriceAndCheck), userInfo: nil, repeats: true)
    }
    
    func setNotify(){
        let content = UNMutableNotificationContent()
        content.title = "CurrencyX"
        content.subtitle = "Notification"
        content.body = "Your expected price has been reached. The current price is \(String(currentPrice))"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "target reached", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    //  Function to set Background image, automatically fit to any screen size and rotation
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
    //  Function to end keyboard when user touch anywhere on screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func Switch(_ sender: Any) {
        if Switch.isOn == true {
            isSwitch = true;
        }
        else {
            isSwitch = false;
        }
    }
    
    @IBAction func Cancel(_ sender: Any) {
        Switch.setOn(false, animated: true)
        BuyP.text = ""
        SellP.text = ""
    }
    
    @IBAction func Accept(_ sender: Any) {
        if (BuyP.text == "" && SellP.text == "") {
            alert(msg: "Please enter the value in the text field")
        }
        else{
            if BuyP.text != ""{
                guard let price = Double(BuyP.text!)
                    else {
                        alert(msg: "Please enter number only!")
                        return
                }
                setBuyPrice = price
//                if (price >= currentPriceS && isSwitch == true){
//                    AudioServicesPlayAlertSound(SystemSoundID(1336))
//                    let sendEmail = configureMailController(option: 1)
//                    if MFMailComposeViewController.canSendMail(){
//                        self.present(sendEmail, animated: true, completion: nil)
//                    }
//                    else{
//                        showMailError()
//                    }
//                    let sendSMS = configureMessageController(option: 1)
//                    if MFMessageComposeViewController.canSendText(){
//                        self.present(sendSMS, animated: true, completion: nil)
//                    }
//                    else{
//                        showMessageError()
//                    }
//                }
            }
            if SellP.text != ""{
                guard let price = Double(SellP.text!)
                    else {
                        alert(msg: "Please enter number only!")
                        return
                }
                setSellPrice = price
//                if (price <= currentPriceB && isSwitch == true){
//                    AudioServicesPlayAlertSound(SystemSoundID(1336))
//                    let sendEmail = configureMailController(option: 2)
//                    if MFMailComposeViewController.canSendMail(){
//                        self.present(sendEmail, animated: true, completion: nil)
//                    }
//                    else{
//                        showMailError()
//                    }
//                    let sendSMS = configureMessageController(option: 2)
//                    if MFMessageComposeViewController.canSendText(){
//                        self.present(sendSMS, animated: true, completion: nil)
//                    }
//                    else{
//                        showMessageError()
//                    }
//                }
            }
        }
    }
    
    @objc func updateCurrPriceAndCheck(){
        self.currentPrice = self.default_data?.double(forKey: symbol)
        checkExpectedPriceReach()
    }
    
    func checkExpectedPriceReach(){
        if (setBuyPrice != nil && setBuyPrice >= currentPrice && isSwitch == true){
            AudioServicesPlayAlertSound(SystemSoundID(1336))
            if (timer != nil && setSellPrice == nil){
                setNotify()
                alert(msg: "Your expected buying price has been reached! The current price is \(String(currentPrice))")
                setBuyPrice = nil
                timer.invalidate()
            }
        }
        if (setSellPrice != nil && setSellPrice <= currentPrice && isSwitch == true){
            AudioServicesPlayAlertSound(SystemSoundID(1336))
            if (timer != nil && setBuyPrice == nil){
                setNotify()
                alert(msg: "Your expected selling price has been reached! The current price is \(String(currentPrice))")
                setSellPrice = nil
                timer.invalidate()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func alert (msg : String){
        let alarm = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alarm.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
        } ))
        self.present(alarm , animated: true, completion: nil)
    }
    
    func configureMailController(option: Int) -> MFMailComposeViewController{
        let email = MFMailComposeViewController()
        email.mailComposeDelegate = self
        
        email.setToRecipients(["dawnmasu@gmail.com"])
        email.setSubject("Your target rate has been reached.")
        if (option == 1){
            email.setMessageBody("Dear Customer, \nYour target rate has been reach. The current price is \(currentPriceS). You can make a purchase now. \nBest Regards,\nCurrency-X App Team", isHTML: false)
        }else if (option == 2){
            email.setMessageBody("Dear Customer, \nYour target rate has been reach. The current price is \(currentPriceB). You can make a purchase now. \nBest Regards,\nCurrency-X App Team", isHTML: false)
        }
        return email
    }
    
    func showMailError(){
        let emailError = UIAlertController(title: "Alert!", message: "Email cannot be sent! Please check your internet connection again!", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        emailError.addAction(dismiss)
        self.present(emailError, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func configureMessageController(option: Int) ->MFMessageComposeViewController {
        let SMS = MFMessageComposeViewController()
        SMS.messageComposeDelegate = self
        
        SMS.recipients = ["1-781-375-6688"]
        if (option == 1){
            SMS.body = "Your expected rate has been reached. The current price is \(currentPriceS)"
        } else if (option == 2){
            SMS.body = "Your expected rate has been reached. The current price is \(currentPriceB)"
        }
        return SMS
    }
    func showMessageError(){
        let SMSError = UIAlertController(title: "Alert!", message: "Cannot send SMS message", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        SMSError.addAction(dismiss)
        self.present(SMSError, animated: true, completion: nil)
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
