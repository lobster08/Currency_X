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

struct cryptoPrices : Codable
{
    let time : String
    let average : Double
    init ()
    {
        time = ""
        average = 0.0
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

struct CryptoPrices
{
    var name : String
    var prices : Double
    var time : String
    init()
    {
        name = ""
        prices = 0.0
        time = ""
    }
}
struct CurrencyPrices
{
    var namePair : String
    var prices : Double
    var time : String
    init()
    {
        namePair = ""
        prices = 0.0
        time = ""
        
    }
}
class DetailView: UIViewController {
    
    // daily cryptocurrencies urls
    var dailyCryptoUrls : [String: String] = ["Bitcoin" : "https://min-api.cryptocompare.com/data/histohour?fsym=BTC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ethereum" : "https://min-api.cryptocompare.com/data/histohour?fsym=ETH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Bitcoin Cash" : "https://min-api.cryptocompare.com/data/histohour?fsym=BCH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ripple" : "https://min-api.cryptocompare.com/data/histohour?fsym=XRP&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Dash" : "https://min-api.cryptocompare.com/data/histohour?fsym=DASH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Litecoin" : "https://min-api.cryptocompare.com/data/histohour?fsym=LTC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Bitcoin Gold" : "https://min-api.cryptocompare.com/data/histohour?fsym=BTG&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "IOTA" : "https://min-api.cryptocompare.com/data/histohour?fsym=IOTA&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Cardano" : "https://min-api.cryptocompare.com/data/histohour?fsym=ADA&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Monero" : "https://min-api.cryptocompare.com/data/histohour?fsym=XMR&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ethereum Classic" : "https://min-api.cryptocompare.com/data/histohour?fsym=ETC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "NEO" : "https://min-api.cryptocompare.com/data/histohour?fsym=NEO&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "NEM"  : "https://min-api.cryptocompare.com/data/histohour?fsym=XEM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "EOS" : "https://min-api.cryptocompare.com/data/histohour?fsym=EOS&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Stellar Lumens" : "https://min-api.cryptocompare.com/data/histohour?fsym=XLM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "BitConnect" : "https://min-api.cryptocompare.com/data/histohour?fsym=BCCOIN&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "OmiseGO" : "https://min-api.cryptocompare.com/data/histohour?fsym=OMG&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Qtum" : "https://min-api.cryptocompare.com/data/histohour?fsym=QTUM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Lisk" : "https://min-api.cryptocompare.com/data/histohour?fsym=LSK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Zcash" : "https://min-api.cryptocompare.com/data/histohour?fsym=ZEC&tsym=USD&limit=24&aggregate=3&e=CCCAGG"]
    
    //weekly cryptocurrencies urls
    var weeklyCryptoUrls : [String: String] = ["Bitcoin" : "https://min-api.cryptocompare.com/data/histoday?fsym=BTC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ethereum" : "https://min-api.cryptocompare.com/data/histoday?fsym=ETH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Bitcoin Cash" : "https://min-api.cryptocompare.com/data/histoday?fsym=BCH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ripple" : "https://min-api.cryptocompare.com/data/histoday?fsym=XRP&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Dash" : "https://min-api.cryptocompare.com/data/histoday?fsym=DASH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Litecoin" : "https://min-api.cryptocompare.com/data/histoday?fsym=LTC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Bitcoin Gold" : "https://min-api.cryptocompare.com/data/histoday?fsym=BTG&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "IOTA" : "https://min-api.cryptocompare.com/data/histoday?fsym=IOTA&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Cardano" : "https://min-api.cryptocompare.com/data/histoday?fsym=ADA&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Monero" : "https://min-api.cryptocompare.com/data/histoday?fsym=XMR&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ethereum Classic" : "https://min-api.cryptocompare.com/data/histoday?fsym=ETC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "NEO" : "https://min-api.cryptocompare.com/data/histoday?fsym=NEO&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "NEM"  : "https://min-api.cryptocompare.com/data/histoday?fsym=XEM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "EOS" : "https://min-api.cryptocompare.com/data/histoday?fsym=EOS&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Stellar Lumens" : "https://min-api.cryptocompare.com/data/histoday?fsym=XLM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "BitConnect" : "https://min-api.cryptocompare.com/data/histoday?fsym=BCCOIN&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "OmiseGO" : "https://min-api.cryptocompare.com/data/histoday?fsym=OMG&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Qtum" : "https://min-api.cryptocompare.com/data/histoday?fsym=QTUM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Lisk" : "https://min-api.cryptocompare.com/data/histoday?fsym=LSK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Zcash" : "https://min-api.cryptocompare.com/data/histoday?fsym=ZEC&tsym=USD&limit=7&aggregate=3&e=CCCAGG"]

    
    //  Create variable to set background image
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    //  var urls : String = [""]
    var dailyCryptoData = dailyCryptoPrices()
    var cPrices = [cryptoPrices]()
    var cPriceList =  [Double]()
    var cryptoPrice = [Double]()
    var currencyPrice = [Double]()
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
    
    //struct variable for firebase
    var cryptPrice = [CryptoPrices]()
    var cryptInfo = CryptoPrices()
    var currPrice = [CurrencyPrices]()
    var currInfo = CurrencyPrices()
    
    //empty array
    var priceList = [Double]()
    var cryptoName = ""
    
    
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
                getCryptoData(arrayUrl: dailyCryptoUrls)
                updateCryptoChart()
               // addDailyCryptoStruct()
             //   displayCrypto()
                // updateCryptChart()
            }
            else
            {
                displayCurrency()
                updateCurrencyChart()
            }
        }
        else if sender.selectedSegmentIndex == 1
        {
            if(MainView.isCryptoSelect == true)
            {
                getCryptoData(arrayUrl: weeklyCryptoUrls)
                updateCryptoChart()
                //updateWeeklyCryptoChart() // get weekly crypto chart
            }
            else
            {
                displayWeeklyCurrency()
                updateCurrencyChart()
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
        cryptoName = cryptCurrency.name
        if(MainView.isCryptoSelect == true)
        {
        //   getDailyCryptoData() // get daily crypto json
        //   updateDailyCryptoChart() //get chart
            getCryptoData(arrayUrl: dailyCryptoUrls)
            updateCryptoChart()
          //  getPrices()
            addDailyCryptoStruct()
            displayCrypto()
           // updateCryptChart()
        }
        else
        {
            displayCurrency()
            updateCurrencyChart()
        }
 
        _ = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(DetailView.refresh), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(DetailView.addDailyCryptoStruct), userInfo: nil, repeats: true)
        
    }
    @objc func addDailyCryptoStruct()
    {
        
        cryptInfo.name = String(cryptCurrency.name)
        cryptInfo.prices = Double(cryptCurrency.price_usd)!
        cryptInfo.time = "Date: \(day) - \(month) - \(year) : \(hh2) : \(mm2) : \(ss2)"
        
        addDailyCryptoPrices()
        cryptPrice.append(cryptInfo)
        print("adding to struct is working")
        
    }
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
    func getCryptoData(arrayUrl : [String : String])
    {
        let urlString = getUrl(urlname: cryptInfo.name, arrayUrl: arrayUrl )
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
            
            if let data = data {
                do{
                    self.cPriceList.removeAll()
                    
                    let jsonDecoder = JSONDecoder()
                    self.dailyCryptoData = try jsonDecoder.decode(dailyCryptoPrices.self , from: data)
                    DispatchQueue.main.async {
                        self.addCryptoPrices()
                        
                        //   print(self.cPriceList)
                        //  print(self.dailyCryptoData)
                        
                    }
                }
                catch {
                    print("Can't pull JSON")
                }
                
            }
        }
        task.resume()
    }

    //add data points to display daily graph
    func addCryptoPrices()    {
       // getDailyCryptoData()
        for i in dailyCryptoData.Data
        {
            cPriceList.append(i.close )

        }
        print (cPriceList)

    }
    //display cryptocurrencies graph
    func updateCryptoChart()
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
        self.lineChart.gridBackgroundColor = NSUIColor.yellow
        //  self.lineChart.chartDescription?.text = "Price Chart" //set title for the graph
    }
    func addDailyCryptoPrices()
    {
        refPrices = Database.database().reference().child("CryptoPrices")
        //add info to firebase
        let prices = ["Name" : cryptInfo.name as String, "Prices" : String(cryptInfo.prices) as String, "Time" : cryptInfo.time as String]
        
        refPrices.setValue(prices)
        print("prices added to firebase")
        
    }
    @objc func refresh(){
        
        if(MainView.isCryptoSelect == true)
        {
            cryptoPrice.append(Double(cryptCurrency.price_usd)!)
            displayCrypto()
           // updateCryptChart()
            displayWeeklyCrypto()
        }
        else
        {
            currencyPrice.append(Double(regCurrency.price))
            displayCurrency()
            updateCurrencyChart()
            displayWeeklyCurrency()
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
    func updateCurrencyChart()
    {
        //array displays on the graph
        var lineChartEntry = [ChartDataEntry]()
        
        //loop
        for i in 0..<currencyPrice.count
        {
            let value = ChartDataEntry(x: Double(i), y: currencyPrice[i] ) //set x and y
            lineChartEntry.append(value)//add info to chart
        }
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Price") //convert lineChartEntry to a LineChartDataSet
        
        line1.colors = [NSUIColor.blue]  //sets color to blue
        
        let data = LineChartData() //this is the object that will be added to the chart
        
        data.addDataSet(line1) //adds the line to the dataset
        
        self.lineChart.data = data
        self.lineChart.gridBackgroundColor = NSUIColor.white
        self.lineChart.chartDescription?.text = "Price Chart" //set title for the graph
    }
    /*
    func updateCryptChart()
    {
        readPrices()
        
        //array displays on the graph
        var lineChartEntry = [ChartDataEntry]()
        
        //loop
        for i in 0..<priceList.count
        {
            let value = ChartDataEntry(x: Double(i), y: priceList[i] ) //set x and y
            lineChartEntry.append(value)//add info to chart
        }
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Price") //convert lineChartEntry to a LineChartDataSet
        
        line1.colors = [NSUIColor.blue]  //sets color to blue
        
        let data = LineChartData() //this is the object that will be added to the chart
        
        data.addDataSet(line1) //adds the line to the dataset
        
        self.lineChart.data = data
        self.lineChart.gridBackgroundColor = NSUIColor.white
        self.lineChart.chartDescription?.text = "Price Chart" //set title for the graph
    }
 */
    func displayWeeklyCrypto()
    {
        
    }
    func displayWeeklyCurrency()
    {
        
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

