//
//  ViewController3.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/01/17.
//  Copyright © 2021 Kaede. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController3: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet weak var barItemBack: UIBarButtonItem!
    
    @IBOutlet weak var tableView2: UITableView!
    
    @IBOutlet weak var line: UILabel!
    
    @IBOutlet weak var sortNoButton: UIButton!
    
    @IBOutlet weak var sortTotButton: UIButton!
    
    @IBOutlet weak var sortCheckButton: UIButton!
    
    @IBOutlet weak var labelRound: UILabel!
    
    @IBOutlet weak var labelCheck: UILabel!
    
    @IBOutlet weak var labelRoundW: UILabel!
    
    
    @IBOutlet weak var upLabel1: UILabel!
    
    @IBOutlet weak var downLabel1: UILabel!
    
    @IBOutlet weak var upLabel2: UILabel!
    
    @IBOutlet weak var downLabel2: UILabel!
    
    @IBOutlet weak var upLabel3: UILabel!
    
    @IBOutlet weak var downLabel3: UILabel!
    
    @IBOutlet weak var naviBar: UINavigationBar!
    
    @IBOutlet weak var remarksTextView: UITextView! // 備考
    
    
    // AdMobバナー
    var bannerView: GADBannerView!
    
    
//    // デフォルトColor
//    var mainColor = UIColor(red: 21/255, green: 196/255, blue: 161/255, alpha: 1)
//    var subColor = UIColor(red: 226/255, green: 247/255, blue: 239/255, alpha: 1)
    
    
//    var argNum : String =  "50"      // 参加人数
    var masterArray : [[Int]] = []  // マスター配列を宣言
    var checkCountArray : [[Int]] = []  // チェック有の数を計上[参加メンバーのNo, チェック数]
    var cellArray : [[Int]] = []  // セル表示用配列を宣言
    var currentMembers: Int = 0   // 現在の参加メンバー数
    
    // 全体のメンバー数（削除された番号もカウント）:finalMasterArray.count
    var totalMember: Int = 0
    
    var sortFlg :Int = 0
    
    var screenWidth:CGFloat = 414
    var screenHeight:CGFloat = 896
    
    //let cellArray : [[Int]] = [[1,2],[2,2],[3,1]]
    
    
//    // viewが表示される度に呼ばれる
//    override func viewWillAppear(_ animated: Bool) {
//        // タブの無効化
//        let tagetTabBar = 0 //タブの番号
//        self.tabBarController!.tabBar.items![tagetTabBar].isEnabled = false // タブの無効化
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
//        let screenHeight:CGFloat = self.view.frame.height
        
        barItemBack.tintColor = mainColor
        
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
        
        
        
        //--------------------------------
        // セル追加時の先頭セルに太い横線を描画
        //--------------------------------
        line!.numberOfLines = 0    // 0行
        line!.backgroundColor = UIColor.clear // 背景色
        line!.layer.borderWidth = 2.0    // 枠線の幅
        line!.layer.borderColor = UIColor.darkGray.cgColor   // 枠線の色
        
        
        //--------------------------------------------------
        // finalMasterArray[]に初期値を格納、または、選出回数を更新
        //--------------------------------------------------
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
                totalMember = finalMasterArray.count
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
        
        
        //--------------------------------
        // セル表示用配列に前画面情報を格納
        //--------------------------------
        cellArray.removeAll()
//        print("checkCountArray=", checkCountArray)
//        print("finalMasterArray=", finalMasterArray)
        for i in 0..<finalMasterArray.count {
            for_j: for j in 0..<checkCountArray.count {
                if finalMasterArray[i][0] == checkCountArray[j][0] {
                    // checkCountArrayに記録があれば引き継ぐ
                    cellArray.append([finalMasterArray[i][0], finalMasterArray[i][1], checkCountArray[j][1]])
                    break for_j
                }
                if j + 1 >= checkCountArray.count {
                    // checkCountArrayに記録がなければ"0"を格納
                    cellArray.append([finalMasterArray[i][0], finalMasterArray[i][1], 0])
                }
            }
        }
//        print("finalMasterArray=", finalMasterArray)
//        print("checkCountArray=", checkCountArray)
//        print("cellArray=", cellArray)
        
        
        //--------------------------------
        // メンバーの追加・削除がある場合、備考を表示
        //--------------------------------
        // 備考表示用のメンバー追加削除有無フラグ
        var addMemberFlg: Bool = false
        var deleteMemberFlg: Bool = false
        // メンバーの追加・削除があるかチェック
        if addMemberFlg == false && deleteMemberFlg == false {
            for i in 0..<finalMasterArray.count {
                if addMemberFlg == false && finalMasterArray[i][2] == 1 {
                    // メンバーの追加がある場合、備考表示フラグを立てる
                    addMemberFlg = true
                }
                if deleteMemberFlg == false && finalMasterArray[i][2] == 9 {
                    // メンバーの削除がある場合、備考表示フラグを立てる
                    deleteMemberFlg = true
                }
            }
        }
        if addMemberFlg == true && deleteMemberFlg == true {
            remarksTextView.text = "※合計の()は、途中から追加したときの、他のメンバーの合計参加数の参考値。"
                                + "()内外の数値を合算し、合計参加数を調整しています。"
        } else if addMemberFlg == true && deleteMemberFlg == false {
            remarksTextView.text = "※合計の()は、途中から追加したときの、他のメンバーの合計参加数の参考値。"
                                + "()内外の数値を合算し、合計参加数を調整しています。"
            
        } else if addMemberFlg == false && deleteMemberFlg == true {
            remarksTextView.text = ""
        } else {
            remarksTextView.text = ""
        }
        
        //TextView編集不可
        remarksTextView.isUserInteractionEnabled = true // タップ時、キーボード非表示
        remarksTextView.isEditable = false // タップ時、キーボード非表示
        
        //
        tableView2.dataSource = self
        tableView2.delegate = self
        
    }
    
    // viewDidLoad()のあとに呼ばれる
    override func viewWillLayoutSubviews() {
        //print("width=\(view.bounds.width), height=\(view.bounds.height)")
        // Modal画面サイズ取得
        screenWidth = view.bounds.width
        screenHeight = view.bounds.height
        
        // SafeAreaの高さ
        //let topSafeAreaHeight = self.view.safeAreaInsets.top
        let topSafeAreaHeight = self.naviBar.frame.height + screenHeight * 10/842
        
        //let button_y = line.frame.origin.y - screenHeight * 60/842
        let button_height = (line.frame.origin.y - topSafeAreaHeight) * 0.62
        let button_y = line.frame.origin.y - button_height - screenHeight * 12/842
//        let upLabel_y = button_y + sortNoButton.frame.height/2 -  screenHeight * 17/842
//        let downLabel_y = button_y + sortNoButton.frame.height/2 +  screenHeight * 3/842
        
        // 表項目ボタン表示設定
        sortNoButton.frame = CGRect(x:screenWidth * 42/414, y:button_y, width:screenWidth * 70/414, height:button_height)
        sortNoButton.layer.cornerRadius = 10
        sortNoButton.backgroundColor = UIColor.white // 背景色を指定
        sortNoButton.setTitleColor(UIColor.black, for: .normal) // ラベルの色を指定
        sortNoButton.layer.borderWidth = 1.0 //外枠の太さを指定
        sortNoButton.layer.borderColor = mainColor.cgColor //外枠の色を指定
        
        
        sortTotButton.frame = CGRect(x:screenWidth * 162/414, y:button_y, width:screenWidth * 70/414, height:button_height)
        sortTotButton.layer.cornerRadius = 10
        sortTotButton.backgroundColor = UIColor.white // 背景色を指定
        sortTotButton.setTitleColor(UIColor.black, for: .normal) // ラベルの色を指定
        sortTotButton.layer.borderWidth = 1.0 //外枠の太さを指定
        sortTotButton.layer.borderColor = mainColor.cgColor //外枠の色を指定
        
        
        sortCheckButton.frame = CGRect(x:screenWidth * 282/414, y:button_y, width:screenWidth * 70/414, height:button_height)
        sortCheckButton.layer.cornerRadius = 10
        sortCheckButton.setTitle("", for: .normal)
        sortCheckButton.backgroundColor = UIColor.white // 背景色を指定
        sortCheckButton.setTitleColor(UIColor.black, for: .normal) // ラベルの色を指定
        sortCheckButton.layer.borderWidth = 1.0 //外枠の太さを指定
        sortCheckButton.layer.borderColor = mainColor.cgColor //外枠の色を指定
        
        // チェックマークの周りの●
        labelRoundW.frame = CGRect(x:screenWidth * 290/414, y:button_y, width:screenWidth * 50/414, height:button_height)
        labelRoundW.textColor = UIColor.white // 背景色を指定
        
        // チェックマーク
        labelRound.frame = CGRect(x:screenWidth * 292/414, y:button_y, width:screenWidth * 50/414, height:button_height)
        labelRound.textColor = mainColor
        self.view.bringSubviewToFront(labelRound) // 最前面
        labelCheck.frame = CGRect(x:screenWidth * 292/414, y:button_y, width:screenWidth * 50/414, height:button_height)
        self.view.bringSubviewToFront(labelCheck) // 最前面
        
        // ソートマークの配置設定
        let sortMarkLabelWidth = screenWidth * 14/414
        let sortMarkLabelHeight = screenHeight * 14/842
        
        upLabel1.frame = CGRect(x:sortNoButton.frame.maxX - sortMarkLabelWidth, y:sortNoButton.frame.midY - sortMarkLabelHeight, width:sortMarkLabelWidth, height:sortMarkLabelHeight)
        upLabel1.textColor = mainColor
        self.view.bringSubviewToFront(upLabel1) // 最前面
        
        downLabel1.frame = CGRect(x:sortNoButton.frame.maxX - sortMarkLabelWidth, y:sortNoButton.frame.midY, width:sortMarkLabelWidth, height:sortMarkLabelHeight)
        downLabel1.textColor = mainColor
        self.view.bringSubviewToFront(downLabel1) // 最前面
        
        upLabel2.frame = CGRect(x:sortTotButton.frame.maxX - sortMarkLabelWidth, y:sortTotButton.frame.midY - sortMarkLabelHeight, width:sortMarkLabelWidth, height:sortMarkLabelHeight)
        upLabel2.textColor = mainColor
        self.view.bringSubviewToFront(upLabel2) // 最前面

        downLabel2.frame = CGRect(x:sortTotButton.frame.maxX - sortMarkLabelWidth, y:sortTotButton.frame.midY, width:sortMarkLabelWidth, height:sortMarkLabelHeight)
        downLabel2.textColor = mainColor
        self.view.bringSubviewToFront(downLabel2) // 最前面

        upLabel3.frame = CGRect(x:sortCheckButton.frame.maxX - sortMarkLabelWidth, y:sortCheckButton.frame.midY - sortMarkLabelHeight, width:sortMarkLabelWidth, height:sortMarkLabelHeight)
        upLabel3.textColor = mainColor
        self.view.bringSubviewToFront(upLabel3) // 最前面

        downLabel3.frame = CGRect(x:sortCheckButton.frame.maxX - sortMarkLabelWidth, y:sortCheckButton.frame.midY, width:sortMarkLabelWidth, height:sortMarkLabelHeight)
        downLabel3.textColor = mainColor
        self.view.bringSubviewToFront(downLabel3) // 最前面
        
//        upLabel1.frame = CGRect(x:screenWidth * CGFloat(42 + 90 - 15 - 4)/414, y:upLabel_y, width:screenWidth * 15/414, height:screenHeight * 15/842)
//        upLabel1.textColor = mainColor

//        downLabel1.frame = CGRect(x:screenWidth * CGFloat(42 + 90 - 15 - 4)/414, y:downLabel_y, width:screenWidth * 15/414, height:screenHeight * 15/842)
//        downLabel1.textColor = mainColor
//
//        upLabel2.frame = CGRect(x:screenWidth * CGFloat(162 + 90 - 15 - 4)/414, y:upLabel_y, width:screenWidth * 15/414, height:screenHeight * 15/842)
//        upLabel2.textColor = mainColor
//
//        downLabel2.frame = CGRect(x:screenWidth * CGFloat(162 + 90 - 15 - 4)/414, y:downLabel_y, width:screenWidth * 15/414, height:screenHeight * 15/842)
//        downLabel2.textColor = mainColor
//
//        upLabel3.frame = CGRect(x:screenWidth * CGFloat(283 + 90 - 15 - 4)/414, y:upLabel_y, width:screenWidth * 15/414, height:screenHeight * 15/842)
//        upLabel3.textColor = mainColor
//
//        downLabel3.frame = CGRect(x:screenWidth * CGFloat(283 + 90 - 15 - 4)/414, y:downLabel_y, width:screenWidth * 15/414, height:screenHeight * 15/842)
//        downLabel3.textColor = mainColor
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        didReceiveMemoryWarning()
    }

    //セルの個数を指定するデリゲートメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return masterArray.count
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! Cell2
        
        // セルに番号を表示
        //cell.textLabel?.text = "\(indexPath.row)"
        
        // スクリーンの横縦幅
        let screenWidth:CGFloat = tableView.frame.width
//        let screenHeight:CGFloat = self.view.frame.height
//        // セルの高さを可変に設定
//        tableView2.estimatedRowHeight = 60
//        tableView2.rowHeight = UITableView.automaticDimension
        
//        print("screenWidth2=",screenWidth)
        // セル上のオブジェクト位置とサイズ指定
        //cell.initialset(sW: screenWidth, sH: tableView.rowHeight)
        cell.initialset(sW: screenWidth, sH: 60)
        //print("cell.initialset")
//        print("screenWidth=",screenWidth)
//        print("tableView2.rowHeight=",tableView.rowHeight)
        
        
        // 選択されたセルの背景色を設定
        let cellSelectedBgView = UIView()
        cellSelectedBgView.backgroundColor = subColor
        cell.selectedBackgroundView = cellSelectedBgView
        
        cell.backgroundColor = UIColor.white // セル白色
        cell.selectionStyle = .default // セルの選択可能にする
        
//        print("indexPath.row=", indexPath.row)
//        print("cellArray=", cellArray)
        
        
        //
        //エラー発生しやすい？
        //画面遷移途中でcell表示が間に合っていないことが原因？
        
//        print("cellArray=", cellArray)
//        print("indexPath.row=", indexPath.row)
        // セルに表示する値を設定する
        cell.CellLabelNo!.text = String(cellArray[indexPath.row][0])
        cell.CellLabelTotal!.text = String(cellArray[indexPath.row][1])
        cell.cellLabelCheckCount!.text = String(cellArray[indexPath.row][2])
        
        
        // 補正値・"削除済み"の表示
        cell.CellLabelCorrectionValue!.text = "" //デフォルトは空欄
        for i in 0..<finalMasterArray.count {
            if cellArray[indexPath.row][0] == finalMasterArray[i][0] {
                switch finalMasterArray[i][2] {
                case 1:
                    // 追加削除フラグ=0(追加) の場合、(補正値)を表示する
                    cell.CellLabelCorrectionValue!.text = "(" + String(finalMasterArray[i][3]) + ")"
//                    print("補正値を格納")
                case 9:
                    // 追加削除フラグ=9(削除) の場合、"削除済み"を表示する
                    cell.CellLabelCorrectionValue!.text = "削除済み"
                    // 削除済みの場合のみ、特別処理
                    cell.backgroundColor = grayOutColor // セルをグレーアウトする
                    cell.selectionStyle = .none // セルの選択不可にする
                default:
                    // 補正値!=0 の場合、表示しない
                    // デフォルトのまま
//                    print("デフォルトのまま")
                    break
                }
                
                
//                if finalMasterArray[i][2] == 1 {
//                    // 補正値=0(追加) の場合、"(補正値)"を表示する
//                    cell.CellLabelCorrectionValue!.text = "(" + String(finalMasterArray[i][3]) + ")"
//                    print("補正値を格納")
//                } else {
//                    // 補正値!=0 の場合、表示しない
//                    // デフォルトのまま
//                    print("デフォルトのまま")
//                }
            }
        }
        
        
        return cell
    }
    
    
    // 「No.」をソート
    @IBAction func sortNo(_ sender: Any) {
        if sortFlg < 1 {
            // 降順ソート
            cellArray.sort{$0[0] > $1[0]}
            sortFlg = 1
        } else {
            // 昇順ソート
            cellArray.sort{$0[0] < $1[0]}
            sortFlg = 0
        }
        // tableViewをリロードしてチェック反映
        tableView2.reloadData()
    }
    
    // 「合計」をソート
    @IBAction func sortTotal(_ sender: Any) {
        if sortFlg < 1 {
            // 降順ソート
            cellArray.sort{$0[1] > $1[1]}
            sortFlg = 1
        } else {
            // 昇順ソート
            cellArray.sort{$0[1] < $1[1]}
            sortFlg = 0
        }
        // tableViewをリロードしてチェック反映
        tableView2.reloadData()
    }
    
    // 「チェック有合計」をソート
    @IBAction func sortCheck(_ sender: Any) {
        if sortFlg < 1 {
            // 降順ソート
            cellArray.sort{$0[2] > $1[2]}
            sortFlg = 1
        } else {
            // 昇順ソート
            cellArray.sort{$0[2] < $1[2]}
            sortFlg = 0
        }
        // tableViewをリロードしてチェック反映
        tableView2.reloadData()
    }
    
    
    

    @IBAction func returnToVC2(_ sender: Any) {
        // 配列初期化
        masterArray.removeAll()
        checkCountArray.removeAll()
        cellArray.removeAll()
        self.dismiss(animated: true, completion: nil)
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
