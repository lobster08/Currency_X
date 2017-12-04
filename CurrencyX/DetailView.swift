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


class DetailView: UIViewController {
    
    // daily cryptocurrencies urls
    var dailyCryptoUrls : [String: String] = ["Bitcoin" : "https://min-api.cryptocompare.com/data/histohour?fsym=BTC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ethereum" : "https://min-api.cryptocompare.com/data/histohour?fsym=ETH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Bitcoin Cash" : "https://min-api.cryptocompare.com/data/histohour?fsym=BCH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ripple" : "https://min-api.cryptocompare.com/data/histohour?fsym=XRP&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Dash" : "https://min-api.cryptocompare.com/data/histohour?fsym=DASH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Litecoin" : "https://min-api.cryptocompare.com/data/histohour?fsym=LTC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Bitcoin Gold" : "https://min-api.cryptocompare.com/data/histohour?fsym=BTG&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "IOTA" : "https://min-api.cryptocompare.com/data/histohour?fsym=IOTA&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Cardano" : "https://min-api.cryptocompare.com/data/histohour?fsym=ADA&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Monero" : "https://min-api.cryptocompare.com/data/histohour?fsym=XMR&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ethereum Classic" : "https://min-api.cryptocompare.com/data/histohour?fsym=ETC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "NEO" : "https://min-api.cryptocompare.com/data/histohour?fsym=NEO&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "NEM"  : "https://min-api.cryptocompare.com/data/histohour?fsym=XEM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "EOS" : "https://min-api.cryptocompare.com/data/histohour?fsym=EOS&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Stellar Lumens" : "https://min-api.cryptocompare.com/data/histohour?fsym=XLM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "BitConnect" : "https://min-api.cryptocompare.com/data/histohour?fsym=BCCOIN&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "OmiseGO" : "https://min-api.cryptocompare.com/data/histohour?fsym=OMG&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Qtum" : "https://min-api.cryptocompare.com/data/histohour?fsym=QTUM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Lisk" : "https://min-api.cryptocompare.com/data/histohour?fsym=LSK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Zcash" : "https://min-api.cryptocompare.com/data/histohour?fsym=ZEC&tsym=USD&limit=24&aggregate=3&e=CCCAGG"]
    
    //weekly cryptocurrencies urls
    var weeklyCryptoUrls : [String: String] = ["Bitcoin" : "https://min-api.cryptocompare.com/data/histoday?fsym=BTC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ethereum" : "https://min-api.cryptocompare.com/data/histoday?fsym=ETH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Bitcoin Cash" : "https://min-api.cryptocompare.com/data/histoday?fsym=BCH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ripple" : "https://min-api.cryptocompare.com/data/histoday?fsym=XRP&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Dash" : "https://min-api.cryptocompare.com/data/histoday?fsym=DASH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Litecoin" : "https://min-api.cryptocompare.com/data/histoday?fsym=LTC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Bitcoin Gold" : "https://min-api.cryptocompare.com/data/histoday?fsym=BTG&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "IOTA" : "https://min-api.cryptocompare.com/data/histoday?fsym=IOTA&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Cardano" : "https://min-api.cryptocompare.com/data/histoday?fsym=ADA&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Monero" : "https://min-api.cryptocompare.com/data/histoday?fsym=XMR&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ethereum Classic" : "https://min-api.cryptocompare.com/data/histoday?fsym=ETC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "NEO" : "https://min-api.cryptocompare.com/data/histoday?fsym=NEO&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "NEM"  : "https://min-api.cryptocompare.com/data/histoday?fsym=XEM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "EOS" : "https://min-api.cryptocompare.com/data/histoday?fsym=EOS&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Stellar Lumens" : "https://min-api.cryptocompare.com/data/histoday?fsym=XLM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "BitConnect" : "https://min-api.cryptocompare.com/data/histoday?fsym=BCCOIN&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "OmiseGO" : "https://min-api.cryptocompare.com/data/histoday?fsym=OMG&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Qtum" : "https://min-api.cryptocompare.com/data/histoday?fsym=QTUM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Lisk" : "https://min-api.cryptocompare.com/data/histoday?fsym=LSK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Zcash" : "https://min-api.cryptocompare.com/data/histoday?fsym=ZEC&tsym=USD&limit=7&aggregate=3&e=CCCAGG"]

    //currency daily urls : Order : JPY, CHF, CAD, SEK, NOK, MXN, ZAR, TRY, CNH, EUR, GBP, AUD, NZD
    var dailyCurrencyUrls : [String : String] = ["USDJPY" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=JPY&limit=24&aggregate=3&e=CCCAGG", "USDCHF" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=CHF&limit=24&aggregate=3&e=CCCAGG", "USDCAD" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=CAD&limit=24&aggregate=3&e=CCCAGG", "USDSEK" : "https://min-api.cryptocompare.com/data/histohour?fsym=SEK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDNOK" : "https://min-api.cryptocompare.com/data/histohour?fsym=NOK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDMXN" : "https://min-api.cryptocompare.com/data/histohour?fsym=MXD&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDZAR" : "https://min-api.cryptocompare.com/data/histohour?fsym=ZAR&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDTRY" : "https://min-api.cryptocompare.com/data/histohour?fsym=TRY&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDCNH" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=CNH&limit=24&aggregate=3&e=CCCAGG", "USDEUR" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=EUR&limit=24&aggregate=3&e=CCCAGG", "USDGBP" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=GBP&limit=24&aggregate=3&e=CCCAGG", "USDAUD" : "https://min-api.cryptocompare.com/data/histohour?fsym=AUD&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDNZD" : "https://min-api.cryptocompare.com/data/histohour?fsym=NZD&tsym=USD&limit=24&aggregate=3&e=CCCAGG"]
   
    //currency weekly urls : Order : JPY, CHF, CAD, SEK, NOK, MXN, ZAR, TRY, CNH, EUR, GBP, AUD, NZD
    var weeklyCurrencyUrls : [String: String] = ["USDJPY" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=JPY&limit=7&aggregate=3&e=CCCAGG", "USDCHF" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=CHF&limit=7&aggregate=3&e=CCCAGG", "USDCAD" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=CAD&limit=7&aggregate=3&e=CCCAGG", "USDSEK" : "https://min-api.cryptocompare.com/data/histoday?fsym=SEK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDNOK" : "https://min-api.cryptocompare.com/data/histoday?fsym=NOK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDMXN" : "https://min-api.cryptocompare.com/data/histoday?fsym=MXD&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDZAR" : "https://min-api.cryptocompare.com/data/histoday?fsym=ZAR&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDTRY" : "https://min-api.cryptocompare.com/data/histoday?fsym=TRY&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDCNH" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=CNH&limit=7&aggregate=3&e=CCCAGG", "USDEUR" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=EUR&limit=7&aggregate=3&e=CCCAGG", "USDGBP" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=GBP&limit=7&aggregate=3&e=CCCAGG", "USDAUD" : "https://min-api.cryptocompare.com/data/histoday?fsym=AUD&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDNZD" : "https://min-api.cryptocompare.com/data/histoday?fsym=NZD&tsym=USD&limit=7&aggregate=3&e=CCCAGG"]

    
    
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
    
    //dates variable
    let hh2 = (Calendar.current.component(.hour, from: Date()))
    let mm2 = (Calendar.current.component(.minute, from: Date()))
    let ss2 = (Calendar.current.component(.second, from: Date()))
    let day = (Calendar.current.component(.day, from: Date()))
    let month = (Calendar.current.component(.month, from: Date()))
    let year = (Calendar.current.component(.year, from: Date()))
    //test
    var dailycrypto = [dailyCryptoPrices]()
    
    
    
    //firebase
    var refPrices : DatabaseReference!
    var user = Auth.auth().currentUser
    // UI variable initialize
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0
        {
            if(MainView.isCryptoSelect == true)
            {

              //  updateDailyCryptoChart() //get daily crypto chart
                getCryptoData(arrayUrl: dailyCryptoUrls, name: cryptCurrency.name)
                updateCryptoChart()
               // addDailyCryptoStruct()
             //   displayCrypto()
                // updateCryptChart()
            }
            else
            {
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

                getCryptoData(arrayUrl: weeklyCryptoUrls, name: cryptCurrency.name)
                updateCryptoChart()
                //updateWeeklyCryptoChart() // get weekly crypto chart
            }
            else
            {
                displayCurrency()
                getCryptoData(arrayUrl: weeklyCurrencyUrls, name: regCurrency.symbol)
                updateCryptoChart()
            }
            
        }
        
    }
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var fromCurrencyLbl: UILabel!
    @IBOutlet weak var toCurrencyLbl: UILabel!
    @IBOutlet weak var fromCurrAmount: UILabel!
    @IBOutlet weak var toCurrAmount: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        backgroundImageName = "Background5.png"
        setBackgroundImage()
        if(MainView.isCryptoSelect == true)
        {
            getCryptoData(arrayUrl: dailyCryptoUrls, name: cryptCurrency.name)
            updateCryptoChart()
            displayCrypto()
        }
        else
        {
            displayCurrency()
            getCryptoData(arrayUrl: dailyCurrencyUrls, name: regCurrency.symbol)
            updateCryptoChart()
        }
 
        _ = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(DetailView.refresh), userInfo: nil, repeats: true)
     
        //reload crypto chart
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(DetailView.updateCryptoChart), userInfo: nil, repeats: true)
        
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
    //add data points to display daily graph
    func addCryptoPrices()
    {
        for i in dailyCryptoData.Data
        {
            cPriceList.append(i.close )

        }
    }
        /**********************************
            Display graph function
        **********************************/
    //display cryptocurrencies graph
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
    /*
    func addDailyCryptoPrices()
    {
        refPrices = Database.database().reference().child("CryptoPrices")
        //add info to firebase
        let prices = ["Name" : cryptInfo.name as String, "Prices" : String(cryptInfo.prices) as String, "Time" : cryptInfo.time as String]
        
        refPrices.setValue(prices)
        print("prices added to firebase")
        
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
    
        /**********************************
            Display textfield function
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "DetailToBuy")
        {
            let passToBuy = segue.destination as! BuyView
            passToBuy.buyData = cryptCurrency
        }
    }
    
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

