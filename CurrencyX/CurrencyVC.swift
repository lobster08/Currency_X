//
//  CurrencyVC.swift
//  CurrencyX
//
//  Created by Nguyen on 11/3/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
struct currency : Codable
{
    var symbol : String
    var price : Float
    var bid : Float
    var ask : Float
    var timestamp : Int
    init()
    {
        symbol = ""
        price = 0.0
        bid = 0.0
        ask = 0.0
        timestamp = 0
    }
}


class CurrencyVC: UIViewController {
    var Currencies = [currency]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getCurrency() {
        let url = URL (string: "https://forex.1forge.com/1.0.2/quotes?&api_key=hz3FMVzCV5cSCQmbvXRvoDuKIWk8f26B")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if let data = data {
                do {
                    //convert to json
                    let jsonDecoder = JSONDecoder()
                    let currList = try jsonDecoder.decode([currency].self, from: data)
                    self.Currencies = currList
                    DispatchQueue.main.async {
                        self.Crypt.reloadData()
                        print("JSON downloaded")
                        print(currList)
                    }
                } catch {
                    print("Can't pull JSON")
                }
                
            } else if let error = error {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
        
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
