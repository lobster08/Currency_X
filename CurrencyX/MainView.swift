//
//  MainView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/18/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

class MainView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    

    //http://rates.fxcm.com/RatesXML
    //http://api.fixer.io/latest
    //https://www.worldcoinindex.com/apiservice/json?key=wECsN7y9YetLXQJNwwMQKJFPI
    

    var cryptArrFin = [worldCoinIndex]()        // JSON data for crypto currencies, access format: cryptArrFin[index].x where x = Label, Name...
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptArrFin.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView .dequeueReusableCell(withIdentifier: "cryptCell", for: indexPath) as! MainViewTableViewCell
        
        
        //cell.currencyLabelLbl.text = cryptArrFin[indexPath.row].Label
        var temp = cryptArrFin[indexPath.row].Label
        
        let index = temp.index(of: "/") ?? temp.endIndex
        let temp2 = String(temp[..<index])
        
        
        
        var temp1 = String(temp.characters.prefix(3))
        
        cell.currencyLabelLbl.text = temp2
        
        cell.currencyPriceLbl.text = "$\(cryptArrFin[indexPath.row].Price_usd)"
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
        
    }
    

    
    
    
    
    
    @IBAction func sendBtn(_ sender: Any) {
        performSegue(withIdentifier: "MainToDetail", sender: self)
    }
    
    @IBOutlet weak var cryptTableView: UITableView!
    
    
    class cryptoCurr : Codable {
        let Markets: [worldCoinIndex]
        
        init(Markets: [worldCoinIndex]){
            self.Markets = Markets
        }
        
    }
    
    class worldCoinIndex : Codable {
        var Label: String
        var Name: String
        var Price_btc: Float
        var Price_usd: Float
        var Price_cny: Float
        var Price_eur: Float
        var Price_gbp: Float
        var Price_rur: Float
        var Volume_24h: Float
        var Timestamp: Int
        init(){
            Label = ""
            Name = ""
            Price_btc = 0.0
            Price_usd = 0.0
            Price_cny = 0.0
            Price_eur = 0.0
            Price_gbp = 0.0
            Price_rur = 0.0
            Volume_24h = 0.0
            Timestamp = 0
        }
    }
    
    
    //for XML data
    class RegCurrs: Codable {
        let regCurrs: [regCurrency]
        
        init(regCurrs: [regCurrency]) {
            self.regCurrs = regCurrs
        }
    }
    
    class regCurrency: Codable {
        let Symbol: String
        let Bid: Float
        let Ask: Float
        let High: Float
        let Low: Float
        let Direction: Float
        let Last: String
        
        init(Symbol: String, Bid: Float, Ask: Float, High: Float, Low: Float, Direction: Float, Last: String) {
            self.Symbol = Symbol
            self.Bid = Bid
            self.Ask = Ask
            self.High = High
            self.Low = Low
            self.Direction = Direction
            self.Last = Last
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJson()      //gets json data and saves to cryptoCurr class
        loadXML()       //gets XML data and saves to regCurr class
        //updateTable()   //updates table, temporarly in loadJson
        
        cryptTableView.delegate = self
        cryptTableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadJson() {
        print("Loading JSON")
        let url = URL(string: "https://www.worldcoinindex.com/apiservice/json?key=wECsN7y9YetLXQJNwwMQKJFPI")
        guard let downloadURL = url else {return}
        
        //get JSON data
        URLSession.shared.dataTask(with: downloadURL) { data, urlResponse, error in
            guard let data = data, error == nil, urlResponse != nil else {
                print("JSON fail")
                return
            }
            print("JSON downloaded")    //error check for success
            
            do {
                let decoder = JSONDecoder()
                let crypt = try decoder.decode(cryptoCurr.self, from: data)       //decode JSON data
                print(crypt.Markets[0].Label)
                
                DispatchQueue.main.async{
                    self.cryptTableView.reloadData()
                }
                
                //self.cryptArrFin = [crypt]
                //print(self.cryptArrFin[0].Markets[1].Label)
                self.cryptArrFin = crypt.Markets
                print(self.cryptArrFin[1].Label)
                print(self.cryptArrFin.count)
                
                
            } catch {
                print("failed to decode JSON")
            }
            }.resume()
        
        // updateTable()
        
    }
    
    func loadXML(){
        print("Loading XML")
        let url = URL(string: "http://rates.fxcm.com/RatesXML")
    }
    
    func updateTable(){
        print("updating table")
        
        
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
