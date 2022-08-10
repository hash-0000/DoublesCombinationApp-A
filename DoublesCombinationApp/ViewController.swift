//
//  ViewController.swift
//  RandaomNumberPair_01
//
//  Created by Naoya on 2020/10/18.
//  Copyright © 2020 Kaede. All rights reserved.
//

import UIKit
import GoogleMobileAds


// デフォルトColor
var mainColor = UIColor(red: 21/255, green: 196/255, blue: 161/255, alpha: 1)
var subColor = UIColor(red: 237/255, green: 255/255, blue: 248/255, alpha: 1)
//var subColor = UIColor(red: 226/255, green: 247/255, blue: 239/255, alpha: 1)
let grayOutColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

//    var mainColor = UIColor(red: 0/255, green: 204/255, blue: 102/255, alpha: 1)
//    var subColor = UIColor(red: 220/255, green: 240/255, blue: 180/255, alpha: 0.3)

//let admobId = "ca-app-pub-8819499017949234/2255414473" //本番ID
let admobId = "ca-app-pub-3940256099942544/2934735716" //サンプルID

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate {
    
    // AdMobバナー
    var bannerView: GADBannerView!
//    var interstitialAd: GADInterstitial?
//    let interstitialAdID = "ca-app-pub-8819499017949234/2255414473"
//    let interstitialAdID = "ca-app-pub-3940256099942544/4411468910"
    
    
    var alertController : UIAlertController!    // アラート表示
    
    var pickerView: UIPickerView = UIPickerView()
    
    
    
    // "作成"ボタン
    @IBOutlet weak var addButton: UIButton!
    
    
    // 枠
    @IBOutlet weak var bkFrame: UIView!
    
    @IBOutlet weak var interFrame: UIView!
    
    @IBOutlet weak var interFrame2: UIView!
    
    @IBOutlet weak var interFrame3: UIView!
    
    
    
    // 1コートの時の参加者数の選択肢
    let list_0 = [                 "4",  "5",  "6",  "7",  "8",  "9", "10",
                "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"]
    // 2コートの時の参加者数の選択肢
    let list_1 = [                                         "8",  "9", "10",
                "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"]
    // 3コートの時の参加者数の選択肢
    let list_2 = [    "12", "13", "14", "15", "16", "17", "18", "19", "20",
                "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"]
    // 4コートの時の参加者数の選択肢
    let list_3 = [                            "16", "17", "18", "19", "20",
                "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"]
    
    @IBOutlet weak var NumOfPert : UITextField!
    
    @IBOutlet weak var uiSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var UINavigationBar: UINavigationBar!
    
    @IBOutlet weak var UIViewNavigationBar: UIView!
    
    // SegmentedControlの選択でテキストNumOfPertの最小値を変更
    @IBAction func actionSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if Int(self.NumOfPert.text!)! < 4 {
                self.NumOfPert.text! = "4"
            }
        case 1:
            if Int(self.NumOfPert.text!)! < 8 {
                self.NumOfPert.text! = "8"
            }
        case 2:
            if Int(self.NumOfPert.text!)! < 12 {
                self.NumOfPert.text! = "12"
            }
        default:
            if Int(self.NumOfPert.text!)! < 16 {
                self.NumOfPert.text! = "16"
            }
        }
    }
    
    
//    @IBAction fileprivate func someAction(){
//        showInterstitialAd()
//    }

//    // viewが表示される度に呼ばれる
//    override func viewWillAppear(_ animated: Bool) {
//        // タブの無効化
//        let tagetTabBar = 0 //タブの番号
//        self.tabBarController!.tabBar.items![tagetTabBar].isEnabled = false // タブの無効化
//    }
    
    // viewが表示される度に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        // タブの有効化
        let tagetTabBar = 0 //タブの番号
        self.tabBarController!.tabBar.items![tagetTabBar].isEnabled = true // タブの有効化
        
        // ContainerVCBで使用したデータを削除
        self.deleteContainerVCBData()
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
        
        
        subColor = UIColor(red: 220/255, green: 255/255, blue: 240/255, alpha: 1)
        mainColor = UIColor(red: 21/255, green: 180/255, blue: 140/255, alpha: 1)
        //self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = mainColor
        
        // Color設定
        addButton.backgroundColor = mainColor
        //self.navigationController?.navigationBar.barTintColor = mainColor
        //self.navigationController?.navigationBar.tintColor = .white
        
        // 枠の設定
        interFrame.layer.cornerRadius = 10
        self.view.sendSubviewToBack(interFrame)
        
        interFrame2.layer.cornerRadius = 10
        self.view.sendSubviewToBack(interFrame2)
        
        interFrame3.layer.cornerRadius = 10
        self.view.sendSubviewToBack(interFrame3)
        
        bkFrame.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.view.sendSubviewToBack(bkFrame)
        
        // view全体の背景色
        self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
//        let screenHeight:CGFloat = self.view.frame.height
        
        // AdMobバナー
        // In this case, we instantiate the banner with desired ad size.
        //bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //let adSize = GADAdSizeFromCGSize(CGSize(width: screenWidth, height: screenWidth*45/320))
        let adSize = GADAdSizeFromCGSize(CGSize(width: screenWidth, height: screenWidth*100/320))
        bannerView = GADBannerView(adSize: adSize)
        //bannerView.adUnitID = "ca-app-pub-8819499017949234/2255414473" //本番ID
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //サンプルID
        bannerView.adUnitID = admobId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        
//        interstitialAd = loadInterstitialAd()
        
        
        
        
        // "追加"ボタンのプロパティ
        //addButton.frame = CGRect(x: 100, y: 100, width: 200, height: 200)  // 1
        //addButton.center = self.view.center  // 2
                
        //addButton.backgroundColor = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 0)  // 3
        //addButton.setTitleColor(UIColor.white, for: UIControl.State.normal)  // 4
         
        //addButton.layer.borderWidth = 4  // 5
        //addButton.layer.borderColor = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 0).cgColor  // 6
         
//        addButton.layer.cornerRadius = 20  // 7
//
//        addButton.layer.shadowOffset = CGSize(width: 0, height: 3 )  // 8
//        addButton.layer.shadowOpacity = 0.8  // 9
//        addButton.layer.shadowRadius = 3  // 10
//        addButton.layer.shadowColor = UIColor.gray.cgColor  // 11
        //addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19) // 太文字
        
        
//        UINavigationBar.barTintColor = UIColor(red: 120/255, green: 255/255, blue: 180/255, alpha: 0)
        
//        UIViewNavigationBar.backgroundColor = UIColor(red: 120/255, green: 255/255, blue: 180/255, alpha: 1)
        
        
        // UIPickerView表示
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        //let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.done))
        let doneItem = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(ViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ViewController.cancel))
        let _flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        //toolbar.setItems([cancelItem, doneItem], animated: true)
        toolbar.setItems([cancelItem, _flexibleItem, doneItem], animated: true)
            
            
            
//            if (NumOfPert.text?.isAlphanumeric())! {
//                print("NumOfPertは半角数字")
//            }else{
//                print("NumOfPertは全角数字")
//            }
            
        self.NumOfPert.inputView = pickerView
        self.NumOfPert.inputAccessoryView = toolbar
        
    }
    
    // レイアウトサイズ決定後の処理
    override func viewDidLayoutSubviews() {
        // 作成ボタン表示設定
        let addButtonHeight: CGFloat = addButton.frame.height
        addButton.layer.cornerRadius = addButtonHeight * 0.3  // 7
        addButton.layer.shadowOffset = CGSize(width: 0, height: 3 )  // 8
        addButton.layer.shadowOpacity = 0.8  // 9
        addButton.layer.shadowRadius = 3  // 10
        addButton.layer.shadowColor = UIColor.gray.cgColor  // 11
    }
    
    
    // 更新バージョン有無チェック回数計上カウンター
    var appVerCheckCount = 0
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        // メイン画面3回表示ごとに最新バージョン有無チェック
        if appVerCheckCount <= 0 {
            // カウンターリセット
            appVerCheckCount = 3
            // 最新バージョン有無チェック
            appVerCheck()
        }
        appVerCheckCount -= 1
//        print("appVerCheckCount=",appVerCheckCount)
    }
    
    // ------------------------------------------------
    // 最新バージョン有無チェック・アラート表示・AppStore移動
    // ------------------------------------------------
    // Apple ID
    let appId = "1541609560"
    // 最新バージョン有無チェック
    func appVerCheck() {
        // 更新版リリース有無チェック
        AppVersionCompare.toAppStoreVersion(appId: appId) { (type) in
            //print("type=",type)
            switch type {
            case .latest: //break
                print("最新バージョンです")
                break
            case .old:
                print("旧バージョンです")
                // 最新バージョンのお知らせ
                self.verCheckAlert(title: "最新バージョンが入手可能です",message: "更新しますか？")
                //self.showAlert()
            case .error: //break
                print("エラー")
                break
            default:
                break // do nothing
            }
        }
    }
    // 更新催促アラート表示
    func verCheckAlert(title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        print("更新バージョンあり")
        alertController.addAction(UIAlertAction(title: "いいえ", style: .default,handler:{(action: UIAlertAction!) -> Void in
                //
            })
        )
        alertController.addAction(UIAlertAction(title: "はい", style: .default,handler:{(action: UIAlertAction!) -> Void in
            // AppStoreに移動
            self.openAppStore()
            })
        )
        DispatchQueue.main.async {
            // メインスレッドでアラート表示
            self.present(self.alertController, animated: true)
        }
    }
    // AppStoreのプロダクトページを開く
    func openAppStore() {
        //let appId = "1541609560"
        let urlString = "itms-apps://itunes.apple.com/app/id\(appId)"
        let url = URL(string: urlString)!
//        print("URLアクセス")
        // URLの正否チェック
        if UIApplication.shared.canOpenURL(url) {
            // URLを開く
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
//                    print("Launching \(url) was successful")
                }
            }
        }
    }
    
    
    
    // -----------------------
    // UIPickerView処理
    // -----------------------
    var tempSelectNum : String = "4"
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch uiSegmentedControl.selectedSegmentIndex {
        case 0:
            return list_0.count
        case 1:
            return list_1.count
        case 2:
            return list_2.count
        default:
            return list_3.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // uiSegmentedControlタップ不可
        uiSegmentedControl.isUserInteractionEnabled = false
        //addButton無効化
        addButton.isEnabled = false
        
        switch uiSegmentedControl.selectedSegmentIndex {
        case 0:
            return list_0[row]
        case 1:
            return list_1[row]
        case 2:
            return list_2[row]
        default:
            return list_3[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch uiSegmentedControl.selectedSegmentIndex {
        case 0:
            tempSelectNum = list_0[row]
        case 1:
            tempSelectNum = list_1[row]
        case 2:
            tempSelectNum = list_2[row]
        default:
            tempSelectNum = list_3[row]
        }
    }
    
    // キャンセル
    @objc func cancel() {
        self.NumOfPert.endEditing(true)
        // uiSegmentedControlタップ許可
        uiSegmentedControl.isUserInteractionEnabled = true
        //addButton有効化
        addButton.isEnabled = true
    }
    
    // 決定：入力完了時に空欄or半角数字かどうかチェック
    @objc func done() {
        if tempSelectNum == "" {
//            print("NumOfPertは空欄")
            // 空欄なので反映
            self.NumOfPert.text = tempSelectNum
            self.NumOfPert.endEditing(true)
        } else {
            if (tempSelectNum.isAlphanumeric()) {
//                print("NumOfPertは半角数字")
                // 半角数字なので反映
                self.NumOfPert.text = tempSelectNum
                self.NumOfPert.endEditing(true)
            }else{
//                print("NumOfPertは全角数字")
                // 半角数字ではないので決定させない
            }
        }
        
        // 参加者数>=コート数×4のチェック
        let tempIndex_A = (Int(uiSegmentedControl.selectedSegmentIndex)+1)*4
        if Int(tempSelectNum)! >= tempIndex_A {
            // 参加者数>=コート数×4のとき（選択した参加者数を格納）
            self.NumOfPert.text = tempSelectNum
            self.NumOfPert.endEditing(true)
        } else {
            // 参加者数<コート数×4のとき（最少数を格納）
            self.NumOfPert.text = String(tempIndex_A)
            self.NumOfPert.endEditing(true)
        }
        
        // uiSegmentedControlタップ許可
        uiSegmentedControl.isUserInteractionEnabled = true
        //addButton有効化
        addButton.isEnabled = true
    }

    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // -----------------------
    // 次画面へタイトル文字列引渡し
    // -----------------------
    // segueが動作することをViewControllerに通知するメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segueのIDを確認して特定のsegueのときのみ動作させる
        if segue.identifier == "toVC2" {
            // 遷移先のViewControllerを取得
            let next = segue.destination as? ViewController2
            // 遷移先の変数にコート数を渡す
            next?.numX = Int(uiSegmentedControl.selectedSegmentIndex) + 1
            // 遷移先の変数に参加人数を渡す
            let tempIndex = (Int(uiSegmentedControl.selectedSegmentIndex)+1)*4
            if Int(self.NumOfPert.text!)! >= tempIndex {
                // 参加者数>=コート数×4のとき（選択した参加者数を格納）
                next?.argNum = self.NumOfPert.text!
            } else {
                // 参加者数<コート数×4のとき（最少数を格納）
                next?.argNum = String(tempIndex)
            }
            // 開始時刻を取得
            next?.startTime = getTime()
        }
    }
    func getTime() -> String{
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let time = f.string(from: now)
        //print("time=", time)
        return time
    }
    
    //--------------------------
    // "作成"ボタン押下処理
    //--------------------------
    @IBAction func addButton(_ sender: Any) {
        // 画面遷移実行
        performSegue(withIdentifier: "toVC2", sender: nil)
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
      //print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      //print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        //print("error=",error)
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      //print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      //print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      //print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      //print("adViewWillLeaveApplication")
    }
    
}

// -----------------------
// 文字列が半角数字かどうか判定
// -----------------------
extension String {
    // 半角数字の判定(""も許可)
    func isAlphanumeric() -> Bool {
        return self.range(of: "[^0-9]+", options: .regularExpression) == nil && self != ""
    }
}

