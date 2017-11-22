//
//  DetailView.swift
//  CurrencyX
//
//  Created by Kha on 11/1/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import Charts

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
    // UI variable initialize
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var fromCurrencyLbl: UILabel!
    @IBOutlet weak var toCurrencyLbl: UILabel!
    @IBOutlet weak var fromCurrAmount: UILabel!
    @IBOutlet weak var toCurrAmount: UILabel!
    
    
    // Process
    override func viewDidLoad()
    {
        super.viewDidLoad()
        backgroundImageName = "Background5.png"
        setBackgroundImage()
       
        
        if(MainView.isCryptoSelect == true)
        {
            displayCrypto()
            updateCryptChart()
        }
        else
        {
            displayCurrency()
            updateCurrencyChart()
        }
        _ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(DetailView.refresh), userInfo: nil, repeats: true)

    }
    @objc func refresh(){
        cryptoPrice.append(Double(cryptCurrency.price_usd)!)
        currencyPrice.append(Double(regCurrency.price))
        
        if(MainView.isCryptoSelect == true)
        {
            displayCrypto()
            updateCryptChart()
        }
        else
        {
            displayCurrency()
            updateCurrencyChart()
        }

       // updateCryptChart()
        //updateCurrencyChart()
        
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
        //array displays on the graph
        var lineChartEntry = [ChartDataEntry]()
        
        //loop
        for i in 0..<cryptoPrice.count
        {
            let value = ChartDataEntry(x: Double(i), y: cryptoPrice[i] ) //set x and y
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
