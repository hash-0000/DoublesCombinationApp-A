//
//  Cell2.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/01/17.
//  Copyright © 2021 Kaede. All rights reserved.
//

import UIKit

class Cell2: UITableViewCell {

    @IBOutlet weak var CellLabelNo: UILabel!
    
    @IBOutlet weak var CellLabelTotal: UILabel!
    
    @IBOutlet weak var cellLabelCheckCount: UILabel!
    
    @IBOutlet weak var CellLabelCorrectionValue: UILabel!
    
    
    var sW : CGFloat = 400 // スクリーン横幅
    var sH : CGFloat = 60 // セル縦幅
    var cellY : CGFloat = 44 // セルのy座標
    
    func initialset(sW : CGFloat, sH : CGFloat) {
        CellLabelNo.frame = CGRect(x:sW * 40/414, y:sH * 10/60,
            width:sW * 49/414, height:sH * 40/80)

        CellLabelTotal.frame = CGRect(x:sW * 151/414, y:sH * 10/60,
            width:sW * 49/414, height:sH * 40/80)

        cellLabelCheckCount.frame = CGRect(x:sW * 281/414, y:sH * 10/60,
            width:sW * 49/414, height:sH * 40/80)
        
        CellLabelCorrectionValue.frame = CGRect(x:sW * 210/414, y:sH * 10/60,
            width:sW * 70/414, height:sH * 40/80)
        
        
//        CellLabelNo.frame = CGRect(x:sW * 43/414, y:sH * 10/60,
//            width:sW * 49/414, height:sH * 40/80)
//
//        CellLabelTotal.frame = CGRect(x:sW * 161/414, y:sH * 10/60,
//            width:sW * 49/414, height:sH * 40/80)
//
//        cellLabelCheckCount.frame = CGRect(x:sW * 291/414, y:sH * 10/60,
//            width:sW * 49/414, height:sH * 40/80)
//
//        CellLabelCorrectionValue.frame = CGRect(x:sW * 220/414, y:sH * 10/60,
//            width:sW * 55/414, height:sH * 40/80)
        
    }
    
    
    

}
