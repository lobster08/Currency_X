//
//  BuyView.swift
//  CurrencyX
//
//  Created by Kha on 10/15/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

class BuyView: UIViewController, UITextFieldDelegate {

    // Initialize
    @IBOutlet weak var buyInput: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    var amount: Float?
    let priceFirst: Float = 1.00
    let priceSecond: Float = 22719.50
    
    
    // Process
    override func viewDidLoad()
    {
        super.viewDidLoad()
        buyInput.delegate = self
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(buyInput.text != nil)
        {
            if(buyInput.text == "")
            {
                totalLabel.text = "0.0"
            }else
            {
                amount = Float(buyInput.text!)
                if(amount != nil)
                {
                    let total = (amount! * priceFirst) / priceSecond
                    totalLabel.text = String(total)
                }
            }
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
