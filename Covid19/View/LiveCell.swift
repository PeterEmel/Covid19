//
//  LiveCell.swift
//  Covid19
//
//  Created by Peter Emel on 4/3/20.
//  Copyright © 2020 Peter Emel. All rights reserved.
//

import UIKit

class LiveCell: UITableViewCell {
    
    //Variables
    var object : LiveModel!
    
    //Outlets
    @IBOutlet weak var casesLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    

    func configureCell(object : LiveModel) {
        self.object = object
        
        casesLbl.text = String(object.cases)
        dateLbl.text = object.date
        timeLbl.text = object.time
        
    }
}
