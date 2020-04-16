//
//  SecondViewController.swift
//  Covid19
//
//  Created by Peter Emel on 4/1/20.
//  Copyright © 2020 Peter Emel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SearchTextField
import DropDown


class SummaryVC: UITableViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var dropView: UIView!

    
    //Variables
    var summaryArray = [SummaryModel]()
    static var countriesNames = [String]()
    let dropDown = DropDown()
    
    
    enum StorageType {
        case userDefaults
        case fileSystem
    }
    
    
    private func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    
    private func store(image: UIImage,
                       forKey key: String,
                       withStorageType storageType: StorageType) {
        if let pngRepresentation = image.pngData() {
            switch storageType {
            case .fileSystem:
                if let filePath = filePath(forKey: key) {
                    do  {
                        try pngRepresentation.write(to: filePath,
                                                    options: .atomic)
                    } catch let err {
                        print("Saving file resulted in error: ", err)
                    }
                }
            case .userDefaults:
                UserDefaults.standard.set(pngRepresentation,
                                          forKey: key)
            }
        }
    }
    
    
    private func retrieveImage(forKey key: String,
                               inStorageType storageType: StorageType) -> UIImage? {
        switch storageType {
        case .fileSystem:
            if let filePath = self.filePath(forKey: key),
                let fileData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: fileData) {
                return image
            }
        case .userDefaults:
            if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        }
        
        return nil
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        tableView.rowHeight = 240
        searchTextField.delegate = self
        
        dropDown.anchorView = dropView
        dropDown.dataSource = ["Today cases", "Total Cases", "Today Deaths", "Total Deaths"]
        dropItemSelected()
        
        SVProgressHUD.show(withStatus: "Loading...")
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.progessEnded), userInfo: nil, repeats: true)
        
        fetchSummaryData(url: SUMARRY)
        
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        
    }
    
    func fetchSummaryData(url: String) {
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                self.summaryData(data: data)
                print(self.summaryArray.count)
                
                let liveTab = self.tabBarController?.viewControllers?[1] as? LiveCountryVC
                liveTab?.summaryArrayClone = self.summaryArray

                self.tableView.reloadData()
                
                SummaryVC.countriesNames.removeAll()
                for countries in self.summaryArray {
                    SummaryVC.countriesNames.append(countries.countryName)
                }
                self.searchTextField.filterStrings(SummaryVC.countriesNames)
                self.progessEnded()
            }else{
                print("Error: \(String(describing: response.result.error))")
                let alert = UIAlertController(title: "Connection Error", message: "Please check your internet connection and try again.", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
                    SVProgressHUD.show(withStatus: "Loading...")
                    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.progessEnded), userInfo: nil, repeats: true)
                    
                    self.fetchSummaryData(url: SUMARRY)
                })
                let action2 = UIAlertAction(title: "OK", style: .default, handler: { (action2) in
                    
                })
                alert.addAction(action1)
                alert.addAction(action2)
                self.present(alert, animated: true)
            }
        }
    }
    
    func summaryData(data: Data) {
        let json = JSON(data)
        
        for (_, subjson) in json {
            let countryName = subjson["country"].stringValue
            let newConfirmed = subjson["todayCases"].intValue
            let totalConfirmed = subjson["cases"].intValue
            let newDeaths = subjson["todayDeaths"].intValue
            let totalDeaths = subjson["deaths"].intValue
            let totalRecovered = subjson["recovered"].intValue
            let activeCases = subjson["active"].intValue
            let criticalCases = subjson["critical"].intValue
            
            let flagURL = subjson["countryInfo"]["flag"].stringValue
            
            
            let newSummary = SummaryModel(countryName: countryName, flagURL:flagURL, flagImage: retrieveImage(forKey: countryName, inStorageType: StorageType.userDefaults)! , newConfirmed: newConfirmed, totalConfirmed: totalConfirmed, newDeaths: newDeaths, totalDeaths: totalDeaths, totalRecovered: totalRecovered, active: activeCases, critical: criticalCases)
           
            if countryName != "" || countryName != "0" {
                summaryArray.append(newSummary)
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summaryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath) as? SummaryCell {
            cell.configureCell(countryData: summaryArray[indexPath.row], index: indexPath.row)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Loading...")
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.progessEnded), userInfo: nil, repeats: true)
        
        for item in summaryArray {
            if item.countryName == searchTextField.text {
                summaryArray.removeAll()
                summaryArray.append(item)
                print(item.countryName)
                tableView.reloadData()
                searchTextField.text = ""
                resignFirstResponder()
                progessEnded()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBtnPressed(searchButton)
        return true
    }
    
    @objc func progessEnded() {
        SVProgressHUD.dismiss()
    }
    
    
    @IBAction func logoPressed(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Loading...")
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.progessEnded), userInfo: nil, repeats: true)
        
        self.summaryArray.removeAll()
        
        fetchSummaryData(url: SUMARRY)
        searchTextField.text = ""
        resignFirstResponder()
    }
    @IBAction func dropDownPressed(_ sender: UIButton) {
        dropDown.show()
    }
    
    func dropItemSelected() {
        dropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            switch index {
            case 0:
                self.summaryArray.sort(by: { $0.newConfirmed>$1.newConfirmed})
                self.tableView.reloadData()
            case 1:
                self.summaryArray.sort(by: { $0.totalConfirmed>$1.totalConfirmed })
                self.tableView.reloadData()
            case 2:
                self.summaryArray.sort(by: { $0.newDeaths>$1.newDeaths })
                self.tableView.reloadData()
            case 3:
                self.summaryArray.sort(by: { $0.totalDeaths>$1.totalDeaths })
                self.tableView.reloadData()
            default:
                print("Default")
            }
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        SVProgressHUD.show(withStatus: "Loading...")
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.progessEnded), userInfo: nil, repeats: true)
        
        self.summaryArray.removeAll()
        fetchSummaryData(url: SUMARRY)
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

