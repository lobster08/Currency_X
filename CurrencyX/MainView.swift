//
//  MainView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/18/17.
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

class CryptoCurrency{
    var id : String
    var name : String
    var symbol : String
    var rank : String
    var price_usd: String
    var price_btc : String
    var volume_usd : String
    var market_cap_usd : String
    var available_supply : String
    var max_supply : String
    var total_supply : String
    var percent_change_1h: String
    var percent_change_24h : String
    var percent_change_7d : String
    var last_updated : String
    init (ID : String, Name : String, Symbol : String, Rank: String, Price_USD: String, Price_BTC: String, Volume_USD: String,
          Market_cap : String, Available_Supply: String, Total_Supply: String, Max_Supply : String, Percent_1h: String, Percent_24h: String, Percent_7d: String, LastUpdated : String){
        id = ID;
        name = Name
        symbol = Symbol
        rank = Rank
        price_usd = Price_USD
        price_btc = Price_BTC
        volume_usd = Volume_USD
        market_cap_usd = Market_cap
        available_supply = Available_Supply
        max_supply = Max_Supply
        total_supply = Total_Supply
        percent_change_1h = Percent_1h
        percent_change_24h = Percent_24h
        percent_change_7d = Percent_7d
        last_updated = LastUpdated
    }
    init(){
        id = ""
        name = ""
        symbol = ""
        rank = ""
        price_usd = ""
        price_btc = ""
        volume_usd = ""
        market_cap_usd = ""
        available_supply = ""
        total_supply = ""
        max_supply = ""
        percent_change_1h = ""
        percent_change_24h = ""
        percent_change_7d = ""
        last_updated = ""
    }
}


//probable don't need this
//class regCurrency: Codable {
//    let Symbol: String
//    let Bid: Float
//    let Ask: Float
//    let High: Float
//    let Low: Float
//    let Direction: Float
//    let Last: String
//
//    init(Symbol: String, Bid: Float, Ask: Float, High: Float, Low: Float, Direction: Float, Last: String) {
//        self.Symbol = Symbol
//        self.Bid = Bid
//        self.Ask = Ask
//        self.High = High
//        self.Low = Low
//        self.Direction = Direction
//        self.Last = Last
//    }
//}

class MainView: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var cryptTableView: UITableView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTopConstraint: NSLayoutConstraint!
    
    var searchBar: UISearchBar!
    
    var selectedCryptCell = CryptoCurrency()
    var crypCurrencyList = [CryptoCurrency]()
    
    //Currencies variable
    var Currencies = [currency]()
    var selectedCurrency = currency()
    
    var isSearching = false
    var filteredCrypt = [CryptoCurrency]()
    
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""

    var menuShowing = false
    var filterShowing = false
    
    var filterButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    var menuButton: UIBarButtonItem!
    
    var isShowCrypto = true
    var isShowCurrency = true
    
    // sees if user clicks on crypto cell or regcurrency cell
    static var isCryptoSelect = false;
    static var isCurrencySelect = false;
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MainView"
        backgroundImageName = "Background4.png"
        menuView.isHidden = true
        filterView.isHidden = true
        setBackgroundImage()
        getData()//get crypto data
        getCurrency()//get currency data
        cryptTableView.delegate = self
        cryptTableView.dataSource = self
        
//        searchBar.delegate = self
//        searchBar.returnKeyType = UIReturnKeyType.done
        menuButton = UIBarButtonItem(image: UIImage(named: "menuButton"), style: .done, target: self, action: #selector(openMenuOption))
        self.navigationItem.leftBarButtonItem = menuButton
        
        searchButton = UIBarButtonItem(image: UIImage(named: "searchButton"), style: .done, target: self, action: #selector(searchItem))
        filterButton = UIBarButtonItem(image: UIImage(named: "filterButton"), style: .done, target: self, action: #selector(filterItems))
        self.navigationItem.rightBarButtonItems = [filterButton, searchButton]
        
       _ = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(MainView.refresh), userInfo: nil, repeats: true)
    }
    
    @objc func searchItem(){
        
    }
    @objc func filterItems(){
        filterShowing = !filterShowing
        if (!filterShowing){
            filterTopConstraint.constant = -300
            filterView.isHidden = true
            self.cryptTableView.alpha = 0.8
            self.navigationItem.rightBarButtonItems?.last?.isEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.cryptTableView.isUserInteractionEnabled = true
        }
        else{
            filterView.isHidden = false
            self.navigationItem.rightBarButtonItems?.last?.isEnabled = false
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.cryptTableView.isUserInteractionEnabled = false
            self.cryptTableView.alpha = 0.1
            createFilterOptionList()
            filterTopConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func openMenuOption(){
        menuShowing = !menuShowing
        if (!menuShowing){
            topConstraint.constant = -300
            menuView.isHidden = true
            self.cryptTableView.alpha = 0.8
            self.navigationItem.rightBarButtonItems?.first?.isEnabled = true
            self.navigationItem.rightBarButtonItems?.last?.isEnabled = true
            self.cryptTableView.isUserInteractionEnabled = true
        }
        else{
            menuView.isHidden = false
            self.navigationItem.rightBarButtonItems?.first?.isEnabled = false
            self.navigationItem.rightBarButtonItems?.last?.isEnabled = false
            self.cryptTableView.isUserInteractionEnabled = false
            self.cryptTableView.alpha = 0.1
            createMenuViewButtons()
            topConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    //  Create Drop Down Menu List
    func createMenuViewButtons(){
        createAccountSettingBtn()
        createLogOutBtn()
        createWalletBtn()
    }
    
    func createAccountSettingBtn() {
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 0, width: 160, height: 40)
        button.setImage(UIImage(named:"customerButton"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2,left: 0,bottom: 2,right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: 5,bottom: 2,right: 0)
        button.setTitle("Account Setting", for: .normal)
        button.layer.borderWidth = 1.0
        button.backgroundColor = UIColor.white //--> set the background color and check
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(accountSettingBtn), for: UIControlEvents.touchUpInside)
        self.menuView.addSubview(button)
    }
    
    @objc func accountSettingBtn(){
        performSegue(withIdentifier: "MainToAcc", sender: self)
    }
    
    func createLogOutBtn() {
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 40, width: 160, height: 40)
        button.setImage(UIImage(named:"exitButton"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2,left: -49,bottom: 2,right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: -44,bottom: 2,right: 0)
        button.setTitle("Log out", for: .normal)
        button.layer.borderWidth = 1.0
        button.backgroundColor = UIColor.white //--> set the background color and check
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(LogoutBtn), for: UIControlEvents.touchUpInside)
        self.menuView.addSubview(button)
    }
    
    @objc func LogoutBtn(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func createWalletBtn(){
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 80, width: 160, height: 40)
        button.setImage(UIImage(named:"wallet"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2,left: -62,bottom: 2,right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: -57,bottom: 2,right: 0)
        button.setTitle("Wallet", for: .normal)
        button.layer.borderWidth = 1.0
        button.backgroundColor = UIColor.white //--> set the background color and check
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(WalletBtn), for: UIControlEvents.touchUpInside)
        self.menuView.addSubview(button)
    }
    
    @objc func WalletBtn(){
        performSegue(withIdentifier: "MainToWallet", sender: self)
    }
    
    // Create Filter Option List
    func createFilterOptionList(){
        createShowCryptoFilterBtn()
        createShowCurrencyFilterBtn()
        createShowAllBtn()
    }
    
    func createShowCryptoFilterBtn(){
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 0, width: 160, height: 40)
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: 0,bottom: 2,right: 0)
        button.setTitle("Show CryptoCurrency", for: .normal)
        button.layer.borderWidth = 1.0
        button.backgroundColor = UIColor.white //--> set the background color and check
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(cryptoFilterBtn), for: UIControlEvents.touchUpInside)
        self.filterView.addSubview(button)
    }
    @objc func cryptoFilterBtn(){
        isShowCrypto = true
        isShowCurrency = false
        self.refresh()
        endFilter()
    }
    
    func createShowCurrencyFilterBtn(){
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 40, width: 160, height: 40)
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: 0,bottom: 2,right: 0)
        button.setTitle("Show Currency", for: .normal)
        button.layer.borderWidth = 1.0
        button.backgroundColor = UIColor.white //--> set the background color and check
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(currencyFilterBtn), for: UIControlEvents.touchUpInside)
        self.filterView.addSubview(button)
    }
    @objc func currencyFilterBtn(){
        isShowCrypto = false
        isShowCurrency = true
        self.refresh()
        endFilter()
    }
    
    func createShowAllBtn(){
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 80, width: 160, height: 40)
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: 0,bottom: 2,right: 0)
        button.setTitle("Show All", for: .normal)
        button.layer.borderWidth = 1.0
        button.backgroundColor = UIColor.white //--> set the background color and check
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(allBtn), for: UIControlEvents.touchUpInside)
        self.filterView.addSubview(button)
    }
    @objc func allBtn(){
        isShowCrypto = true
        isShowCurrency = true
        self.refresh()
        endFilter()
    }
    func endFilter(){
        filterShowing = !filterShowing
        filterTopConstraint.constant = -300
        filterView.isHidden = true
        self.cryptTableView.alpha = 0.8
        self.navigationItem.rightBarButtonItems?.last?.isEnabled = true
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        self.cryptTableView.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh(){
        crypCurrencyList.removeAll()
        Currencies.removeAll()
        getData()
        getCurrency()
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
    
    //get crypto function
    func getData(){
        var available_supply : String = ""
        var total_supply : String = ""
        var max_supply : String = ""
        var url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?limit=10")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if (error == nil && data != nil) {
                do{
                    let json : NSArray = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    for i in 0..<json.count {
                        let value : Dictionary = json.object(at: i) as! Dictionary<String,AnyObject>
                        var ret_value = self.nullToNil(value: value["available_supply"] as? AnyObject)
                        if ret_value == nil { available_supply = "0"}
                        else{ available_supply = value["available_supply"]! as! String}
                        ret_value = self.nullToNil(value: value["total_supply"] as? AnyObject)
                        if ret_value == nil { total_supply = "0"}
                        else{ total_supply = value["total_supply"]! as! String}
                        ret_value = self.nullToNil(value: value["max_supply"] as? AnyObject)
                        if ret_value == nil { max_supply = "0"}
                        else{ total_supply = value["max_supply"]! as! String}
                        
                        var cryptpInfo = CryptoCurrency(ID: value["id"]! as! String, Name: value["name"]! as! String, Symbol: value["symbol"]! as! String, Rank: value["rank"]! as! String, Price_USD : value["price_usd"]! as! String, Price_BTC: value["price_btc"]! as! String, Volume_USD: value["24h_volume_usd"]! as! String, Market_cap: value["market_cap_usd"]! as! String, Available_Supply: available_supply, Total_Supply: total_supply, Max_Supply : max_supply, Percent_1h: value["percent_change_1h"]! as! String, Percent_24h: value["percent_change_24h"]! as! String, Percent_7d: value["percent_change_7d"]! as! String, LastUpdated: value["last_updated"]! as! String)
                        self.crypCurrencyList.append(cryptpInfo)
                    }
                    DispatchQueue.main.async {
                        self.cryptTableView.reloadData()
                    }
                }
                catch{
                    print(error)
                }
            }
            else{
                print(error)
            }
        }
        task.resume()
    }
    
    //get regular currency function
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
                                self.cryptTableView.reloadData()
                                print("JSON downloaded")
                              //  print(currList)
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
    func nullToNil(value : AnyObject?) -> AnyObject?{
        if value is NSNull {
            return nil
        }
        else{
            return value
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredCrypt.count
        }
        else if (isShowCrypto && !isShowCurrency) {
            return crypCurrencyList.count
        }
        else if (isShowCurrency && !isShowCrypto){
            return Currencies.count
        }
            return (crypCurrencyList.count + Currencies.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let prototypeCell = cryptTableView
        if (isShowCrypto && indexPath.row < crypCurrencyList.count)
        {
            let cell = tableView .dequeueReusableCell(withIdentifier: "cryptCell", for: indexPath)
            let currLbl = cell.contentView.viewWithTag(1) as! UILabel
            let priceLbl = cell.contentView.viewWithTag(2) as! UILabel
        
            if isSearching {
                currLbl.text = filteredCrypt[indexPath.row].symbol           //from filtered list
                priceLbl.text = filteredCrypt[indexPath.row].price_usd       //from filtered list
            } else {
                currLbl.text = crypCurrencyList[indexPath.row].symbol         //raw data
                priceLbl.text = crypCurrencyList[indexPath.row].price_usd     //raw data
            }
            return cell
        }
        else
        {
            let cell1 = tableView .dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)

            let firstlbl = cell1.contentView.viewWithTag(5) as! UILabel
            let currencyLbl = cell1.contentView.viewWithTag(6) as! UILabel
            let priceLabel = cell1.contentView.viewWithTag(7) as! UILabel

            firstlbl.text = String(Currencies[indexPath.row].symbol.characters.prefix(3))
            currencyLbl.text = String(Currencies[indexPath.row].symbol.characters.suffix(3))
            priceLabel.text = String(Currencies[indexPath.row].price)
            return cell1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //      selectedCryptCell = cryptArrFin[indexPath.row]
        if (indexPath.row < crypCurrencyList.count)
        {
            MainView.isCryptoSelect = true;
            MainView.isCurrencySelect = false;
            selectedCryptCell = crypCurrencyList[indexPath.row]
        }
        else
        {
            MainView.isCurrencySelect = true;
            MainView.isCryptoSelect = false;
            selectedCurrency = Currencies[indexPath.row]
        }
        self.performSegue(withIdentifier: "MainToDetail", sender: self)
    }
    
    @IBAction func NotificationSetting(_ sender: Any) {
        performSegue(withIdentifier: "MainToAcc", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToDetail" {
            let dvc = segue.destination as! DetailView
            dvc.cryptCurrency = selectedCryptCell
            dvc.regCurrency = selectedCurrency
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            //tableView.reloadData()
        } else {
            filteredCrypt = crypCurrencyList.filter({$0.symbol == searchBar.text!})
            //tableView.reloadData()
        }
    }
}
