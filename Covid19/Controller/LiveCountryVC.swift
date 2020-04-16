//
//  LiveCountryVC.swift
//  Covid19
//
//  Created by Peter Emel on 4/3/20.
//  Copyright © 2020 Peter Emel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SearchTextField

class LiveCountryVC: UITableViewController {
    
    //Outlets
    @IBOutlet weak var searchField: SearchTextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var countaryName: UILabel!
    @IBOutlet weak var countryFlag: UIImageView!
    
    
    //Variables
    var liveArray = [LiveModel]()
    var URL_LIVE = ""
    var summaryArrayClone = [SummaryModel]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = UIColor.clear
        countaryName.isHidden = true
        tableView.rowHeight = 105
        
        searchField.filterStrings(SummaryVC.countriesNames)

    }

    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        print("search button pressed")
        print(summaryArrayClone[1].countryName)
        self.tableView.separatorColor = UIColor.lightGray

        for country in summaryArrayClone {
            if searchField.text == country.countryName {
                countaryName.text = country.countryName
                countaryName.isHidden = false
                countryFlag.image = country.flagImage
                
                URL_LIVE = "https://api.covid19api.com/live/country/\(country.countryName)/status/confirmed"
                
                SVProgressHUD.show(withStatus: "Loading...")
                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.progessEnded), userInfo: nil, repeats: true)
                fetchLiveData(url: URL_LIVE)
            }
        }
        
    }
    
    
    func fetchLiveData(url: String) {
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                self.liveJsonData(data: data)
                print(self.liveArray.count)
                self.liveArray.reverse()
                self.tableView.reloadData()
                
                self.progessEnded()
            }else{
                print("Error: \(String(describing: response.result.error))")
                let alert = UIAlertController(title: "Connection Error", message: "Please check your internet connection and try again.", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
                    SVProgressHUD.show(withStatus: "Loading...")
                    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.progessEnded), userInfo: nil, repeats: true)
                    
                    self.fetchLiveData(url: self.URL_LIVE)
                })
                let action2 = UIAlertAction(title: "OK", style: .default, handler: { (action2) in
                    
                })
                alert.addAction(action1)
                alert.addAction(action2)
                self.present(alert, animated: true)
            }
        }
    }
    
    func liveJsonData(data: Data) {
        let json = JSON(data)
        
        for (_, subjson) in json {
            let cases = subjson["Cases"].intValue
            let dateTime = subjson["Date"].stringValue
            
            
            let newLiveData = LiveModel(cases: cases, date: dateParsing(date: dateTime)[0], time: dateParsing(date: dateTime)[1])
            
            liveArray.append(newLiveData)
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liveArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "liveCell", for: indexPath) as? LiveCell {
            
            cell.configureCell(object: liveArray[indexPath.row])
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    @objc func progessEnded() {
        SVProgressHUD.dismiss()
    }
    
    func dateParsing(date: String) -> [String] {
        // 2020-04-03T16:55:37Z
        
        let scanner = Scanner(string: date)
        
        let t = CharacterSet(charactersIn: "T")
        let z = CharacterSet(charactersIn: "Z")
        
        var dateMod, timeMod : NSString?
        
        
        scanner.scanUpToCharacters(from: t, into: &dateMod)
        let dateModified = dateMod! as String
        scanner.scanUpToCharacters(from: z, into: &timeMod)
        var timeModified = timeMod! as String
        timeModified.remove(at: timeModified.startIndex)

        print("Date: \(dateMod)")
        print("Time: \(timeMod)")
        
        let dateTimeArray = [dateModified, timeModified]
        
        return dateTimeArray
    }
}
