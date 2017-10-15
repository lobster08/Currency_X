//
//  BuyView.swift
//  CurrencyX
//
//  Created by Kha on 10/15/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

class BuyView: UIViewController {

    // Initialize
    @IBOutlet weak var buyInput: UITextField!
    @IBOutlet weak var iniCurrency: UILabel!
    @IBOutlet weak var afterCurrency: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    var totalAmount: Double?
    
    // Process
    
    
    @IBAction func acceptButton(_ sender: Any) {
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
