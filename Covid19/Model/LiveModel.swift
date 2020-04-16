//
//  LiveModel.swift
//  Covid19
//
//  Created by Peter Emel on 4/3/20.
//  Copyright © 2020 Peter Emel. All rights reserved.
//

import Foundation

class LiveModel {
    var cases : Int = 0
    var date : String = ""
    var time : String = ""
    
    init(cases:Int, date:String, time:String) {
        self.cases = cases
        self.date = date
        self.time = time
    }
}
