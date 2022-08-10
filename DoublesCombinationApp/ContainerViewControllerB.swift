//
//  ContainerViewControllerB.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/12/17.
//  Copyright © 2021 Kaede. All rights reserved.
//

//・画面表示直後、及びグループ選択直後はtableViewは空
//・「メンバー表示」ボタン押下でリスト表示、かつ、編集モート度ON
//　※リストは、チェックなしメンバーのみ表示
//・「ランダムに並び替え」ボタン押下でリストをランダムに並び替え
//・編集モードONではセル移動のみ可能（セル削除不可）
//・セルの上から昇順で採番
//・「固定」ボタン押下で編集モードOFF、このとき、ボタンラベルを「編集」に変更、かつ、他のボタン操作不可
//・「編集」ボタン押下で編集モードON、かつ、他のボタンタップ可能


import UIKit

// リストのキー（固定値）
let containerItemListKey: String = "itemListKey0123"
let selectedGroupNameKey: String = "selectedGroupNameKey0123"
let fixFlgKey: String = "fixFlgKey0123"

class ContainerViewControllerB: UIViewController {
    
    
    
    @IBOutlet weak var groupeName: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    // ボタン
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var fixButton: UIButton!
    // ラベル
    @IBOutlet weak var fixStateLabel: UILabel!
    
    
    var PickerView = UIPickerView() // ピッカー表示
    var alertController: UIAlertController!    // アラート表示
    
    var itemList: [String] = [] // tableView表示用
    
    var groupList: [GroupList] = [] // [グループID, グループ名]
    var selectedGroupID: Int = 0 // 選択されたグループID
    var selectedGroupName: String = "" // 選択されたグループ名
    var stItemList: [ItemList] = [] // [tag, [itemList]]：リストのタグ、チェックマーク、データ
    // ※チェックなしメンバーのみリストに表示する
    // ※tag = groupID
    
    var tablecellCount: Int = 0 // tableViewのセル数
    
    // メンバー登録を促すメッセージラベルのタグ
    let msgLabelTag: Int = 9911
    
    var fixFlg: Bool = false // tableView固定状態保持用（true:固定中/false:編集中）
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("ControllerB表示！！")
        
        groupeName.text = ""
        fixStateLabel.text = ""
        fixStateLabel.adjustsFontSizeToFitWidth = true // 文字サイズ自動調整
        
        // ボタン表示設定
        showButton.backgroundColor = mainColor
        showButton.setTitleColor(UIColor.white, for: .normal)
        showButton.layer.cornerRadius = showButton.frame.height * 0.2
        showButton.layer.shadowOffset = CGSize(width: 0, height: 2 )
        showButton.layer.shadowOpacity = 0.8
        showButton.layer.shadowRadius = 3
        showButton.layer.shadowColor = UIColor.gray.cgColor
        //
        shuffleButton.backgroundColor = mainColor
        shuffleButton.setTitleColor(UIColor.white, for: .normal)
        shuffleButton.layer.cornerRadius = shuffleButton.frame.height * 0.2
        shuffleButton.layer.shadowOffset = CGSize(width: 0, height: 2 )
        shuffleButton.layer.shadowOpacity = 0.8
        shuffleButton.layer.shadowRadius = 3
        shuffleButton.layer.shadowColor = UIColor.gray.cgColor
        //
        fixButton.backgroundColor = mainColor
        fixButton.setTitleColor(UIColor.white, for: .normal)
        fixButton.layer.cornerRadius = fixButton.frame.height * 0.2
        fixButton.layer.shadowOffset = CGSize(width: 0, height: 2 )
        fixButton.layer.shadowOpacity = 0.8
        fixButton.layer.shadowRadius = 3
        fixButton.layer.shadowColor = UIColor.gray.cgColor
        fixButton.setTitle("固定", for: .normal)
        
        // グループ選択のPickerView
        PickerView.delegate = self
        PickerView.dataSource = self
        groupeName.inputView = PickerView
        
//        // groupList取得
//        groupList.removeAll()
//        groupList = loadGroupList()!
        
        // toolbar表示（PickerViewの決定/キャンセル）
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ContainerViewControllerB.donePressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ContainerViewControllerB.cancelPressed))
        toolbar.setItems([cancel , space, done ], animated: true)
        groupeName.inputAccessoryView = toolbar
        
        // tableView設定
        tableView.estimatedRowHeight = 44 // セル高さ(テキトーな値)
        tableView.rowHeight = UITableView.automaticDimension // セル高さ自動調整
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ContainerCellB", bundle: nil), forCellReuseIdentifier: "ContainerCellB")
        tableView.tableFooterView = UIView() // 空白行の罫線なし
        tableView.isEditing = true // tableView編集モード有効化（ソート用）
        tableView.allowsSelection = false // Cellのタップ選択許可
        
        // メンバー追加を促すラベル削除（念の為）
        removeMsgLabel()
        
        
        
    }
    
    // toolbar用 決定/キャンセル
    @objc func donePressed() {
        view.endEditing(true)
    }

    @objc func cancelPressed() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 画面表示後の処理
    override func viewDidAppear(_ animated: Bool) {
        // tableViewの表示がない時（itemListのデータ数が0の時）
        if itemList.count == 0 {
            // 操作説明ラベル表示
            showDescriptionLabel()
        }
    }
    
    // 画面表示直前の処理（表示されるたびに呼ばれる）
    override func viewWillAppear(_ animated: Bool) {
        //print("画面表示直前に呼ばれた！！！")
        // セル数初期化
        tablecellCount = 0
        
        // groupList取得（PickerView表示項目の最新データを取得するためにココで処理）
        groupList.removeAll()
        if let groupListTmp = loadGroupList() {
            groupList = groupListTmp
        }
        
        // データが無い場合
        if groupList.count == 0 {
            // nilの場合（保存データが存在しない場合）
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "yyyyMMddHHmmss"
            // グループIDを発行
            let groupID: Int = Int( df.string(from: date))!
            //print("groupID = \(groupID)")
            groupList.append(GroupList(ID: groupID, name: "グループ1"))
            
            // groupListを保存
            saveGroupList(groupList: groupList)
        }
        
        //print("groupList取得")
        //print("groupList = \(groupList)")
        
        // 初期化
        groupeName.text = ""
        selectedGroupName = ""
        selectedGroupID = 0
        // グループ名がUserDefaultsに登録されていたかチェック
        // ※groupListから削除された場合、groupeNameは空欄にする
        selectedGroupName  = loadSelectedGroupName()
        if selectedGroupName != "" {
            // 登録されていた場合
            for_checkGroupList: for i in 0..<groupList.count {
                if groupList[i].name == selectedGroupName {
                    // groupListにグループ名が登録されている場合
                    // グループ名テキストに入力
                    groupeName.text = selectedGroupName
                    // ID記録
                    selectedGroupID = groupList[i].ID
                    
                    break for_checkGroupList
                }
            }
        } else {
            // グループ名空欄のまま処理終了
        }
        
        // グループ名が空欄の場合、処理終了
        guard groupeName.text != "" else {
            // itemList初期化
            itemList.removeAll()
            // UserdefaultsからitemList削除
            removeItemList()
            
            // 表示更新
            tableView.reloadData()
            
            // 固定処理をデフォルト状態に戻す
            // fixFlg初期化
            fixFlg = false
            fixButton.setTitle("固定", for: .normal)
            // グループ選択許可
            groupeName.isEnabled = true
            groupeName.backgroundColor = .clear // 色戻す
            // 表示更新ボタン活性
            showButton.isEnabled = true
            showButton.backgroundColor = mainColor // 色戻す
            // ランダム並び替えボタン活性
            shuffleButton.isEnabled = true
            shuffleButton.backgroundColor = mainColor // 色戻す
            // 固定状態ラベルのテキスト削除（空欄）
            fixStateLabel.text = ""
            // tableView編集モード有効化（ソート有効）
            tableView.isEditing = true
            
            // 処理終了
            return
        }
        
        // 以下、グループ名が入力された場合に実行
        
        // tableView表示更新
        // UserDefaultsからitemList取得
        if let itemListTmp = loadItemList() {
            // UserDefaultsからデータ取得に成功した場合
            if itemListTmp.count > 0 {
                // 要素数>0の場合
                // itemListにメンバー名を格納
                itemList.removeAll()
                for i in 0..<itemListTmp.count {
                    itemList.append(itemListTmp[i])
                }
                //print("itemList = \(itemList)")
                // 保存
                saveItemList(itemList: itemList)
                // 表示更新
                tableView.reloadData()
            }
        }
        
        // 固定状態反映
        // セル数>0の場合、
        let flg: Bool = groupSelectionReminder()
        if flg == true {
            return
        }
        
        // 以下、セル数>0の場合に実行
        
        // fixFlg取得
        fixFlg = loadFixFlg() // 取得失敗時、0 or falseが返る
        
        // tableViewが表示されている場合
        // ※「固定」ボタン押下時と分岐条件が逆の点に注意！！
        if fixFlg == true {
            // 固定中の場合
            // グループ選択不可
            groupeName.isEnabled = false
            groupeName.backgroundColor = subColor
            // 表示更新ボタン非活性
            showButton.isEnabled = false
            showButton.backgroundColor = .systemGray2
            // ランダム並び替えボタン非活性
            shuffleButton.isEnabled = false
            shuffleButton.backgroundColor = .systemGray2
            // 固定状態ラベルのテキスト入力
            fixStateLabel.text = "[固定中]"
            fixButton.setTitle("編集", for: .normal)
            // tableView編集モード無効化（ソート無効）
            tableView.isEditing = false
        } else {
            // 編集中の場合（デフォルト状態）
            // グループ選択許可
            groupeName.isEnabled = true
            groupeName.backgroundColor = .clear // 色戻す
            // 表示更新ボタン活性
            showButton.isEnabled = true
            showButton.backgroundColor = mainColor // 色戻す
            // ランダム並び替えボタン活性
            shuffleButton.isEnabled = true
            shuffleButton.backgroundColor = mainColor // 色戻す
            // 固定状態ラベルのテキスト削除（空欄）
            fixStateLabel.text = ""
            fixButton.setTitle("固定", for: .normal)
            // tableView編集モード有効化（ソート有効）
            tableView.isEditing = true
        }
    }
    
    
    // --------------------------
    // UserDefaults処理郡
    // --------------------------
    // 保存(groupList)
    func saveGroupList(groupList: [GroupList]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(groupList) else {
            return
        }
        UserDefaults.standard.set(data, forKey: groupListKey)
    }
    
    // 取得(groupList)
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
    
    // 保存(itemList)
    func saveItemList(itemList: [String]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(itemList) else {
            return
        }
        UserDefaults.standard.set(data, forKey: containerItemListKey)
    }
    
    // 取得(itemList)
    func loadItemList() -> [String]? {
        let jsonDecoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: containerItemListKey),
              let itemList = try? jsonDecoder.decode([String].self, from: data) else {
            return nil
        }
        return itemList
    }
    
    // 削除（itemList）
    func removeItemList() {
        UserDefaults.standard.removeObject(forKey: containerItemListKey)
    }
    
    // 保存（selectedGroupName）
    func saveSelectedGroupName() {
        UserDefaults.standard.set(selectedGroupName, forKey: selectedGroupNameKey)
    }
    
    // 取得（selectedGroupName）
    func loadSelectedGroupName() -> String {
        var selectedGroupName:String = ""
        if let strTmp = UserDefaults.standard.string(forKey: selectedGroupNameKey) {
            selectedGroupName = strTmp
        }
        return selectedGroupName
    }
    
    // 保存（fixFlg）
    func saveFixFlg() {
        UserDefaults.standard.set(fixFlg, forKey: fixFlgKey)
    }
    
    // 取得（fixFlg）
    func loadFixFlg() -> Bool {
        var fixFlg:Bool = false
        let flgTmp = UserDefaults.standard.bool(forKey: fixFlgKey) // 取得失敗時は0 or falseが返る
        fixFlg = flgTmp
        return fixFlg
    }
    
    
    
    
    
    
    // --------------------------
    // ボタン押下処理郡
    // --------------------------
    // 表示更新ボタン押下（メンバーリスト表示）
    @IBAction func displayMemberList(_ sender: Any) {
        // グループ名が選択されているかどうか判定
        if groupeName.text == "" {
            // グループ名が選択されていない場合
            // メッセージ表示のみ
            let title:String = "グループが選択されていません"
            let msg: String = "グループを選択してください"
            defaultAlert(title: title,message: msg)
        } else {
            // グループ名が選択されている場合
            // UserDefaultsからメンバー名取得&tableView更新
            loadDataAndTableUpdate()
        }
    }
    
    // UserDefaultsからメンバー名取得&tableView更新
    func loadDataAndTableUpdate() {
        // メンバー追加を促すラベル削除
        removeMsgLabel()
        
        // stItemList取得
        stItemList.removeAll()
        if let stItemListTmp = loadStItemList() {
            // 保存データが存在する場合
            stItemList.append(contentsOf: stItemListTmp)
            //print("stItemList取得成功！")
            
            //print("selectedGroupID = \(selectedGroupID)")
            //print("stItemList = \(stItemList)")
            // itemListにメンバー名を格納
            for_checkIDFlg: for i in 0..<stItemList.count {
                if stItemList[i].itemListKey == selectedGroupID {
                    // IDが保存されている場合
                    // itemListにメンバー名を格納（""データは除く）
                    itemList.removeAll()
                    for j in 0..<stItemList[i].itemList.count {
                        if stItemList[i].itemList[j].text != "" && stItemList[i].itemList[j].checkLfg != true {
                            // データが""でない、かつ、セルのチェックなしの場合、itemListに追加
                            itemList.append(stItemList[i].itemList[j].text)
                        }
                    }
                    // 保存
                    saveItemList(itemList: itemList)
                    //print("itemList保存！")
                    break for_checkIDFlg
                }
            }
            //print("itemList = \(itemList)")
            
            // tableView更新
            tableView.reloadData()
        } else {
            // 取得失敗した場合
            // itemListとtableViewはそのまま
            //print("stItemList取得失敗")
            //stItemList = []
        }
        //print("stItemList = \(stItemList)")
        
        // メンバーがいない場合、メンバー追加を促すラベル表示
        if tablecellCount == 0 {
            // UILabel作成
            let msgLabel = UILabel()
            msgLabel.tag = msgLabelTag
            msgLabel.numberOfLines = 0 // 複数行表示
            // メッセージ文言作成
            let text1: String = "メンバーがいません"
            let text2: String = "メンバー登録画面で追加してください"
            msgLabel.text = text1 + "\n" + text2
            // 一行目太文字化
            // attributedStringを作成
            let attrText = NSMutableAttributedString(string: msgLabel.text!)
            // 複数の属性を一括指定
            attrText.addAttributes([
                    .foregroundColor: UIColor.black,
                    .font: UIFont.boldSystemFont(ofSize: 19)
                ], range: NSMakeRange(0, 9))
            // msgLabelに反映
            msgLabel.attributedText = attrText
            //frame設定
            let msgLabelWidth: CGFloat = 300 // msgLabel横幅
            let screenWidth: CGFloat = self.view.frame.width // 画面横幅
            msgLabel.frame = CGRect(x: (screenWidth - msgLabelWidth) / 2, y: self.tableView.frame.minY + 20, width: msgLabelWidth, height: 80)
            msgLabel.textColor = .systemGray2 // 文字色指定
            msgLabel.textAlignment = NSTextAlignment.center // 中央寄せ
            self.view.addSubview(msgLabel)
            //print("メンバー追加催促ラベル表示！！")
        }
    }
    
    // メンバー追加を促すラベル削除
    func removeMsgLabel() {
        // msgLabel削除（タグを指定）
        // すべてのsubView検索
        for subViewTmp in self.view.subviews {
            //  タグがmsgLabelTagに一致するかどうかチェック
            if subViewTmp.tag == msgLabelTag {
                // subViewTmp削除
                subViewTmp.removeFromSuperview()
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
    
    // ランダム並び替えボタン押下（メンバーリストをランダムで並び替え）
    @IBAction func randomSort(_ sender: Any) {
        // セル数>0の場合、
        let flg: Bool = groupSelectionReminder()
        if flg == true {
            return
        }
        
        // 以下、セル数>0の場合に実行
        
        // itemListの順番をシャッフル
        itemList.shuffle()
        
        // 保存
        //print("itemList = \(itemList)")
        saveItemList(itemList: itemList)
        
        // 表示更新
        tableView.reloadData()
    }
    
    
    func groupSelectionReminder() -> Bool {
        var flg: Bool = false // メッセージラベル表示有無（true:表示あり/false:表示なし）
        
        // tableViewのセル数=0の場合
        if tablecellCount == 0 {
            
            // 操作説明ラベル表示
            showDescriptionLabel()
            
//            // メンバー追加を促すラベル削除
//            removeMsgLabel()
//
//            // UILabel作成
//            let msgLabel = UILabel()
//            msgLabel.tag = msgLabelTag
//            msgLabel.numberOfLines = 0 // 複数行表示
//            // メッセージ文言作成
//            let text1: String = "グループを選択し、"
//            let text2: String = "メンバーリストを表示しましょう"
//            msgLabel.text = text1 + "\n" + text2
//            //frame設定
//            let msgLabelWidth: CGFloat = 300 // msgLabel横幅
//            let screenWidth: CGFloat = self.view.frame.width // 画面横幅
//            msgLabel.frame = CGRect(x: (screenWidth - msgLabelWidth) / 2, y: self.tableView.frame.minY + 20, width: msgLabelWidth, height: 80)
//            msgLabel.textColor = .systemGray2 // 文字色指定
//            msgLabel.textAlignment = NSTextAlignment.center // 中央寄せ
//            self.view.addSubview(msgLabel)
//            //print("グループ選択・メンバー表の表示催促ラベル表示！！")
            
            flg = true
        }
        return flg
    }
    
    // 操作説明ラベル表示
    func showDescriptionLabel() {
        // メンバー追加を促すラベル削除
        removeMsgLabel()
        
        // UILabel作成
        let msgLabel = UILabel()
        msgLabel.tag = msgLabelTag
        msgLabel.numberOfLines = 0 // 複数行表示
        // メッセージ文言作成
        let text1: String = "グループを選択し、"
        let text2: String = "メンバーリストを表示しましょう"
        msgLabel.text = text1 + "\n" + text2
        //frame設定
        let msgLabelWidth: CGFloat = 300 // msgLabel横幅
        let screenWidth: CGFloat = self.view.frame.width // 画面横幅
        msgLabel.frame = CGRect(x: (screenWidth - msgLabelWidth) / 2, y: self.tableView.frame.minY + 20, width: msgLabelWidth, height: 80)
        msgLabel.textColor = .systemGray2 // 文字色指定
        msgLabel.textAlignment = NSTextAlignment.center // 中央寄せ
        self.view.addSubview(msgLabel)
        //print("グループ選択・メンバー表の表示催促ラベル表示！！")
    }
    
    
    // 固定ボタン押下（リスト固定）
    @IBAction func listFix(_ sender: Any) {
        // セル数>0の場合、
        let flg: Bool = groupSelectionReminder()
        if flg == true {
            return
        }
        
        // 以下、セル数>0の場合に実行
        
        // tableViewが表示されている場合
        if fixFlg == false {
            // 編集中の場合
            // グループ選択不可
            groupeName.isEnabled = false
            groupeName.backgroundColor = subColor
            // 表示更新ボタン非活性
            showButton.isEnabled = false
            showButton.backgroundColor = .systemGray2
            // ランダム並び替えボタン非活性
            shuffleButton.isEnabled = false
            shuffleButton.backgroundColor = .systemGray2
            // tableView編集モード無効化（ソート無効）
            tableView.isEditing = false
            // 固定状態ラベルのテキスト入力
            fixStateLabel.text = "[固定中]"
            fixButton.setTitle("編集", for: .normal)
            fixFlg = true // 固定中に切り替え
            // fixFlg保存
            saveFixFlg()
        } else {
            // 固定中の場合
            // グループ選択許可
            groupeName.isEnabled = true
            groupeName.backgroundColor = .clear // 色戻す
            // 表示更新ボタン活性
            showButton.isEnabled = true
            showButton.backgroundColor = mainColor // 色戻す
            // ランダム並び替えボタン活性
            shuffleButton.isEnabled = true
            shuffleButton.backgroundColor = mainColor // 色戻す
            // tableView編集モード有効化（ソート有効）
            tableView.isEditing = true
            // 固定状態ラベルのテキスト削除（空欄）
            fixStateLabel.text = ""
            fixButton.setTitle("固定", for: .normal)
            fixFlg = false // 編集中に切り替え
            // fixFlg保存
            saveFixFlg()
        }
    }
    
    
    
    
    
}

extension ContainerViewControllerB: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // PickerViewの種類（オブジェクト数）
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 選択行数（componentによるオブジェクトごとの場合分けが可能：ここでは使用しない）
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = groupList.count
        if count > 0 {
            count = groupList.count + 1
        }
        return count
    }
    
    // 選択肢（componentによるオブジェクトごとの場合分けが可能：ここでは使用しない）
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ""
        } else {
            return groupList[row - 1].name
        }
    }
    
    // 決定（componentによるオブジェクトごとの場合分けが可能：ここでは使用しない）
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var row_: Int = row
        if row > 0 {
            row_ = row - 1
        }
        groupeName.text = groupList[row_].name // テキストフィールドに表示
        selectedGroupID = groupList[row_].ID // 選択されたグループ名のIDを記録
        selectedGroupName = groupList[row_].name // 選択されたグループ名を記録
        // 保存
        saveSelectedGroupName()
    }
    
}

extension ContainerViewControllerB: UITableViewDelegate, UITableViewDataSource {
    
    // Section数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tablecellCount = itemList.count // セル数記録
        return itemList.count
    }
    
    // セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCellB", for: indexPath ) as! ContainerCellB
        cell.numberLabel.text = String(indexPath.row + 1)
        cell.nameLabel.text = itemList[indexPath.row]
        return cell
    }
    
    // ソート可能
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セル移動時のデータの処理
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //print("セルを移動！！")
        
        // 移動したセルのデータ取得
        let moveData = itemList[sourceIndexPath.row]
        // 取得したデータを配列から削除
        itemList.remove(at: sourceIndexPath.row)
        // 移動先の配列の位置にデータを挿入
        itemList.insert(moveData, at:destinationIndexPath.row)
        // 保存
        //print("itemList = \(itemList)")
        saveItemList(itemList: itemList)
        
        // 0.2秒止める
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // 0.5秒後に実行したい処理
            tableView.reloadData()
        }
    }
        
    
    // セル編集可能
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // tableViewの見た目設定
    // 左側の＋/ーの表示
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none // 表示しない
    }
    
    // 編集モード時、左側の＋/ーを表示にしてできたスペースを埋める
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false // スペースを埋めるように左につめる
    }
}
