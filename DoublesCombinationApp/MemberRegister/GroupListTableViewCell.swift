//
//  GroupListTableViewCell.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/12/02.
//  Copyright © 2021 Kaede. All rights reserved.
//

import UIKit

class GroupListTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    var delegate: GroupListDelegate! = nil
    var cellRow: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(text: String) {
        self.textField.text = text
        self.textField.borderStyle = .none // 枠線を非表示にする
        self.textField.returnKeyType = UIReturnKeyType.done // 改行→完了に表記変更
    }
    
    // セルの行数を保持(ViewControllerで設定)
    func setCellrow(cellRow: Int) {
        self.cellRow = cellRow
    }
    
    //-- キーボードを閉じる --
    // リターン(完了)をタップで閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("キーボードを閉じる（セルの処理）")
        // キーボードを閉じる
        self.textField.resignFirstResponder()
        self.textField.text = textField.text
        
        return true
    }
    
    // デリゲートメソッド(完了タップ)
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("セルの処理：textField.text! = \(textField.text!)")
        //テキストフィールドから受けた通知をデリゲート先に流す
        //ここでエラー
        self.delegate.textFieldDidEndEditing(cell: self, value:textField.text!)
    }
    
}

//デリゲート先に適用してもらうプロトコル
protocol GroupListDelegate {
    func textFieldDidEndEditing(cell:GroupListTableViewCell, value:String)
}
