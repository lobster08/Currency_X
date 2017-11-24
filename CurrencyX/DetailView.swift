//
//  DetailView.swift
//  CurrencyX
//
//  Created by Kha on 11/1/17.
//  Copyright © 2017 Team 5. All rights reserved.
//


import UIKit
import Charts
import FirebaseDatabase
import Firebase
import FirebaseAuth


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
    
    //  Create variable to set background image
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
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
                addDailyCryptoStruct()
                displayCrypto()
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
                // readPrices()
                displayWeeklyCrypto()
                updateCryptChart()
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
            addDailyCryptoStruct()
            displayCrypto()
            updateCryptChart()
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
            updateCryptChart()
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
                print("Test this shit \(self.priceList.count)")
                
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

