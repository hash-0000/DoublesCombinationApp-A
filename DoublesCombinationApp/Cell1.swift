//
//  Cell1.swift
//  RandaomNumberPair_01
//
//  Created by Naoya on 2020/10/18.
//  Copyright © 2020 Kaede. All rights reserved.
//

import UIKit

class Cell1: UITableViewCell {


    @IBOutlet weak var cellLabel1: UILabel!
    
    @IBOutlet weak var cellLabel2: UILabel!
    
    @IBOutlet weak var cellLabelVS: UILabel!
    
    @IBOutlet weak var cellLabel3: UILabel!
    
    @IBOutlet weak var cellLabel4: UILabel!
    
    @IBOutlet weak var cellLabelRound: UILabel!
    
    @IBOutlet weak var cellLabelCheck: UILabel!
    
    @IBOutlet weak var cellLabelLine: UILabel!
    
    @IBOutlet weak var tableViewLine: UILabel!
    
    
    
    var sW : CGFloat = 414 // スクリーン横幅
    var sH : CGFloat = 896 // スクリーン縦幅
    var cellY : CGFloat = 44 // セルのy座標
    
    func initialset(sW : CGFloat, sH : CGFloat) {
        cellLabel1.frame = CGRect(x:sW * 55/414, y:sH * 13/80,
            width:sW * 50/414, height:sH * 60/80)
        
        cellLabel2.frame = CGRect(x:sW * 105/414, y:sH * 13/80,
            width:sW * 50/414, height:sH * 60/80)
        
        cellLabelVS.frame = CGRect(x:sW * 155/414, y:sH * 13/80,
            width:sW * 50/414, height:sH * 60/80)
        
        cellLabel3.frame = CGRect(x:sW * 215/414, y:sH * 13/80,
            width:sW * 50/414, height:sH * 60/80)
        
        cellLabel4.frame = CGRect(x:sW * 260/414, y:sH * 13/80,
            width:sW * 50/414, height:sH * 60/80)
        
//        cellLabel1.frame = CGRect(x:sW * 20/414, y:sH * 10/80,
//            width:sW * 60/414, height:sH * 60/80)
//
//        cellLabel2.frame = CGRect(x:sW * 80/414, y:sH * 10/80,
//            width:sW * 50/414, height:sH * 60/80)
//
//        cellLabelVS.frame = CGRect(x:sW * 140/414, y:sH * 10/80,
//            width:sW * 40/414, height:sH * 60/80)
//
//        cellLabel3.frame = CGRect(x:sW * 180/414, y:sH * 10/80,
//            width:sW * 60/414, height:sH * 60/80)
//
//        cellLabel4.frame = CGRect(x:sW * 240/414, y:sH * 10/80,
//            width:sW * 50/414, height:sH * 60/80)
        
        
        //cellLabelRound.frame = CGRect(x:sW * 336/414, y:sH * 10/80,
            //width:sW * 50/414, height:sH * 60/80)
        
//        cellLabelCheck.frame = CGRect(x:sW * 359/414, y:sH * 1/80,
//            width:sW * 40/414, height:sH * 60/80)
        //cellLabelCheck.frame = CGRect(x:sW * 350/414, y:sH * 10/80,
            //width:sW * 50/414, height:sH * 60/80)

    }

}
