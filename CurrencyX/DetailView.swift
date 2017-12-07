//
//  DetailView.swift
//  CurrencyX
//
//  Created by Kha on 11/1/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import Foundation
import UIKit
import Charts
import FirebaseDatabase
import Firebase
import FirebaseAuth

//
class info : NSObject {
    var buyAmount: String?
    var buyCost : String?
    var buyTotalPrice : String?
    var date : String?
    var type : String?

    override init()
    {
        buyCost = ""
        buyAmount = ""
        buyTotalPrice = ""
        date = ""
        type = ""
    }
    init(amount1: String, cost1: String, totalprice : String, data1 : String, type1 : String){
        buyAmount = amount1
        buyCost = cost1
        buyTotalPrice = totalprice
        date = data1
        type = type1
    }
    init(data : Dictionary<String, String>)
    {
        if let amount = data["buyAmount"] as? String {
            self.buyAmount = amount
        }
        if let date = data["data"] as? String {
            self.date = date
        }
        if let cost = data["buyCost"] as? String {
            self.buyCost = cost
        }
        if let totalprice = data["buyTotalPrice"] as? String {
            self.buyTotalPrice = totalprice
        }
        if let type1 = data["Type"] as? String {
            self.type = type1
        }

    }
}

// struct for cryptoPrices
struct dailyCryptoPrices : Codable
{
    private enum CodingKeys: String, CodingKey {
        case Response
        case _type = "Type"
        case Aggregated
        case Data
        case TimeTo
        case TimeFrom
        case FirstValueInArray
        case ConversionType

    }

    let Response : String
    let _type : Int
    let Aggregated : Bool
    let Data : [data]
    let TimeTo : Double
    let TimeFrom : Double
    let FirstValueInArray : Bool
    let ConversionType : convType
    

    struct data : Codable
    {
        let time : Double
        let close : Double
        let high : Double
        let low : Double
        let open : Double
        let volumefrom : Double
        let volumeto : Double
        init()
        {
            time = 0
            close = 0.0
            high = 0.0
            low = 0.0
            open = 0.0
            volumefrom = 0.0
            volumeto = 0.0
        }
    }

    init()
    {
        Response = ""
        _type = 0

        Aggregated = false
        Data = [data]()
        TimeTo  = 0.0
        TimeFrom = 0.0
        FirstValueInArray = true
        ConversionType = convType()


    }
    struct convType : Codable
    {
        let type : String
        let conversionSymbol : String
        init()
        {
            type = ""
            conversionSymbol = ""
        }
    }
}


class DetailView: UIViewController, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
  

    /********************************
        TableView Functions
   **************************************/
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numOfInfo
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
        
        let dateLbl = cell?.contentView.viewWithTag(1) as! UILabel
        let typeLbl = cell?.contentView.viewWithTag(2) as! UILabel
        let totalAmountLbl = cell?.contentView.viewWithTag(3) as! UILabel
        let amountLvb = cell?.contentView.viewWithTag(4) as! UILabel

        dateLbl.text = purchaseInfo[indexPath.row].date
        typeLbl.text = purchaseInfo[indexPath.row].type
        totalAmountLbl.text = purchaseInfo[indexPath.row].buyTotalPrice
        amountLvb.text = "\(purchaseInfo[indexPath.row].buyAmount) shares at \(purchaseInfo[indexPath.row].buyCost)"
        
        return cell!
        
    }
    
    
    // daily cryptocurrencies urls
    var dailyCryptoUrls : [String: String] = ["Bitcoin" : "https://min-api.cryptocompare.com/data/histohour?fsym=BTC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ethereum" : "https://min-api.cryptocompare.com/data/histohour?fsym=ETH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Bitcoin Cash" : "https://min-api.cryptocompare.com/data/histohour?fsym=BCH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ripple" : "https://min-api.cryptocompare.com/data/histohour?fsym=XRP&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Dash" : "https://min-api.cryptocompare.com/data/histohour?fsym=DASH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Litecoin" : "https://min-api.cryptocompare.com/data/histohour?fsym=LTC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Bitcoin Gold" : "https://min-api.cryptocompare.com/data/histohour?fsym=BTG&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "IOTA" : "https://min-api.cryptocompare.com/data/histohour?fsym=IOTA&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Cardano" : "https://min-api.cryptocompare.com/data/histohour?fsym=ADA&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Monero" : "https://min-api.cryptocompare.com/data/histohour?fsym=XMR&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ethereum Classic" : "https://min-api.cryptocompare.com/data/histohour?fsym=ETC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "NEO" : "https://min-api.cryptocompare.com/data/histohour?fsym=NEO&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "NEM"  : "https://min-api.cryptocompare.com/data/histohour?fsym=XEM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "EOS" : "https://min-api.cryptocompare.com/data/histohour?fsym=EOS&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Stellar Lumens" : "https://min-api.cryptocompare.com/data/histohour?fsym=XLM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "BitConnect" : "https://min-api.cryptocompare.com/data/histohour?fsym=BCCOIN&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "OmiseGO" : "https://min-api.cryptocompare.com/data/histohour?fsym=OMG&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Qtum" : "https://min-api.cryptocompare.com/data/histohour?fsym=QTUM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Lisk" : "https://min-api.cryptocompare.com/data/histohour?fsym=LSK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Zcash" : "https://min-api.cryptocompare.com/data/histohour?fsym=ZEC&tsym=USD&limit=24&aggregate=3&e=CCCAGG"]
    
    //weekly cryptocurrencies urls
    var weeklyCryptoUrls : [String: String] = ["Bitcoin" : "https://min-api.cryptocompare.com/data/histoday?fsym=BTC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ethereum" : "https://min-api.cryptocompare.com/data/histoday?fsym=ETH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Bitcoin Cash" : "https://min-api.cryptocompare.com/data/histoday?fsym=BCH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ripple" : "https://min-api.cryptocompare.com/data/histoday?fsym=XRP&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Dash" : "https://min-api.cryptocompare.com/data/histoday?fsym=DASH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Litecoin" : "https://min-api.cryptocompare.com/data/histoday?fsym=LTC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Bitcoin Gold" : "https://min-api.cryptocompare.com/data/histoday?fsym=BTG&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "IOTA" : "https://min-api.cryptocompare.com/data/histoday?fsym=IOTA&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Cardano" : "https://min-api.cryptocompare.com/data/histoday?fsym=ADA&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Monero" : "https://min-api.cryptocompare.com/data/histoday?fsym=XMR&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ethereum Classic" : "https://min-api.cryptocompare.com/data/histoday?fsym=ETC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "NEO" : "https://min-api.cryptocompare.com/data/histoday?fsym=NEO&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "NEM"  : "https://min-api.cryptocompare.com/data/histoday?fsym=XEM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "EOS" : "https://min-api.cryptocompare.com/data/histoday?fsym=EOS&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Stellar Lumens" : "https://min-api.cryptocompare.com/data/histoday?fsym=XLM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "BitConnect" : "https://min-api.cryptocompare.com/data/histoday?fsym=BCCOIN&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "OmiseGO" : "https://min-api.cryptocompare.com/data/histoday?fsym=OMG&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Qtum" : "https://min-api.cryptocompare.com/data/histoday?fsym=QTUM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Lisk" : "https://min-api.cryptocompare.com/data/histoday?fsym=LSK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Zcash" : "https://min-api.cryptocompare.com/data/histoday?fsym=ZEC&tsym=USD&limit=7&aggregate=3&e=CCCAGG"]

    //currency daily urls : Order : JPY, CHF, CAD, SEK, NOK, MXN, ZAR, TRY, CNH, EUR, GBP, AUD, NZD
    var dailyCurrencyUrls : [String : String] = ["USDJPY" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=JPY&limit=24&aggregate=3&e=CCCAGG", "USDCHF" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=CHF&limit=24&aggregate=3&e=CCCAGG", "USDCAD" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=CAD&limit=24&aggregate=3&e=CCCAGG", "USDSEK" : "https://min-api.cryptocompare.com/data/histohour?fsym=SEK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDNOK" : "https://min-api.cryptocompare.com/data/histohour?fsym=NOK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDMXN" : "https://min-api.cryptocompare.com/data/histohour?fsym=MXN&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDZAR" : "https://min-api.cryptocompare.com/data/histohour?fsym=ZAR&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDTRY" : "https://min-api.cryptocompare.com/data/histohour?fsym=TRY&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDCNH" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=CNH&limit=24&aggregate=3&e=CCCAGG", "USDEUR" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=EUR&limit=24&aggregate=3&e=CCCAGG", "USDGBP" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=GBP&limit=24&aggregate=3&e=CCCAGG", "USDAUD" : "https://min-api.cryptocompare.com/data/histohour?fsym=AUD&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDNZD" : "https://min-api.cryptocompare.com/data/histohour?fsym=NZD&tsym=USD&limit=24&aggregate=3&e=CCCAGG"]
   
    //currency weekly urls : Order : JPY, CHF, CAD, SEK, NOK, MXN, ZAR, TRY, CNH, EUR, GBP, AUD, NZD
    var weeklyCurrencyUrls : [String: String] = ["USDJPY" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=JPY&limit=7&aggregate=3&e=CCCAGG", "USDCHF" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=CHF&limit=7&aggregate=3&e=CCCAGG", "USDCAD" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=CAD&limit=7&aggregate=3&e=CCCAGG", "USDSEK" : "https://min-api.cryptocompare.com/data/histoday?fsym=SEK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDNOK" : "https://min-api.cryptocompare.com/data/histoday?fsym=NOK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDMXN" : "https://min-api.cryptocompare.com/data/histoday?fsym=MXN&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDZAR" : "https://min-api.cryptocompare.com/data/histoday?fsym=ZAR&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDTRY" : "https://min-api.cryptocompare.com/data/histoday?fsym=TRY&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDCNH" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=CNH&limit=7&aggregate=3&e=CCCAGG", "USDEUR" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=EUR&limit=7&aggregate=3&e=CCCAGG", "USDGBP" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=GBP&limit=7&aggregate=3&e=CCCAGG", "USDAUD" : "https://min-api.cryptocompare.com/data/histoday?fsym=AUD&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDNZD" : "https://min-api.cryptocompare.com/data/histoday?fsym=NZD&tsym=USD&limit=7&aggregate=3&e=CCCAGG"]

    
    
    //  Create variable to set background image
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    //  var urls : String = [""]
    var dailyCryptoData = dailyCryptoPrices()
    var cPriceList =  [Double]()
    // Variable Initialize
    var cryptCurrency = CryptoCurrency()
    var regCurrency = currency()
    var ref: DatabaseReference!
    var currencyName : String = ""
    var amountTxt = String()
    
    var numOfInfo : Int = 0
    var purchaseInfo = [info]()
    
    static var amount = 0
    let userID = Auth.auth().currentUser?.uid

    //dates variable
    let hh2 = (Calendar.current.component(.hour, from: Date()))
    let mm2 = (Calendar.current.component(.minute, from: Date()))
    let ss2 = (Calendar.current.component(.second, from: Date()))
    let day = (Calendar.current.component(.day, from: Date()))
    let month = (Calendar.current.component(.month, from: Date()))
    let year = (Calendar.current.component(.year, from: Date()))
    
    
    //firebase
    var refPrice: DatabaseReference!
    var user = Auth.auth().currentUser
    // UI variable initialize
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0
        {
            if(MainView.isCryptoSelect == true)
            {
                
                
                readAmount()
                getCryptoData(arrayUrl: dailyCryptoUrls, name: cryptCurrency.name)
                updateCryptoChart()
            }
            else
            {
                readAmount()
                displayCurrency()
                getCryptoData(arrayUrl: dailyCurrencyUrls, name: regCurrency.symbol)
                updateCryptoChart()

               // updateCurrencyChart()
            }
        }
        else if sender.selectedSegmentIndex == 1
        {
            if(MainView.isCryptoSelect == true)
            {
                readAmount()
                readInfo()
                getCryptoData(arrayUrl: weeklyCryptoUrls, name: cryptCurrency.name)
                updateCryptoChart()
                //updateWeeklyCryptoChart() // get weekly crypto chart
            }
            else
            {
                readAmount()
                readInfo()
                displayCurrency()
                getCryptoData(arrayUrl: weeklyCurrencyUrls, name: regCurrency.symbol)
                updateCryptoChart()
            }
            
        }
        
    }
    //table view cell variables
    
    
    @IBOutlet weak var TableView: UITableView!
    

    @IBOutlet weak var buyButtonHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var buyButtonWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var fromCurrencyLbl: UILabel!
    @IBOutlet weak var toCurrencyLbl: UILabel!
    @IBOutlet weak var fromCurrAmount: UILabel!
    @IBOutlet weak var toCurrAmount: UILabel!
    @IBAction func NotiButton(_ sender: Any) {
        performSegue(withIdentifier: "DetailToNotification", sender: self)

    }
    @IBAction func sellButton(_ sender: Any) {
        performSegue(withIdentifier: "DetailToSell", sender: self)

    }
    
    @IBAction func buyButton(_ sender: Any) {
        performSegue(withIdentifier: "DetailToBuy", sender: self)

    }
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //self.backgroundImage = UIImage.imageWithColor(UIColor.clearColor())
        backgroundImageName = "background6.png"
        setBackgroundImage()
        tabBar.delegate = self
        tabBar.backgroundColor = UIColor.clear
        TableView.delegate = self
        TableView.dataSource = self
        
      //  else
        //{
          //  print("iuhfuisdhfkshk      \(amountArr[0] )")
            //sellButton.isHidden = false
        //}
        //tabBar.backgroundImage = UIImage.imageWithColor(UIColor.clearColor())
        if(MainView.isCryptoSelect == true)
        {
            currencyName = cryptCurrency.name
            readAmount()
            readInfo()

            getCryptoData(arrayUrl: dailyCryptoUrls, name: cryptCurrency.name)
            updateCryptoChart()
            displayCrypto()
        }
        else
        {
            currencyName = regCurrency.symbol
            readAmount()
            readInfo()
            displayCurrency()
            getCryptoData(arrayUrl: dailyCurrencyUrls, name: regCurrency.symbol)
            updateCryptoChart()
        }
 
        _ = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(DetailView.refresh), userInfo: nil, repeats: true)
     
        //reload crypto chart
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(DetailView.updateCryptoChart), userInfo: nil, repeats: true)
        
    }
    /*******************************
            Tab Bar Function
    ********************************/
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (item.tag == 1) {
            performSegue(withIdentifier: "DetailToBuy", sender: self)
        }
        else if (item.tag == 2)
        {
            performSegue(withIdentifier: "DetailToSell", sender: self)
        }
        else if (item.tag == 3)
        {
            performSegue(withIdentifier: "DetailToNotification", sender: self)
        }
    }
    
    /*
    @objc func addDailyCryptoStruct()
    {
        
        cryptInfo.name = String(cryptCurrency.name)
        cryptInfo.prices = Double(cryptCurrency.price_usd)!
        cryptInfo.time = "Date: \(day) - \(month) - \(year) : \(hh2) : \(mm2) : \(ss2)"
        
        addDailyCryptoPrices()
        cryptPrice.append(cryptInfo)
        print("adding to struct is working")
        
    }
 */
    /**********************************
        Search function - returns url
    **********************************/
    
    //return daily crypto url link
    func getUrl(urlname : String, arrayUrl : [String : String]) -> String
    {
            for (key, value) in arrayUrl
            {
                if (urlname == key)
                {
                    return value
                }
            }
        return ""
    }
        /**********************************
            Load JSON function
        **********************************/
    func getCryptoData(arrayUrl : [String : String], name : String)
    {
        let urlString = getUrl(urlname: name, arrayUrl: arrayUrl )
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
            
            if let data = data {
                do{
                    self.cPriceList.removeAll()

                    let jsonDecoder = JSONDecoder()
                    self.dailyCryptoData = try jsonDecoder.decode(dailyCryptoPrices.self , from: data)
                    DispatchQueue.main.async {
                   
                    }
                }
                catch {
                    print("Can't pull JSON")
                }
                self.addCryptoPrices()
            }
        }
        task.resume()
    }
        /**********************************
            Add points to graph function
        **********************************/
    func addCryptoPrices()
    {
        for i in dailyCryptoData.Data
        {
            cPriceList.append(i.open )

        }
    }
        /**********************************
            Display graph function
        **********************************/
   @objc  func updateCryptoChart()
    {
        
        //array displays on the graph
        var lineChartEntry = [ChartDataEntry]()
        var b = 0
        //hourly time
        let now = Date()
        //let hourlyArray = [String]
        var components = DateComponents()
        components.hour = -1
        let oneHourAgo = Calendar.current.date(byAdding: components, to: now)
        //loop
        for i in cPriceList
        {
            
            
            let value = ChartDataEntry(x: Double(b), y: i ) //set x and yc
            b = b + 1
            lineChartEntry.append(value)//add info to chart
        }
        self.lineChart.reloadInputViews()
        self.lineChart.pin(to: lineChart)
        self.lineChart.notifyDataSetChanged()

        let line1 = LineChartDataSet(values: lineChartEntry, label: "Price") //convert lineChartEntry to a LineChartDataSet
        
        line1.colors = [NSUIColor.red]  //sets color to blue
        
        let data = LineChartData() //this is the object that will be added to the chart
        
        data.addDataSet(line1) //adds the line to the dataset
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        self.lineChart.legend.enabled = false
        self.lineChart.data = data
        
        self.lineChart.lineData?.setDrawValues(false)
        self.lineChart.borderColor = NSUIColor.cyan
        //self.lineChart.lineData?.se
        self.lineChart.backgroundColor = NSUIColor.clear
        self.lineChart.chartDescription?.enabled = false //set title for the graph
        self.lineChart.invalidateIntrinsicContentSize()

    }
    /**********************************************
        Read From Firebase Functions
    **********************************************/


    func readInfo()
    {
            self.purchaseInfo = [info]()
            ref = Database.database().reference().child("PurchasedInfo").child((user?.uid)!).child(currencyName)//.childByAutoId()
            ref.observeSingleEvent(of: .childAdded, with: { (snapshot) in
                self.numOfInfo = Int(snapshot.childrenCount)
                print("asdljasdh \(self.numOfInfo)")
                if let dictionary = snapshot.value as? NSDictionary {
                    for item in dictionary  {
                        //print(item)

                        if let infomation = item.key as? Dictionary<String,String>{

                            let infos = info(data: infomation)
                            self.purchaseInfo.append(infos)
                            print(self.purchaseInfo)
                            self.TableView.reloadData()

                    }
                    DispatchQueue.main.async {
                        self.TableView.reloadData()
                    }
                    }
                }
            })
            TableView.delegate = self
            TableView.dataSource = self
    }
    func readAmount()
    {
       // self.amountArr.removeAll()
        ref = Database.database().reference().child("PurchasedAmount").child(userID!).child(currencyName)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
            if let value = snapshot.value as? NSDictionary {
                for snapDict in value {
                     self.amountTxt = snapDict.value as! String

                    print(self.amountTxt)
               
                }
                
            }
            }
                //if firebase doesn't have a value, the sell button is hidden
            else {
                self.sellButton.isHidden = true
                self.buyButtonHeightConstrain.constant = 40
                self.buyButtonWidthConstrain.constant = 400
                //  self.buyButton.translatesAutoresizingMaskIntoConstraints = false
                //self.buyButton.frame.origin = CGPoint(x: 400, y: 3000)
            }
        })
    }
    /*
     //read firebase values for 7 days graph -- Crypto
     func readPrices()
     {
     
     ref = Database.database().reference().child("crypPrices").child(cryptoName)
     ref.observeSingleEvent(of: .value, with: { (snapshot) in
     if let snapshotValue = snapshot.value as? NSDictionary{
     for snapDict in snapshotValue{
     print ("For loop enters")
     let smt = snapDict.value as! Double
     self.priceList.append(Double(smt))
     print (smt)
     }
     
     }
     })
     }
     
     */
    
   

    /*
    func addDailyCryptoPrices()
    {
     refPrices = Database.database().reference().child("CryptoPrices")         refPrices.setValue(prices)

        //add info to firebase
        let prices = ["Name" : cryptInfo.name as String, "Prices" : String(cryptInfo.prices) as String, "Time" : cryptInfo.time as String]
        
        print("prices added to firebase")
        refPrices.setValue(prices)
     
    }
 */
    @objc func refresh(){
        
        if(MainView.isCryptoSelect == true)
        {
         //   cryptoPrice.append(Double(cryptCurrency.price_usd)!)
            displayCrypto()
           // updateCryptChart()
        }
        else
        {
           // currencyPrice.append(Double(regCurrency.price))
            displayCurrency()
          //  updateCurrencyChart()
        }
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
  
    
        /**********************************
            Display textfield functions
        **********************************/
    func displayCrypto()
    {
        fromCurrencyLbl.text = cryptCurrency.name
        toCurrencyLbl.text = "USD"
        fromCurrAmount.text = "1"
        toCurrAmount.text = String(cryptCurrency.price_usd)
        
    }
    func displayCurrency()
    {
        fromCurrencyLbl.text = String(regCurrency.symbol.characters.prefix(3))
        toCurrencyLbl.text = String(regCurrency.symbol.characters.suffix(3))
        fromCurrAmount.text = "1"
        toCurrAmount.text = String(regCurrency.price)
        
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "DetailToBuy")
        {
            let passToBuy = segue.destination as! BuyView
            passToBuy.buyData = cryptCurrency
            
            let passdata = segue.destination as! BuyView
            passdata.cryptoData = cryptCurrency
            passdata.currencyData = regCurrency
        }else if (segue.identifier == "DetailToSell"){
            
            let passToSell = segue.destination as! SellView
            passToSell.sellDataCrypCurr = cryptCurrency
            passToSell.sellDataRegCurr = regCurrency
        }
    }
    
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

