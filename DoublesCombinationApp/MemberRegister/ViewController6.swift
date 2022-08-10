//
//  ViewController6.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/12/02.
//  Copyright © 2021 Kaede. All rights reserved.
//

import UIKit
import GoogleMobileAds

// グループIDリストのキー（固定値）
let groupListKey = "groupIDListKey0123"

class ViewController6: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, GroupListDelegate, GADBannerViewDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var barItemBack: UIBarButtonItem!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // 背景色用View
    @IBOutlet weak var backView: UIView!
    
    
    // AdMobバナー
    var bannerView: GADBannerView!
    
    // userDefaultsの定義
    var userDefaults = UserDefaults.standard
    
    var groupList: [GroupList] = [] // [[グループID, グループ名]]
    
    var groupName: String = ""
    var groupID: String = ""
    
    //var mainColor: UIColor = UIColor(red: 102/255, green: 179/255, blue: 255/255, alpha: 1.0)
    
//    // viewが表示される度に呼ばれる
//    override func viewWillAppear(_ animated: Bool) {
//        // タブの有効化
//        let tagetTabBar = 0 //タブの番号
//        self.tabBarController!.tabBar.items![tagetTabBar].isEnabled = true // タブの有効化
//    }
    
    // tableViewのy座標の初期値
    var tableViewFrameOriginY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self  // 戻る処理用
        
        // 背景色用View
        self.view.sendSubviewToBack(backView) // 最背面に移動
        self.backView.backgroundColor = .systemGray6 // 色指定
        
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
//        let screenHeight:CGFloat = self.view.frame.height
        
        barItemBack.tintColor = mainColor
        
        // ■■ AdMobバナー ■■
        let adSize = GADAdSizeFromCGSize(CGSize(width: screenWidth, height: screenWidth*100/320))
        bannerView = GADBannerView(adSize: adSize)
        //bannerView.adUnitID = "ca-app-pub-8819499017949234/2255414473" //本番ID
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //サンプルID
        bannerView.adUnitID = admobId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        
        // UserDefaults全削除
        //removeUserDefaults()
        
        //self.view.backgroundColor = .systemGray6
        
        textField.tag = 99990
        addButton.tag = 99991
        
        // 色
        textField.backgroundColor = .white
        // 角丸
        textField.layer.cornerRadius = 5  // 7
        
        // 角丸
        addButton.layer.cornerRadius = 10  // 7
        // 色
        addButton.backgroundColor = mainColor
        // 影
        addButton.layer.shadowOffset = CGSize(width: 0, height: 3 )  // 8
        addButton.layer.shadowOpacity = 0.8  // 9
        addButton.layer.shadowRadius = 3  // 10
        addButton.layer.shadowColor = UIColor.gray.cgColor  // 11
        
        tableView.estimatedRowHeight = 44 //テキトーな値
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "GroupListTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupListTableViewCell")
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true // Cellのタップ選択許可
        
        // userDefaultsに保存された値の取得
        groupList.removeAll()
        if let groupIDListTmp = loadGroupList() {
            groupList.append(contentsOf: groupIDListTmp)
        } else {
            // データが存在しない場合、デフォルトを用意
            //print("データなしのため初期値設定")
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "yyyyMMddHHmmss"
            // グループIDを発行
            let groupID: Int = Int( df.string(from: date))!
            //print("groupID = \(groupID)")
            groupList.append(GroupList(ID: groupID, name: "グループ1"))
            // 保存
            saveGroupList(groupList: groupList)
            
            // stItemListも追加&保存
            let cellItem: [CellItem] = [CellItem(checkLfg: false, text: "サンプル1")]
            let stItemList: [ItemList] = [ItemList(itemListKey: groupID, itemList: cellItem)]
            saveStItemList(stItemList: stItemList)
            //print("stItemList = \(stItemList)")
        }
        //print("groupList = \(groupList)")
        
        textField.returnKeyType = UIReturnKeyType.done // 改行→完了に表記変更
        textField.delegate = self
        
        
        // タップ認識するためのインスタンスを生成
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        // Viewに追加
        view.addGestureRecognizer(tapGesture)
        
        // ***キーボード表示・非表示の際にViewを上下に移動
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // ***キーボードを表示する際の処理
    @objc func keyboardWillShow(notification: NSNotification) {
        // textFieldタップの場合は何もしない
        if textField.isFirstResponder {
            return
        }
    
        if self.view.frame.origin.y == 0 {
            if self.tableView.frame.origin.y == tableViewFrameOriginY {
                if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
    //                self.tableView.frame.origin.y -= keyboardRect.height * 0.4
                    self.view.frame.origin.y -= keyboardRect.height * 0.70
                }
            }
        }
    }
    
    // ***キーボードを閉じる際の処理
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
//        if self.tableView.frame.origin.y != tableViewFrameOriginY {
//            self.tableView.frame.origin.y = tableViewFrameOriginY
//        }
    }
    
    // レイアウトサイズ決定後の処理
    override func viewDidLayoutSubviews() {
        // tableViewのy座標を記録（キーボード表示で上下移動後に使用）
        tableViewFrameOriginY = tableView.frame.origin.y
        
        // スクリーンの横縦幅
//        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        // iPhone以外の場合
        if UIDevice.current.userInterfaceIdiom != .phone {
            //print("これはiPadです。")
            // tableView_xのレイアウト調整
        
            let tableView_x = self.tableView.frame.origin.x
            let tableView_y = self.tableView.frame.origin.y
            let tableView_width = self.tableView.frame.width
            //let interFrame2_height = self.interFrame2.frame.height
            //AutoLayout解除
            self.tableView.translatesAutoresizingMaskIntoConstraints = true
            // currentViewControllerの高さ*0.8
            self.tableView.frame = CGRect(x: tableView_x, y: tableView_y,
                                              width: tableView_width,
                                              height: screenHeight * 0.55)
        }
    }
    
    
    // 保存([stItemList])
    func saveStItemList(stItemList: [ItemList]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(stItemList) else {
            return
        }
        UserDefaults.standard.set(data, forKey: stItemListKey)
    }
    
    // キーボードを閉じる際の処理
    @objc public func dismissKeyboard() {
        // ここでは何もしない
//        // セル追加&保存
//        print("セル追加&保存")
//        addGroupName()
//
        //print("キーボードを閉じるA")
//        view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //-- キーボードを閉じる --
    // リターン(完了)をタップで閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            // テキストが空でない場合
            // セル追加&保存
            //print("セル追加&保存")
            addGroupName()
        }
        
        // キーボードを閉じる
        //print("キーボードを閉じるB")
        textField.resignFirstResponder()
        textField.text = textField.text
        return true
    }
    
    // textField以外をタップで閉じる（キーボードを表示していないときは、textFieldタップで呼ばれる）
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //　textFieldと追加ボタンをタップしたときだけ、処理実行しない
        let touchevent = touches.first!
        let touchedView = touchevent.view!
        
        if let label = touchedView as? UITextField {
            // ラベルをタップした場合
            if label.tag == textField.tag {
                // ラベルのタグがtextField.tagと同一の場合
                // 何もせず終了
                return
            }
        }
        
        if let button = touchedView as? UIButton {
            // ボタンをタップした場合
            if button.tag == addButton.tag {
                // ボタンのタグがaddButton.tagと同一の場合
                // 何もせず終了
                return
            }
        }
        
        // その他のUIパーツをタップした場合、キーボードを閉じる
        //print("キーボードを閉じるC")
        view.endEditing(true)
    }
    
    // デリゲートメソッド(完了タップ)
    func textFieldDidEndEditing(cell: GroupListTableViewCell, value:String) {
        //print("デリゲートメソッド")
        
        // セルの行数を取得
        let index = cell.cellRow
        //print("index = \(index)")
        
        //データを更新
        groupList[index].name = value
        //print("groupList = \(groupList)")
        
        // 保存
        saveGroupList(groupList: groupList)
    }
    
    // UserDefaults全削除（開発用）
//    func removeUserDefaults() {
//        let appDomain = Bundle.main.bundleIdentifier
//        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
//    }
    
    
    // ※※※動作がおかしい。追加タップでテキストなし判定となる！？
    // 追加ボタンをタップ時の処理
    @IBAction func tapAddButton(_ sender: Any) {
        // キーボードは閉じない
        //print("追加ボタンタップ！")
        if textField.text != "" {
            // テキストが空でない場合
            // セル追加&保存
            //print("セル追加&保存")
            addGroupName()
            
        } else {
            // テキストが空の場合、メッセージ表示
            let alert: UIAlertController = UIAlertController(title: "確認", message:  "追加するグループ名を入力してください", preferredStyle:  UIAlertController.Style.alert)
            // OKボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                // 実際の処理
                // 処理なし
            })
            //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    // ※※※追加ボタンタップ時に、キーボードを閉じる処理が複数回呼ばれることが問題！！！
    // セル追加処理
    func addGroupName() {
        //print("セル追加処理")
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        // グループIDを発行
        let groupID: Int = Int( df.string(from: date))!
        //print("groupID = \(groupID)")
        
        // 保存済みのIDが発行された場合、重複するので何もせず終了
        for i in 0..<groupList.count {
            if groupList[i].ID == groupID {
                break
            }
        }
        
        groupList.append(GroupList(ID: groupID, name: textField.text!)) // 追加
        //print("groupList = \(groupList)")
        saveGroupList(groupList: groupList) // 保存
        
        // stItemListも追加&保存
        var stItemList: [ItemList] = loadStItemList()!
        let cellItem: [CellItem] = [CellItem(checkLfg: false, text: "")]
        stItemList.append(ItemList(itemListKey: groupID, itemList: cellItem))
        saveStItemList(stItemList: stItemList)
        //print("stItemList = \(stItemList)")
        
        // 画面更新
        textField.text = ""
        tableView.reloadData()
    }
    
    // 保存(GroupList)
    func saveGroupList(groupList: [GroupList]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(groupList) else {
            return
        }
        UserDefaults.standard.set(data, forKey: groupListKey)
    }
    
    // 取得(GroupList)
    func loadGroupList() -> [GroupList]? {
        let jsonDecoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: groupListKey),
              let groupList = try? jsonDecoder.decode([GroupList].self, from: data) else {
            return nil
        }
        return groupList
    }
    
    // 取得([stItemList])
    func loadStItemList() -> [ItemList]? {
        let jsonDecoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: stItemListKey),
              let stItemList = try? jsonDecoder.decode([ItemList].self, from: data) else {
            return nil
        }
        return stItemList
    }
    
    
    
    // -----------------------
    // tableView処理
    // -----------------------
    // テーブルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
    // セル設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("セルの表示内容設定")
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListTableViewCell", for: indexPath) as! GroupListTableViewCell
        
        // userDefaultsに保存された値の取得
//        let groupIDTmp: String = groupIDList[indexPath.row]
//        let groupListTmp: [String] = userDefaults.array(forKey: groupIDTmp) as! [String]
        
        if groupList.count > 0 {
            cell.setCell(text: groupList[indexPath.row].name)
        } else {
            cell.setCell(text: "")
        }
        
//        // セルのチェックマーク状態をリセット
//        if myTodo.todoDone {
//            // チェックあり
//            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
//        } else {
//            // チェックなし
//            cell.accessoryType = UITableViewCell.AccessoryType.none
//        }
        
        cell.setCellrow(cellRow: indexPath.row) // セルの行数を保持
        
        // 自作セルのデリゲート先に自分を設定
        cell.delegate = self
        
        return cell
    }
    
    // ソート可能
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セル移動時のデータの処理
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 移動したセルのデータ取得
        let moveData = groupList[sourceIndexPath.row]
        // 取得したデータを配列から削除
        groupList.remove(at: sourceIndexPath.row)
        // 移動先の配列の位置にデータを挿入
        groupList.insert(moveData, at:destinationIndexPath.row)
        // 保存
        //print("groupList = \(groupList)")
        saveGroupList(groupList: groupList) // 保存
    }
    
    // セル編集可能
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セルを削除した時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除可能かどうか判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // グループリストから削除
            groupList.remove(at: indexPath.row)
            // セルを削除
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            //print("groupList = \(groupList)")
            
            saveGroupList(groupList: groupList) // 保存
        }
    }
    
    // セルタップ時にキーボードを表示
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("セルタップ！！")
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListTableViewCell", for: indexPath) as! GroupListTableViewCell
        // セルに色を付けない
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        // セルのテキストフィールドでキーボードを表示する
        cell.textField.becomeFirstResponder()
    }
    
    
    
    
    // 閉じるボタン押下
    @IBAction func tapCloseButton(_ sender: Any) {
        
        
//        let preNC = self.presentingViewController as! UINavigationController
//        let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! ViewController5
//        preVC.reloadGroupList() // groupList更新
        
        // 選択中のセルのgroupIDを渡す
        // 選択していなければ戦闘のgroupIDを渡す
        //preVC.selectedLabelTag =
        
        
        
//        preVC.initReadUserDefaults() // userDefaultsに保存されたデータの取得
//        preVC.showTabs() // メニュータブ更新
//        preVC.showList() // リスト更新
//        preVC.updateList() // // リストの表示更新
//
//        // 画面遷移後、選択したメニューにフォーカス
//        var selectedLabelTag = preVC.selectedLabelTag // ←ココを修正
//        var existFlg: Bool = false
//        for i in 0..<groupList.count {
//            if selectedLabelTag == groupList[i].ID {
//                existFlg = true
//            }
//        }
//        if existFlg == false {
//            selectedLabelTag = groupList[0].ID
//        }
//
//        preVC.viewAnimate(selectedLabelTag: selectedLabelTag) // 選択されたメニューラベルにフォーカス
        
        
        // これは実装したい
        // 表示されたラベルのタグを保存
        //UserDefaults.standard.set(selectedLabelTag, forKey: selectedLabelKey)
        
        // 選択中のセルのgroupIDの
        // 遷移先メニューラベルを選択
        // &対応するリストを表示させる
        
        // 遷移先画面表示更新
        //let preNC = self.presentingViewController as! UINavigationController
        // let preNC = self.navigationController as! UINavigationController でも可能かと思います
        //let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! PreviousViewController
        //preVC.variable = self.variable  //ここで値渡し
        
//        let vc = self.presentingViewController// as! ViewController5
//        vc!.viewDidLayoutSubviews()
        
        // 現在の画面を閉じる
        //self.dismiss(animated: true, completion: nil)
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
    
}

// TextFieldでキーボードを表示可能にする
class TextFieldSub: UITextField {
    override var canBecomeFirstResponder: Bool {
        return true
    }
}


struct GroupList: Codable {
    var ID: Int
    var name: String
 
    init(ID: Int, name: String) {
        self.ID = ID
        self.name = name
    }
}

struct ItemList: Codable {
    var itemListKey: Int
    var itemList: [CellItem]
 
    init(itemListKey: Int, itemList: [CellItem]) {
        self.itemListKey = itemListKey
        self.itemList = itemList
    }
}

struct CellItem: Codable {
    var checkLfg: Bool
    var text: String
 
    init(checkLfg: Bool, text: String) {
        self.checkLfg = checkLfg
        self.text = text
    }
}
