//
//  Cell3.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/06/06.
//  Copyright © 2021 Kaede. All rights reserved.
//

import UIKit

class Cell3: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var roundLabel: UILabel!
    
    
    @IBOutlet weak var checkLabel: UILabel!
    
    var sW : CGFloat = 400 // スクリーン横幅
    var sH : CGFloat = 60 // セル縦幅
    var cellY : CGFloat = 44 // セルのy座標
    
    func initialset(sW : CGFloat, sH : CGFloat) {
        numberLabel.frame = CGRect(x:sW * 40/414, y:sH * 12/60,
            width:sW * 50/414, height:sH * 36/80)

        commentLabel.frame = CGRect(x:sW * 128/414, y:sH * 12/60,
            width:sW * 100/414, height:sH * 36/80)

        roundLabel.frame = CGRect(x:sW * 269/414, y:sH * 12/60,
            width:sW * 30/414, height:sH * 36/80)
        
        checkLabel.frame = CGRect(x:sW * 251/414, y:sH * 12/60,
            width:sW * 30/414, height:sH * 36/80)
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//    }

}
