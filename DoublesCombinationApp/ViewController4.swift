//
//  ViewController4.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/06/06.
//  Copyright © 2021 Kaede. All rights reserved.
//

import UIKit
import GoogleMobileAds


// ※設計方針
// ①finalMasterArray[]はVC4で更新、masterArray[]はVC2で更新
// ②VC2→VC4遷移時、masterArray[]→finalMasterArray[]に値を渡す
// 　このとき、finalMasterArray[]のメンバ増減情報を反映して正しい選出回数を格納
// ②VC4→VC2遷移時、finalMasterArray[]→masterArray[]に値を渡す
// 　このとき、finalMasterArray[]のメンバ増減情報を反映して補正後の選出回数を格納（乱数計算用）
var finalMasterArray: [[Int]] = []  // メンバー増減を加味したマスター配列を宣言
                                    // ([番号, 選出回数,
                                    // 追加削除フラグ:0=追加削除なし/1=追加/9=削除,
                                    // 追加時のMasterArrayの最低選出回数:0 or 回数])


class ViewController4: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate {
    
    // AdMobバナー
    var bannerView: GADBannerView!
    
    @IBOutlet weak var tableView3: UITableView!
    
    @IBOutlet weak var settingButton: UIButton! // 設定反映ボタン
    
    @IBOutlet weak var addNumbersText: UITextField! // 追加人数入力テキスト
    
    
    @IBOutlet weak var interFrame: UIView!
    
    @IBOutlet weak var interFrame2: UIView!
    
    @IBOutlet weak var interFrame3: UIView!
    
    
    var alertController: UIAlertController!    // アラート表示
    var pickerView: UIPickerView = UIPickerView()   // PickerView表示
    
    // 画面遷移で引数受付
    var masterArray : [[Int]] = []
    //var argNum: String =  "4"      // 参加人数 = currentMembers
    var numX: Int = 2              // コート数
    
    // 現在の参加メンバー数(VC2から参加数argNumを受け取る)
    var currentMembers: Int = 0
    
    
    // 全体のメンバー数（削除された番号もカウント）:初回currentMembers + 追加数
    var totalMember: Int = 0
    
    // 更新後の参加メンバー数(設定反映ボタン押下時の)
    var updatedMembers: Int = 0
    
    var pairArray : [[Int]] = []  // ペア配列を宣言
    var pairArrayCount : Int = 0    // ペア配列要素数
    
    
    
//    // デフォルトColor
//    var mainColor = UIColor(red: 21/255, green: 196/255, blue: 161/255, alpha: 1)
//    var subColor = UIColor(red: 226/255, green: 247/255, blue: 239/255, alpha: 1)
    
    let maxTotalMenber: Int = 99// メンバー追加を快味した最大参加可能人数
    
    
    var cellArray: [[Int]] = []  // セル表示用配列を宣言
                                    //([番号, 追加削除フラグ:0=増減なし/1=増/9=減])
    
    var cellCheckFlg: [Bool] = []  // 行のチェック有無Flag(true:チェックあり/false:チェックなし)
    
    //  チェックされたセルの位置を保存しておく辞書を宣言
    var selectedCells: [String:Bool]=[String:Bool]()
    
    // メンバー追加用リスト
    // 現在の参加メンバー数：40人以下
    let list_10 = [  "",  "1",  "2",  "3",  "4",  "5",  "6",  "7",  "8",  "9", "10"]
    let list_9 = [  "",  "1",  "2",  "3",  "4",  "5",  "6",  "7",  "8",  "9"]
    let list_8 = [  "",  "1",  "2",  "3",  "4",  "5",  "6",  "7",  "8"]
    let list_7 = [  "",  "1",  "2",  "3",  "4",  "5",  "6",  "7"]
    let list_6 = [  "",  "1",  "2",  "3",  "4",  "5",  "6"]
    // 現在の参加メンバー数：41~45人
    let list_5 = [  "",  "1",  "2",  "3",  "4",  "5"]
    let list_4 = [  "",  "1",  "2",  "3",  "4"]
    let list_3 = [  "",  "1",  "2",  "3"]
    let list_2 = [  "",  "1",  "2"]
    let list_1 = [  "",  "1"]
    // 現在の参加メンバー数：46人以上
    let list_0 = [  ""]
    
    // viewが表示される度に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        // タブの無効化
        let tagetTabBar = 0 //タブの番号
        self.tabBarController!.tabBar.items![tagetTabBar].isEnabled = false // タブの無効化
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ■■ settingButton設定 ■■
        // Color設定
        settingButton.backgroundColor = mainColor
        settingButton.layer.cornerRadius = 20  // 7
        settingButton.layer.shadowOffset = CGSize(width: 0, height: 3 )  // 8
        settingButton.layer.shadowOpacity = 0.8  // 9
        settingButton.layer.shadowRadius = 3  // 10
        settingButton.layer.shadowColor = UIColor.gray.cgColor  // 11
        
        // 枠の設定
        interFrame.layer.cornerRadius = 10
        self.view.sendSubviewToBack(interFrame)
        
        interFrame2.layer.cornerRadius = 10
        self.view.sendSubviewToBack(interFrame2)
        
        interFrame3.layer.cornerRadius = 10
        self.view.sendSubviewToBack(interFrame3)
        
        
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
//        let screenHeight:CGFloat = self.view.frame.height
        
        // ■■ AdMobバナー ■■
        // In this case, we instantiate the banner with desired ad size.
        //bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //let adSize = GADAdSizeFromCGSize(CGSize(width: screenWidth, height: screenWidth*45/320))
        let adSize = GADAdSizeFromCGSize(CGSize(width: screenWidth, height: screenWidth*50/320))
        bannerView = GADBannerView(adSize: adSize)
        //bannerView.adUnitID = "ca-app-pub-8819499017949234/2255414473" //本番ID
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //サンプルID
        bannerView.adUnitID = admobId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        
        // ■■ UIPickerView表示,編集可否制御 ■■
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(ViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ViewController.cancel))
        let _flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem, _flexibleItem, doneItem], animated: true)
        //self.addNumbersText.inputView = pickerView
        //self.addNumbersText.inputAccessoryView = toolbar
        
        // 最大参加可能人数以上の人数の場合、addNumbersTextは編集不可&文言表示
        if currentMembers >= maxTotalMenber {
            self.addNumbersText.text = "---"
            self.addNumbersText.backgroundColor = grayOutColor
            self.addNumbersText.isEnabled = false // 編集不可
        } else {
            self.addNumbersText.text = ""
            self.addNumbersText.backgroundColor = UIColor.clear
            self.addNumbersText.isEnabled = true // 編集可能
            // UIPickerView表示
            self.addNumbersText.inputView = pickerView
            self.addNumbersText.inputAccessoryView = toolbar
        }
        
        
        
        
        // セル複数選択可否（trueで複数選択、falseで単一選択）
        tableView3.allowsMultipleSelection = true
        
        
        totalMember = finalMasterArray.count
        
//        print("currentMembers=", currentMembers)
//        print("totalMember=", totalMember)
//        print("finalMasterArray=", finalMasterArray)
        // finalMasterArray[]に初期値を格納、または、選出回数を更新
        if finalMasterArray.isEmpty {
            // finalMasterArray[]が空の場合
            for i in 0..<currentMembers {
                // 初期値を格納
                finalMasterArray.append([masterArray[i][0], masterArray[i][1], 0, 0])
            }
        } else {
            // 空でない場合
            
            // 対戦表から受け取ったmasterArray[]で、finalMasterArray[]の選出回数を更新
            for i in 0..<currentMembers {
                if totalMember > 0 {
                    for j in 0..<totalMember {
                        if finalMasterArray[j][0] == masterArray[i][0] {
                            // 選出回数を更新
                            finalMasterArray[j][1] = masterArray[i][1] - finalMasterArray[j][3]
                        }
                    }
                } else {
                    for j in 0..<currentMembers {
                        if finalMasterArray[j][0] == masterArray[i][0] {
                            // 選出回数を更新
                            finalMasterArray[j][1] = masterArray[i][1] - finalMasterArray[j][3]
                        }
                    }
                }
            }
        }
//        print("finalMasterArray=", finalMasterArray)
        
        // ・セル表示用配列に値を格納([番号, 追加削除フラグ])
        // ・行のチェック有無Flgに行数分true/false格納
        // 　finalMasterArray[]の追加削除フラグ=9の場合、行チェックあり"true"格納
        // 　追加削除フラグ=9以外の場合、行チェックなし"false"格納
        cellCheckFlg.removeAll() // 初期化
        if totalMember > 0 {
//            print("totalMember=", totalMember)
            for i in 0..<totalMember {
                cellArray.append([finalMasterArray[i][0], finalMasterArray[i][2]])
                
                if finalMasterArray[i][2] == 9 {
                    cellCheckFlg.append(true)
                } else {
                    cellCheckFlg.append(false)
                }
            }
        } else {
//            print("currentMembers=", currentMembers)
            for i in 0..<currentMembers {
                cellArray.append([finalMasterArray[i][0], finalMasterArray[i][2]])
                
                if finalMasterArray[i][2] == 9 {
                    cellCheckFlg.append(true)
                } else {
                    cellCheckFlg.append(false)
                }
            }
        }
//        print("cellArray=", cellArray)
//        print("cellCheckFlg=",cellCheckFlg)
        
    }
    
    override func didReceiveMemoryWarning() {
        didReceiveMemoryWarning()
    }

    //セルの個数を指定するデリゲートメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! Cell3

        // セルに表示する値を設定する
        cell.numberLabel!.text = String(cellArray[indexPath.row][0])
        cell.backgroundColor = UIColor.white // セル白色
        
        // 削除済みかどうかチェック
        if cellArray[indexPath.row][1] == 9 {
            // 削除済みの場合
            cell.commentLabel!.text = "削除済み"
            // セルの選択不可にする
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            // グレーアウト
            cell.backgroundColor = grayOutColor
            // チェック有りを辞書に登録
            let key = "\(indexPath.section)-\(indexPath.row)"
            selectedCells[key] = true
        } else {
            // 削除済みでない場合
            cell.commentLabel!.text = ""
            //
//            // チェック無しを辞書に登録
//            let key = "\(indexPath.section)-\(indexPath.row)"
//            selectedCells[key] = false
        }
        
        //--------------------------------------
        // チェック有無をcellごとに辞書から取り出し設定
        //--------------------------------------
        let key = "\(indexPath.section)-\(indexPath.row)"
//        print("key =",key)
//        print("selectedCells[key] =",selectedCells[key] as Any)
        if selectedCells[key] != nil{
//            print("チェック有")
            // セルにチェックマークを付ける
            cell.roundLabel.text = "●"
            cell.checkLabel.text = "✓"
            cell.roundLabel.textColor = UIColor.gray
            cell.roundLabel.font = UIFont.systemFont(ofSize: 26)

            if cellCheckFlg[indexPath.row] == false {
                cellCheckFlg[indexPath.row] = true
            }
        }else{
//            print("チェック無")
            // セルのチェックマークを外す
            cell.roundLabel.text = "◯"
            cell.checkLabel.text = ""
            cell.roundLabel.textColor = .lightGray
            cell.roundLabel.font = UIFont.systemFont(ofSize: 26)

//            print("indexPath.row=",indexPath.row)
            if cellCheckFlg[indexPath.row] == true {
                cellCheckFlg[indexPath.row] = false
            }
        }

        // セルが選択された時の背景色を消す
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        // 選択されたセルの背景色を設定
        //let cellSelectedBgView = UIView()
        //cellSelectedBgView.backgroundColor = subColor
        //cell.selectedBackgroundView = cellSelectedBgView
        
        
        return cell
    }

    // -----------------------
    // セルのチェックマーク処理
    // -----------------------
    // セルが選択された時に呼び出される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("セル選択")
        
        // 削除済みの番号は何もしない
        if cellArray[indexPath.row][1] == 9 {
            return
        }

        // チェック有無をcellごとに辞書から取り出し設定
        let key = "\(indexPath.section)-\(indexPath.row)"
        //print("key =",key)
        //print("selectedCells[key] =",selectedCells[key] as Any)
        if selectedCells[key] != nil{
            selectedCells.removeValue(forKey:key)
        }else{
            selectedCells[key] = true;
        }

        // tableViewをリロードしてチェック反映
        tableView.reloadData()
//
        

    }
    
    
    
    // -----------------------
    // UIPickerView処理
    // -----------------------
    var tempSelectNum : String = ""
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
//    var currentMembersVolume = 1
//    func currentMembersCheck() -> Int{
//        var result = 9
//        if currentMembers <= 40 {
//            result = 0
//        } else if currentMembers > 40 && currentMembers <= 45 {
//            result = 1
//        }
//        return result
//    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        // 最大参加可能人数-10以下の場合
        if currentMembers <= maxTotalMenber - 10 {
            return list_10.count
        }
        
        // 最大参加可能人数-(1~9)の場合とデフォルト
        switch currentMembers {
        case maxTotalMenber - 9:
            return list_9.count
        case maxTotalMenber - 8:
            return list_8.count
        case maxTotalMenber - 7:
            return list_7.count
        case maxTotalMenber - 6:
            return list_6.count
        case maxTotalMenber - 5:
            return list_5.count
        case maxTotalMenber - 4:
            return list_4.count
        case maxTotalMenber - 3:
            return list_3.count
        case maxTotalMenber - 2:
            return list_2.count
        case maxTotalMenber - 1:
            return list_1.count
        default:
            return list_0.count
        }
        
//        currentMembersVolume = currentMembersCheck()
//
//        switch currentMembersVolume {
//        case 0:
//            return list_10.count
//        case 1:
//            return list_5.count
//        default:
//            return list_0.count
//        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // 最大参加可能人数-10以下の場合
        if currentMembers <= maxTotalMenber - 10 {
            return list_10[row]
        }
        
        // 最大参加可能人数-(1~9)の場合とデフォルト
        switch currentMembers {
        case maxTotalMenber - 9:
            return list_9[row]
        case maxTotalMenber - 8:
            return list_8[row]
        case maxTotalMenber - 7:
            return list_7[row]
        case maxTotalMenber - 6:
            return list_6[row]
        case maxTotalMenber - 5:
            return list_5[row]
        case maxTotalMenber - 4:
            return list_4[row]
        case maxTotalMenber - 3:
            return list_3[row]
        case maxTotalMenber - 2:
            return list_2[row]
        case maxTotalMenber - 1:
            return list_1[row]
        default:
            return list_0[row]
        }
        
//        currentMembersVolume = currentMembersCheck()
//
//        switch currentMembersVolume {
//        case 0:
//            return list_10[row]
//        case 1:
//            return list_5[row]
//        default:
//            return list_0[row]
//        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // 最大参加可能人数-10以下の場合
        if currentMembers <= maxTotalMenber - 10 {
            tempSelectNum = list_10[row]
            return
        }
        
        // 最大参加可能人数-(1~9)の場合とデフォルト
        switch currentMembers {
        case maxTotalMenber - 9:
            tempSelectNum = list_9[row]
            return
        case maxTotalMenber - 8:
            tempSelectNum = list_8[row]
            return
        case maxTotalMenber - 7:
            tempSelectNum = list_7[row]
            return
        case maxTotalMenber - 6:
            tempSelectNum = list_6[row]
            return
        case maxTotalMenber - 5:
            tempSelectNum = list_5[row]
            return
        case maxTotalMenber - 4:
            tempSelectNum = list_4[row]
            return
        case maxTotalMenber - 3:
            tempSelectNum = list_3[row]
            return
        case maxTotalMenber - 2:
            tempSelectNum = list_2[row]
            return
        case maxTotalMenber - 1:
            tempSelectNum = list_1[row]
            return
        default:
            tempSelectNum = list_0[row]
            return
        }
        
//        currentMembersVolume = currentMembersCheck()
//
//        switch currentMembersVolume {
//        case 0:
//            tempSelectNum = list_10[row]
//        case 1:
//            tempSelectNum = list_5[row]
//        default:
//            tempSelectNum = list_0[row]
//        }
    }
    
    // キャンセル
    @objc func cancel() {
        self.addNumbersText.endEditing(true)
    }
    
    // 決定
    @objc func done() {
        if tempSelectNum == "" {
//            print("addNumbersTextは空欄")
            // 空欄なので反映
            self.addNumbersText.text = tempSelectNum
            self.addNumbersText.endEditing(true)
        } else {
            if (tempSelectNum.isAlphanumeric()) {
//                print("addNumbersTextは半角数字")
                // 半角数字なので反映
                self.addNumbersText.text = tempSelectNum
                self.addNumbersText.endEditing(true)
            }else{
//                print("addNumbersTextは半角数字でない")
                // 半角数字ではないので空欄とする
                tempSelectNum = ""
                self.addNumbersText.text = tempSelectNum
                self.addNumbersText.endEditing(true)
            }
        }
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    // ------------------------------------------------
    // ダブルス対戦表画面へ戻るボタンタップ処理（変更を反映しない）
    // ------------------------------------------------
    @IBAction func backButton(_ sender: Any) {
        
        // ダブルス対戦表画面へ戻る
        if addDeleteFlg() {
            // 変更がある場合、確認メッセージ表示
            backAlert(title: "対戦表へ戻りますか？",message: "変更は反映されません")
        } else {
            // メッセージ表示せずにダブルス対戦表画面に戻る
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func backAlert(title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .default,handler:{(action: UIAlertAction!) -> Void in
                // 何もしない
            })
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default,handler:{(action: UIAlertAction!) -> Void in
                // ダブルス対戦表画面に戻る
                self.navigationController?.popViewController(animated: true)
            })
        )
        present(alertController, animated: true)
    }
    
    // ---------------------------------------
    // メンバー追加削除の有無チェック処理（変更を反映しない）
    // true:増減あり/false:増減なし
    // ---------------------------------------
    func addDeleteFlg() -> Bool {
        var incDecFlg: Bool = false // 人数増減フラグ（true:増減あり/false:増減なし）
        
        // メンバー追加有無チェック
        if countAddMember() != "0" {
            incDecFlg = true
        }
        // 増減フラグが立っているかチェック
        if incDecFlg == false {
            // フラグが立っていない場合、メンバー削除有無チェック
            if countDeleteMember().isEmpty == false {
                incDecFlg = true
            }
        }
        
        return incDecFlg
    }
    
    // メンバー追加数カウント処理（設定反映前）
    func countAddMember() -> String {
        var addMenbers: String = "0"
        
        if addNumbersText.text != "" && addNumbersText.text != "---" {
            addMenbers = addNumbersText.text!
        } else {
            addMenbers = "0"
        }
        
        return addMenbers
    }
    
    // メンバー削除数カウント処理（設定反映前）
    func countDeleteMember() -> Array<Int> {
        var deleteNumber: [Int] = []
        
        // cellCheckFlgが立っているNoから、グレーセル(cellArray[No, 9]のNo)を除く
        deleteNumber.removeAll()
        var cellArray9: [Int] = []
        cellArray9.removeAll()
        // グレーセル(cellArray[No, 9]のNo)を抽出
//        print("cellArray=", cellArray)
//        print("cellArray.count=", cellArray.count)
        for i in 0..<cellArray.count {
            if cellArray[i][1] == 9 {
//                print("cellArray[i][0-1]=", cellArray[i][0], cellArray[i][1])
                cellArray9.append(cellArray[i][0])
            }
        }
//        print("cellArray9=", cellArray9)
//        print("cellCheckFlg=", cellCheckFlg)
        // チェック付きセル農地、グレーセルを除外する
        for_i: for i in 0..<cellCheckFlg.count {
            // フラグが立っているNo(i+1)を取得
            if cellCheckFlg[i] == true {
//                print("i=", i)
                if cellArray9.isEmpty == false {
                    // グレーセルが存在する場合
                    for_j: for j in 0..<cellArray9.count {
//                        print("j=", j)
                        if i + 1 == cellArray9[j] {
                            // グレーセル(cellArray[No, 9]のNo)に該当あり
//                            print("break")
                            break for_j
                        }
                        // 最後のjループ？
                        if j + 1 >= cellArray9.count {
                            // グレーセル(cellArray[No, 9]のNo)に該当なし(新規削除)
                            // No=i+1をdeleteNumberに追加
                            deleteNumber.append(i + 1)
                        }
                    }
                } else {
                    // グレーセルが存在しない場合
                    // No=i+1をdeleteNumberに追加
                    deleteNumber.append(i + 1)
                }
            }
        }
//        print("deleteNumber=", deleteNumber)
        
        return deleteNumber
    }
    
    // ---------------------------------------
    // 設定反映ボタン タップ処理
    // ---------------------------------------
    @IBAction func settingButton(_ sender: Any) {
        // 変更がある場合、確認メッセージ
        var addMenbers: String = "0"
        var deleteNumber: [Int] = []
        var deleteNumberCount: Int = 0
        var strDeleteNumber: String = ""
        
        // メンバー増減の有無チェック
        if addDeleteFlg() == false {
            // 増減がない場合
            // 何もせず
            let msg = "メンバーの追加、削除を指定してください"
            defaultAlert(title: "変更がありません",message: msg)
        } else {
            // 増減がある場合
            // メンバー追加数（設定反映前）
            addMenbers = countAddMember()
            
            // メンバー削除数（設定反映前）
            deleteNumber.removeAll()
            deleteNumberCount = countDeleteMember().count
            for i in 0..<deleteNumberCount{
                deleteNumber.append(countDeleteMember()[i])
            }
            
            // strDeleteNumberへ入力
            if deleteNumber.isEmpty == false {
                for i in 0..<deleteNumber.count{
                    strDeleteNumber = strDeleteNumber + String(deleteNumber[i])
                    if i + 1 < deleteNumber.count{
                        strDeleteNumber = strDeleteNumber + ","
                    }
                }
            } else {
                strDeleteNumber = "-"
            }
            
//            print("currentMembers=", currentMembers)
//            print("addMenbers=", addMenbers)
//            print("deleteNumber=", deleteNumber)
            // 更新後参加数 = 現在の参加数 + 追加メンバー数 - 削除メンバー数
            updatedMembers = currentMembers + Int(addMenbers)! - deleteNumber.count
//            print("updatedMembers=", updatedMembers)
            
            // 更新後、最低人数以上かどうかチェック
            let intMinNum: Int = numX * 4
//            print("intMinNum=", intMinNum)
            if updatedMembers >= intMinNum {
                // 最低人数以上の場合、設定反映
                let msg = "追加人数: " + addMenbers + "人\n"
                    + "削除番号: " + strDeleteNumber + "\n"
                    + "反映後の参加人数: " + String(updatedMembers) + "人"
                settingAlert(title: "設定を反映しますか？",message: msg)
            } else {
                // 最低人数以下の場合、設定見直し
                let msg = "メンバーが最低人数より少なくなります\n"
                    + "最低人数= " + String(intMinNum) + "人 (コート数 × 4人)\n"
                    + "反映後の人数: " + String(updatedMembers) + "人(参考まで)"
                ngAlert(title: "設定を反映できません",message: msg)
            }
        }
    }
    
    // 設定入力の催促メッセージ
    func defaultAlert(title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default,handler:{(action: UIAlertAction!) -> Void in
                // 何もしない
            })
        )
        present(alertController, animated: true)
    }
    
    // 設定反映の確認メッセージ
    func settingAlert(title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .default,handler:{(action: UIAlertAction!) -> Void in
                // 何もしない
            })
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default,handler:{(action: UIAlertAction!) -> Void in
                // 設定反映
                self.settingAddDelete()
                // ダブルス対戦表画面へ戻る
                self.navigationController?.popViewController(animated: true)
            })
        )
        present(alertController, animated: true)
        
    }
    
    // 設定反映処理(finalMasterArray[]の更新)
    func settingAddDelete() {
        var addMenbers: String = "0"
//        var deleteNumber: [Int] = []
        
        // -- メンバー追加 --
        // メンバー追加数を取得
        addMenbers = countAddMember()
        
        // 既存メンバの最少の参加数(補正値を加味)を取得(削除メンバの参加数は除外)
        var finalMasterArrayMin: Int = 100000
        for i in 0..<finalMasterArray.count {
            if finalMasterArrayMin > finalMasterArray[i][1] + finalMasterArray[i][3] && finalMasterArray[i][2] != 9 {
                finalMasterArrayMin = finalMasterArray[i][1] + finalMasterArray[i][3]
            }
        }
//        // 既存メンバの最少の参加数-1とすることで、追加メンバが次回必ず参加できるようになる
//        // ただし、finalMasterArrayMin=0のときはそのまま(-1して負の値になるのを回避)
//        if finalMasterArrayMin >= 1 {
//            finalMasterArrayMin -= 1
//        }
        
        // finalMasterArray[]にメンバー追加
        // このとき、既存メンバの最少の参加数を3番目に格納
        var addMenbersArray: [Int] = [] // pairArray追加用配列
        addMenbersArray.removeAll()
        for _ in 0..<Int(addMenbers)! {
            // 初期値を格納
            // 3つ目の値：メンバー追加=1
            finalMasterArray.append([finalMasterArray.count + 1, 0, 1, finalMasterArrayMin])
            // 追加メンバーの番号を格納
            addMenbersArray.append(finalMasterArray.count)
        }
//        print("finalMasterArray.count=", finalMasterArray.count)
//        print("finalMasterArray=", finalMasterArray)
//        print("addMenbersArray=", addMenbersArray)
        
//        // -- メンバー削除 --
//        // 削除番号を取得
//        deleteNumber.removeAll()
//        for i in 0..<countDeleteMember().count {
//            deleteNumber.append(countDeleteMember()[i])
//        }
        
        for i in 0..<finalMasterArray.count {
            for j in 0..<cellCheckFlg.count {
                if finalMasterArray[i][0] == j + 1 && cellCheckFlg[j] {
                    // finalMasterArrayの番号のセル行数にチェックがある場合(cellCheckFlg=True)
                    // 9:削除を格納
                    finalMasterArray[i][2] = 9
                }
            }
        }
//        print("削除チェック9格納")
//        print("finalMasterArray=", finalMasterArray)
        
        // -- 設定反映(ダブルス対戦表のmasterArray[]に設定) --
        // - finalMasterArrayの追加削除フラグ=9(削除)以外のメンバーを渡す
        // NavigationControllerを取得
        let nav = self.navigationController!
        // 呼び出し元のViewControllerを遷移履歴から取得しパラメータを渡す
        let InfoVc = nav.viewControllers[nav.viewControllers.count-2] as! ViewController2
        InfoVc.masterArray.removeAll()
        for i in 0..<finalMasterArray.count {
            if finalMasterArray[i][2] != 9 {
                // 追加削除フラグ=9(削除)以外の場合、対戦表で使用するメンバーを渡す
                InfoVc.masterArray.append([finalMasterArray[i][0] ,finalMasterArray[i][1] + finalMasterArray[i][3]])
            }
        }
//        print("InfoVc.masterArray=", InfoVc.masterArray)
        
        // - 設定後の参加人数を渡す
        InfoVc.argNum = String(InfoVc.masterArray.count)
//        print("InfoVc.argNum=", InfoVc.argNum)
        
        // - 追加メンバーを加味したペアを追加し、
        // - 追加削除フラグ=9(削除)のメンバーを除いたpairArrayを渡す
        // 追加メンバーを加味したペアを追加
        
//        print("pairArray=", pairArray)
//        print("pairArray.count=", pairArray.count)
        if addMenbersArray.isEmpty == false {
            // メンバー追加がある場合
            // pairArray[]のユニークな要素を取り出す
            var pairArrayTmp: [Int] = []
            pairArrayTmp.removeAll()
            for i in 0..<pairArray.count {
                pairArrayTmp.append(pairArray[i][0])
                pairArrayTmp.append(pairArray[i][1])
            }
            // 重複削除
            var pairArrayTmpUnique = Array(Set(pairArrayTmp))
            // ソート
            pairArrayTmpUnique.sort()
//            print("pairArrayTmpUnique=", pairArrayTmpUnique)
            //
//            print("addMenbersArray=", addMenbersArray)
//            print("addMenbersArray.count=", addMenbersArray.count)
            // 既存メンバーと追加メンバーの組み合わせを追加
            for i in 0..<addMenbersArray.count {
                for j in 0..<pairArrayTmpUnique.count {
                    // 番号の若い方を左にペアを作成しpairArray[]に追加(ペア選出回数:0)
                    pairArray.append([pairArrayTmpUnique[j], addMenbersArray[i], 0])
                }
            }
            // 追加メンバーどうしの組み合わせを追加
            for i in 0..<addMenbersArray.count - 1 {
                for j in i + 1..<addMenbersArray.count {
                    pairArray.append([addMenbersArray[i], addMenbersArray[j], 0])
                }
            }
//            print("追加")
//            print("pairArray=", pairArray)
        }
        //追加削除フラグ=9(削除)のメンバーが存在するか判定する？
        // pairArrayから追加削除フラグ=9(削除)のメンバーを除く
        var deleteMember: [Int] = [] //追加削除フラグ=9(削除)のメンバー格納用配列
        deleteMember.removeAll()
//        print("finalMasterArray=", finalMasterArray)
//        print("finalMasterArray.count=", finalMasterArray.count)
        for i in 0..<finalMasterArray.count {
            if finalMasterArray[i][2] == 9 {
                deleteMember.append(finalMasterArray[i][0])
            }
        }
//        print("deleteMember=", deleteMember)
//        print("deleteMember.count=", deleteMember.count)
//        print("追加削除フラグ=9(削除)のメンバーを除く")
        // 追加削除フラグ=9(削除)のメンバーを除く
        for i in (0..<pairArray.count).reversed() {
            for_j: for j in 0..<deleteMember.count{
                if pairArray[i][0] == deleteMember[j] || pairArray[i][1] == deleteMember[j] {
                    // 追加削除フラグ=9(削除)のメンバーを除く
                    pairArray.remove(at: i)
                    break for_j
                }
            }
        }
        // pairArrayを渡す
        InfoVc.pairArray.removeAll()
        for i in 0..<pairArray.count {
            InfoVc.pairArray.append([pairArray[i][0], pairArray[i][1], pairArray[i][2]])
        }
//        print("追加削除後")
//        print("InfoVc.pairArray=", InfoVc.pairArray)
        
        // - pairArrayCountを渡す
        InfoVc.pairArrayCount = InfoVc.pairArray.count
//        print("InfoVc.pairArrayCount=", InfoVc.pairArrayCount)
        
        // 初回処理終了フラグを渡す
        InfoVc.initialProcessFlg = false
        
        // 更新後参加数（追加削除も加味した参加数）を渡す
        InfoVc.totalMember = updatedMembers
        
//        print("InfoVc.checkCountArray=", InfoVc.checkCountArray)
//        print("InfoVc.masterArray.count=", InfoVc.masterArray.count)
//        print("updatedMembers=", updatedMembers)
        // チェック記録配列を更新、全員”0”を格納し、TableView更新時にチェック有無更新
        //InfoVc.checkCountArray.removeAll() // 初期化
        //InfoVc.checkCountArrayは蓄積のため初期化しない
        //InfoVc.checkCountArrayにメンバー追加
        // checkCountArrayの最大値を取得
        let max_tmp = InfoVc.checkCountArray[InfoVc.checkCountArray.count - 1][0]
        for i in 0..<InfoVc.masterArray.count {
            if max_tmp < InfoVc.masterArray[i][0] {
                // 最大値を超えた番号のメンバーが追加される場合、追加
                InfoVc.checkCountArray.append([InfoVc.masterArray[i][0], 0])
            }
        }
        //InfoVc.checkCountArrayからメンバー削除
        //masterArrayが持っている番号はそのまま、持っていない番号は削除
        //masterArrayは蓄積のため削除しない
//        for i in (0..<InfoVc.checkCountArray.count).reversed() {
//            for_j: for j in (0..<InfoVc.masterArray.count).reversed() {
//                if InfoVc.checkCountArray[i][0] == InfoVc.masterArray[j][0] {
//                    // 画面遷移後のメンバーがcheckCountArrayに存在する場合、そのまま
//                    break for_j
//                }
//                if j <= 0 {
//                    // 画面遷移後のメンバーがcheckCountArrayに存在しない場合
//                    // その番号を削除
//                    InfoVc.checkCountArray.remove(at: i)
//                }
//            }
//        }
//        print("InfoVc.checkCountArray=", InfoVc.checkCountArray)
//        print("InfoVc.masterArray=", InfoVc.masterArray)
        
    }
    
    // 設定見直し催促メッセージ（最低人数より少数となるため）
    func ngAlert(title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "設定を見直す", style: .default,handler:{(action: UIAlertAction!) -> Void in
                // 何もしない
            })
        )
        present(alertController, animated: true)
    }
    
    
    //--------------------------
    // AdMobバナー広告表示処理
    //--------------------------
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: bottomLayoutGuide,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
             NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ]
        )
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        print("error=",error)
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
    
}
