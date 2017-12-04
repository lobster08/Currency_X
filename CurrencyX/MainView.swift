//
//  MainView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/18/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
//  Create struct to store Dictionary JSON downloaded from API
struct currency : Codable
{
    var symbol : String
    var price : Float
    var bid : Float
    var ask : Float
    var timestamp : Int
    init(Symbol: String, Price: Float, Bid: Float, Ask: Float, Timestamp: Int)
    {
        symbol = Symbol
        price = Price
        bid = Bid
        ask = Ask
        timestamp = Timestamp
    }
    init(){
        symbol = ""
        price = 0.0
        bid = 0.0
        ask = 0.0
        timestamp = 0
    }
}

//  Class to store data Dictionary JSON downloaded from API
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

class MainView: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var cryptTableView: UITableView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTopConstraint: NSLayoutConstraint!
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    var isStartUp : Bool = true
    
    //  Variables using in searching
    var searchBar = UISearchBar()
    var isSearching = false
    var filteredCrypt = [CryptoCurrency]()  // Array to store matching searching keyword in crypCurrencyList
    var filteredCurr = [currency]()         // Array to store matching searching keyword in Currencies list
    
    //  Cryptocurrency variables
    var selectedCryptCell = CryptoCurrency()
    var crypCurrencyList = [CryptoCurrency]()
    var prevCrypCurrencyList = [CryptoCurrency]()
    
    //  Currencies variable
    var Currencies = [currency]()
    var selectedCurrency = currency()
    var prevCurrency = [currency]()
    
    //  variables to set background image
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    //  variables of Menu List or Filter List to check if each is activated
    var menuShowing = false
    var filterShowing = false
    
    //  Button variables
    var filterButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    var menuButton: UIBarButtonItem!
    
    //  variables to check which type of currency is chosen to display (Crypto/Currency/All)
    var isShowCrypto = true
    var isShowCurrency = true
    
    // sees if user clicks on crypto cell or regcurrency cell
    static var isCryptoSelect = false
    static var isCurrencySelect = false
    
    //  Create User Defaults
    var default_data : UserDefaults!

    var backgroundTaskIdentifier : UIBackgroundTaskIdentifier!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageName = "Background4.png"
        default_data = UserDefaults.init(suiteName: "Fetch Data API")
        //  Hide Menu List and Filter List
        menuView.isHidden = true
        filterView.isHidden = true
        
        //  Set background image and fetch data (crypto + currency) to display on Table View
        setBackgroundImage()
        getData()//get crypto data
        getCurrency()//get currency data
        
        cryptTableView.delegate = self
        cryptTableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        //  Create buttons (Menu + Search + Filter) on Navigation Bar
        createButtonsOnNavigationBar()
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)})
        
        //  Set up timer to fetch data (Crypto + Currency) and update on Table View every 90 seconds
        _ = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(MainView.refresh), userInfo: nil, repeats: true)
    }
    
    //  Function to refresh Table View to be displayed
    //  It will be called to fetch new data frop API and update on Table View
    @objc func refresh(){
        isStartUp = false
        crypCurrencyList.removeAll()
        Currencies.removeAll()
        getData()
        getCurrency()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func createButtonsOnNavigationBar(){
        //        menuButton = UIBarButtonItem(image: UIImage(named: "menuButton"), style: .done, target: self, action: #selector(openMenuOption))
        menuButton = resizeButton(image: "menuButton", function: "openMenuOption")
        self.navigationItem.leftBarButtonItem = menuButton
        
        //        searchButton = UIBarButtonItem(image: UIImage(named: "searchButton"), style: .done, target: self, action: #selector(searchItem))
        //        filterButton = UIBarButtonItem(image: UIImage(named: "filterButton"), style: .done, target: self, action: #selector(filterItems))
        searchButton = resizeButton(image: "searchButton", function: "searchItem")
        filterButton = resizeButton(image: "filterButton", function: "filterItems")
        self.navigationItem.rightBarButtonItems = [filterButton, searchButton]
        self.navigationItem.title = "Main View"
        
    }
    func resizeButton(image: String, function:String) -> UIBarButtonItem{
        let button = UIButton(type: .system)
        button.setImage(UIImage.init(named: image), for: UIControlState.normal)
        button.addTarget(self, action:Selector(function), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }
    @objc func searchItem(){
        isSearching = true
        self.navigationItem.setLeftBarButton(nil, animated: true)
        self.navigationItem.setRightBarButtonItems(nil, animated: true)
        //        searchController = UISearchController(searchResultsController: resultsController)
        //        searchController.searchResultsUpdater = self
        //        resultsController.tableView.delegate = self
        //        resultsController.tableView.dataSource = self
        //        self.searchController.dimsBackgroundDuringPresentation = true
        //        definesPresentationContext = true
        
        self.navigationItem.titleView = searchBar
        self.searchBar.isHidden = false
        self.searchBar.showsCancelButton = true
        self.searchBar.placeholder = "Enter your search here"
        //      cryptTableView.tableHeaderView = searchBar
        //      searchController.searchBar.showsCancelButton = true
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
    func setMenuBtnProperties(button: UIButton, image: String, title: String, function: String){
        button.setImage(UIImage(named:image), for: .normal)
        button.setTitle(title, for: .normal)
        button.tintColor = UIColor.black
        button.layer.borderWidth = 1.0
        button.backgroundColor = UIColor.init(red: 0.902, green: 0.902, blue: 0.980, alpha: 0.8)
        //    button.backgroundColor = UIColor.init(red: 0.529, green: 0.808, blue: 0.980, alpha: 0.8)
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: Selector(function), for: UIControlEvents.touchUpInside)
        self.menuView.addSubview(button)
    }
    //  The functions below will create buttons inside Menu Drop Down List
    //  Menu Drop Down List contains 3 options: Account Setting, Wallet, Logout
    func createAccountSettingBtn() {
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 0, width: 160, height: 40)
        button.imageEdgeInsets = UIEdgeInsets(top: 2,left: 0,bottom: 2,right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: 5,bottom: 2,right: 0)
        setMenuBtnProperties(button: button, image: "customerButton", title: "Account Setting", function: "accountSettingBtn")
    }
    @objc func accountSettingBtn(){
        performSegue(withIdentifier: "MainToAcc", sender: self)
    }
    
    func createWalletBtn(){
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 40, width: 160, height: 40)
        button.imageEdgeInsets = UIEdgeInsets(top: 2,left: -63,bottom: 2,right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: -58,bottom: 2,right: 0)
        setMenuBtnProperties(button: button, image: "wallet", title: "Wallet", function: "WalletBtn")
    }
    @objc func WalletBtn(){
        performSegue(withIdentifier: "MainToWallet", sender: self)
    }
    
    func createLogOutBtn() {
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 80, width: 160, height: 40)
        button.imageEdgeInsets = UIEdgeInsets(top: 2,left: -49,bottom: 2,right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: -44,bottom: 2,right: 0)
        setMenuBtnProperties(button: button, image: "exitButton", title: "Log out", function: "LogoutBtn")
    }
    @objc func LogoutBtn(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // Create Filter Option List
    func createFilterOptionList(){
        createShowCryptoFilterBtn()
        createShowCurrencyFilterBtn()
        createShowAllBtn()
    }
    func setFilterBtnProperties(button: UIButton, title: String, function: String){
        button.titleEdgeInsets = UIEdgeInsets(top: 2,left: 0,bottom: 2,right: 0)
        button.setTitle(title, for: .normal)
        button.tintColor = UIColor.black
        button.layer.borderWidth = 1.0
        button.backgroundColor = UIColor.init(red: 0.902, green: 0.902, blue: 0.980, alpha: 0.8)
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: Selector(function), for: UIControlEvents.touchUpInside)
        self.filterView.addSubview(button)
    }
    
    //  The functions below will create buttons inside Filter View Drop Down List
    //  Filter Drop Down List contains 3 options: Show Cryptocurrency, Show Currency, and Show All
    func createShowCryptoFilterBtn(){
        let button = UIButton(type: .system)
        button.frame =  CGRect(x: 0, y: 0, width: 160, height: 40)
        setFilterBtnProperties(button: button, title: "Show CryptoCurrency", function: "cryptoFilterBtn")
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
        setFilterBtnProperties(button: button, title: "Show Currency", function: "currencyFilterBtn")
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
        setFilterBtnProperties(button: button, title: "Show All", function: "allBtn")
    }
    @objc func allBtn(){
        isShowCrypto = true
        isShowCurrency = true
        self.refresh()
        endFilter()
    }
    
    //  Function to clear Filter View Drop Down List after User touch one of buttons
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
    
    /**********************************************************************************************/
    /*           These following functions are used to set Background Image of MainView           */
    /**********************************************************************************************/
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
    /**********************************************************************************************/
    /*              These following functions are used to fetch data from API webpage             */
    /**********************************************************************************************/
    
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
                        self.default_data?.setValue(Double(cryptpInfo.price_usd)!, forKey: cryptpInfo.symbol)
                        if (self.isStartUp){
                            self.prevCrypCurrencyList.append(cryptpInfo)
                        }
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
        let url = URL (string: "https://forex.1forge.com/1.0.2/quotes?pairs=USDJPY,USDCHF,USDCAD,USDSEK,USDNOK,USDMXN,USDZAR,USDCNH,USDEUR,USDGBP,USDAUD,USDNZD&api_key=hz3FMVzCV5cSCQmbvXRvoDuKIWk8f26B")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if (error == nil && data != nil){
                do {
                    //convert to json
                    let json : NSArray = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    for i in 0..<json.count{
                        let value : Dictionary = json.object(at: i) as! Dictionary<String,AnyObject>
                        var currencyInfo = currency(Symbol: value["symbol"] as! String, Price: value["price"] as! Float, Bid: value["bid"] as! Float, Ask: value["ask"] as! Float, Timestamp: value["timestamp"] as! Int)
                        self.Currencies.append(currencyInfo)
                        self.default_data?.setValue(Double(currencyInfo.price), forKey: currencyInfo.symbol)
                        if (self.isStartUp){
                            self.prevCurrency.append(currencyInfo)
                        }
                    }
                    DispatchQueue.main.async {
                        self.cryptTableView.reloadData()
                        print("JSON downloaded")
                    }
                }
                catch {
                    print("Can't pull JSON")
                }
            }
            else if let error = error {
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
    /**********************************************************************************************/
    /*              These following functions belong to Table View display and reload             */
    /**********************************************************************************************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            if (isShowCrypto && !isShowCurrency){
                return filteredCrypt.count
            }
            else if (isShowCurrency && !isShowCrypto){
                return filteredCurr.count
            }
            else{
                return filteredCrypt.count + filteredCurr.count
            }
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
        let defaultCell = UITableViewCell()
        if (isSearching && (filteredCrypt.count != 0 || filteredCurr.count != 0)){
            if (isShowCrypto && indexPath.row < filteredCrypt.count){
                let cell = cryptTableView.dequeueReusableCell(withIdentifier: "cryptCell", for: indexPath)
                let currLbl = cell.contentView.viewWithTag(1) as! UILabel
                let priceLbl = cell.contentView.viewWithTag(2) as! UILabel
                
                currLbl.text = filteredCrypt[indexPath.row].symbol         //raw data
                priceLbl.text = filteredCrypt[indexPath.row].price_usd     //raw data
                return cell
            }
            if (isShowCurrency && filteredCurr.count != 0){
                let cell = cryptTableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
                
                let firstlbl = cell.contentView.viewWithTag(5) as! UILabel
                let currencyLbl = cell.contentView.viewWithTag(6) as! UILabel
                let priceLabel = cell.contentView.viewWithTag(7) as! UILabel
                
                firstlbl.text = String(filteredCurr[indexPath.row].symbol.characters.prefix(3))
                currencyLbl.text = String(filteredCurr[indexPath.row].symbol.characters.suffix(3))
                priceLabel.text = String(filteredCurr[indexPath.row].price)
                return cell
            }
        }
        else{
            if (isShowCrypto && indexPath.row < crypCurrencyList.count)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cryptCell", for: indexPath)
                let currLbl = cell.contentView.viewWithTag(1) as! UILabel
                let priceLbl = cell.contentView.viewWithTag(2) as! UILabel
                let status = cell.contentView.viewWithTag(3) as! UIImageView
                let delta = cell.contentView.viewWithTag(4) as! UILabel
                
                if (!isStartUp){
                    let value = Double(crypCurrencyList[indexPath.row].price_usd)! - Double(prevCrypCurrencyList[indexPath.row].price_usd)!
                    if (value < 0){
                        status.image = UIImage(named: "down.png")
                    }
                    else if (value > 0){
                        status.image = UIImage(named: "up.png")
                    }
                    if (value != 0){
                        delta.text = String(format: "%.5f", abs(value))
                    }
                    prevCrypCurrencyList[indexPath.row] = crypCurrencyList[indexPath.row]
                }
                currLbl.text = crypCurrencyList[indexPath.row].symbol         //raw data
                priceLbl.text = crypCurrencyList[indexPath.row].price_usd     //raw data
                return cell
            }
            else if (indexPath.row <  Currencies.count)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
                
                let firstlbl = cell.contentView.viewWithTag(5) as! UILabel
                let currencyLbl = cell.contentView.viewWithTag(6) as! UILabel
                let priceLabel = cell.contentView.viewWithTag(7) as! UILabel
                let status = cell.contentView.viewWithTag(8) as! UIImageView
                let delta = cell.contentView.viewWithTag(9) as! UILabel
                
                if (!isStartUp){
                    let value = Double(Currencies[indexPath.row].price) - Double(prevCurrency[indexPath.row].price)
                    if (value < 0){
                        status.image = UIImage(named: "down.png")
                    }
                    else if (value > 0){
                        status.image = UIImage(named: "up.png")
                    }
                    if (value != 0){
                        delta.text = String(format: "%.5f", abs(value))
                    }
                    prevCurrency[indexPath.row] = Currencies[indexPath.row]
                }
                firstlbl.text = String(Currencies[indexPath.row].symbol.characters.prefix(3))
                currencyLbl.text = String(Currencies[indexPath.row].symbol.characters.suffix(3))
                priceLabel.text = String(Currencies[indexPath.row].price)
                return cell
            }
        }
        return defaultCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

       // self.performSegue(withIdentifier: "MainToNotification", sender: self)
    }
    
    @IBAction func NotificationSetting(_ sender: Any) {
        performSegue(withIdentifier: "MainToNotification", sender: self)
    }
    
    @IBAction func CurrencyNotification(_ sender: Any) {
        performSegue(withIdentifier: "MainToNotification", sender: self)
    }
    //  Function to perform Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToDetail" {
            let dvc = segue.destination as! DetailView
            dvc.cryptCurrency = selectedCryptCell
            dvc.regCurrency = selectedCurrency
        }
        else if segue.identifier == "MainToNotification" {
            let dvc = segue.destination as! Notification
            if (MainView.isCryptoSelect){
                MainView.isCryptoSelect = !MainView.isCryptoSelect
                dvc.symbol = selectedCryptCell.symbol
                dvc.currentPrice = Double(selectedCryptCell.price_usd)!
            }else if (MainView.isCurrencySelect){
                MainView.isCurrencySelect = !MainView.isCurrencySelect
                dvc.symbol = selectedCurrency.symbol
                dvc.currentPrice = Double(selectedCurrency.price)
            }
        }
    }
    /**********************************************************************************************/
    /*              These following functions belong to Searching Item in Table View              */
    /**********************************************************************************************/
    
    //  Function is called when User enters their search keywords in the text field of search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCurr.removeAll()
        filteredCrypt.removeAll()
        if (searchBar.text == ""){
            refresh()
        }
        if (isShowCrypto && searchText != ""){
            filteredCrypt = crypCurrencyList.filter({ (dict: CryptoCurrency) -> Bool in
                if (dict.name.contains(searchText) || dict.id.contains(searchText) ||
                    dict.symbol.contains(searchText)) {
                    return true
                }
                else{
                    return false
                }
            })
        }
        if (isShowCurrency && searchText != ""){
            let searchWord = searchText.uppercased()
            filteredCurr = Currencies.filter({ (dict: currency) -> Bool in
                if (dict.symbol.contains(searchWord)) {
                    return true
                }
                else{
                    return false
                }
            })
        }
        DispatchQueue.main.async {
            self.cryptTableView.reloadData()
        }
    }
    //  Function is called when User press button "x" to clear the text field of search bar
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.searchBar.text = ""
        refresh()
        return true
    }
    //  Function is called when User press button "Cancel" to stop searching item
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        self.searchBar.text = ""
        self.searchBar.isHidden = true
        self.navigationItem.titleView = nil
        createButtonsOnNavigationBar()
        refresh()
    }
    //  Function is called when User click button search icon on Navigation Bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        isSearching = false
        searchBar.endEditing(true)
        searchBar.showsCancelButton = true
    }
}

