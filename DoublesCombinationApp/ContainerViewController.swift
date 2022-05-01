//
//  ContainerViewController.swift
//  DoublesCombinationApp
//
//  Created by Naoya on 2021/12/15.
//  Copyright © 2021 Kaede. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ControllerA表示！！")
    }
    
    // subView全削除
    func removeAllSubviews(parentView: UIView){
        var subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    // デフォルト表示
    func defaultView() {
        // 背景色を無職にする
        self.view.backgroundColor = .clear
        // subViewをすべて削除
        removeAllSubviews(parentView: self.view)
    }
    
    // 自身の縦横サイズ
    var VCHeight: CGFloat = 660 // 仮の値
    var VCWidth: CGFloat = 414 // 仮の値
    
    
}
