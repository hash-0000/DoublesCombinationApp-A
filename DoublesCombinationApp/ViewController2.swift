//
//  ViewController2.swift
//  RandaomNumberPair_01
//
//  Created by Naoya on 2020/10/18.
//  Copyright © 2020 Kaede. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    // AdMobバナー
    var bannerView: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var startTimeLabel: UILabel! // 開始時刻
    
    @IBOutlet weak var numberOfParticipantsLabel: UILabel! // 参加人数
    
    // 対戦表/メンバー表切り替え用View
    @IBOutlet weak var containerView: UIView!
    weak var currentViewController: UIViewController?
    
    
    // 画面遷移で引数受付
    var argNum : String =  "4"      // 参加人数
    var numX : Int = 2              // コート数
    var startTime : String = "0時0分" // 開始時刻
//    // デフォルトColor
//    var mainColor = UIColor(red: 21/255, green: 196/255, blue: 161/255, alpha: 1)
//    var subColor = UIColor(red: 226/255, green: 247/255, blue: 239/255, alpha: 1)
    
    // 全体のメンバー数（削除された番号もカウント）:初回currentMembers + 追加数
    var totalMember: Int = 0
    
    var cellCheckFlg: [Int] = []  // 行のチェック有無Flag
    
    // 変数宣言
    var masterArray : [[Int]] = []  // マスター配列を宣言([番号, 選出回数])
    var pairArray : [[Int]] = []  // ペア配列を宣言([ペア1, ペア2, ペア選出回数])
    var pairArrayCount : Int = 0    // ペア配列要素数
    var previousPairArray : [[Int]] = []  // 前回値ペア配列を宣言
    var previousPairArrayCount : Int = 0    // 前回値ペア配列要素数
    var previousPairArray_temp : [[Int]] = []  // 前回値ペア配列の一時保管用配列を宣言
    var previousPairArrayCount_temp : Int = 0    // 前回値ペア配列一時保管用配列の要素数
    //var pairArray_temp : [[Int]] = []  // 作業用ペア配列を宣言
    var checkCountArray : [[Int]] = []  // チェック有の数を計上、集計画面へ渡す[参加メンバーのNo, チェック数]
    var pairArray_Low : [[Int]] = []    // 参加回数の少ないペア
    var pairArray_Mid : [[Int]] = []    // 参加回数の中間のペア
    var pairArray_High : [[Int]] = []    // 参加回数の多いペア
    var masterArray_Low : [Int] = []    // 参加回数の少ない人
    var masterArray_High : [Int] = []   // 参加回数の多い人
    var masterArray_Mid : [Int] = []   // 参加回数が中間の人
    var masterArray_LMH : [Int] = []   // 処理用
    var cellArray : [[String]] = [] {
        didSet {
            tableView?.reloadData()
            // リロード直後、セルの最下段をbottomに合わせて表示（自動スクロール）
            tableView.scrollToRow(at: IndexPath(row: cellArray.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
        }
    } // cell表示用配列を宣言
    // 横線の色
    let cellLineColor : [UIColor] = [UIColor.lightGray, UIColor.clear, UIColor.clear, UIColor.clear]
    // 回転数の枠線の色
    var tableViewLineColor : [UIColor] = [UIColor(red: 220/255, green: 240/255, blue: 180/255, alpha: 0.3), UIColor.clear, UIColor.clear, UIColor.clear]
    var initArray : [Int] = []      // 初回組み合わせ作成用配列を宣言
    var randomArray : [Int] = []    // 乱数作成作業用配列を宣言
    var tempArray : [String] = []   // temp配列
    var uniquecheckArray : [String] = []   // 重複回避用配列(最大：コート数×4)
    
    var alertController : UIAlertController!    // アラート表示
    
    //  チェックされたセルの位置を保存しておく辞書を宣言
    var selectedCells:[String:Bool]=[String:Bool]()
    
    // 初回セルデータ設定中の行数カウント用
    var initCellRowCount: Int = 1
    
    // 追加セルデータ設定中の行数カウント用
    var addCellRowCount: Int = 1
    
    var initialProcessFlg: Bool = true
    
    // 画面下のボタン
    @IBOutlet weak var addCellButton: UIButton!
    
    
    // tableViewのframe情報(初期値は仮)
    var table_x:CGFloat = 0
    var table_y:CGFloat = 44
    var table_width:CGFloat = 414
    var table_height:CGFloat = 320
//    // startTimeLabelのframe情報(初期値は仮)
//    var stLabel_x:CGFloat = 20
//    var stLabel_y:CGFloat = 686
//    var stLabel_width:CGFloat = 189
//    var stLabel_height:CGFloat = 30
//    // numberOfParticipantsLabelのframe情報(初期値は仮)
//    var nopLabel_x:CGFloat = 20
//    var nopLabel_y:CGFloat = 718
//    var nopLabel_width:CGFloat = 189
//    var nopLabel_height:CGFloat = 30
    
    
    
    
    // viewが表示される度に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        // タブの無効化
        let tagetTabBar = 0 //タブの番号
        self.tabBarController!.tabBar.items![tagetTabBar].isEnabled = false // タブの無効化
        
        // 参加人数を表示
        if totalMember > 0 {
            // 増減後の人数
            numberOfParticipantsLabel.text = "参加人数　" + String(totalMember) + " 人"
        } else {
            // 初期設定人数
            numberOfParticipantsLabel.text = "参加人数　" + String(argNum) + " 人"
        }
    }
    
    // レイアウトサイズ決定後の処理
    override func viewDidLayoutSubviews() {
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        
        
        // iPhone以外の場合
        if UIDevice.current.userInterfaceIdiom != .phone {
            //print("これはiPadです。")
            // containerView()のレイアウト調整
            let containerView_x = self.containerView.frame.origin.x
            let containerView_y = self.containerView.frame.origin.y
            let containerView_width = self.containerView.frame.width
            //let containerView_height = self.containerView.frame.height
            //AutoLayout解除
            self.containerView.translatesAutoresizingMaskIntoConstraints = true
            // currentViewControllerの高さ*0.8
            self.containerView.frame = CGRect(x: containerView_x, y: containerView_y,
                                              width: containerView_width,
                                              height: screenHeight * 0.74)
            
            // tableViewのレイアウト調整
            let tableView_x = self.tableView.frame.origin.x
            let tableView_y = self.tableView.frame.origin.y
            let tableView_width = self.tableView.frame.width
            //let tableView_height = self.tableView.frame.height
            //AutoLayout解除
            self.tableView.translatesAutoresizingMaskIntoConstraints = true
            // currentViewControllerの高さ*0.8
            self.tableView.frame = CGRect(x: tableView_x, y: tableView_y,
                                              width: tableView_width,
                                              height: screenHeight * 0.65)
            
            
            //AutoLayout解除
            self.numberOfParticipantsLabel.translatesAutoresizingMaskIntoConstraints = true
            // numberOfParticipantsLabel
            numberOfParticipantsLabel.frame = CGRect(x:startTimeLabel.frame.origin.x, y:startTimeLabel.frame.origin.y + 30, width:200, height:30)
            
            
        }
        
        
        
        // tableViewのセルの縦幅
        let cellHight: CGFloat = screenHeight * 45 / 896
        if cellHight > 45 {
            tableView.rowHeight = cellHight
        } else {
            tableView.rowHeight = 45
        }
        
        let _y = tableView.frame.origin.y + tableView.frame.height
        
        // addCellButtonのプロパティ
        let addbuttonWidth: CGFloat = screenHeight * 42/896 + 20
        //addCellButton.frame = CGRect(x:screenWidth * 320/414, y:_y + screenHeight * 5/896, width:addbuttonWidth, height:addbuttonWidth)
        addCellButton.frame = CGRect(x:screenWidth * 310/414, y:_y + screenHeight * 10/896, width:addbuttonWidth, height:addbuttonWidth)
        addCellButton.layer.cornerRadius = addbuttonWidth/2
        addCellButton.layer.shadowOffset = CGSize(width: 0, height: 2 )  // 8
        addCellButton.layer.shadowOpacity = 0.8  // 9
        addCellButton.layer.shadowRadius = 2  // 10
        addCellButton.layer.shadowColor = UIColor.gray.cgColor  // 11
        
    }
    
    override func viewDidLoad() {
//        // iPhone以外の場合
//        if UIDevice.current.userInterfaceIdiom != .phone {
//            print("これはiPadです。")
//           // currentViewControllerの高さ*0.8
////            self.containerView.frame.height = self.containerView.frame.height * 0.8
//            let containerView_x = self.containerView.frame.origin.x
//            let containerView_y = self.containerView.frame.origin.y
//            let containerView_width = self.containerView.frame.width
//            let containerView_height = self.containerView.frame.height
//            self.containerView.frame = CGRect(x: containerView_x, y: containerView_y,
//                                              width: containerView_width,
//                                              height: containerView_height * 0.6)
//        }
        
        // chileViewデフォルト表示
        self.currentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentA")
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(self.currentViewController!)
        self.addSubview(subView: self.currentViewController!.view, toView: self.containerView)
        
        // いつもの
        super.viewDidLoad()
        
        // 初回実行処理（VCから遷移してきたときのみ実行）
        if initialProcessFlg {
            // 初回処理実行
            initialProcess()
            // 初回処理終了
            initialProcessFlg = false
        }
        
        // スクリーンの縦幅
        let screenHeight:CGFloat = self.view.frame.height
        
        // tableViewのセルの縦幅
        //tableView.rowHeight = screenHeight * 50 / 896
        
        
//        // 画面遷移で受け取る
//        print("masterArray=", masterArray)
//        print("argNum=", argNum)
//        print("pairArray=", pairArray)
//        print("pairArrayCount=", pairArrayCount)
//        print("initialProcessFlg=", initialProcessFlg)
//        print("totalMember=", totalMember)
        
        // tableViewのframe情報更新
        table_x = tableView.frame.origin.x
        table_y = tableView.frame.origin.y
        table_width = tableView.frame.width
        table_height = tableView.frame.height
//        // startTimeLabelのframe情報
//        stLabel_x = startTimeLabel.frame.origin.x
//        stLabel_y = startTimeLabel.frame.origin.y
//        stLabel_width = startTimeLabel.frame.width
//        stLabel_height = startTimeLabel.frame.height
//        // numberOfParticipantsLabelのframe情報
//        nopLabel_x = numberOfParticipantsLabel.frame.origin.x
//        nopLabel_y = numberOfParticipantsLabel.frame.origin.y
//        nopLabel_width = numberOfParticipantsLabel.frame.width
//        nopLabel_height = numberOfParticipantsLabel.frame.height
    }
    
    // 初回実行処理
    func initialProcess() {
        
        // 開始時刻を表示
        startTimeLabel.text = "開始時刻　" + startTime
        
        // Color設定
        addCellButton.backgroundColor = mainColor
        tableViewLineColor = [mainColor, UIColor.clear, UIColor.clear, UIColor.clear]
        
        // 標準の戻るボタン非表示
        self.navigationItem.hidesBackButton = true
        
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        // AdMobバナー
        // In this case, we instantiate the banner with desired ad size.
        //bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        let adSize = GADAdSizeFromCGSize(CGSize(width: screenWidth, height: screenWidth*45/320))
        bannerView = GADBannerView(adSize: adSize)
        //bannerView.adUnitID = "ca-app-pub-8819499017949234/2255414473" //本番ID
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //サンプルID
        bannerView.adUnitID = admobId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        
        
        let _y = tableView.frame.origin.y + tableView.frame.height
        
//        // addCellButtonのプロパティ
//        let addbuttonWidth: CGFloat = screenHeight * 45/896 + 20
//        //addCellButton.frame = CGRect(x:screenWidth * 234/414, y:_y + 20 - screenHeight * 55/896, width:screenWidth * 160/414, height:screenHeight * 55/896)
//        //addCellButton.frame = CGRect(x:screenWidth * 340/414 - 20, y:_y - 40 - screenHeight * 55/896, width:addbuttonWidth, height:addbuttonWidth)
//        addCellButton.frame = CGRect(x:screenWidth * 320/414, y:_y + screenHeight * 5/896, width:addbuttonWidth, height:addbuttonWidth)
//        //addCellButton.layer.cornerRadius = addCellButton.frame.width / 2
//        addCellButton.layer.cornerRadius = addbuttonWidth/2
//        addCellButton.layer.shadowOffset = CGSize(width: 0, height: 2 )  // 8
//        addCellButton.layer.shadowOpacity = 0.8  // 9
//        addCellButton.layer.shadowRadius = 2  // 10
//        addCellButton.layer.shadowColor = UIColor.gray.cgColor  // 11
        //addCellButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19) // 太文字
        
        let labelHeight: CGFloat = screenHeight * 30 / 896
        
        // startTimeLabel
        startTimeLabel.frame = CGRect(x:screenWidth * 20/414, y:_y + screenHeight * 5/896, width:200, height:labelHeight)
        
        // numberOfParticipantsLabel
        numberOfParticipantsLabel.frame = CGRect(x:screenWidth * 20/414, y:_y + screenHeight * 5/896 + labelHeight * 1.75, width:200, height:labelHeight)
//        // numberOfParticipantsLabel
//        numberOfParticipantsLabel.frame = CGRect(x:screenWidth * 20/414, y:_y + screenHeight * 10/896 + labelHeight, width:200, height:labelHeight)
        
        
        // チェック有数計上配列に参加人数分の数を格納、最初はチェック無しなので全員”0”
        checkCountArray.removeAll() // 初期化
        for i in 0..<Int(argNum)! {
            // 初回は1から順に番号を格納
            checkCountArray.append([i+1, 0])
        }
        
//        print("argNum=",argNum)
        
        
        // 行のチェック有無Flgに行数分”0”代入
        cellCheckFlg.removeAll() // 初期化
        let w = Int(ceil(Double(argNum)! / 4.0))
//        print("w=",w)
//        print("Double(argNum)! / 4))=",Double(argNum)! / 4.0)
        var n: Int = 0
        while n < w {
            for _ in 0..<numX {
                cellCheckFlg.append(0)
                n += 1
            }
        }
//        print("cellCheckFlg=",cellCheckFlg)
        
        // ペア配列に全ての組み合わせのペアを格納
        pairArrayCount = 0
        for i in 1..<Int(argNum)! {
            n = 1
            while (i + n) <= Int(argNum)! {
                pairArray.append([i, i + n, 0])
                pairArrayCount += 1
                n += 1
            }
        }
//        print("ペア配列初期化")
//        print("pairArray=",pairArray)
//        print("pairArrayCount=",pairArrayCount)
        
        // 前回値ペア配列に初期値を設定
        previousPairArrayCount = 0
        for _ in 0..<numX {
            previousPairArray.append([0, 0, 0, 0])
            previousPairArrayCount += 1
        }
//        print("previousPairArray=",previousPairArray)
//        print("previousPairArrayCount=",previousPairArrayCount)
        
        previousPairArrayCount_temp = 0
        for _ in 0..<(numX - 1) {
            previousPairArray_temp.append([0, 0, 0, 0])
            previousPairArrayCount_temp += 1
        }
//        print("previousPairArray_temp=",previousPairArray_temp)
//        print("previousPairArrayCount_temp=",previousPairArrayCount_temp)
        
        // マスター配列に参加人数分の数を格納、初回は全員1回参加
        masterArray.removeAll() // 初期化
        for i in 0..<Int(argNum)! {
            masterArray.append([i+1, 1])
        }
        
        
        // 初回組み合わせ用配列
        for i in 0..<Int(argNum)! {
            initArray.append(i + 1)
        }
//        print("initArray=",initArray)
        
//        print("cellArray.count=",cellArray.count)
        
        // ----------------------
        // 初回組み合わせ作成
        // ----------------------
        initCellRowCount = 1
        var preCount :Int = 0
        while initArray.count > 0 {
//            print("initArray.count=",initArray.count)
            if initArray.count >= 4 {
                // 初回組み合わせ用配列に4つ以上数字が残っている場合
                for _ in 0..<4 {
                    // 初回組み合わせ用配列から順番にtemp配列に追加
                    tempArray.append(String(initArray[0]))
                    
                    // ユニークチェック配列にtempArrayと同じ数字を格納
                    if uniquecheckArray.count < numX*4 {
                        // ユニークチェック配列にtempArrayと同じ数字を格納
                        uniquecheckArray.append(String(initArray[0]))
                    } else {
                        // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                        uniquecheckArray.removeAll()
                        uniquecheckArray.append(String(initArray[0]))
                    }
                    
                    // 追加した数字を初回組み合わせ用配列から消去
                    initArray.remove(at: 0)
//                    print("initArray",initArray)
                }
            } else {
                // 初回組み合わせ用配列の残りの数字が3つ以下の場合
                switch initArray.count%4 {
                case 1:
                    // 残り1つの場合
//                    print("case1")
//                    print("initArray.count%4=",initArray.count%4)
                    // tempArray[0]に残りの1つを格納
                    tempArray.append(String(initArray[0]))
                    
                    // ユニークチェック配列にtempArrayと同じ数字を格納
                    if uniquecheckArray.count < numX*4 {
                        // ユニークチェック配列にtempArrayと同じ数字を格納
                        uniquecheckArray.append(String(initArray[0]))
                    } else {
                        // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                        uniquecheckArray.removeAll()
                        uniquecheckArray.append(String(initArray[0]))
                    }
                    
                    // 乱数作成作業用配列に参加数分の数を格納
                    for i in 0..<Int(argNum)! {
                        randomArray.append(i + 1)
//                        print("randomArray",randomArray[i])
                    }
                    
                    // 乱数がユニークになるように重複削除
                    for j in 0..<Int(uniquecheckArray.count) {
                        // 配列の最初に一致したインデックス番号が返される
                        if let firstIndex = randomArray.firstIndex(of: Int(uniquecheckArray[j])!) {
//                            print("インデックス番号: \(firstIndex)") // 2
                            // uniquecheckArrayの要素と同じ数字をrandomArrayが持っていたら削除
                            randomArray.remove(at: firstIndex)
                        }
                    }
//                    print("randomArray_unique=",randomArray)
                    
                    // 参加人数分の数(argNum)から3人をランダムで抽出
                    var k = randomArray.count
                    //var k = Int(argNum)!  - 1 //数字が1つ減っている
                    
                    
                    // 他3つをランダムで抽出しtempArray[1]〜[3]に格納
                    for p in 0..<3 {
                        // 乱数がユニークになるように重複削除
                        for j in 0..<Int(uniquecheckArray.count) {
                            // 配列の最初に一致したインデックス番号が返される
                            if let firstIndex = randomArray.firstIndex(of: Int(uniquecheckArray[j])!) {
//                                print("インデックス番号: \(firstIndex)") // 2
                                // uniquecheckArrayの要素と同じ数字をrandomArrayが持っていたら削除
                                randomArray.remove(at: firstIndex)
                            }
                        }
//                        print("randomArray_unique=",randomArray)
                        
                        // 乱数を一つ取り出す
                        var randomInt: Int = Int.random(in: 0..<k)
                        
                        if p >= 2 {
                            // tempArray[3]をランダムで決める場合
                            for q in 0..<previousPairArrayCount {
                                if (Int(tempArray[2])! == previousPairArray[q][0] && randomArray[randomInt] == previousPairArray[q][1]) || (Int(tempArray[2])! == previousPairArray[q][1] && randomArray[randomInt] == previousPairArray[q][0]) || (Int(tempArray[2])! == previousPairArray[q][2] && randomArray[randomInt] == previousPairArray[q][3]) || (Int(tempArray[2])! == previousPairArray[q][3] && randomArray[randomInt] == previousPairArray[q][2]) {
                                    // 前回値ペア配列と今回選出中のペアが一致していた場合、
                                    // k/2で範囲を分割して乱数再取得
                                    if randomInt < k/2 {
                                        randomInt = Int.random(in: k/2..<k)
                                    } else {
                                        randomInt = Int.random(in: 0..<k/2)
                                    }
                                }
                            }
                        }
                        // マスター配列からランダムに抽出した数をtemp配列に追加
                        tempArray.append(String(randomArray[randomInt]))
                        
                        // ユニークチェック配列にtempArrayと同じ数字を格納
                        if uniquecheckArray.count < numX*4 {
                            // ユニークチェック配列にtempArrayと同じ数字を格納
                            uniquecheckArray.append(String(randomArray[randomInt]))
                        } else {
                            // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                            uniquecheckArray.removeAll()
                            uniquecheckArray.append(String(randomArray[randomInt]))
                        }
                        
                        // マスター配列にカウント+1
                        var indexes = [IndexPath]()
                        var count = 0
                        for array in masterArray {
                            if let existNum = array.firstIndex(of: randomArray[randomInt]){
                                let indexpath: IndexPath = [count,existNum]
                                indexes.append(indexpath)
                            }
                            count += 1
                        }
                        masterArray[indexes[0][0]][1] += 1
//                        print("indexes=",indexes)
//                        print("masterArray=",masterArray)
        
//                        print("randomInt=",randomInt)
//                        print("masterArray=",masterArray[randomInt][0],masterArray[randomInt][1])
//                        print("randomArray=",randomArray)
//                        print("tempArray=",tempArray)
        
                        k -= 1
                    }
                    
                    // 最後の1つを消去
                    initArray.remove(at: 0)
                    
                case 2:
                    // 残り2つの場合
//                    print("case2")
//                    print("initArray.count%4=",initArray.count%4)
                    // tempArray[0],tempArray[1]に残りの2つを格納
                    tempArray.append(String(initArray[0]))
                    tempArray.append(String(initArray[1]))
                    
                    // ユニークチェック配列にtempArrayと同じ数字を格納
                    if uniquecheckArray.count < numX*4 {
                        // ユニークチェック配列にtempArrayと同じ数字を格納
                        uniquecheckArray.append(String(initArray[0]))
                        uniquecheckArray.append(String(initArray[1]))
                    } else {
                        // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                        uniquecheckArray.removeAll()
                        uniquecheckArray.append(String(initArray[0]))
                        uniquecheckArray.append(String(initArray[1]))
                    }
                    
                    // 乱数作成作業用配列に参加数分の数を格納
                    for i in 0..<Int(argNum)! {
                        randomArray.append(i + 1)
//                        print(randomArray[i])
                    }
                    
                    // 乱数がユニークになるように重複削除
                    for j in 0..<Int(uniquecheckArray.count) {
                        // 配列の最初に一致したインデックス番号が返される
                        if let firstIndex = randomArray.firstIndex(of: Int(uniquecheckArray[j])!) {
//                            print("インデックス番号: \(firstIndex)") // 2
                            // uniquecheckArrayの要素と同じ数字をrandomArrayが持っていたら削除
                            randomArray.remove(at: firstIndex)
                        }
                    }
//                    print("randomArray_unique=",randomArray)
                    
                    // 参加人数分の数(argNum)から3人をランダムで抽出
                    var k = randomArray.count
                    //var k = Int(argNum)!  - 2 //数字が2つ減っている
                    
                    // 他2つをランダムで抽出しtempArray[2]〜[3]に格納
                    for p in 0..<2 {
                        // 乱数がユニークになるように重複削除
                        for j in 0..<Int(uniquecheckArray.count) {
                            // 配列の最初に一致したインデックス番号が返される
                            if let firstIndex = randomArray.firstIndex(of: Int(uniquecheckArray[j])!) {
//                                print("インデックス番号: \(firstIndex)") // 2
                                // uniquecheckArrayの要素と同じ数字をrandomArrayが持っていたら削除
                                randomArray.remove(at: firstIndex)
                            }
                        }
//                        print("randomArray_unique=",randomArray)
                        
                        // 乱数を一つ取り出す
                        var randomInt: Int = Int.random(in: 0..<k)
                        
                        if p >= 1 {
                            // tempArray[3]をランダムで決める場合
                            for q in 0..<previousPairArrayCount {
                                if (Int(tempArray[2])! == previousPairArray[q][0] && randomArray[randomInt] == previousPairArray[q][1]) || (Int(tempArray[2])! == previousPairArray[q][1] && randomArray[randomInt] == previousPairArray[q][0]) || (Int(tempArray[2])! == previousPairArray[q][2] && randomArray[randomInt] == previousPairArray[q][3]) || (Int(tempArray[2])! == previousPairArray[q][3] && randomArray[randomInt] == previousPairArray[q][2]) {
                                    // 前回値ペア配列と今回選出中のペアが一致していた場合、
                                    // k/2で範囲を分割して乱数再取得
                                    if randomInt < k/2 {
                                        randomInt = Int.random(in: k/2..<k)
                                    } else {
                                        randomInt = Int.random(in: 0..<k/2)
                                    }
                                }
                            }
                        }
                        
                        // マスター配列からランダムに抽出した数をtemp配列に追加
                        tempArray.append(String(randomArray[randomInt]))
                        
                        // ユニークチェック配列にtempArrayと同じ数字を格納
                        if uniquecheckArray.count < numX*4 {
                            // ユニークチェック配列にtempArrayと同じ数字を格納
                            uniquecheckArray.append(String(randomArray[randomInt]))
                        } else {
                            // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                            uniquecheckArray.removeAll()
                            uniquecheckArray.append(String(randomArray[randomInt]))
                        }
                        
                        // マスター配列にカウント+1
                        var indexes = [IndexPath]()
                        var count = 0
                        for array in masterArray {
                            if let existNum = array.firstIndex(of: randomArray[randomInt]){
                                let indexpath: IndexPath = [count,existNum]
                                indexes.append(indexpath)
                            }
                            count += 1
                        }
                        masterArray[indexes[0][0]][1] += 1
//                        print("indexes=",indexes)
//                        print("masterArray=",masterArray)
        
//                        print("randomInt=",randomInt)
//                        print("masterArray=",masterArray[randomInt][0],masterArray[randomInt][1])
//                        print("randomArray=",randomArray)
//                        print("tempArray=",tempArray)
        
                        k -= 1
                    }
                    
                    // 最後の2つを消去
                    initArray.remove(at: 1)
                    initArray.remove(at: 0)
                    
                case 3:
                    // 残り3つの場合
//                    print("case3")
//                    print("initArray.count%4=",initArray.count%4)
                    // tempArray[0],tempArray[1],tempArray[1]に残りの3つを格納
                    tempArray.append(String(initArray[0]))
                    tempArray.append(String(initArray[1]))
                    tempArray.append(String(initArray[2]))
                    
                    // ユニークチェック配列にtempArrayと同じ数字を格納
                    if uniquecheckArray.count < numX*4 {
                        // ユニークチェック配列にtempArrayと同じ数字を格納
                        uniquecheckArray.append(String(initArray[0]))
                        uniquecheckArray.append(String(initArray[1]))
                        uniquecheckArray.append(String(initArray[2]))
                    } else {
                        // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                        uniquecheckArray.removeAll()
                        uniquecheckArray.append(String(initArray[0]))
                        uniquecheckArray.append(String(initArray[1]))
                        uniquecheckArray.append(String(initArray[2]))
                    }
                    
                    // 乱数作成作業用配列に参加数分の数を格納
                    for i in 0..<Int(argNum)! {
                        randomArray.append(i + 1)
//                        print(randomArray[i])
                    }
                    
                    // 乱数がユニークになるように重複削除
                    for j in 0..<Int(uniquecheckArray.count) {
                        // 配列の最初に一致したインデックス番号が返される
                        if let firstIndex = randomArray.firstIndex(of: Int(uniquecheckArray[j])!) {
//                            print("インデックス番号: \(firstIndex)") // 2
                            // uniquecheckArrayの要素と同じ数字をrandomArrayが持っていたら削除
                            randomArray.remove(at: firstIndex)
                        }
                    }
//                    print("randomArray_unique=",randomArray)
                    
                    // 参加人数分の数(argNum)から3人をランダムで抽出
                    var k = randomArray.count
                    //var k = Int(argNum)!  - 3 //数字が3つ減っている
                    
                    
                    // 他1つをランダムで抽出しtempArray[3]に格納
                    for _ in 0..<1 {
                        
//                        // 乱数を一つ取り出す
//                        let randomInt = Int.random(in: 0..<k)
//                        let randomIntTmp = randomArray[randomInt]
//                        // マスター配列からランダムに抽出した数をtemp配列に追加
//                        tempArray.append(String(masterArray[randomIntTmp][0]))
//                        // マスター配列にカウント+1
//                        masterArray[randomIntTmp][1] += 1
//                        // 今回の数を削除（重複回避）
//                        randomArray.remove(at: randomInt)
                        
                        // 乱数がユニークになるように重複削除
                        for j in 0..<Int(uniquecheckArray.count) {
                            // 配列の最初に一致したインデックス番号が返される
                            if let firstIndex = randomArray.firstIndex(of: Int(uniquecheckArray[j])!) {
//                                print("インデックス番号: \(firstIndex)") // 2
                                // uniquecheckArrayの要素と同じ数字をrandomArrayが持っていたら削除
                                randomArray.remove(at: firstIndex)
                            }
                        }
//                        print("randomArray_unique=",randomArray)
                        
                        // tempArray[2]まではユニークなのでtempArray[3]は乱数を一つ取り出せば良い
                        // 乱数を一つ取り出す
                        let randomInt: Int = Int.random(in: 0..<k)
                        
                        // マスター配列からランダムに抽出した数をtemp配列に追加
                        tempArray.append(String(randomArray[randomInt]))
                        
                        // ユニークチェック配列にtempArrayと同じ数字を格納
                        if uniquecheckArray.count < numX*4 {
                            // ユニークチェック配列にtempArrayと同じ数字を格納
                            uniquecheckArray.append(String(randomArray[randomInt]))
                        } else {
                            // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                            uniquecheckArray.removeAll()
                            uniquecheckArray.append(String(randomArray[randomInt]))
                        }
                        
                        // マスター配列にカウント+1
                        var indexes = [IndexPath]()
                        var count = 0
                        for array in masterArray {
                            if let existNum = array.firstIndex(of: randomArray[randomInt]){
                                let indexpath: IndexPath = [count,existNum]
                                indexes.append(indexpath)
                            }
                            count += 1
                        }
                        masterArray[indexes[0][0]][1] += 1
//                        print("indexes=",indexes)
//                        print("masterArray=",masterArray)
        
//                        print("randomInt=",randomInt)
//                        print("masterArray=",masterArray[randomInt][0],masterArray[randomInt][1])
//                        print("randomArray=",randomArray)
//                        print("tempArray=",tempArray)
        
                        k -= 1
                    }
                    
                    // 最後の3つを消去
                    initArray.remove(at: 2)
                    initArray.remove(at: 1)
                    initArray.remove(at: 0)
                    
                default :
                    break
                }
            }
            
            
            // ソート
            if Int(tempArray[0])! > Int(tempArray[1])! {
                let temp = tempArray[0]
                tempArray[0] = tempArray[1]
                tempArray[1] = temp
            }
            if Int(tempArray[2])! > Int(tempArray[3])! {
                let temp = tempArray[2]
                tempArray[2] = tempArray[3]
                tempArray[3] = temp
            }
            
//            print("cellArray1=",cellArray)
            // cell表示用配列に乱数追加
            cellArray.append([tempArray[0],tempArray[1],tempArray[2],tempArray[3]])
//            print("cellArray2=",cellArray)
//            print("tempArray1=",tempArray)
            
            // ペア選出数をペア配列に記録
            for i in 0..<pairArrayCount {
                if (pairArray[i][0] == Int(tempArray[0])!) && (pairArray[i][1] == Int(tempArray[1])!) {
                    pairArray[i][2] += 1
                } else if (pairArray[i][0] == Int(tempArray[2])!) && (pairArray[i][1] == Int(tempArray[3])!) {
                    pairArray[i][2] += 1
                }
            }
//            print("初回ペア選出")
//            print("pairArray=",pairArray)
            
            if initCellRowCount % numX != 0 {
                // コート数-1までのコートにペアを設定する場合
                // 前回値ペア配列の一時保管用配列に今回のペアを記録
                previousPairArray_temp[preCount][0] = Int(tempArray[0])!
                previousPairArray_temp[preCount][1] = Int(tempArray[1])!
                previousPairArray_temp[preCount][2] = Int(tempArray[2])!
                previousPairArray_temp[preCount][3] = Int(tempArray[3])!
//                print("A")
//                print("previousPairArray_temp=",previousPairArray_temp)
//                print("preCount=",preCount)
                if (preCount + 1) <= (numX - 1) {
                    preCount += 1
                } else {
                    preCount = 0
                }
            } else {
                // 最後のコートにペアを設定する場合
                // 前回値ペア配列を一時保管用配列で更新
                if previousPairArrayCount_temp >= 1 {
                    for s in 0..<previousPairArrayCount_temp {
                        previousPairArray[s][0] = previousPairArray_temp[s][0]
                        previousPairArray[s][1] = previousPairArray_temp[s][1]
                        previousPairArray[s][2] = previousPairArray_temp[s][2]
                        previousPairArray[s][3] = previousPairArray_temp[s][3]
                    }
                }
                // 前回値ペア配列に今回のペアを記録
                previousPairArray[preCount][0] = Int(tempArray[0])!
                previousPairArray[preCount][1] = Int(tempArray[1])!
                previousPairArray[preCount][2] = Int(tempArray[2])!
                previousPairArray[preCount][3] = Int(tempArray[3])!
//                print("B")
//                print("previousPairArray=",previousPairArray)
//                print("preCount=",preCount)
//                print("previousPairArrayCount_temp=",previousPairArrayCount_temp)
                preCount = 0
            }
            initCellRowCount += 1
            // temp配列の要素を全削除
            tempArray.removeAll()
//            print("tempArray2=",tempArray)
            
        }
        
        // ---------------------------------
        // 初回はコート数分のcellを作成する
        // ---------------------------------
        // 必ずnumX>cellArray.count%numXに調整済み
        let remainCell = (numX - (cellArray.count % numX)) % numX
        // ※2コート以外の場合の追加を考慮すること
//        switch cellArray.count%numX {
        switch remainCell {
        case 0:
            break
            
        case 1:
            // 残り1cell必要な場合
//            print("初回のコート数分(1)cell作成")
//            print("cellArray.count=",cellArray.count)
//            print("cellArray.count%numX=",cellArray.count%numX)
            // randomArrayの要素を全削除（初期化）
            randomArray.removeAll()
            // 乱数作成作業用配列に参加数分の数を格納
            for i in 0..<Int(argNum)! {
                randomArray.append(i + 1)
//                print(randomArray[i])
            }
            
            // 参加人数分の数(argNum)から4人をランダムで抽出
            var k = Int(argNum)! - (cellArray.count % numX)*4 //数字が減っている
            for p in 0..<4 {
                // 乱数がユニークになるように重複削除
                for j in 0..<Int(uniquecheckArray.count) {
                    // 配列の最初に一致したインデックス番号が返される
                    if let firstIndex = randomArray.firstIndex(of: Int(uniquecheckArray[j])!) {
//                        print("インデックス番号: \(firstIndex)") // 2
                        // uniquecheckArrayの要素と同じ数字をrandomArrayが持っていたら削除
                        randomArray.remove(at: firstIndex)
                    }
                }
//                print("randomArray_unique=",randomArray)
//                print("randomArray=",randomArray)
                
                // 乱数を一つ取り出す
                var randomInt: Int = Int.random(in: 0..<k)
//                print("k=",k)
//                print("previousPairArray=",previousPairArray)
//                print("tempArray=",tempArray)
//                print("randomArray=",randomArray)
                
                if p == 1 {
                    // tempArray[1]をランダムで決める場合
                    for q in 0..<previousPairArrayCount {
                        if (Int(tempArray[0])! == previousPairArray[q][0] && randomArray[randomInt] == previousPairArray[q][1]) || (Int(tempArray[0])! == previousPairArray[q][1] && randomArray[randomInt] == previousPairArray[q][0]) || (Int(tempArray[0])! == previousPairArray[q][2] && randomArray[randomInt] == previousPairArray[q][3]) || (Int(tempArray[0])! == previousPairArray[q][3] && randomArray[randomInt] == previousPairArray[q][2]) {
                            // 前回値ペア配列と今回選出中のペアが一致していた場合、
                            // k/2で範囲を分割して乱数再取得
                            if randomInt < k/2 {
                                randomInt = Int.random(in: k/2..<k)
                            } else {
                                randomInt = Int.random(in: 0..<k/2)
                            }
                        }
                    }
                } else if p >= 3 {
                    // tempArray[3]をランダムで決める場合
                    for q in 0..<previousPairArrayCount {
                        if (Int(tempArray[2])! == previousPairArray[q][0] && randomArray[randomInt] == previousPairArray[q][1]) || (Int(tempArray[2])! == previousPairArray[q][1] && randomArray[randomInt] == previousPairArray[q][0]) || (Int(tempArray[2])! == previousPairArray[q][2] && randomArray[randomInt] == previousPairArray[q][3]) || (Int(tempArray[2])! == previousPairArray[q][3] && randomArray[randomInt] == previousPairArray[q][2]) {
                            // 前回値ペア配列と今回選出中のペアが一致していた場合、
                            // k/2で範囲を分割して乱数再取得
                            if randomInt < k/2 {
                                randomInt = Int.random(in: k/2..<k)
                            } else {
                                randomInt = Int.random(in: 0..<k/2)
                            }
                        }
                    }
                }
                
                // マスター配列からランダムに抽出した数をtemp配列に追加
                tempArray.append(String(randomArray[randomInt]))
                
                // ユニークチェック配列にtempArrayと同じ数字を格納
                if uniquecheckArray.count < numX*4 {
                    // ユニークチェック配列にtempArrayと同じ数字を格納
                    uniquecheckArray.append(String(randomArray[randomInt]))
                } else {
                    // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                    uniquecheckArray.removeAll()
                    uniquecheckArray.append(String(randomArray[randomInt]))
                }
                
                // マスター配列にカウント+1
                var indexes = [IndexPath]()
                var count = 0
                for array in masterArray {
                    if let existNum = array.firstIndex(of: randomArray[randomInt]){
                        let indexpath: IndexPath = [count,existNum]
                        indexes.append(indexpath)
                    }
                    count += 1
                }
                masterArray[indexes[0][0]][1] += 1
//                print("indexes=",indexes)
//                print("masterArray=",masterArray)
                
//                print("randomInt=",randomInt)
//                print("masterArray=",masterArray[randomInt][0],masterArray[randomInt][1])
//                print("randomArray=",randomArray)
//                print("tempArray=",tempArray)
                
                k -= 1
            }
            
            // ソート
            if Int(tempArray[0])! > Int(tempArray[1])! {
                let temp = tempArray[0]
                tempArray[0] = tempArray[1]
                tempArray[1] = temp
            }
            if Int(tempArray[2])! > Int(tempArray[3])! {
                let temp = tempArray[2]
                tempArray[2] = tempArray[3]
                tempArray[3] = temp
            }
            
//            print("cellArray1=",cellArray)
            // cell表示用配列に乱数追加
            cellArray.append([tempArray[0],tempArray[1],tempArray[2],tempArray[3]])
//            print("cellArray2=",cellArray)
            
//            print("tempArray1=",tempArray)
            
            // ペア選出数をペア配列に記録
            for i in 0..<pairArrayCount {
                if (pairArray[i][0] == Int(tempArray[0])!) && (pairArray[i][1] == Int(tempArray[1])!) {
                    pairArray[i][2] += 1
                } else if (pairArray[i][0] == Int(tempArray[2])!) && (pairArray[i][1] == Int(tempArray[3])!) {
                    pairArray[i][2] += 1
                }
            }
//            print("初回ペア選出(残り1行)")
//            print("pairArray=",pairArray)
            
            
            // 最後のコートにペアを設定する場合
            // 前回値ペア配列を一時保管用配列で更新
            for s in 0..<previousPairArrayCount_temp {
                previousPairArray[s][0] = previousPairArray_temp[s][0]
                previousPairArray[s][1] = previousPairArray_temp[s][1]
                previousPairArray[s][2] = previousPairArray_temp[s][2]
                previousPairArray[s][3] = previousPairArray_temp[s][3]
            }
            // 前回値ペア配列に今回のペアを記録
            previousPairArray[preCount][0] = Int(tempArray[0])!
            previousPairArray[preCount][1] = Int(tempArray[1])!
            previousPairArray[preCount][2] = Int(tempArray[2])!
            previousPairArray[preCount][3] = Int(tempArray[3])!
//            print("C")
//            print("previousPairArray=",previousPairArray)
//            print("previousPairArrayCount_temp=",previousPairArrayCount_temp)
            preCount = 0
            initCellRowCount += 1
            
            
            // temp配列の要素を全削除
            tempArray.removeAll()
//            print("tempArray2=",tempArray)
            
        case 2:
            // 残り2cell必要な場合
//            print("初回のコート数分(2)cell作成")
//            print("cellArray.count=",cellArray.count)
//            print("cellArray.count%numX=",cellArray.count%numX)
            // randomArrayの要素を全削除（初期化）
            randomArray.removeAll()
            // 乱数作成作業用配列に参加数分の数を格納
            for i in 0..<Int(argNum)! {
                randomArray.append(i + 1)
//                print(randomArray[i])
            }
            
            // 参加人数分の数(argNum)から4人をランダムで抽出
            var k = Int(argNum)! - (cellArray.count % numX)*4 //数字が減っている
            
            // 2cell作成
            for _ in 0..<2 {
            
                for p in 0..<4 {
                    
                    // 乱数がユニークになるように重複削除
                    for j in 0..<Int(uniquecheckArray.count) {
                        // 配列の最初に一致したインデックス番号が返される
                        if let firstIndex = randomArray.firstIndex(of: Int(uniquecheckArray[j])!) {
//                            print("インデックス番号: \(firstIndex)") // 2
                            // uniquecheckArrayの要素と同じ数字をrandomArrayが持っていたら削除
                            randomArray.remove(at: firstIndex)
                        }
                    }
//                    print("randomArray_unique=",randomArray)
                    
                    // 乱数を一つ取り出す
                    var randomInt: Int = Int.random(in: 0..<k)
                    
                    if p == 1 {
                        // tempArray[1]をランダムで決める場合
                        for q in 0..<previousPairArrayCount {
                            if (Int(tempArray[0])! == previousPairArray[q][0] && randomArray[randomInt] == previousPairArray[q][1]) || (Int(tempArray[0])! == previousPairArray[q][1] && randomArray[randomInt] == previousPairArray[q][0]) || (Int(tempArray[0])! == previousPairArray[q][2] && randomArray[randomInt] == previousPairArray[q][3]) || (Int(tempArray[0])! == previousPairArray[q][3] && randomArray[randomInt] == previousPairArray[q][2]) {
                                // 前回値ペア配列と今回選出中のペアが一致していた場合、
                                // k/2で範囲を分割して乱数再取得
                                if randomInt < k/2 {
                                    randomInt = Int.random(in: k/2..<k)
                                } else {
                                    randomInt = Int.random(in: 0..<k/2)
                                }
                            }
                        }
                    } else if p >= 3 {
                        // tempArray[3]をランダムで決める場合
                        for q in 0..<previousPairArrayCount {
                            if (Int(tempArray[2])! == previousPairArray[q][0] && randomArray[randomInt] == previousPairArray[q][1]) || (Int(tempArray[2])! == previousPairArray[q][1] && randomArray[randomInt] == previousPairArray[q][0]) || (Int(tempArray[2])! == previousPairArray[q][2] && randomArray[randomInt] == previousPairArray[q][3]) || (Int(tempArray[2])! == previousPairArray[q][3] && randomArray[randomInt] == previousPairArray[q][2]) {
                                // 前回値ペア配列と今回選出中のペアが一致していた場合、
                                // k/2で範囲を分割して乱数再取得
                                if randomInt < k/2 {
                                    randomInt = Int.random(in: k/2..<k)
                                } else {
                                    randomInt = Int.random(in: 0..<k/2)
                                }
                            }
                        }
                    }
                    
                    // マスター配列からランダムに抽出した数をtemp配列に追加
                    tempArray.append(String(randomArray[randomInt]))
                    
                    // ユニークチェック配列にtempArrayと同じ数字を格納
                    if uniquecheckArray.count < numX*4 {
                        // ユニークチェック配列にtempArrayと同じ数字を格納
                        uniquecheckArray.append(String(randomArray[randomInt]))
                    } else {
                        // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                        uniquecheckArray.removeAll()
                        uniquecheckArray.append(String(randomArray[randomInt]))
                    }
                    
                    // マスター配列にカウント+1
                    var indexes = [IndexPath]()
                    var count = 0
                    for array in masterArray {
                        if let existNum = array.firstIndex(of: randomArray[randomInt]){
                            let indexpath: IndexPath = [count,existNum]
                            indexes.append(indexpath)
                        }
                        count += 1
                    }
                    masterArray[indexes[0][0]][1] += 1
//                    print("indexes=",indexes)
//                    print("masterArray=",masterArray)
                    
//                    print("randomInt=",randomInt)
//                    print("masterArray=",masterArray[randomInt][0],masterArray[randomInt][1])
//                    print("randomArray=",randomArray)
//                    print("tempArray=",tempArray)
                    
                    k -= 1
                }
                
                // ソート
                if Int(tempArray[0])! > Int(tempArray[1])! {
                    let temp = tempArray[0]
                    tempArray[0] = tempArray[1]
                    tempArray[1] = temp
                }
                if Int(tempArray[2])! > Int(tempArray[3])! {
                    let temp = tempArray[2]
                    tempArray[2] = tempArray[3]
                    tempArray[3] = temp
                }
                
//                print("cellArray1=",cellArray)
                // cell表示用配列に乱数追加
                cellArray.append([tempArray[0],tempArray[1],tempArray[2],tempArray[3]])
//                print("cellArray2=",cellArray)
                
//                print("tempArray1=",tempArray)
                
                // ペア選出数をペア配列に記録
                for i in 0..<pairArrayCount {
                    if (pairArray[i][0] == Int(tempArray[0])!) && (pairArray[i][1] == Int(tempArray[1])!) {
                        pairArray[i][2] += 1
                    } else if (pairArray[i][0] == Int(tempArray[2])!) && (pairArray[i][1] == Int(tempArray[3])!) {
                        pairArray[i][2] += 1
                    }
                }
//                print("初回ペア選出(残り2行)")
//                print("pairArray=",pairArray)
                
                
                if initCellRowCount % numX != 0 {
                    // コート数-1までのコートにペアを設定する場合
                    // 前回値ペア配列の一時保管用配列に今回のペアを記録
                    previousPairArray_temp[preCount][0] = Int(tempArray[0])!
                    previousPairArray_temp[preCount][1] = Int(tempArray[1])!
                    previousPairArray_temp[preCount][2] = Int(tempArray[2])!
                    previousPairArray_temp[preCount][3] = Int(tempArray[3])!
//                    print("D")
//                    print("previousPairArray_temp=",previousPairArray_temp)
//                    print("preCount=",preCount)
                    if (preCount + 1) <= (numX - 1) {
                        preCount += 1
                    } else {
                        preCount = 0
                    }
                } else {
                    // 最後のコートにペアを設定する場合
                    // 前回値ペア配列を一時保管用配列で更新
                    for s in 0..<previousPairArrayCount_temp {
                        previousPairArray[s][0] = previousPairArray_temp[s][0]
                        previousPairArray[s][1] = previousPairArray_temp[s][1]
                        previousPairArray[s][2] = previousPairArray_temp[s][2]
                        previousPairArray[s][3] = previousPairArray_temp[s][3]
                    }
                    // 前回値ペア配列に今回のペアを記録
                    previousPairArray[preCount][0] = Int(tempArray[0])!
                    previousPairArray[preCount][1] = Int(tempArray[1])!
                    previousPairArray[preCount][2] = Int(tempArray[2])!
                    previousPairArray[preCount][3] = Int(tempArray[3])!
//                    print("E")
//                    print("previousPairArray=",previousPairArray)
//                    print("preCount=",preCount)
//                    print("previousPairArrayCount_temp=",previousPairArrayCount_temp)
                    preCount = 0
                }
                initCellRowCount += 1
                
                // temp配列の要素を全削除
                tempArray.removeAll()
//                print("tempArray2=",tempArray)
            
            }
        
        case 3:
            // 残り3cell必要な場合
//            print("初回のコート数分(3)cell作成")
//            print("cellArray.count=",cellArray.count)
//            print("cellArray.count%numX=",cellArray.count%numX)
            // randomArrayの要素を全削除（初期化）
            randomArray.removeAll()
            // 乱数作成作業用配列に参加数分の数を格納
            for i in 0..<Int(argNum)! {
                randomArray.append(i + 1)
//                print(randomArray[i])
            }
            
            // 参加人数分の数(argNum)から4人をランダムで抽出
            var k = Int(argNum)! - (cellArray.count % numX)*4 //数字が減っている
            
            // 3cell作成
            for _ in 0..<3 {
            
                for p in 0..<4 {
                    
                    // 乱数がユニークになるように重複削除
                    for j in 0..<Int(uniquecheckArray.count) {
                        // 配列の最初に一致したインデックス番号が返される
                        if let firstIndex = randomArray.firstIndex(of: Int(uniquecheckArray[j])!) {
//                            print("インデックス番号: \(firstIndex)") // 2
                            // uniquecheckArrayの要素と同じ数字をrandomArrayが持っていたら削除
                            randomArray.remove(at: firstIndex)
                        }
                    }
//                    print("randomArray_unique=",randomArray)
                    
                    // 乱数を一つ取り出す
                    var randomInt: Int = Int.random(in: 0..<k)
                    
                    if p == 1 {
                        // tempArray[1]をランダムで決める場合
                        for q in 0..<previousPairArrayCount {
                            if (Int(tempArray[0])! == previousPairArray[q][0] && randomArray[randomInt] == previousPairArray[q][1]) || (Int(tempArray[0])! == previousPairArray[q][1] && randomArray[randomInt] == previousPairArray[q][0]) || (Int(tempArray[0])! == previousPairArray[q][2] && randomArray[randomInt] == previousPairArray[q][3]) || (Int(tempArray[0])! == previousPairArray[q][3] && randomArray[randomInt] == previousPairArray[q][2]) {
                                // 前回値ペア配列と今回選出中のペアが一致していた場合、
                                // k/2で範囲を分割して乱数再取得
                                if randomInt < k/2 {
                                    randomInt = Int.random(in: k/2..<k)
                                } else {
                                    randomInt = Int.random(in: 0..<k/2)
                                }
                            }
                        }
                    } else if p >= 3 {
                        // tempArray[3]をランダムで決める場合
                        for q in 0..<previousPairArrayCount {
                            if (Int(tempArray[2])! == previousPairArray[q][0] && randomArray[randomInt] == previousPairArray[q][1]) || (Int(tempArray[2])! == previousPairArray[q][1] && randomArray[randomInt] == previousPairArray[q][0]) || (Int(tempArray[2])! == previousPairArray[q][2] && randomArray[randomInt] == previousPairArray[q][3]) || (Int(tempArray[2])! == previousPairArray[q][3] && randomArray[randomInt] == previousPairArray[q][2]) {
                                // 前回値ペア配列と今回選出中のペアが一致していた場合、
                                // k/2で範囲を分割して乱数再取得
                                if randomInt < k/2 {
                                    randomInt = Int.random(in: k/2..<k)
                                } else {
                                    randomInt = Int.random(in: 0..<k/2)
                                }
                            }
                        }
                    }
                    
                    // マスター配列からランダムに抽出した数をtemp配列に追加
                    tempArray.append(String(randomArray[randomInt]))
                    
                    // ユニークチェック配列にtempArrayと同じ数字を格納
                    if uniquecheckArray.count < numX*4 {
                        // ユニークチェック配列にtempArrayと同じ数字を格納
                        uniquecheckArray.append(String(randomArray[randomInt]))
                    } else {
                        // ユニークチェック配列を初期化してtempArrayと同じ数字を格納
                        uniquecheckArray.removeAll()
                        uniquecheckArray.append(String(randomArray[randomInt]))
                    }
                    
                    // マスター配列にカウント+1
                    var indexes = [IndexPath]()
                    var count = 0
                    for array in masterArray {
                        if let existNum = array.firstIndex(of: randomArray[randomInt]){
                            let indexpath: IndexPath = [count,existNum]
                            indexes.append(indexpath)
                        }
                        count += 1
                    }
                    masterArray[indexes[0][0]][1] += 1
//                    print("indexes=",indexes)
//                    print("masterArray=",masterArray)
                    
//                    print("randomInt=",randomInt)
//                    print("masterArray=",masterArray[randomInt][0],masterArray[randomInt][1])
//                    print("randomArray=",randomArray)
//                    print("tempArray=",tempArray)
                    
                    k -= 1
                }
                
                // ソート
                if Int(tempArray[0])! > Int(tempArray[1])! {
                    let temp = tempArray[0]
                    tempArray[0] = tempArray[1]
                    tempArray[1] = temp
                }
                if Int(tempArray[2])! > Int(tempArray[3])! {
                    let temp = tempArray[2]
                    tempArray[2] = tempArray[3]
                    tempArray[3] = temp
                }
                
//                print("cellArray1=",cellArray)
                // cell表示用配列に乱数追加
                cellArray.append([tempArray[0],tempArray[1],tempArray[2],tempArray[3]])
//                print("cellArray2=",cellArray)
                
//                print("tempArray1=",tempArray)
                
                // ペア選出数をペア配列に記録
                for i in 0..<pairArrayCount {
                    if (pairArray[i][0] == Int(tempArray[0])!) && (pairArray[i][1] == Int(tempArray[1])!) {
                        pairArray[i][2] += 1
                    } else if (pairArray[i][0] == Int(tempArray[2])!) && (pairArray[i][1] == Int(tempArray[3])!) {
                        pairArray[i][2] += 1
                    }
                }
//                print("初回ペア選出(残り3行)")
//                print("pairArray=",pairArray)
                
                
                if initCellRowCount % numX != 0 {
                    // コート数-1までのコートにペアを設定する場合
                    // 前回値ペア配列の一時保管用配列に今回のペアを記録
                    previousPairArray_temp[preCount][0] = Int(tempArray[0])!
                    previousPairArray_temp[preCount][1] = Int(tempArray[1])!
                    previousPairArray_temp[preCount][2] = Int(tempArray[2])!
                    previousPairArray_temp[preCount][3] = Int(tempArray[3])!
//                    print("F")
//                    print("previousPairArray_temp=",previousPairArray_temp)
//                    print("preCount=",preCount)
                    if (preCount + 1) <= (numX - 1) {
                        preCount += 1
                    } else {
                        preCount = 0
                    }
                } else {
                    // 最後のコートにペアを設定する場合
                    // 前回値ペア配列を一時保管用配列で更新
                    for s in 0..<previousPairArrayCount_temp {
                        previousPairArray[s][0] = previousPairArray_temp[s][0]
                        previousPairArray[s][1] = previousPairArray_temp[s][1]
                        previousPairArray[s][2] = previousPairArray_temp[s][2]
                        previousPairArray[s][3] = previousPairArray_temp[s][3]
                    }
                    // 前回値ペア配列に今回のペアを記録
                    previousPairArray[preCount][0] = Int(tempArray[0])!
                    previousPairArray[preCount][1] = Int(tempArray[1])!
                    previousPairArray[preCount][2] = Int(tempArray[2])!
                    previousPairArray[preCount][3] = Int(tempArray[3])!
//                    print("G")
//                    print("previousPairArray=",previousPairArray)
//                    print("preCount=",preCount)
//                    print("previousPairArrayCount_temp=",previousPairArrayCount_temp)
                    preCount = 0
                }
                initCellRowCount += 1
                
                // temp配列の要素を全削除
                tempArray.removeAll()
//                print("tempArray2=",tempArray)
            
            }
        
        default :
            break
        }
        
        
        
        // ユニークチェック配列の全要素を削除
        uniquecheckArray.removeAll()
        
        //
        tableView.dataSource = self
        tableView.delegate = self
        
        
        // 複数選択を有効
        tableView.allowsMultipleSelection = true
    }
    

    // -----------------------
    // -----------------------
    // 追加ボタン押下処理
    // -----------------------
    // -----------------------
    @IBAction func addCellButton(_ sender: Any) {
//        print("追加ボタン押下")
        
        
        // 画面遷移で受け取る
//        print("masterArray=", masterArray)
//        print("argNum=", argNum)
//        print("pairArray=", pairArray)
//        print("pairArrayCount=", pairArrayCount)
//        print("initialProcessFlg=", initialProcessFlg)
        
        
        
        
        // 行チェック有無Flgにコート数分"0"追加
        for _ in 0..<numX {
            cellCheckFlg.append(0)
        }
        
        // ユニークチェック配列を初期化
        uniquecheckArray.removeAll()
        
        // temp配列の要素を全削除
        tempArray.removeAll()
        
        // 乱数作成作業用配列の要素を全削除
        randomArray.removeAll()
        
        
        // ペア選出用配列初期化
        var masterArray_Temp : [Int] = []
        var pairCount : [Int] = []
        pairCount.removeAll()
        pairArray_Low.removeAll()
        pairArray_Mid.removeAll()
        pairArray_High.removeAll()
        var pairArray_use: [[Int]] = []
        var pairArray_use_count :Int = 0
        var randomPair : [[Int]] = []
        var candidate : [Int] = []
        
        //var count_tmp: [Int] = []
        
        
//        print("作業用ペア配列初期化")
//        // 作業用ペア配列に全ての組み合わせのペアを格納
//        var pairArray_temp_count: Int = 0
//        print("pairArray=", pairArray)
//        if pairArray.isEmpty {
//            for i in 1..<pairArray.count {
//                pairArray_temp.append([pairArray[i][0], pairArray[i][1], 0])
//            }
//        }
//        pairArray_temp_count = pairArray_temp.count + 1
//
//        print("pairArray_temp=",pairArray_temp)
//        print("pairArray_temp_count=",pairArray_temp_count)
        
        
        
        
//        var pairArray_temp_dummy: [[Int]] = []
//        var pairArray_temp_dummy_count: Int = 0
//        pairArray_temp_dummy.removeAll()
//        for i in 1..<pairArray.count {
//            pairArray_temp_dummy.append([pairArray[i][0], pairArray[i][1], 0])
//            //pairArray_temp_dummy_count += 1
//        }
//        pairArray_temp_dummy_count = pairArray_temp_dummy.count + 1
//        print("pairArray_temp=",pairArray_temp)
//        print("pairArray_temp_dummy_count=",pairArray_temp_dummy_count)
        
        
        
        
        
        //var loopCount: Int = 1
        
        //pairArray_temp,masterArray_Temp
        //
        
        // 参加者数
//        print("argNum=",argNum)
        
        addCellRowCount = 1
        //var preCount :Int = 0
        
        // コート数(numX)だけ４人組をランダムで作成
        for _ in 0..<numX {
            // ◆マスター配列から参加数が最少の人、最少+1の人、その他の人に分ける
            masterArray_Temp.removeAll()
            // 参加者全員を、参加数の多少で分ける
            for i in 0..<Int(argNum)! {
                masterArray_Temp.append(masterArray[i][1])
            }
//            print("masterArray_Temp=",masterArray_Temp)
//            print("uniquecheckArray=",uniquecheckArray)
            masterArray_Low.removeAll()
            masterArray_Mid.removeAll()
            masterArray_High.removeAll()
            var uniqueFlg :Bool = true
            for i in 0..<Int(argNum)! {
                
                // ユニークチェック
                uniqueFlg = true
                if Int(uniquecheckArray.count) > 0 {
                    for j in 0..<Int(uniquecheckArray.count) {
                        if (masterArray[i][0] == Int(uniquecheckArray[j])!) {
                            // ユニークチェック配列の要素と一致する場合はfalse
                            uniqueFlg = false
//                            print("uniqueFlg = false")
                            break
                        }
                    }
                }
                // ユニークチェック配列の要素と一致する場合は除外
                if uniqueFlg == false {
                    continue
                }
                
                // 参加数の多少で分ける
                if masterArray[i][1] == masterArray_Temp.min() {
                    // 参加数が最少の人
                    masterArray_Low.append(masterArray[i][0])
                } else if  masterArray[i][1] == (masterArray_Temp.min()! + 1) {
                    // 参加数が最少+1の人
                    masterArray_Mid.append(masterArray[i][0])
                } else {
                    // その他の人
                    masterArray_High.append(masterArray[i][0])
                }
            }
//            print("masterArray_Low=",masterArray_Low)
//            print("masterArray_High=",masterArray_High)
//            print("masterArray_Mid=",masterArray_Mid)
            
            
            // ◆参加者が4人選出されるまでループ、コート数分選出するようにユニークチェックを行う
            var randomInt: Int = 0
            candidate.removeAll()
            for _ in 0...3 {
                if masterArray_Low.count >= 1 {
                    // 参加数が最少の人から選出
                    randomInt = Int.random(in: 1...masterArray_Low.count) - 1
                    candidate.append(masterArray_Low[randomInt])
                    masterArray_Low.remove(at: randomInt)
                } else if masterArray_Mid.count >= 1 {
                    // 人数不足の場合、参加数が最少+1の人からも選出
                    randomInt = Int.random(in: 1...masterArray_Mid.count) - 1
                    candidate.append(masterArray_Mid[randomInt])
                    masterArray_Mid.remove(at: randomInt)
                } else if masterArray_High.count >= 1 {
                    // それでも人数不足の場合、その他の人からも選出
                    randomInt = Int.random(in: 1...masterArray_High.count) - 1
                    candidate.append(masterArray_High[randomInt])
                    masterArray_High.remove(at: randomInt)
                }
            }
            // 重複削除
            // candidateをNSOrderedSetに変換
            let orderedSet: NSOrderedSet = NSOrderedSet(array: candidate)
            // 再度candidateに戻す
            candidate = orderedSet.array as! [Int]
            // 昇順でソート
            candidate.sort{ $0 < $1 }
//            print("ソート完了")
//            print("candidate=",candidate)
            
            // ◆マスターペア配列から選出回数が最少のペア、最少+1のペア、その他のペアに分ける
            for i in 0..<pairArrayCount {
                pairCount.append(pairArray[i][2])
            }
            var lowCount = 0
            var midCount = 0
            var highCount = 0
            pairArray_Low.removeAll()
            pairArray_Mid.removeAll()
            pairArray_High.removeAll()
            for i in 0..<pairArrayCount {
                if pairArray[i][2] == pairCount.min() {
                    // 選出回数の最少のペア
                    pairArray_Low.append([pairArray[i][0],pairArray[i][1]])
                    lowCount += 1
                } else if pairArray[i][2] == (pairCount.min()! + 1) {
                    // 選出回数の最少+1のペア
                    pairArray_Mid.append([pairArray[i][0],pairArray[i][1]])
                    midCount += 1
                } else {
                    // 選出回数のその他のペア
                    pairArray_High.append([pairArray[i][0],pairArray[i][1]])
                    highCount += 1
                }
            }
//            print("pairCount=",pairCount)
//            print("lowCount=",lowCount)
//            print("pairArray_Low=",pairArray_Low)
//            print("midCount=",midCount)
//            print("pairArray_Mid=",pairArray_Mid)
//            print("highCount=",highCount)
//            print("pairArray_High=",pairArray_High)
            
            
            //
            // 選出中のpairArray_Lowのペアの、残りのペアも重複していないかチェック
            // candidate= [2, 3, 6, 7]
            // pairArray_Low= [[1, 4], [1, 7], [2, 5], [2, 8], [3, 6], [3, 8], [4, 7], [4, 8], [6, 7]]
            // pairArray_use= [[3, 6], [6, 7]] ←この時点で[6, 7]も除外したかった
            // tempArray= ["6", "7", "2", "3"]
            // →修正済み
            
            // ◆選出回数が最少のペアのうち、両方が選出者4人の誰かであるペアを抽出し、代表ペア配列に格納
            pairArray_use_count = 0
            pairArray_use.removeAll()
            var c1 :[Int] = []
            c1.removeAll()
            for i in 0..<lowCount {
                for j in 0..<candidate.count {
                    if pairArray_Low[i][0] == candidate[j] {
                        for_loop3: for k in j..<candidate.count {
                            if j < k && pairArray_Low[i][1] == candidate[k] {
                                // 前回値ペア配列との重複を除外
                                for_loop4: for q in 0..<previousPairArrayCount {
//                                    print("previousPairArray=",previousPairArray)
                                    if (pairArray_Low[i][0] == previousPairArray[q][0] && pairArray_Low[i][1] == previousPairArray[q][1]) || (pairArray_Low[i][0] == previousPairArray[q][1] && pairArray_Low[i][1] == previousPairArray[q][0]) || (pairArray_Low[i][0] == previousPairArray[q][2] && pairArray_Low[i][1] == previousPairArray[q][3]) || (pairArray_Low[i][0] == previousPairArray[q][3] && pairArray_Low[i][1] == previousPairArray[q][2]) {
                                        // 重複していた場合、スルー（for_loop3を次のループへ）
                                        continue for_loop3
                                    }
                                }
                                // 重複していない場合
                                // candidate[j]と[k]以外の、選出されていない要素をc1に格納
                                c1.removeAll()
                                for s in 0..<candidate.count {
                                    if s != j && s != k {
                                        c1.append(candidate[s])
                                    }
                                }
//                                print("c1=",c1)
//                                print("previousPairArray=",previousPairArray)
//                                print("previousPairArrayCount=",previousPairArrayCount)
                                // c1と前回値ペア配列との重複を確認
                                for_loop5: for t in 0..<previousPairArrayCount {
                                    if (c1[0] == previousPairArray[t][0] && c1[1] == previousPairArray[t][1]) || (c1[0] == previousPairArray[t][1] && c1[1] == previousPairArray[t][0]) || (c1[0] == previousPairArray[t][2] && c1[1] == previousPairArray[t][3]) || (c1[0] == previousPairArray[t][3] && c1[1] == previousPairArray[t][2]) {
                                        // 重複していた場合、スルー（for_loop3を次のループへ）
//                                        print("c1 is NG")
                                        continue for_loop3
                                    }
                                }
                                // 重複していない場合、pairArray_useに格納
                                pairArray_use.append([pairArray_Low[i][0], pairArray_Low[i][1]])
                                pairArray_use_count += 1
//                                print("c1 is OK")
                            }
                        }
                    }
                }
            }
//            print("pairArray_use=",pairArray_use)
//            print("candidate=",candidate)
            
            // ◆ランダムペア配列に格納
            var r1 :Int = 0
            var r11 :Int = 0
            var r12 :Int = 0
            //var r2 :Int = 0
            var r21 :Int = 0
            var r22 :Int = 0
            randomPair.removeAll()
            if pairArray_use_count >= 2 {
                // ◆代表ペア配列の要素数 >= 2 の場合
                // 代表ペア配列から2組のペアをランダムに選出し、ランダムペア配列に格納
                
                // pairArray_use= [[1, 3], [1, 4], [2, 3], [2, 4]]のとき
                // [1, 3], [2, 4]が選出される
                var uniqueFlg :Bool = false
                for_uni: for i in 0..<pairArray_use_count {
                    r11 = pairArray_use[i][0]
                    r12 = pairArray_use[i][1]
                    
                    for j in (i + 1)..<pairArray_use_count {
                        r21 = pairArray_use[j][0]
                        r22 = pairArray_use[j][1]
                        
                        if r11 != r12  && r11 != r21  && r11 != r22  && r12 != r21  && r12 != r22  && r21 != r22 {
                            // 4人がユニークな場合、フラグを立ててループを抜ける
                            uniqueFlg = true
                            break for_uni
                        }
                    }
                }
                if uniqueFlg == true {
                    // pairArray_useに4人ともユニークな2ペアの組み合わせが存在する場合
                    // そのままランダムペア配列に格納
                    randomPair.append([r11, r12])
                    randomPair.append([r21, r22])
                } else {
                    // 4人のうち2人でも重複する場合
                    // ランダムに1ペア抽出
                    r1 = Int.random(in: 1...pairArray_use_count) - 1
                    r11 = pairArray_use[r1][0]
                    r12 = pairArray_use[r1][1]
                    for i in (0..<candidate.count).reversed() {
                        if candidate[i] == r11 || candidate[i] == r12 {
                            candidate.remove(at: i)
                        }
                    }
//                    print("candidate=",candidate)
                    // 残り2人を抽出
                    r21 = candidate[0]
                    r22 = candidate[1]
                    randomPair.append([r11, r12])
                    randomPair.append([r21, r22])
                }
                
            } else if pairArray_use_count == 1 {
                // ◆代表ペア配列の要素数 == 1 の場合
                // 代表ペア配列の1組のペアを選出
                r11 = pairArray_use[0][0]
                r12 = pairArray_use[0][1]
                for i in (0..<candidate.count).reversed() {
                    if candidate[i] == r11 || candidate[i] == r12 {
                        candidate.remove(at: i)
                    }
                }
//                print("candidate=",candidate)
                // 選出者4人のうち残り2人でペア作成
                r21 = candidate[0]
                r22 = candidate[1]
                var checkFlg1: Bool = true
                // 前回値ペア配列との重複を除外
                for_check1: for q in 0..<previousPairArrayCount {
                    if (r21 == previousPairArray[q][0] && r22 == previousPairArray[q][1]) || (r21 == previousPairArray[q][1] && r22 == previousPairArray[q][0]) || (r21 == previousPairArray[q][2] && r22 == previousPairArray[q][3]) || (r21 == previousPairArray[q][3] && r22 == previousPairArray[q][2]) {
                        // 重複していた場合
                        checkFlg1 = false
                        break for_check1
                    }
                }
                if checkFlg1 == false {
                    // 重複していた場合、順番入れ替え
                    // ランダムペア配列に格納
                    randomPair.append([r11, r22])
                    randomPair.append([r12, r21])
                } else {
                    // 重複していない場合、順番そのまま
                    // ランダムペア配列に格納
                    randomPair.append([r11, r12])
                    randomPair.append([r21, r22])
                }
                
            } else {
                //
                // 前回値ペア配列と重複しない処理を追加
                //
                
                
                
                // ◆代表ペア配列の要素数 <= 0 の場合
                // 選出者4人から2組のペアをランダムに作って代表ペア配列に格納
                r1 = Int.random(in: 1...candidate.count) - 1
                r11 = candidate[r1]
                candidate.remove(at: r1)
                r1 = Int.random(in: 1...candidate.count) - 1
                r12 = candidate[r1]
                candidate.remove(at: r1)
                r21 = candidate[0]
                r22 = candidate[1]
//                print("r11=",r11, "r12=",r12, "r21=",r21, "r22=",r22)
                
                // 前回値ペア配列との重複を除外
                var duplicateFlg: Bool = true
                var duplicateFlg2: Bool = true
                for_dupl_chack1: for q in 0..<previousPairArrayCount {
                    if (r11 == previousPairArray[q][0] && r12 == previousPairArray[q][1]) || (r11 == previousPairArray[q][1] && r12 == previousPairArray[q][0]) || (r11 == previousPairArray[q][2] && r12 == previousPairArray[q][3]) || (r11 == previousPairArray[q][3] && r12 == previousPairArray[q][2]) {
                        // 重複していた場合
                        duplicateFlg = false
                        break for_dupl_chack1
                    }
                }
//                print("duplicateFlg=",duplicateFlg)
                if duplicateFlg == true {
                    for_dupl_chack2: for q in 0..<previousPairArrayCount {
                        // 重複していない場合、もう一方のペアの重複を確認
                        if (r21 == previousPairArray[q][0] && r22 == previousPairArray[q][1]) || (r21 == previousPairArray[q][1] && r22 == previousPairArray[q][0]) || (r21 == previousPairArray[q][2] && r22 == previousPairArray[q][3]) || (r21 == previousPairArray[q][3] && r22 == previousPairArray[q][2]) {
                            // 重複していた場合
                            duplicateFlg = false
                            break for_dupl_chack2
                        }
                    }
                    if duplicateFlg == true {
                        // [r11, r12]と[r21, r22]が前回値ペア配列のペアと重複していない
                        // ランダムペア配列に格納
                        randomPair.append([r11, r12])
                        randomPair.append([r21, r22])
                    }
                }
//                print("duplicateFlg=",duplicateFlg)
                if duplicateFlg == false {
                    for_dupl_chack3: for q in 0..<previousPairArrayCount {
                        if (r11 == previousPairArray[q][0] && r21 == previousPairArray[q][1]) || (r11 == previousPairArray[q][1] && r21 == previousPairArray[q][0]) || (r11 == previousPairArray[q][2] && r21 == previousPairArray[q][3]) || (r11 == previousPairArray[q][3] && r21 == previousPairArray[q][2]) {
                            // 重複していた場合
                            duplicateFlg2 = false
                            break for_dupl_chack3
                        }
                    }
                }
//                print("duplicateFlg2=",duplicateFlg2)
                // ([r11,r12] or [r21,r22] が重複している) and [r11,r21] が重複していない場合
                if duplicateFlg == false && duplicateFlg2 == true {
                    // 重複していない場合、もう一方のペアの重複を確認
                    for_dupl_chack4: for q in 0..<previousPairArrayCount {
                        if (r12 == previousPairArray[q][0] && r22 == previousPairArray[q][1]) || (r12 == previousPairArray[q][1] && r22 == previousPairArray[q][0]) || (r12 == previousPairArray[q][2] && r22 == previousPairArray[q][3]) || (r12 == previousPairArray[q][3] && r22 == previousPairArray[q][2]) {
                            // 重複していた場合
                            duplicateFlg2 = false
                            break for_dupl_chack4
                        }
                    }
                    if duplicateFlg2 == true {
                        // [r11, r21]と[r12, r22]が前回値ペア配列のペアと重複していない
                        // ランダムペア配列に格納
                        randomPair.append([r11, r21])
                        randomPair.append([r12, r22])
                    }
                }
//                print("duplicateFlg2=",duplicateFlg2)
                if duplicateFlg2 == false {
                    // 残りのペアをランダムペア配列に格納（運任せで重複は仕方ない）
                    randomPair.append([r11, r22])
                    randomPair.append([r12, r21])
                }
                
            }
            
            // ◆ランダムペア配列をtempArrayに追加
            // 取得した乱数をtempArrayに追加
            tempArray.append(String(randomPair[0][0]))
            tempArray.append(String(randomPair[0][1]))
            tempArray.append(String(randomPair[1][0]))
            tempArray.append(String(randomPair[1][1]))
            
            // ユニークチェック配列にも追加
            uniquecheckArray.append(String(randomPair[0][0]))
            uniquecheckArray.append(String(randomPair[0][1]))
            uniquecheckArray.append(String(randomPair[1][0]))
            uniquecheckArray.append(String(randomPair[1][1]))
            
            // マスター配列にカウント+1
            for i in 0..<Int(argNum)! {
                if masterArray[i][0] == Int(tempArray[0]) || masterArray[i][0] == Int(tempArray[1]) || masterArray[i][0] == Int(tempArray[2]) || masterArray[i][0] == Int(tempArray[3]) {
                    masterArray[i][1] += 1
                }
            }
//            print("masterArray=",masterArray)
            
            // ペア選出数をペア配列に記録
            for i in 0..<pairArrayCount {
                if (pairArray[i][0] == Int(tempArray[0])!) && (pairArray[i][1] == Int(tempArray[1])!) {
                    pairArray[i][2] += 1
                } else if (pairArray[i][0] == Int(tempArray[2])!) && (pairArray[i][1] == Int(tempArray[3])!) {
                    pairArray[i][2] += 1
                }
            }
//            print("追加ペア選出")
//            print("pairArray=",pairArray)
//            print("tempArray=",tempArray)
            
            // ソート
            if Int(tempArray[0])! > Int(tempArray[1])! {
                let temp = tempArray[0]
                tempArray[0] = tempArray[1]
                tempArray[1] = temp
            }
            if Int(tempArray[2])! > Int(tempArray[3])! {
                let temp = tempArray[2]
                tempArray[2] = tempArray[3]
                tempArray[3] = temp
            }

            // cell表示用配列に乱数追加
            cellArray.append([tempArray[0],tempArray[1],tempArray[2],tempArray[3]])
//            print("cellArray=",cellArray)
            
//            print("addCellRowCount=",addCellRowCount)
            if addCellRowCount % numX != 0 {
                // コート数-1までのコートにペアを設定する場合
                // 前回値ペア配列の一時保管用配列に今回のペアを記録
                previousPairArray_temp[addCellRowCount - 1][0] = Int(tempArray[0])!
                previousPairArray_temp[addCellRowCount - 1][1] = Int(tempArray[1])!
                previousPairArray_temp[addCellRowCount - 1][2] = Int(tempArray[2])!
                previousPairArray_temp[addCellRowCount - 1][3] = Int(tempArray[3])!
//                print("H")
//                print("previousPairArray_temp=",previousPairArray_temp)
            } else {
                // 最後のコートにペアを設定する場合
                // 前回値ペア配列を一時保管用配列で更新
                for s in 0..<previousPairArrayCount_temp {
                    previousPairArray[s][0] = previousPairArray_temp[s][0]
                    previousPairArray[s][1] = previousPairArray_temp[s][1]
                    previousPairArray[s][2] = previousPairArray_temp[s][2]
                    previousPairArray[s][3] = previousPairArray_temp[s][3]
                }
                // 前回値ペア配列に今回のペアを記録
                previousPairArray[addCellRowCount - 1][0] = Int(tempArray[0])!
                previousPairArray[addCellRowCount - 1][1] = Int(tempArray[1])!
                previousPairArray[addCellRowCount - 1][2] = Int(tempArray[2])!
                previousPairArray[addCellRowCount - 1][3] = Int(tempArray[3])!
//                print("I")
//                print("previousPairArray=",previousPairArray)
//                print("previousPairArrayCount_temp=",previousPairArrayCount_temp)
            }
            addCellRowCount += 1
            
            // temp配列の要素を全削除
            tempArray.removeAll()
        }
        
        // 追加ボタン押下処理の最後に配列の全要素を削除
        masterArray_Temp.removeAll()
        masterArray_Low.removeAll()
        masterArray_High.removeAll()
        randomArray.removeAll()
        uniquecheckArray.removeAll()
    }
    
    // -----------------------
    // -----------------------
    // tableView関連処理
    // -----------------------
    // -----------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    //フッターの色を透明に
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView: UIView = UIView()
//        footerView.backgroundColor = UIColor.clear
//        return footerView
//    }
//    //フッターの高さ
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 100 //高さ
//    }
    
    //セルの個数を指定するデリゲートメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // チェック有数計上配列リセット
//        for i in 0..<Int(argNum)! {
//            checkCountArray[i][1] = 0
//        }
        
        return cellArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! Cell1
        
        
        // スクリーンの横縦幅
        let screenWidth:CGFloat = tableView.frame.width
        //let screenHeight:CGFloat = self.view.frame.height
        
        
        
        // セル上のオブジェクト位置とサイズ指定
        cell.initialset(sW: screenWidth, sH: tableView.rowHeight)
        //print("cell.initialset")
        
        // セルに表示する値を設定する
        cell.cellLabel1!.text = cellArray[indexPath.row][0] + "."
        cell.cellLabel2!.text = cellArray[indexPath.row][1] + "."
        cell.cellLabel3!.text = cellArray[indexPath.row][2] + "."
        cell.cellLabel4!.text = cellArray[indexPath.row][3] + "."
        
        // セルが選択された時の背景色を消す
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        // セルの色付け
        if (Int(indexPath.row) % (numX*2)) < numX {
            //cell.backgroundColor = UIColor(red: 153/255, green: 255/255, blue: 255/255, alpha: 0.3)
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        } else {
            //cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 153/255, alpha: 0.3)
            //cell.backgroundColor = UIColor(red: 220/255, green: 240/255, blue: 180/255, alpha: 0.3)
            cell.backgroundColor = subColor
        }
        
//        print("チェック2")
        
        
        //--------------------------------
        // セル追加時の先頭セルに太い横線を描画
        //--------------------------------
        cell.cellLabelLine!.numberOfLines = 0    // 0行
        cell.cellLabelLine!.backgroundColor = UIColor.clear // 背景色
        cell.cellLabelLine!.layer.borderWidth = 2.0    // 枠線の幅
        cell.cellLabelLine!.layer.borderColor = cellLineColor[indexPath.row % numX].cgColor    // 枠線の色
        
        //--------------------------------
        // セル追加時の先頭セルに回転数の枠設定
        //--------------------------------
        //cell.tableViewLine!.numberOfLines = 0    // 0行
        //cell.tableViewLine!.backgroundColor = UIColor.clear // 背景色
        //cell.tableViewLine!.layer.borderWidth = 2.0    // 枠線の幅
        cell.tableViewLine!.layer.cornerRadius = 6    // 丸み
        cell.tableViewLine!.clipsToBounds = true      // 丸み
        //cell.tableViewLine!.layer.borderColor = tableViewLineColor[indexPath.row % numX].cgColor    // 枠線の色
        // 1回転の先頭行に回転数を表示
        if indexPath.row % numX == 0 {
            cell.tableViewLine!.backgroundColor = mainColor
            cell.tableViewLine!.text = String(Int(floor(Double(indexPath.row / numX))) + 1)
        } else {
            cell.tableViewLine!.backgroundColor = UIColor.clear
            cell.tableViewLine!.text = ""
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
            cell.cellLabelRound.text = "●"
            cell.cellLabelCheck.text = "✓"
            //cell.cellLabelRound.textColor = UIColor(red: 0/255, green: 204/255, blue: 102/255, alpha: 1)
            cell.cellLabelRound.textColor = mainColor
            cell.cellLabelRound.font = UIFont.systemFont(ofSize: 30)
            
//            print("cellCheckFlg=", cellCheckFlg)
            if cellCheckFlg[indexPath.row] == 0 {
                // チェック有数計上配列を更新
                //checkCountArray
//                print("cellArray=", cellArray)
//                print("checkCountArray=", checkCountArray)
                // セルに表示する値をa1に設定する
                let a0 = Int(cellArray[indexPath.row][0])!
                let a1 = Int(cellArray[indexPath.row][1])!
                let a2 = Int(cellArray[indexPath.row][2])!
                let a3 = Int(cellArray[indexPath.row][3])!
                for i in 0..<checkCountArray.count {
                    switch checkCountArray[i][0] {
                    case a0:
                        checkCountArray[i][1] += 1
                    case a1:
                        checkCountArray[i][1] += 1
                    case a2:
                        checkCountArray[i][1] += 1
                    case a3:
                        checkCountArray[i][1] += 1
                    default :
                        break
                    }
                }
//                print("checkCountArray=", checkCountArray)
//                checkCountArray[a0][1] += 1
//                checkCountArray[a1][1] += 1
//                checkCountArray[a2][1] += 1
//                checkCountArray[a3][1] += 1
//                print("checkCountArray+=",checkCountArray)
                
                cellCheckFlg[indexPath.row] = 1
            }
        }else{
//            print("チェック無")
            // セルのチェックマークを外す
            cell.cellLabelRound.text = "◯"
            cell.cellLabelCheck.text = ""
            cell.cellLabelRound.textColor = .lightGray
            cell.cellLabelRound.font = UIFont.systemFont(ofSize: 26)
            //cell.cellLabelRound.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
            
//            print("indexPath.row=",indexPath.row)
//            print("cellCheckFlg=", cellCheckFlg)
            if cellCheckFlg[indexPath.row] == 1 {
                // チェック有数計上配列を更新
                //checkCountArray
//                print("cellArray=", cellArray)
//                print("checkCountArray=", checkCountArray)
                // セルに表示する値をa1に設定する
                let a0 = Int(cellArray[indexPath.row][0])!
                let a1 = Int(cellArray[indexPath.row][1])!
                let a2 = Int(cellArray[indexPath.row][2])!
                let a3 = Int(cellArray[indexPath.row][3])!
                for i in 0..<checkCountArray.count {
                    switch checkCountArray[i][0] {
                    case a0:
                        checkCountArray[i][1] -= 1
                    case a1:
                        checkCountArray[i][1] -= 1
                    case a2:
                        checkCountArray[i][1] -= 1
                    case a3:
                        checkCountArray[i][1] -= 1
                    default :
                        break
                    }
                }
//                print("checkCountArray=", checkCountArray)
//                checkCountArray[a0][1] -= 1
//                checkCountArray[a1][1] -= 1
//                checkCountArray[a2][1] -= 1
//                checkCountArray[a3][1] -= 1
//                print("checkCountArray-=",checkCountArray)
                
                cellCheckFlg[indexPath.row] = 0
            }
        }
        
        
        return cell
    }
    
    
    
    // -----------------------
    // セルのチェックマーク処理
    // -----------------------
    // セルが選択された時に呼び出される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("セル選択")
        
        
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
        
    }
    
    
    // -------------------------------
    // メッセージ表示・メイン画面へ戻る処理
    // -------------------------------
    @IBAction func endButton(_ sender: Any) {
        // 確認メッセージ
        alert(title: "終了しますか？",message: "今回の対戦表はリセットされます")
    }
    
    func alert(title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .default,handler:{(action: UIAlertAction!) -> Void in
                //
            })
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default,handler:{(action: UIAlertAction!) -> Void in
                // すべての配列の要素を削除する（初期化）
                self.masterArray.removeAll()
                //self.cellArray.removeAll()
                self.initArray.removeAll()
                self.randomArray.removeAll()
                self.tempArray.removeAll()
                self.uniquecheckArray.removeAll()
                self.cellCheckFlg.removeAll()
                self.checkCountArray.removeAll()
                self.previousPairArray.removeAll()
                finalMasterArray.removeAll()
                
                // ContainerVCBで使用したデータを削除
                self.deleteContainerVCBData()
                
                // 初期設定画面に戻る
                //self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            })
        )
        present(alertController, animated: true)
    }
    
    // --------------------------------------
    // UserDefaultsからContainerVCBで使用した
    // itemListとselectedGroupNameを削除
    // --------------------------------------
    func deleteContainerVCBData() {
        // itemList削除
        UserDefaults.standard.removeObject(forKey: containerItemListKey)
        // selectedGroupName削除
        UserDefaults.standard.removeObject(forKey: selectedGroupNameKey)
    }
    
    // --------------------------------------
    // 試合数画面・メンバー追加削除画面へ列引渡し
    // --------------------------------------
    // segueが動作することをViewControllerに通知するメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segueのIDを確認して特定のsegueのときのみ動作させる
        // 試合数画面へ遷移する場合
        if segue.identifier == "toVC3" {
            // 遷移先のViewControllerを取得
            let next = segue.destination as? ViewController3
            // 遷移先の変数にメンバー数分の参加数を渡す
            for i in 0..<Int(argNum)! {
                // 設定
                if (next?.masterArray.count)! >= Int(argNum)! {
//                    print("A")
                    // 2回目以降の画面遷移（遷移先配列に前回格納済み）
                    for j in 0..<2 {
//                        print("2回目以降のVC3への遷移")
                        next?.masterArray[i][j] = masterArray[i][j]
                    }
                } else {
//                    print("B")
                    // 初回の画面遷移（遷移先配列は空）
//                    print("初回のVC3への遷移")
                    next?.masterArray.append([masterArray[i][0], masterArray[i][1]])
                }
            }
            // 参加メンバー数を渡す
            next?.currentMembers = Int(argNum)!
            
            // checkCountArray[]を渡す
//            print("checkCountArray=", checkCountArray)
//            print("argNum=", argNum)
//            print("totalMember=", totalMember)
            next?.checkCountArray.removeAll() // 初期化
//            if Int(argNum)! > totalMember {
//                for i in 0..<Int(argNum)! {
//                    next?.checkCountArray.append([checkCountArray[i][0], checkCountArray[i][1]])
//                }
//            } else {
//                for i in 0..<totalMember {
//                    next?.checkCountArray.append([checkCountArray[i][0], checkCountArray[i][1]])
//                }
//            }
            for i in 0..<checkCountArray.count {
                next?.checkCountArray.append([checkCountArray[i][0], checkCountArray[i][1]])
            }
//            print("next?.checkCountArray=", next?.checkCountArray as Any)
        }
        
        // メンバー追加削除画面へ遷移する場合
        if segue.identifier == "toVC4" {
            // 遷移先のViewControllerを取得
            let next = segue.destination as? ViewController4
            // 遷移先の変数に値を渡す
            // masterArray[]を渡す
            next?.masterArray.removeAll()
            for i in 0..<Int(argNum)! {
                next?.masterArray.append([masterArray[i][0], masterArray[i][1]])
            }
            // 参加人数(argNum)を渡す
            next?.currentMembers = Int(argNum)!
            // コート数(numX)を渡す
            next?.numX = numX
            // pairArray[]を渡す
            next?.pairArray.removeAll()
            for i in 0..<pairArrayCount {
                next?.pairArray.append([pairArray[i][0], pairArray[i][1], pairArray[i][2]])
            }
            
        }
    }
    
    
    //--------------------------
    // 集計画面へ移動
    //--------------------------
    @IBAction func aggregateButton(_ sender: Any) {
        // 画面遷移実行
        performSegue(withIdentifier: "toVC3", sender: nil)
    }
    //--------------------------
    // メンバー追加削除画面へ移動
    //--------------------------
    @IBAction func addRemoveMemberButton(_ sender: Any) {
        // 画面遷移実行
        performSegue(withIdentifier: "toVC4", sender: nil)
    }
    
    
    //--------------------------
    // 画面部分切り替え
    //--------------------------
    @IBAction func segmentedControl(_ sender: Any) {
        // SegmentControlの選択で画面表示切り替え
        if (sender as AnyObject).selectedSegmentIndex == 0 {
            // その他：「対戦表」選択時
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentA")
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
            
            // 最背面に表示
            self.view.sendSubviewToBack(self.containerView)
        } else {
            // 「メンバー表」選択時
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentB")
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
            
            // 最前面に表示
            self.view.bringSubviewToFront(self.containerView)
        }
    }
    
    
    //--------------------------
    // 画面切り替え用関数群
    //--------------------------
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)

        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParent: nil)
        self.addChild(newViewController)
        self.addSubview(subView: newViewController.view, toView:self.containerView!)
        // TODO: Set the starting state of your constraints here
        newViewController.view.layoutIfNeeded()

        // TODO: Set the ending state of your constraints here

        UIView.animate(withDuration: 0.5, animations: {
                // only need to call layoutIfNeeded here
                newViewController.view.layoutIfNeeded()
            },
            completion: { finished in
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParent()
                newViewController.didMove(toParent: self)
        })
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

//
class MyView: UIView {
    
    var startX: CGFloat = 0
    var startY: CGFloat = 44
    var endX: CGFloat = 600
    var endY: CGFloat = 44
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        path.close()
        path.lineWidth = 5.0 // 線の太さ
        UIColor.brown.setStroke() // 色をセット
        path.stroke()
    }
    
}
