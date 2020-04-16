//
//  SummaryModel.swift
//  Covid19
//
//  Created by Peter Emel on 4/1/20.
//  Copyright © 2020 Peter Emel. All rights reserved.
//

import Foundation
import UIKit

class SummaryModel {
    var countryName : String = ""
    var flagURL : String = ""
    var flagImage : UIImage?
    var newConfirmed : Int = 0
    var totalConfirmed : Int = 0
    var newDeaths : Int = 0
    var totalDeaths : Int = 0
    var totalRecovered : Int = 0
    var active : Int = 0
    var critical : Int = 0

    init(countryName:String, flagURL:String, flagImage:UIImage, newConfirmed:Int, totalConfirmed:Int, newDeaths:Int, totalDeaths:Int, totalRecovered:Int, active:Int, critical:Int) {
        self.countryName = countryName
        self.flagURL = flagURL
        self.flagImage = flagImage
        self.newConfirmed = newConfirmed
        self.totalConfirmed = totalConfirmed
        self.newDeaths = newDeaths
        self.totalDeaths = totalDeaths
        self.totalRecovered = totalRecovered
        self.active = active
        self.critical = critical
    }
}
