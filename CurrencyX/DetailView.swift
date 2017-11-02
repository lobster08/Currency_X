//
//  DetailView.swift
//  CurrencyX
//
//  Created by Kha on 11/1/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

class DetailView: UIViewController {

    var cryptCurrency = worldCoinIndex()
    
    
    // Process
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    
    @IBAction func purchaseButton(_ sender: Any)
    {
        performSegue(withIdentifier: "DetailToBuy", sender: self)
    }
    
    @IBAction func sellButton(_ sender: Any)
    {
        performSegue(withIdentifier: "DetailToSell", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
