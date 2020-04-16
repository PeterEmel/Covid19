//
//  SummaryCell.swift
//  Covid19
//
//  Created by Peter Emel on 4/1/20.
//  Copyright © 2020 Peter Emel. All rights reserved.
//

import UIKit

class SummaryCell: UITableViewCell {
    private var countryData : SummaryModel!

    //Outlets
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var newConfirmedLbl: UILabel!
    @IBOutlet weak var totalConfirmedLbl: UILabel!
    @IBOutlet weak var newDeathsLbl: UILabel!
    @IBOutlet weak var totalDeathsLbl: UILabel!
    @IBOutlet weak var totalRecoveredLbl: UILabel!
    @IBOutlet weak var activeLbl: UILabel!
    @IBOutlet weak var criticalLbl: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    
    
    func configureCell(countryData:SummaryModel, index: Int) {
        self.countryData = countryData

        countryLbl.text = countryData.countryName
        newConfirmedLbl.text = String(countryData.newConfirmed)
        totalConfirmedLbl.text = String(countryData.totalConfirmed)
        newDeathsLbl.text = String(countryData.newDeaths)
        totalDeathsLbl.text = String(countryData.totalDeaths)
        totalRecoveredLbl.text = String(countryData.totalRecovered)
        activeLbl.text = String(countryData.active)
        criticalLbl.text = String(countryData.critical)
        flagImageView.image = countryData.flagImage
        
      
    }
}
