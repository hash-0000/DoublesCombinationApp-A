//
//  ItemCell.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/12/02.
//  Copyright © 2021 Kaede. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var delegate: ItemDelegate! = nil
    var cellRow: Int = 0
    var checkFlg: Bool = false
    
    //var mainColor: UIColor = UIColor(red: 102/255, green: 179/255, blue: 255/255, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // 初期設定(ViewControllerで呼ぶ)
    func setCell(text: String) {
        self.textField.text = text
        self.textField.borderStyle = .none // 枠線を非表示にする
        self.textField.returnKeyType = UIReturnKeyType.done // 改行→完了に表記変更
        
        
        // チェック有無でテキストに属性付加
        attributeText()
    }
    
    // チェック有無でテキストに属性付加
    func attributeText() {
        // 取り消し線共通設定
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: textField.text!)
        
        // チェックマーク有無を判定
        if checkFlg == true {
            // チェックマーク付きの場合、取り消し線を付加
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1.5, range: NSMakeRange(0, attributeString.length))
            
            // 文字色グレー
            textField.textColor = UIColor.systemGray
            
            // チェックマーク設定
            checkButton.setTitleColor(mainColor, for: .normal) // ◯色付け
            checkLabel.text = "✓" // チェックマーク付加
            self.checkLabel.textColor = mainColor // チェックマーク色付け
            
        } else {
            // チェックマーク付きの場合、取り消し線を削除
            attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
            
            // 文字色ブラック
            textField.textColor = .black
            
            // チェックマーク設定
            checkButton.setTitleColor(.systemGray, for: .normal) // 色付けデフォルト
            checkLabel.text = "" // チェックマーク削除
            checkLabel.textColor = .white // チェックマーク白色
        }
        // textFieldに反映
        textField.attributedText = attributeString
    }
    
    // セルの行数を保持(ViewControllerで設定)
    func setCellrow(cellRow: Int) {
        self.cellRow = cellRow
    }
    
    //-- キーボードを閉じる --
    // リターン(完了)をタップで閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print("完了タップ！（セルの処理）")
        // キーボードを閉じる
        self.textField.resignFirstResponder()
        self.textField.text = textField.text
        return true
    }
    
    // デリゲートメソッド(完了タップ)
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("セルの処理：textField.text! = \(textField.text!)")
        //テキストフィールドから受けた通知をデリゲート先に流す
        self.delegate.textFieldDidEndEditing(cell: self, value:textField.text!)
    }
    
    // デリゲートメソッド(チェックマークタップ)
    func cellTappedMarking(checkFlg: Bool) {
        //print("セルのチェックマークがタップされたデリゲート処理")
        self.delegate.cellTappedMarking(cell: self, checkFlg: checkFlg)
    }
    
    
    @IBAction func checkButton(_ sender: Any) {
        //print("チェックボタンがタップされた！")
        if checkFlg == false {
            // false状態でタップされた場合
            // フラグを反転してチェックマークを入れる
            checkFlg = true
            checkButton.setTitleColor(mainColor, for: .normal) // ◯色付け
            //checkButton.setTitle("●", for: .normal)
            //checkButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
            
            checkLabel.text = "✓" // チェックマーク付加
            self.checkLabel.textColor = mainColor // チェックマーク色付け
            //print("checkFlg = \(checkFlg)")
        } else {
            // true状態でタップされた場合
            // フラグを反転してチェックマークを外す
            checkFlg = false
            checkButton.setTitleColor(.systemGray, for: .normal) // 色付けデフォルト
            //checkButton.setTitle("◯", for: .normal)
            //checkButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
            
            checkLabel.text = "" // チェックマーク削除
            self.checkLabel.textColor = .white // チェックマーク白色
            //print("checkFlg = \(checkFlg)")
        }
        
        // チェック有無でテキストに属性付加
        attributeText()
        
        //print("セルがタップされた（セルの処理）")
        // デリゲート
        self.delegate.cellTappedMarking(cell: self, checkFlg: checkFlg)
    }
    
}

//デリゲート先に適用してもらうプロトコル
protocol ItemDelegate {
    func textFieldDidEndEditing(cell:ItemCell, value:String)
    func cellTappedMarking(cell:ItemCell, checkFlg: Bool)
}
