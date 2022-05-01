//
//  ViewController5.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/12/02.
//  Copyright © 2021 Kaede. All rights reserved.
//

import UIKit
import GoogleMobileAds

// リストのキー（固定値）
let stItemListKey = "stItemListListKey0123"
let selectedLabelKey = "selectedLabelKey0123"

extension UIColor {
  struct MyTheme {
    static var firstColor: UIColor  { return UIColor(red: 1, green: 0, blue: 0, alpha: 1) }
    static var secondColor: UIColor { return UIColor(red: 0, green: 1, blue: 0, alpha: 1) }
  }
}

class ViewController5: UIViewController, UIScrollViewDelegate, GADBannerViewDelegate {
    
    
    @IBOutlet weak var barItemFolder: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView! // ヘッダーメニュー用ScrollView
    
    @IBOutlet weak var listScrollView: UIScrollView! // メインリスト用ScrollView
    
    @IBOutlet weak var addButton: UIButton! // リストセル追加ボタン
    
    @IBOutlet weak var trashButton: UIButton! // リストセル削除ボタン
    
    @IBOutlet weak var cellCountLabel: UILabel! // 登録数ラベル
    
    
    //残件
    //・VC6でスワイプダウンしたときに、VC5に反映されない問題
    //　→スワイプダウン禁止で対応する？
    
    
    
    
    // AdMobバナー
    var bannerView: GADBannerView!
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    // scrollViewのタブの横幅
    let tabLabelWidth: CGFloat = 130
    
    var groupList: [GroupList] = [] // [グループID, グループ名]
    var stItemList: [ItemList] = [] // [tag, [itemList]]：リストのタグ、チェックマーク、データ
    // itemList[i].checkLfg → false:チェックなし/true:チェックあり
    //var itemList: [String] = [] // [ToDo項目]
    
    //var mainColor: UIColor = UIColor(red: 102/255, green: 179/255, blue: 255/255, alpha: 1.0)
    var textColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    
    
    var selectedLabelTag: Int = 0 // 選択中のラベルのタグ（選択が切り替わるたびに更新,UserDefaultsに保存）
    
    // テーブルごとのセルのチェック有無を記録する構造体（配列で使用）
    struct CheckList: Codable {
        var itemListKey: Int
        var checkFlg: [Bool]
     
        init(itemListKey: Int, checkFlg: [Bool]) {
            self.itemListKey = itemListKey
            self.checkFlg = checkFlg
        }
    }
    
    var checkList: [CheckList] = []
    let checkListKey = "checkListKey0123" // キー
    
    // listScrollViewの枠の一番下のy座標
    var listScrollViewMax_y: CGFloat = 0
    
    // viewが表示される度に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppearが呼ばれた！！")
        
        // タブの有効化
        let tagetTabBar = 0 //タブの番号
        self.tabBarController!.tabBar.items![tagetTabBar].isEnabled = true // タブの有効化
        
        
        // GroupList再読み込み
        reloadGroupList()
        print("groupList = \(groupList)")
        
        initReadUserDefaults() // userDefaultsに保存されたデータの取得
        
        showTabs() // メニュータブ更新
        showList() // リスト更新
        updateList() // // リストの表示更新
        
        // 画面遷移後、選択したメニューにフォーカス
        // selectedLabelTag取得
        selectedLabelTag = loadSelectedLabelTag()
        
        // 取得したselectedLabelTagはgroupListに登録されているかチェック
        var checkFlg: Bool = false
        for_checkTag:for i in 0..<groupList.count {
            if selectedLabelTag == groupList[i].ID {
                checkFlg = true
                break for_checkTag
            }
        }
        
        print("groupList = \(groupList)")
        
        // selectedLabelTagの取得に失敗した場合(selectedLabelTag = 0)、
        // またはgroupListに登録されていない場合(checkFlg = false)、
        // groupListの最初のIDを代わりに格納
        if selectedLabelTag == 0 || checkFlg == false {
            selectedLabelTag = groupList[0].ID
            // 保存
            UserDefaults.standard.set(selectedLabelTag, forKey: selectedLabelKey)
        }
        
        print("取得したselectedLabelTag = \(selectedLabelTag)")
        
        viewAnimate(selectedLabelTag: selectedLabelTag) // 選択されたメニューラベルにフォーカス
        
        // 表示更新
        if let tableView = getSubTableView(selectedLabelTag: selectedLabelTag) {
            tableView.reloadData() // 表示更新
        }
        
        // 登録数（セル数）の表示更新
        reloadCellCountLabel()
        
        // groupListのデータ有無チェック（ボタン表示/非表示）
        groupListDataExistCheck()
        
    }
    
//    //
//    override func viewDidAppear(_ animated: Bool) {
//        print("viewDidAppearが呼ばれた！！")
//        viewAnimate(selectedLabelTag: selectedLabelTag) // 選択されたメニューラベルにフォーカス
//
//        // 表示更新
//        if let tableView = getSubTableView(selectedLabelTag: selectedLabelTag) {
//            tableView.reloadData() // 表示更新
//        }
//
//        // 登録数（セル数）の表示更新
//        reloadCellCountLabel()
//
//        // groupListのデータ有無チェック（ボタン表示/非表示）
//        groupListDataExistCheck()
//    }
//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iOS15対応
        // UITabBarの色　デフォルト：無色 → 白色に指定
        // うまくいかないのでストーリーボードで設定
        
        // UINavigationBarの色　デフォルト：無色 → 白色に指定
        let appearance2 = UINavigationBarAppearance()
        appearance2.configureWithOpaqueBackground()
        appearance2.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance2
        navigationController?.navigationBar.scrollEdgeAppearance = appearance2
        
        
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
//        let screenHeight:CGFloat = self.view.frame.height
        
        barItemFolder.tintColor = mainColor
        
        
        
        // ■■ AdMobバナー ■■
        let adSize = GADAdSizeFromCGSize(CGSize(width: screenWidth, height: screenWidth*50/320))
        bannerView = GADBannerView(adSize: adSize)
        //bannerView.adUnitID = "ca-app-pub-8819499017949234/2255414473" //本番ID
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //サンプルID
        bannerView.adUnitID = admobId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        
        
        subColor = UIColor(red: 220/255, green: 255/255, blue: 240/255, alpha: 1)
        mainColor = UIColor(red: 21/255, green: 180/255, blue: 140/255, alpha: 1)
        
        // userDefaults全削除（開発用）
        //removeUserDefaults()
        
        self.view.backgroundColor = .systemGray6
        
//        // リストセル追加ボタン設定
//        // 角丸
//        addButton.layer.cornerRadius = addButton.frame.width / 2
//        //addButton.clipsToBounds = true // 枠外はみ出し表示不可
//        // 色
//        addButton.backgroundColor = mainColor
//        // 影
//        addButton.layer.shadowOffset = CGSize(width: 0, height: 2 )  // 8
//        addButton.layer.shadowOpacity = 0.8  // 9
//        addButton.layer.shadowRadius = 2  // 10
//        addButton.layer.shadowColor = UIColor.gray.cgColor  // 11
//
//        // リストセル削除ボタン設定
//        // 角丸
//        trashButton.layer.cornerRadius = addButton.frame.width / 2
//        //trashButton.clipsToBounds = true // 枠外はみ出し表示不可
//        // 色
//        trashButton.backgroundColor = .white
//        // 枠線
//        trashButton.layer.borderWidth = 0.5 // 枠線の幅
//        trashButton.layer.borderColor = mainColor.cgColor
//        // 影
//        trashButton.layer.shadowOffset = CGSize(width: 0, height: 2 )  // 8
//        trashButton.layer.shadowOpacity = 0.8  // 9
//        trashButton.layer.shadowRadius = 2  // 10
//        trashButton.layer.shadowColor = UIColor.gray.cgColor  // 11
//
//        // 削除ボタンにイメージ追加
//        let picture = UIImage(named: "ゴミ箱_緑_21_196_161.001")
//        self.trashButton.setImage(picture, for: .normal)
        
        
        
        //scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false // スクロールバー非表示
        //scrollView.delegate = self
        
        scrollView.backgroundColor = .white
        
        // タップ認識するためのインスタンスを生成
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        // Viewに追加
        view.addGestureRecognizer(tapGesture)
        
        
        //-- userDefaultsに保存されたデータの取得
        initReadUserDefaults()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //※※※※※※※※※※※※※※※※※※※※※※
    //・groupListデータなし（ボタン非表示）→グループ追加→画面戻ってもボタン非表示
    //　→groupList再読み込みしない、タブ選択もなし、画面更新なし　のため
    //◯VC6→VC5画面戻った再、画面更新なし、データ再読み込みもなし
    //　→dissmiss前に処理or画面表示前に処理が必要
    //　→OK
    //・余計なデータがUserDefaultsに残っている？一度すべて削除しても良さそう
    //
    //
    //
    //※※※※※※※※※※※※※※※※※※※※※※
    
    // userDefaultsに保存されたデータの取得
    func initReadUserDefaults() {
        print("UserDefaults読み込み")
        // groupList読み込み
        groupList.removeAll()
        if let groupIDListTmp = loadGroupList() {
            // 保存データが存在する場合
            groupList.append(contentsOf: groupIDListTmp)
            print("groupList取得")
        }
        
        // データが無い場合
        if groupList.count == 0 {
            // nilの場合（保存データが存在しない場合）
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "yyyyMMddHHmmss"
            // グループIDを発行
            let groupID: Int = Int( df.string(from: date))!
            print("groupID = \(groupID)")
            groupList.append(GroupList(ID: groupID, name: "グループ1"))
            
            // groupListを保存
            saveGroupList(groupList: groupList)
        }
        
        print("groupList = \(groupList)")
        
        // stItemList再取得
        print("stItemList = \(stItemList)")
        stItemList.removeAll()
        if let stItemListTmp = loadStItemList() {
            // 保存データが存在する場合
            stItemList.append(contentsOf: stItemListTmp)
            print("stItemList取得")
        } else {
            print("stItemList取得失敗")
            stItemList = []
        }
        print("stItemList = \(stItemList)")
        
        // stItemList読み込みと整理
        // groupListが持つIDが、stItemListが持つitemListKeyに保存されているかチェック
        var addIDTmp: [Int] = [] // 追加するIDを仮で保持
        for i in 0..<groupList.count {
            // stItemListに登録のあるIDかどうかチェック
            let ID: Int = groupList[i].ID
            var checkIDFlg: Bool = false
            for_checkIDFlg: for j in 0..<stItemList.count {
                if stItemList[j].itemListKey == ID {
                    // IDが保存されている場合
                    checkIDFlg = true
                    break for_checkIDFlg
                }
            }
            
            if checkIDFlg == false {
                // IDが保存されていない場合
                // 新規に追加されたIDなので、stItemListにも追加するために仮で保持
                print("IDが新規追加されたので、stItemListにも追加")
                addIDTmp.append(ID)
                
            }
        }
        
        // 新規に追加されたID分の要素をstItemListに追加
        for i in 0..<addIDTmp.count {
            //stItemList.append(ItemList(itemListKey: addIDTmp[i], itemList: [""]))
            let cellItem: [CellItem] = [CellItem(checkLfg: false, text: "")]
            stItemList.append(ItemList(itemListKey: addIDTmp[i], itemList: cellItem))
        }
        
        // 逆パターンのチェック
        // stItemListが持つitemListKeyが、groupListが持つIDに保存されているかチェック
        var deleteElementNumber: [Int] = [] // 削除するKeyを仮で保持
        for i in 0..<stItemList.count {
            // stItemListに登録のあるIDかどうかチェック
            let itemListKey: Int = stItemList[i].itemListKey
            var checkKeyFlg: Bool = false
            for_checkKeyFlg: for j in 0..<groupList.count {
                if groupList[j].ID == itemListKey {
                    // itemListKeyがgroupListに存在する場合
                    checkKeyFlg = true
                    break for_checkKeyFlg
                }
            }
            
            if checkKeyFlg == false {
                // itemListKeyがgroupListに存在しない場合
                // groupListから削除されているので、stItemListからも削除する
                print("groupListから削除されたIDなので、stItemListからも削除")
                deleteElementNumber.append(i)
            }
        }
        
        // 要素削除（逆順forループ）
        for i in (0..<deleteElementNumber.count).reversed() {
            stItemList.remove(at: deleteElementNumber[i])
        }
        
        print("stItemList = \(stItemList)")
        // 保存
        saveStItemList(stItemList: stItemList)
        
        // selectedLabelTag取得
        selectedLabelTag = loadSelectedLabelTag()
        
        // selectedLabelTagの取得に失敗した場合、groupListの最初のIDを代わりに格納
        if selectedLabelTag == 0 {
            selectedLabelTag = groupList[0].ID
        }
        print("取得したselectedLabelTag = \(selectedLabelTag)")
    }
    
    // userDefaults全削除
    func removeUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
    }
    
    // キーボードと閉じる際の処理
    @objc public func dismissKeyboard() {
        print("キーボードを閉じるA")
        view.endEditing(true)
    }
    
    // groupList再取得
    func reloadGroupList() {
        // userDefaultsに保存された値の取得
        groupList.removeAll()
        if let groupIDListTmp = loadGroupList() {
            groupList.append(contentsOf: groupIDListTmp)
        }
        
        // データが無い場合
        if groupList.count == 0 {
            // nilの場合（保存データが存在しない場合）
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "yyyyMMddHHmmss"
            // グループIDを発行
            let groupID: Int = Int( df.string(from: date))!
            print("groupID = \(groupID)")
            groupList.append(GroupList(ID: groupID, name: "グループ1"))
            
            // groupListを保存
            saveGroupList(groupList: groupList)
        }
        print("groupList再読み込み")
        print("groupList = \(groupList)")
    }
    
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
    
    
    // 保存([stItemList])
    func saveStItemList(stItemList: [ItemList]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(stItemList) else {
            return
        }
        UserDefaults.standard.set(data, forKey: stItemListKey)
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
    
    // 保存（selectedLabelTag）
    
    
    // 取得（selectedLabelTag）
    func loadSelectedLabelTag() -> Int {
        var selectedLabelTag = 0
        if UserDefaults.standard.integer(forKey: selectedLabelKey) != nil {
            selectedLabelTag = UserDefaults.standard.integer(forKey: selectedLabelKey)
        }
        return selectedLabelTag // 0：取得失敗、その他のInt：保存済みのタグ番号を返す
    }
    
    
    // textField以外をタップで閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("キーボードを閉じるA")
        view.endEditing(true)
    }

    
    
    // -----------------------
    // scrollView処理
    // -----------------------

    // レイアウトサイズ決定後の処理
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews()が呼ばれた！")
        
        // ボタン表示設定
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        // listScrollViewの枠の一番下のy座標を記録
        listScrollViewMax_y = listScrollView.frame.origin.y + listScrollView.frame.height
        
        print("listScrollView.frame = \(listScrollView.frame)")
        print("listScrollViewMax_y = \(listScrollViewMax_y)")
        
        let addbuttonWidth: CGFloat = screenHeight * 42/896 + 20
        if listScrollViewMax_y > 0 {
            addButton.frame = CGRect(x:screenWidth * 310/414, y:listScrollViewMax_y + screenHeight * 10/896, width:addbuttonWidth, height:addbuttonWidth)
            trashButton.frame = CGRect(x:screenWidth * 104/414 - addbuttonWidth, y:listScrollViewMax_y + screenHeight * 10/896, width:addbuttonWidth, height:addbuttonWidth)
        }
        
        // リストセル追加ボタン設定
        // 角丸
        //addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.layer.cornerRadius = addbuttonWidth / 2
        //addButton.clipsToBounds = true // 枠外はみ出し表示不可
        // 色
        addButton.backgroundColor = mainColor
        // 影
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2 )  // 8
        addButton.layer.shadowOpacity = 0.8  // 9
        addButton.layer.shadowRadius = 2  // 10
        addButton.layer.shadowColor = UIColor.gray.cgColor  // 11
        
        // リストセル削除ボタン設定
        // 角丸
        //trashButton.layer.cornerRadius = trashButton.frame.width / 2
        trashButton.layer.cornerRadius = addbuttonWidth / 2
        //trashButton.clipsToBounds = true // 枠外はみ出し表示不可
        // 色
        trashButton.backgroundColor = .white
        // 枠線
        trashButton.layer.borderWidth = 0.5 // 枠線の幅
        trashButton.layer.borderColor = mainColor.cgColor
        // 影
        trashButton.layer.shadowOffset = CGSize(width: 0, height: 2 )  // 8
        trashButton.layer.shadowOpacity = 0.8  // 9
        trashButton.layer.shadowRadius = 2  // 10
        trashButton.layer.shadowColor = UIColor.gray.cgColor  // 11
        
        // 削除ボタンにイメージ追加
        let picture = UIImage(named: "ゴミ箱_緑_21_196_161.001")
        self.trashButton.setImage(picture, for: .normal)
        
        
        
        // GroupList再読み込み
        reloadGroupList()
        // タブ表示
        showTabs()
        // リスト表示
        showList()
        
        
        // 保存されたselectedLabelTagを取得
        selectedLabelTag = loadSelectedLabelTag()
        
        // selectedLabelTagの取得に失敗した場合、groupListの最初のIDを代わりに格納
        if selectedLabelTag == 0 {
            selectedLabelTag = groupList[0].ID
        }
        print("取得したselectedLabelTag = \(selectedLabelTag)")
        
        // 選択されたラベルにフォーカスして移動する & 選択されたラベルに対応したリストを表示する
        viewAnimate(selectedLabelTag: selectedLabelTag)
        
        // リストセル追加ボタンを最前面に表示
        self.view.bringSubviewToFront(addButton)
        
        // 登録数（セル数）の表示更新
        reloadCellCountLabel()
        
        groupListDataExistCheck()
    }
    
    // subView削除
    func removeAllSubviews(parentView: UIView){
        let subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    // タブにgroupListを表示（内容更新）
    func showTabs() {
        print("ヘッダーメニュー表示")
        // scrollViewのsubView削除(画面遷移で戻ってくるときに削除)
        removeAllSubviews(parentView: scrollView)
        
        //scrollViewのDelegateを指定
        scrollView.delegate = self

        scrollView.isUserInteractionEnabled = true
        //scrollView.backgroundColor = UIColor.systemGray3

        //タブの縦幅(UIScrollViewと同じ)
        let tabLabelHeight:CGFloat = scrollView.frame.height

        var originX:CGFloat = scrollView.frame.minX
        //groupListをタブに表示
        for i in 0..<groupList.count {
            //タブになるUILabelを作る
            let label = UILabel()
            label.textAlignment = .center
            label.numberOfLines = 0 // 複数行表示
            label.frame = CGRect(x:originX, y:0, width:tabLabelWidth, height:tabLabelHeight)
            label.text = groupList[i].name

            // ラベルのタップ受付
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController5.labelTapped(_:))))
            
            // タグ付け
            label.tag = groupList[i].ID
            
            print("label.tag = \(label.tag)")
            
            //label.backgroundColor = UIColor.systemBlue
            
            // scrollViewに貼り付け
            scrollView.addSubview(label)

            //次のタブのx座標を用意する
            originX += tabLabelWidth
        }
        //scrollViewのcontentSizeを，タブ全体のサイズに合わせる
        //最終的なoriginX = タブ全体の横幅
        scrollView.contentSize = CGSize(width:originX, height:tabLabelHeight)
    }
    
    // リスト表示
    func showList() {
        print("リスト表示")
        print("groupList = \(groupList)")
        
        // listScrollViewのsubView削除(画面遷移で戻ってくるときに削除)
        removeAllSubviews(parentView: listScrollView)
        
        //-- リスト用scrollViewの設定 --
        listScrollView.isUserInteractionEnabled = true
        listScrollView.backgroundColor = UIColor.systemGray6
        listScrollView.delegate = self //scrollViewのDelegateを指定
        listScrollView.isPagingEnabled = true // メニュー単位のスクロールを可能にする
        listScrollView.showsHorizontalScrollIndicator = false // 水平方向のスクロールインジケータを非表示にする
        
        
        let tableViewWidth: CGFloat = listScrollView.frame.width * 0.9
        let tableViewHeight: CGFloat = listScrollView.frame.height
        let deltaX: CGFloat = listScrollView.frame.width * 0.1 / 2
        var listOriginX: CGFloat = listScrollView.frame.minX + deltaX
        
        
        
        
        //groupListで定義したタブを1つずつ用意していく
        for i in 0..<groupList.count {
        
            // tableViewの設定
            var tableView = UITableView() // 後から変更可能
            
            tableView.estimatedRowHeight = 44 // セル高さ(テキトーな値)
            tableView.rowHeight = UITableView.automaticDimension // セル高さ自動調整
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
            
            
            // キーボードを閉じる設定
            // UISTableView のドラッグ開始時にキーボードを閉じる
            tableView.keyboardDismissMode = .onDrag
            
            // UISTableView を下方向ドラッグで上にスクロールするのに合わせてキーボードを閉じる
            tableView.keyboardDismissMode = .interactive
            
            
            // 複数選択を可能にする(true: 複数選択可能/false:単一選択)
            tableView.allowsMultipleSelectionDuringEditing = true
            
            
            // 角丸
            tableView.layer.cornerRadius = 10.0
            tableView.clipsToBounds = true
            
            
            tableView.frame = CGRect(x:listOriginX, y:0, width:tableViewWidth, height:tableViewHeight)

            // ラベルのタップ受付
            tableView.isUserInteractionEnabled = true
            tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController5.tableViewTapped(_:))))
            
            
            tableView.tableFooterView = UIView() // 空白行の罫線なし
            
            
            tableView.isEditing = true // tableView編集モード有効化（ソート用）
            //tableView.allowsSelectionDuringEditing = true // Cellのタップ選択許可
            tableView.allowsSelectionDuringEditing = false
            
            // tableViewのinsetをゼロにする
            //tableView.separatorInset = UIEdgeInsets.zero
            
//            // sectionヘッダーの高さ
//            tableView.sectionHeaderHeight = 100
            
            // tableViewのセルの縦幅
            let cellHight: CGFloat = screenHeight * 45 / 896
            if cellHight > 45 {
                tableView.rowHeight = cellHight
            } else {
                tableView.rowHeight = 45
            }
            
            
            // タグ付け
            tableView.tag = groupList[i].ID
            
            print("tableView.tag = \(tableView.tag)")
            
            listScrollView.addSubview(tableView)
            
            
            // 次のtableViewのx座標を用意
            listOriginX += listScrollView.frame.width
            
        }
        
        //scrollViewのcontentSizeを，タブ全体のサイズに合わせる
        //最終的なoriginX = タブ全体の横幅
        listScrollView.contentSize = CGSize(width:listOriginX, height:tableViewHeight)
        print("listScrollView.contentSize.width = \(listScrollView.contentSize.width)")
    }
    
    // リストの表示内容更新
    func updateList() {
        // scrollView内のsubView検索
        for_searchSubView: for subView in self.listScrollView.subviews {
            if let tableView = subView as? UITableView {
                // tableViewの場合
                if tableView.tag == selectedLabelTag {
                    // 選択中（表示中）のtableViewのタグの場合
                    print("tableViewのリストの表示更新")
                    tableView.reloadData() // 表示更新
                    break for_searchSubView
                }
            }
        }
    }
    
    // groupListのデータ有無チェック（ボタン表示/非表示）
    func groupListDataExistCheck() {
        if groupList.count == 0 {
            // groupListにデータが無い場合
            addButton.isHidden = true // 非表示
            trashButton.isHidden = true // 非表示
        } else {
            // groupListにデータがある場合
            addButton.isHidden = false // 表示
            trashButton.isHidden = false // 非表示
        }
    }
    
    // 登録数（セル数）の表示更新
    func reloadCellCountLabel() {
        if groupList.count == 0 {
            // groupListにデータが無い場合
            cellCountLabel.text = "グループを追加してください。"
            return
        }
        
        
        var count: Int = 0
        for_searchKey: for i in 0..<stItemList.count {
            if stItemList[i].itemListKey == selectedLabelTag {
                for j in 0..<stItemList[i].itemList.count {
                    if stItemList[i].itemList[j].text != "" && stItemList[i].itemList[j].checkLfg != true {
                        // テキスト=""以外、かつ、チェックフラグ=false以外の場合
                        print("text = \(stItemList[i].itemList[j].text)")
                        print("checkLfg = \(stItemList[i].itemList[j].checkLfg)")
                        count += 1
                        print("count = \(count)")
                    }
                }
                break for_searchKey
            }
        }
        cellCountLabel.text = "登録数  " + String(count) + "人"
    }
    
    
    // リストセル追加ボタンタップ時の処理
    @IBAction func addButtonTapped(_ sender: Any) {
        print("追加ボタンタップ！")
        print("selectedLabelTag = \(selectedLabelTag)")
        print("stItemList = \(stItemList)")
        
        print("キーボードを閉じるB")
        view.endEditing(true)
        
        
        // 空白セル追加
        for_searchKey:for i in 0..<stItemList.count {
            if stItemList[i].itemListKey == selectedLabelTag {
                // 登録済みのKeyの場合
                // 空セルを追加
                //stItemList[i].itemList.append("")
                let cellItem: CellItem = CellItem(checkLfg: false, text: "")
                stItemList[i].itemList.append(cellItem)
                
                break for_searchKey
            } else {
                // 登録されていないKeyの場合
                // 何もしない
            }
        }
        
        
        print("stItemList = \(stItemList)")
        
        
        // 以下、サンプル
        // 表示更新
        if let tableView = getSubTableView(selectedLabelTag: selectedLabelTag) {
            tableView.reloadData() // 表示更新
        }
        
        // 保存
        saveStItemList(stItemList: stItemList)
        
        // 登録数（セル数）の表示更新
        reloadCellCountLabel()
    }
    
    // リストセル削除ボタンタップ時の処理
    @IBAction func trashButtonTapped(_ sender: Any) {
        // チェックマークのついたセルを削除
        print("削除ボタンタップ！")
        print("selectedLabelTag = \(selectedLabelTag)")
        print("stItemList = \(stItemList)")
        
        print("キーボードを閉じるB")
        view.endEditing(true)
        
        // セル削除
        for i in 0..<stItemList.count {
            if stItemList[i].itemListKey == selectedLabelTag {
                // 登録済みのKeyの場合
                // itemList内検索（逆順forループ）
                for j in (0..<stItemList[i].itemList.count).reversed() {
                    if stItemList[i].itemList[j].checkLfg == true {
                        // チェックフラグが立っている場合
                        // グループリストから削除
                        stItemList[i].itemList.remove(at: j)
                    }
                }
                print("stItemList[i].itemList = \(stItemList[i].itemList)")
                
                // 削除した結果、要素数が0となった場合
                if stItemList[i].itemList.count == 0 {
                    // データが存在しない場合、空セル追加
                    stItemList[i].itemList.append(CellItem(checkLfg: false, text: ""))
                    print("空セル追加")
                    print("stItemList[i].itemList = \(stItemList[i].itemList)")
                }
                
            } else {
                // 登録されていないKeyの場合
                // 何もしない
            }
        }
        
        
        
        print("stItemList = \(stItemList)")
        
        // ここから
        // 表示更新
        if let tableView = getSubTableView(selectedLabelTag: selectedLabelTag) {
            tableView.reloadData() // 表示更新
        }
        
        // 保存
        saveStItemList(stItemList: stItemList)
        
        // 登録数（セル数）の表示更新
        reloadCellCountLabel()
    }
    
    // listScrollView上のtableViewの表示更新
    func getSubTableView(selectedLabelTag: Int) -> UITableView? {
        var tableView: UITableView? = nil
        // すべてのsubViewを検索
        for_reloadData: for subView in self.listScrollView.subviews {
            // tableViewの場合
            if let tableViewTmp = subView as? UITableView {
                // タグ判定
                if tableViewTmp.tag == selectedLabelTag {
                    tableView = tableViewTmp
                    break for_reloadData
                }
            }
        }
        
        return tableView
    }
    
    
    
    // labelタップイベント
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        print("メニューラベルタップ!!!")
        
        print("キーボードを閉じるC")
        view.endEditing(true)
        
        // タップしたsubViewのタグ取得
        let index = sender.view?.tag
        // labelタグを記録
        selectedLabelTag = index!
        
        
        print("タップされたラベルのタグ：selectedLabelTag = \(selectedLabelTag)")
//        print("tableTag = \(tableTag)")
        
        
        
        
//        if (self.view.viewWithTag(selectedLabelTag) as? UITableView) != nil {
//            print("tableView_tmpを取得できた！") // 取得できない
//        }
        
        // 選択されたラベルにフォーカスして移動する & 選択されたラベルに対応したリストを表示する
        viewAnimate(selectedLabelTag: selectedLabelTag)
        
        // 選択されたラベルのタグを保存
        UserDefaults.standard.set(selectedLabelTag, forKey: selectedLabelKey)
        
        // 登録数（セル数）の表示更新
        reloadCellCountLabel()
    }
    
    // 選択されたラベルにフォーカスして移動する & 選択されたラベルに対応したリストを表示する
    func viewAnimate(selectedLabelTag: Int) {
        print("selectedLabelTag = \(selectedLabelTag)")
        // すべてのsubViewを検索
        for subView in self.scrollView.subviews {
            // ラベルの場合
            if let label = subView as? UILabel {
                print("labelがタップされた！")
                // タップされたtagがのlabelであるかどうか判定
                //if label.tag == sender.view?.tag {
                if label.tag == selectedLabelTag {
                    print("タップされたlabelの場合、色付けする")
                    // タップされたlabelの場合
                    label.textColor = textColor
                    label.backgroundColor = mainColor
                    
                    // 選択されたラベルのタグに等しいキーが、配列の何番目かを取得
                    var listViewcount: Int = 0
                    for_getListCount : for i in 0..<groupList.count {
                        if groupList[i].ID == selectedLabelTag {
                            listViewcount = i
                            break for_getListCount
                        }
                    }
                    print("listViewcount = \(listViewcount)")
                    
                    // ラベルスクロール
                    labelScroll(listViewcount: listViewcount)
                    
                    // タップしたラベルに対応したリストを表示する
                    let listX: CGFloat = CGFloat(listViewcount) * listScrollView.frame.width
                    UIView.animate(withDuration: 0.3, animations: {
                        self.listScrollView.contentOffset = CGPoint(x:listX, y:0)
                    })
                    print("表示するリストのタグと位置")
                    print("groupList = \(groupList)")
                    print("listViewcount = \(listViewcount)")
                    print("listX = \(listX)")
                    
                } else {
                    print("タップされていないラベルの場合、色付けを解除する")
                    // その他のlabelの場合
                    label.textColor = .black
                    label.backgroundColor = .clear
                }
            }
        }
    }
    
    // ラベルスクロール(listViewcount:配列の何番目か)
    func labelScroll(listViewcount: Int) {
        // タップしたラベルを移動する
        if scrollView.contentSize.width > scrollView.frame.width {
            // contentsViewの横幅 > scrollViewの横幅の場合
            if tabLabelWidth * ( CGFloat(listViewcount) + 0.5) > scrollView.frame.width / 2 {
                // contentsViewの左端〜タップしたラベルの中心 > scrollViewの横幅の半分の場合
                if tabLabelWidth * ( CGFloat(groupList.count - listViewcount) - 0.5) > scrollView.frame.width / 2 {
                    // タップしたラベルの中心〜contentsViewの右端 > scrollViewの横幅の半分の場合
                    // タップしたラベルを中央に持ってくる
                    let x: CGFloat = CGFloat(listViewcount) * tabLabelWidth // ラベルのx座標
                    let movedX: CGFloat = x - (scrollView.frame.width - tabLabelWidth) / 2 // 移動後のx座標
                    UIView.animate(withDuration: 0.3, animations: {
                        self.scrollView.contentOffset = CGPoint(x:movedX, y:0)
                    })
                } else if tabLabelWidth * ( CGFloat(groupList.count - listViewcount) - 0.5) < scrollView.frame.width / 2 {
                    // タップしたラベルの中心〜contentsViewの右端 < scrollViewの横幅の半分の場合
                    let movedX: CGFloat =  scrollView.contentSize.width - scrollView.frame.width // 移動後のx座標
                    UIView.animate(withDuration: 0.3, animations: {
                        self.scrollView.contentOffset = CGPoint(x:movedX, y:0)
                    })
                }
            } else if tabLabelWidth * ( CGFloat(listViewcount) + 0.5) < scrollView.frame.width / 2 {
                // contentsViewの左端〜タップしたラベルの中心 < scrollViewの横幅の半分の場合
                // 初期位置に戻す
                let movedX: CGFloat = 0 // 移動後のx座標
                //let movedX: CGFloat = x - (scrollView.frame.width - tabLabelWidth) / 2 // 移動後のx座標
                UIView.animate(withDuration: 0.3, animations: {
                    self.scrollView.contentOffset = CGPoint(x:movedX, y:0)
                })
            }
        }
    }
    
    // listScrollView(メインのToDoリスト)横スクロール時の処理(ヘッダーメニューを移動する)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        print("スクロールストップ")
        
        if scrollView == listScrollView {
            print("listScrollViewスクロールストップ")
            print("scrollView.tag = \(scrollView.tag)")
            print("listScrollView.tag = \(listScrollView.tag)")
            
            // スクロール後のx座標取得
            let listX: CGFloat = self.listScrollView.contentOffset.x
            // スクロール後の表示中のlistScrollViewの番号取得（0,1,2,...）
            let listViewcountTmp: Int = Int(listX / listScrollView.frame.width)
            print("listX = \(listX)")
            print("listViewcountTmp = \(listViewcountTmp)")
            
            // 表示中のsubViewのタグを記録
            selectedLabelTag = groupList[listViewcountTmp].ID
            print("selectedLabelTag = \(selectedLabelTag)")
            
            // すべてのsubViewを検索
            for subView in self.scrollView.subviews {
                // ラベルの場合
                if let label = subView as? UILabel {
                    if label.tag == selectedLabelTag {
                        // タップされたlabelの場合
                        label.textColor = textColor
                        label.backgroundColor = mainColor
                        // ラベルスクロール
                        labelScroll(listViewcount: listViewcountTmp)
                    } else {
                        // その他のlabelの場合
                        label.textColor = .black
                        label.backgroundColor = .clear
                    }
                }
            }
        }
        
        print("selectedLabelTag = \(selectedLabelTag)")
        // 表示されたラベルのタグを保存
        UserDefaults.standard.set(selectedLabelTag, forKey: selectedLabelKey)
        
        // 登録数（セル数）の表示更新
        reloadCellCountLabel()
    }
    
    
    
    // tableViewタップイベント
    @objc func tableViewTapped(_ sender: UITapGestureRecognizer) {
        print("tableViewタップ！")
        
        // タップしたsubViewのタグ取得
        let index = sender.view?.tag
        // labelタグを記録
        selectedLabelTag = index!
        
        print("タップされたtableViewのタグ：selectedLabelTag = \(selectedLabelTag)")
    }
    
    
    // 画面遷移
    @IBAction func toManagementVC(_ sender: Any) {
        performSegue(withIdentifier: "toGroupListVC", sender: nil)
    }
    
    // VC6→C5へ戻る際の処理
    @IBAction func backToVC5(segue: UIStoryboardSegue) {
        print("VC6→C5へ戻る")
//        // 画面更新
//        viewDidLayoutSubviews()
        
        //
        self.viewWillAppear(true)
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

extension ViewController5: UITableViewDelegate, UITableViewDataSource, ItemDelegate {
    
    // -----------------------
    // tableView処理
    // -----------------------
//    // Section数
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
     
//    // Sectionのタイトル
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return ""
//    }
    // Section数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var itemCount: Int = 1
        for_getCellCount: for i in 0..<stItemList.count {
            if tableView.tag == stItemList[i].itemListKey {
                // tableViewのタグが保存データに存在する場合
                print("セル数")
                print("tableView.tag = \(tableView.tag)")
                itemCount = stItemList[i].itemList.count
                break for_getCellCount
            }
        }
        print("itemCount = \(itemCount)")
        return itemCount
    }

    // セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath ) as! ItemCell
        
        print("セルの内容")
        print("tableView.tag = \(tableView.tag)")
        print("stItemList = \(stItemList)")
        
        var getCellDataFlg: Bool = false
        
        var itemList: [CellItem] = [] // [checkLfg, text]
        for_getCellData: for i in 0..<stItemList.count {
            if tableView.tag == stItemList[i].itemListKey {
                // tableViewのタグが保存データに存在する場合
                print("セルデータ取得")
                print("tableView.tag = \(tableView.tag)")
                // セルごとのチェックフラグとテキストを格納
                itemList = stItemList[i].itemList
                
                getCellDataFlg = true
                break for_getCellData
            }
        }
        
        if getCellDataFlg == false {
            // データが存在しない場合、空セル追加
            itemList.append(CellItem(checkLfg: false, text: ""))
            // 保存
            stItemList.append(ItemList(itemListKey: tableView.tag, itemList: itemList))
            saveStItemList(stItemList: stItemList)
            print("タグ該当なしのため空セル追加&保存")
            print("stItemList = \(stItemList)")
        }
        
        print("itemList = \(itemList)")
        var flg:Bool = false
        var text: String = ""
        if itemList.count > 0 && itemList.count > indexPath.row {
            print("個別セルのチェックフラグとtext取得")
            flg = itemList[indexPath.row].checkLfg
            text = itemList[indexPath.row].text
        }
        print("flg = \(flg)")
        print("text = \(text)")
        cell.checkFlg = flg // セルのフラグを反映
        cell.setCell(text: text) // セルのテキストを入力
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
        print("セルを移動！！")
        // セルのテキストデータ移動
        for_sortData: for i in 0..<stItemList.count {
            if stItemList[i].itemListKey == tableView.tag {
                // 移動したセルのデータ取得
                let moveData = stItemList[i].itemList[sourceIndexPath.row]
                // 取得したデータを配列から削除
                stItemList[i].itemList.remove(at: sourceIndexPath.row)
                // 移動先の配列の位置にデータを挿入
                stItemList[i].itemList.insert(moveData, at:destinationIndexPath.row)
                // 保存
                print("stItemList = \(stItemList)")
                saveStItemList(stItemList: stItemList)
                
                break for_sortData
            }
        }
        
        //tableView.reloadData() // 表示更新
        
    }
    
    // セル編集可能
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セルを削除した時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        print("editingStyle = \(editingStyle)")
        // 削除可能かどうか判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // セルのテキストデータ削除
            for_deleteData: for i in 0..<stItemList.count {
                if stItemList[i].itemListKey == tableView.tag {
                    // グループリストから削除
                    stItemList[i].itemList.remove(at: indexPath.row)
                    // セルを削除
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                    // 保存
                    print("stItemList = \(stItemList)")
                    saveStItemList(stItemList: stItemList)
                    
                    break for_deleteData
                }
            }
        }
    }
    
    
//    // ↓ここから↓
//    // セルタップ時の処理
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // タップされたセルの行番号を出力
//        print("\(indexPath.row)番目の行が選択されました。")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath ) as! ItemCell
//        cell.textField.becomeFirstResponder() // セルのテキストフィールドでキーボードを表示
//    }
//
//    // 選択解除時のデリゲートメソッド
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        // 選択した解除した行番号が出力される
//        print(indexPath.row)
//    }
//    // ↑ここまで↑　呼ばれていない
    
    
    
//    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
//    }

    
    // tableViewの見た目設定
    // 左側の＋/ーの表示
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        print("tableView表示設定1")
        return .none // 表示しない
    }
    
    // 編集モード時、左側の＋/ーを表示にしてできたスペースを埋める
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        print("tableView表示設定2")
        return false // スペースを埋めるように左につめる
    }
    
    
    
    // デリゲートメソッド(完了タップ)
    func textFieldDidEndEditing(cell: ItemCell, value:String) {
        // 呼ばれていない！！？？
        print("デリゲートメソッド")
        print("selectedLabelTag = \(selectedLabelTag)")
        print("cell.cellRow = \(cell.cellRow)")
        //let tableView: UITableView = self.view.viewWithTag(selectedLabelTag) as! UITableView
//        var tableView = UITableView()
//        var getSubViewFlg: Bool = false // デリゲートを受け取るtableViewが存在するかどうかのフラグ
//        // ※※※この処理は必要？
//        for_getTableView: for subView in self.listScrollView.subviews {
//            if (subView.viewWithTag(selectedLabelTag) as? UITableView) != nil {
//                tableView = subView.viewWithTag(selectedLabelTag) as! UITableView
//                getSubViewFlg = true
//                print("getSubViewFlg = \(getSubViewFlg)")
//                break for_getTableView
//            }
//        }
//
//        guard getSubViewFlg == true else {
//            // tableViewが存在しない
//            print("デリゲートを受け取るtableViewが存在しないので、何もせずに処理終了")
//            return
//        }
//        print("デリゲートを受け取るtableViewが存在するので、表示更新と保存処理を実行")
        
        
        
        //変更されたセルのインデックスを取得
        //let tableView = UITableView()
        //let index = tableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to:tableView))
        // セルの行数を取得
        let index = cell.cellRow

        print("index = \(index)")
        
        // 表示中のtableViewのitemListを取得
        //var itemList: [String] = []
        for_setValue: for i in 0..<stItemList.count {
            if selectedLabelTag == stItemList[i].itemListKey {
                // tableViewのタグが保存データに存在する場合
//                print("セル表示")
//                print("tableView.tag = \(tableView.tag)")
                //itemList = stItemList[i].itemList
                
                //データを更新
                stItemList[i].itemList[index].text = value // 引数(cell入力文字列)を入力
                //stItemList[i].itemList[index!.row] = value
                
                
                print("stItemList[i].itemList.count = \(stItemList[i].itemList.count)")
                // 選択中のセルがtableViewの末尾のセルかどうか判定
                if index == stItemList[i].itemList.count - 1 {
                    // 選択中のセルが末尾の場合
                    if stItemList[i].itemList[index].text != "" {
                        // 末尾のセルが空欄でない場合、空セルを追加
                        let cellItem: CellItem = CellItem(checkLfg: false, text: "")
                        stItemList[i].itemList.append(cellItem)
                    }
                }
                
                break for_setValue
            } else {
                // データが存在しない場合
                // 何もしない
            }
        }
        
        print("更新後のデータ")
        print("index.row = \(index)")
        print("groupList = \(groupList)")
        print("stItemList = \(stItemList)")
        
        
        
        
        // 保存
        saveStItemList(stItemList: stItemList)
        print("stItemList = \(stItemList)")
        print("保存完了！")
        
//        // リスト表示更新
//        tableView.reloadData()
        
        // 表示更新
        if let tableView = getSubTableView(selectedLabelTag: selectedLabelTag) {
            tableView.reloadData() // 表示更新
        }
        
        // 登録数（セル数）の表示更新
        reloadCellCountLabel()
    }
    
    // デリゲートメソッド(チェックマークタップ)
    func cellTappedMarking(cell: ItemCell, checkFlg: Bool) {
        print("セルのチェックマークがタップされたデリゲート処理")
        print("cell.cellRow = \(cell.cellRow)")
        // セルの行数を取得
        let index = cell.cellRow
        print("index = \(index)")
        print("checkFlg = \(checkFlg)")
        
        for_itemCount: for i in 0..<stItemList.count {
            if selectedLabelTag == stItemList[i].itemListKey {
                // セルのチェックフラグ状態を保存用リストに追加
                stItemList[i].itemList[index].checkLfg = checkFlg
                break for_itemCount
            }
        }
        print("stItemList = \(stItemList)")
        
        // 保存
        saveStItemList(stItemList: stItemList)
        
        
        // 表示更新
        if let tableView = getSubTableView(selectedLabelTag: selectedLabelTag) {
            tableView.reloadData() // 表示更新
        }
        
        // 登録数（セル数）の表示更新
        reloadCellCountLabel()
    }
    
    
}


extension UIScrollView {
//    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.superview?.touchesBegan(touches, with: event)
//        print("touches began")
//    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        print("touches began")
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.touchesMoved(touches, with: event)
        print("touches moved")
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.touchesEnded(touches, with: event)
        print("touches ended")
    }
}
