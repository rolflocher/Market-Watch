//
//  ViewController.swift
//  AppleTVTest
//
//  Created by Rolf Locher on 12/8/18.
//  Copyright © 2018 Rolf Locher. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    
    @IBOutlet weak var lineChart: LineChart!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    
    
    @IBAction func volumeButton(_ sender: Any) {
        self.getTopVolume()
    }
    @IBAction func changeButton(_ sender: Any) {
        self.getTopChange()
    }
    @IBAction func depthButton(_ sender: Any) {
        self.getTopDepth()
    }
    @IBAction func offsetButton(_ sender: Any) {
        self.getTopOffset()
    }
    
    //Control Vars
    var currentBaseAsset : String = ""
    var currentQuoteAsset : String = ""
    
    
    // Control Booleans
    var topPrice = false
    var topChange = false
    var hasNoPair = false
    var cell0done = false
    var cell1done = false
    var cell2done = false
    var cell3done = false
    
    
    // Global Images
    var symbolImage1 : UIImage? = nil //UIImage(named: "default1")
    var symbolImage2 : UIImage? = nil //UIImage(named: "default1")
    
    
    // Global Data Arrays
    var tableDataDicArray = [[String:Any]]()
    var chartDataPointDicArray = [String : [PointEntry]]()
    var pairsAndBasesDicDic = [String : [String : Any]]() // pairAndBasesDicArray["BTC"]["quoteAsset"]
    var urlForSymbolDic = [String:String]()
    

    // CollectionView Labels
    var basePrice : String = ""
    var baseVolume : String = ""
    var baseChange : String = ""
    var baseMarketCap : String = ""
    var quotePrice : String = ""
    var quoteVolume : String = ""
    var quoteChange : String = ""
    var quoteMarketCap : String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.getTopVolume()
        self.exchangeInfoPing()
        self.getSymbolImageURLs()
        
        tableView.dataSource=self
        tableView.delegate=self
        collectionView.dataSource=self
        collectionView.delegate=self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 54, left: 40, bottom: 10, right: 29)
        
        layout.itemSize = CGSize(width: 300, height: 300)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipe(gesture:)))
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipe(gesture:)))
        swipeRightRecognizer.direction = .right
        lineChart.addGestureRecognizer(swipeRightRecognizer)
        swipeLeftRecognizer.direction = .left
        //swipeLeftRecognizer.isEnabled = true
        lineChart.addGestureRecognizer(swipeLeftRecognizer)
        respondToSwipe(gesture: swipeRightRecognizer)
        respondToSwipe(gesture: swipeLeftRecognizer)
        lineChart.isUserInteractionEnabled = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @objc func respondToSwipe (gesture: UISwipeGestureRecognizer) -> Void{
        
        
        print("swipe tried to do something")
        if lineChart.customSC.selectedSegmentIndex == 0 {
            lineChart.customSC.selectedSegmentIndex = 1
        }
        else {
            lineChart.customSC.selectedSegmentIndex = 0
        }
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        switch ( indexPath.row ) {
        case 0:
            cell.symbolImage.image = symbolImage1
            cell.label0.text = ""
            cell.label1.text = ""
            cell.label2.text = ""
            cell.label3.text = ""
        case 1:
            cell.symbolImage.image = nil //UIImage(named: "default1")
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.label0.text = self.basePrice
            cell.label1.text = self.baseChange
            cell.label2.text = self.baseVolume
            cell.label3.text = self.baseMarketCap
        case 2:
            cell.symbolImage.image = symbolImage2
            cell.label0.text = ""
            cell.label1.text = ""
            cell.label2.text = ""
            cell.label3.text = ""
        default:
            cell.symbolImage.image = nil //UIImage(named: "default1")
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.label0.text = self.quotePrice
            cell.label1.text = self.quoteChange
            cell.label2.text = self.quoteVolume
            cell.label3.text = self.quoteMarketCap
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell = collectionView.cellForItem(at: indexPath)
//        cell?.layer.borderColor = UIColor.gray.cgColor
//        cell?.layer.borderWidth = 2
        if( indexPath == [0,0]) {
            if currentBaseAsset != "" {
                updatePriceListCryptoCompare(symbol: currentBaseAsset)
                print(currentBaseAsset)
            }
//            let vc: UIViewController = storyboard!.instantiateViewController(withIdentifier: "Cloudview") as UIViewController
//            self.present(vc, animated: true, completion: nil)
        }
        if( indexPath == [0,1]) {
//            let vc: UIViewController = storyboard!.instantiateViewController(withIdentifier: "Colorview") as UIViewController
//            self.present(vc, animated: true, completion: nil)
        }
        if( indexPath == [0,2]) {
            if currentQuoteAsset != "" {
                updatePriceListCryptoCompare(symbol: currentQuoteAsset)
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.layer.borderColor = UIColor.lightGray.cgColor
//        cell?.layer.borderWidth = 0.0
//    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("test33")
        //lineChart.customSC.selectedSegmentIndex = 1
        return 19
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //print("test22")
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        updatePriceLists(symbol: tableDataDicArray[indexPath.row]["name"] as! String)
        getSymbolImage(pair : tableDataDicArray[indexPath.row]["name"] as! String)
        getPairInfo(pair: tableDataDicArray[indexPath.row]["name"] as! String)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyTableViewCell
        
        if self.tableDataDicArray.count > 0 {
            cell.symbolLabel?.text = self.tableDataDicArray[indexPath.row]["name"] as? String
            cell.priceLabel?.text = self.tableDataDicArray[indexPath.row]["value"] as? String
        }
        
        return cell
        
    }
    
    
    func getTopVolume(){
        let url = URL(string: "https://api.binance.com/api/v1/ticker/24hr")!
        let request = URLRequest(url:url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            do{
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    print("fail")
                    return
                }
                
                struct Coin {
                    let name: String
                    let change: Double
                }
                var coins = [Coin]()
                
                for x in 0..<jsonArray.count {
                    
                    coins.append(Coin(name:jsonArray[x]["symbol"] as! String, change:Double(jsonArray[x]["volume"] as! String)!))
                    
                }
                self.tableDataDicArray = []
                if self.topChange {
                    let newArr = coins.sorted { $0.change < $1.change }
                    self.topChange = !self.topChange
                    for x in 0..<20 {
                        let item : [String:Any] = ["name": newArr[x].name, "value" :  String(format:"%f",newArr[x].change)]
                        self.tableDataDicArray.append(item)
                    }
                }
                else {
                    let newArr = coins.sorted { $0.change > $1.change }
                    self.topChange = !self.topChange
                    for x in 0..<20 {
                        let item : [String:Any] = ["name": newArr[x].name, "value" :  String(format:"%f",newArr[x].change)]
                        self.tableDataDicArray.append(item)
                    }
                }
                
                self.hasNoPair = false
                DispatchQueue.main.async (execute: { () -> Void in
                    self.tableView?.reloadData()
                })
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        })
        task.resume()
    }
    
    func getTopDepth(){
        
        let url = URL(string: "https://api.binance.com/api/v1/ticker/24hr")!
        let request = URLRequest(url:url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            do{
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    print("fail")
                    return
                }
                
                struct Coin {
                    let name: String
                    let change: Double
                }
                var coins = [Coin]()
                
                for x in 0..<jsonArray.count {
                    let temp = Double(jsonArray[x]["askPrice"] as! String)
                    let temp1 = Double(jsonArray[x]["bidPrice"] as! String)
                    let temp3 = (temp! - temp1!) / temp1!
                    
                    coins.append(Coin(name:jsonArray[x]["symbol"] as! String, change:temp3))
                    
                }
                self.tableDataDicArray = []
                if self.topChange {
                    let newArr = coins.sorted { $0.change < $1.change }
                    self.topChange = !self.topChange
                    for x in 0..<20 {
                        let item : [String:Any] = ["name": newArr[x].name, "value" :  String(format:"%f",newArr[x].change)]
                        self.tableDataDicArray.append(item)
                    }
                }
                else {
                    let newArr = coins.sorted { $0.change > $1.change }
                    self.topChange = !self.topChange
                    for x in 0..<20 {
                        let item : [String:Any] = ["name": newArr[x].name, "value" :  String(format:"%f",newArr[x].change)]
                        self.tableDataDicArray.append(item)
                    }
                }
                
                self.hasNoPair = false
                DispatchQueue.main.async (execute: { () -> Void in
                    self.tableView?.reloadData()
                })
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        })
        task.resume()
        
    }
    
    
    
    func updatePriceLists(symbol : String){
        print(symbol)
        let url = URL(string: "https://api.binance.com/api/v1/klines?symbol=" + symbol + "&interval=3m")!
        let request = URLRequest(url:url)
        //request.httpMethod = "POST"
        //let secretkey = "xMuYSDli8ZKctX9tF9BbI7qwbMt7bMU1iwgDF7kaiQe4xBzdHrN5CGLEbOxLzHhm"
        //let normalkey = "QCVwEfXdXcSsWVLfRvT5bYYdWaBnW8VCdECeT8dyCO9Omr6jPS2uYwFY2ulgFDFE"
        //request.setValue(secretkey, forHTTPHeaderField: "Authorization")
        
        //request.httpBody = yourPayload
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            do{
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                //print(jsonResponse)
                guard let jsonArray = jsonResponse as? [[Any]] else {
                    print("fail")
                    return
                }
                
                var dataEntries : [PointEntry] = []
                
                let dateFormatter = DateFormatter()
//                dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
//                dateFormatter.locale = NSLocale.current
//                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
                
                for x in 0..<499 {
                    guard let stringC = jsonArray[x][3] as? String else {
                        return
                    }
                    
                    let date = Date(timeIntervalSince1970: (jsonArray[x][6] as! TimeInterval)/1000)
                    let strDate = dateFormatter.string(from: date)
                    
                    
                    dataEntries.append(PointEntry(value: Double(stringC)!, label: strDate))//strDate))
                }
                
                //self.chartDataPointDicArray[symbol] = dataEntries
                self.lineChart.dataEntries = dataEntries
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        })
        task.resume()
    }
    
    
    
    func updatePriceListCryptoCompare(symbol: String) {
        //let symbol2 = pairsAndBasesDicDic[pair]!["quoteAsset"] as! String
        
        let url = URL(string: "https://min-api.cryptocompare.com/data/histohour?fsym=\(symbol)&tsym=USD&limit=500")!
        print(url)
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                guard let jsonArray = jsonResponse as? [String: Any] else {
                    return
                }
                print(jsonArray)
                let format1 = jsonArray["Data"] as! [[String:Any]]
                //var format2 = format1[symbol1] as! [String:Any]
                //var format3 = format2["USD"] as! [String:Any]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd yyyy"
                var dataEntries : [PointEntry] = []
                for x in 0..<format1.count {
                    //let format2 = format1[x]["close"] //as! [String:Any]
                    let temp = format1[x]["time"] as! Double
                    print(temp)
                    let date = Date(timeIntervalSince1970: temp)
                    print(date)
                    let strDate = dateFormatter.string(from: date)
                    //let temp1 = String(format: "%f", date)
                    //print(format1[x]["time"])
                    
                    
                    dataEntries.append(PointEntry(value: (format1[x]["close"] as! Double), label: strDate))
                }
                self.lineChart.dataEntries = dataEntries
                
                
                
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    
    

    func getTopChange(){
        let url = URL(string: "https://api.binance.com/api/v1/ticker/24hr")!
        let request = URLRequest(url:url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            do{
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    print("fail")
                    return
                }
                
                struct Coin {
                    let name: String
                    let change: Double
                }
                var coins = [Coin]()
                
                for x in 0..<jsonArray.count {
                    
                    coins.append(Coin(name:jsonArray[x]["symbol"] as! String, change:Double(jsonArray[x]["priceChangePercent"] as! String)!))
                    
                }
                self.tableDataDicArray = []
                if self.topChange {
                    let newArr = coins.sorted { $0.change < $1.change }
                    self.topChange = !self.topChange
                    for x in 0..<20 {
                        let item : [String:Any] = ["name": newArr[x].name, "value" :  String(format:"%f",newArr[x].change)]
                        self.tableDataDicArray.append(item)
                    }
                }
                else {
                    let newArr = coins.sorted { $0.change > $1.change }
                    self.topChange = !self.topChange
                    for x in 0..<20 {
                        let item : [String:Any] = ["name": newArr[x].name, "value" :  String(format:"%f",newArr[x].change)]
                        self.tableDataDicArray.append(item)
                    }
                }
                
                self.hasNoPair = false
                DispatchQueue.main.async (execute: { () -> Void in
                    self.tableView?.reloadData()
                })
               
            } catch let parsingError {
                print("Error", parsingError)
            }
        })
        task.resume()
    }
    
    
    
    func getTopOffset(){
        let url = URL(string: "https://api.binance.com/api/v1/ticker/24hr")!
        let request = URLRequest(url:url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            do{
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    print("fail")
                    return
                }
                
                struct Coin {
                    let name: String
                    let change: Double
                }
                var coins = [Coin]()
                
                for x in 0..<jsonArray.count {
                    let temp = Double(jsonArray[x]["highPrice"] as! String)
                    let temp1 = Double(jsonArray[x]["lowPrice"] as! String)
                    let temp2 = Double(jsonArray[x]["lastPrice"] as! String)
                    let temp3 = (temp! - temp1!) / temp2!
                    
                    coins.append(Coin(name:jsonArray[x]["symbol"] as! String, change:temp3))
                    
                }
                self.tableDataDicArray = []
                if self.topChange {
                    let newArr = coins.sorted { $0.change < $1.change }
                    self.topChange = !self.topChange
                    for x in 0..<20 {
                        let item : [String:Any] = ["name": newArr[x].name, "value" :  String(format:"%f",newArr[x].change)]
                        self.tableDataDicArray.append(item)
                    }
                }
                else {
                    let newArr = coins.sorted { $0.change > $1.change }
                    self.topChange = !self.topChange
                    for x in 0..<20 {
                        let item : [String:Any] = ["name": newArr[x].name, "value" :  String(format:"%f",newArr[x].change)]
                        self.tableDataDicArray.append(item)
                    }
                }
                
                self.hasNoPair = false
                DispatchQueue.main.async (execute: { () -> Void in
                    self.tableView?.reloadData()
                })
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        })
        task.resume()
    }
    
    
    func getSymbolImageURLs() {
        
                let url = URL(string: "https://min-api.cryptocompare.com/data/all/coinlist")!
        
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        
                    guard let dataResponse = data,
                        error == nil else {
                            print(error?.localizedDescription ?? "Response Error")
                            return }
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with:
                            dataResponse, options: [])
        
                        guard let jsonArray = jsonResponse as? [String: Any] else {
                            return
                        }
                        let format1 = jsonArray["Data"] as! [String:Any]
                        for (key, _) in format1 {
                            let format2 = format1[key] as! [String:Any]
                            if let format3 = format2["ImageUrl"] as? String {
                                self.urlForSymbolDic[key] = format3
                            }
                            
                        }
                        
                    } catch let parsingError {
                        print("Error", parsingError)
                    }
                }
                task.resume()
    }
    
    
    
    func getSymbolImage(pair : String){
        
        self.cell0done = false
        self.cell2done = false
        
        let symbolurl1 = urlForSymbolDic[pairsAndBasesDicDic[pair]!["baseAsset"] as! String]
        
        //print(symbolurl1)
        
        if symbolurl1 != nil {
            let session = URLSession(configuration: .default)
            
            let PictureURL = URL(string: "https://www.cryptocompare.com" + symbolurl1!)!  //   /media/12318415/42.png")!
            
            let downloadPicTask = session.dataTask(with: PictureURL) { (data, response, error) in
                if let e = error {
                    print("Error downloading picture: \(e)")
                } else {
                    // No errors found.
                    // It would be weird if we didn't have a response, so check for that too.
                    if let res = response as? HTTPURLResponse {
                        print("Downloaded picture with response code \(res.statusCode)")
                        if let imageData = data {
                            // Finally convert that Data into an image and do what you wish with it.
                            self.symbolImage1 = UIImage(data: imageData)
    //                        DispatchQueue.main.async {
    //                            self.collectionView!.reloadData()
    //                        }
                            self.cell0done = true
                            self.checkForCollectionViewUpdate()
                
                            
                        } else {
                            print("Couldn't get image: Image is nil")
                        }
                        
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            
            downloadPicTask.resume()
        }
        else {
            self.symbolImage1 = UIImage(named: "default1")
            self.cell0done = true
            self.checkForCollectionViewUpdate()
        }
        
        let symbolurl2 = urlForSymbolDic[pairsAndBasesDicDic[pair]!["quoteAsset"] as! String]
        
        let session1 = URLSession(configuration: .default)
        
        let PictureURL1 = URL(string: "https://www.cryptocompare.com" + symbolurl2!)!  //   /media/12318415/42.png")!
        
        let downloadPicTask1 = session1.dataTask(with: PictureURL1) { (data, response, error) in
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        self.symbolImage2 = UIImage(data: imageData)
//                        DispatchQueue.main.async {
//                            self.collectionView!.reloadData()
//                        }
                        self.cell2done = true
                        self.checkForCollectionViewUpdate()
                        

                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                    
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask1.resume()
        
        
        
        
        
        
    }
    
    
    
    func exchangeInfoPing() {
                let url = URL(string: "https://api.binance.com/api/v1/exchangeInfo")!
        
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        
                    guard let dataResponse = data,
                        error == nil else {
                            print(error?.localizedDescription ?? "Response Error")
                            return }
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with:
                            dataResponse, options: [])
        
                        guard let jsonArray = jsonResponse as? [String: Any] else {
                            return
                        }
                        let format1 = jsonArray["symbols"] as! [[String:Any]]
                        self.tableDataDicArray = []
                        for x in 0..<format1.count {
                            let format2 = format1[x]["symbol"] as! String
                            let format3 = format1[x]["baseAsset"] as! String
                            let format4 = format1[x]["quoteAsset"] as! String
                            //let item : [String:Any] = ["mainAsset": format2, "baseAsset" :  format3]
                            self.pairsAndBasesDicDic[format2] = ["baseAsset" : format3, "quoteAsset" : format4]
                        }
                        self.hasNoPair = true
                        DispatchQueue.main.async (execute: { () -> Void in
                            self.tableView?.reloadData()
                        })
                    } catch let parsingError {
                        print("Error", parsingError)
                    }
                }
                task.resume()
    }
    
    
    func getPairInfo(pair : String) {
        
        self.cell1done = false
        self.cell3done = false
        
        let symbol1 = pairsAndBasesDicDic[pair]!["baseAsset"] as! String
        let symbol2 = pairsAndBasesDicDic[pair]!["quoteAsset"] as! String
        
        currentBaseAsset = symbol1
        currentQuoteAsset = symbol2
        
        let url = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=\(symbol1),\(symbol2)&tsyms=USD")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                guard let jsonArray = jsonResponse as? [String: Any] else {
                    return
                }
                //print(jsonArray)
                let format1 = jsonArray["RAW"] as! [String:Any]
                var format2 = format1[symbol1] as! [String:Any]
                var format3 = format2["USD"] as! [String:Any]
                
                if (format3["PRICE"] as! Double) > 1 {
                    self.basePrice = "Price: $" + String(format: "%0.2f", (format3["PRICE"] as! Double))
                }
                else {
                    self.basePrice = "Price: $" + String(format: "%f", (format3["PRICE"] as! Double))
                }
                
                self.baseVolume = "Volume: $" + self.formatPoints(from: (format3["VOLUME24HOURTO"] as! Double))
                self.baseChange = "Change: " + String(format: "%0.2f", (format3["CHANGEPCT24HOUR"] as! Double)) + "%"
                self.baseMarketCap = "MKT Cap: $" + self.formatPoints(from: (format3["MKTCAP"] as! Double))
                
                self.cell1done = true
                self.checkForCollectionViewUpdate()
                
                //print(symbol2)
                //print(format1)
                format2 = format1[symbol2] as! [String:Any]
                format3 = format2["USD"] as! [String:Any]
                
                if (format3["PRICE"] as! Double) > 1 {
                     self.quotePrice = "Price: $" + String(format: "%0.2f", (format3["PRICE"] as! Double))
                }
                else {
                     self.quotePrice = "Price: $" + String(format: "%f", (format3["PRICE"] as! Double))
                }
               
                self.quoteVolume = "Volume: $" + self.formatPoints(from: (format3["VOLUME24HOURTO"] as! Double))
                self.quoteChange = "Change: " + String(format: "%0.2f", (format3["CHANGEPCT24HOUR"] as! Double)) + "%"
                self.quoteMarketCap = "MKT Cap: $" + self.formatPoints(from: (format3["MKTCAP"] as! Double))
                
                self.cell3done = true
                self.checkForCollectionViewUpdate()
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    
    func checkForCollectionViewUpdate () {
        
        if ( cell0done && cell1done && cell2done && cell3done) {
            DispatchQueue.main.async (execute: { () -> Void in
                self.collectionView!.reloadData()
            })
        }
    }
    
    
    func formatPoints(from: Double) -> String {
        
        let thousand = from / 1000
        let million = from / 1000000
        let billion = from / 1000000000
        
        if billion >= 1.0 {
            return "\(round(billion*10)/10)B"
        } else if million >= 1.0 {
            return "\(round(million*10)/10)M"
        } else if thousand >= 1.0 {
            return ("\(round(thousand*10/10))K")
        } else {
            return "\(Int(from))"
        }
    }
    
    
}

