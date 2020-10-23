//
//  MainSceneViewController.swift
//  ARWorld
//
//  Created by JinYingZhe on 12/7/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit

class MainSceneViewController: UIViewController {
    
    @IBOutlet weak var settingUB: UIButton!
    @IBOutlet weak var startUB: UIButton!
    @IBOutlet weak var shopUB: UIButton!
    @IBOutlet weak var profileUB: UIButton!
    @IBOutlet weak var avatarUIV: UIImageView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var crystalUL: UILabel!
    @IBOutlet weak var goldUL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initTitleBar()

        startUB.layer.cornerRadius = 10.0
        startUB.layer.borderWidth = 1
        startUB.layer.borderColor = UIColor.white.cgColor
        
        settingUB.layer.cornerRadius = 10.0
        settingUB.layer.borderWidth = 1
        settingUB.layer.borderColor = UIColor.white.cgColor
        
        shopUB.layer.cornerRadius = 10.0
        shopUB.layer.borderWidth = 1
        shopUB.layer.borderColor = UIColor.white.cgColor
        
        profileUB.layer.cornerRadius = 10.0
        profileUB.layer.borderWidth = 1
        profileUB.layer.borderColor = UIColor.white.cgColor

        let font = UIFont.systemFont(ofSize: 14)
        segment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
//        let str : NSString = "如果你没有AR眼镜，请点击此链接。"
//        lblGotoShop.delegate = self
//        lblGotoShop.text = str as String
//        let range : NSRange = str.range(of: "请点击此链接。")
//        lblGotoShop.addLink(to: NSURL(string: "https://item.taobao.com/item.htm?id=575767392308")! as URL, with: range)
        
    }

    @IBAction func onSegumaneChange(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            UserDefaults.standard.set(true, forKey: Global.keyARGameIsPhone)
        }
        else{
            UserDefaults.standard.set(false, forKey: Global.keyARGameIsPhone)
        }
    }

    func initTitleBar () {
        avatarUIV.layer.cornerRadius = 10.0
        avatarUIV.layer.borderWidth = 1
        avatarUIV.layer.borderColor = UIColor.white.cgColor
        let url = URL(string: Global.userInfo.headUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data {
            let image = UIImage(data: imageData)
            avatarUIV.image = image
        }

        crystalUL.text = String(Global.userInfo.cnt_crystal)
        goldUL.text = String(Global.userInfo.cnt_gold)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        crystalUL.text = String(Global.userInfo.cnt_crystal)
        goldUL.text = String(Global.userInfo.cnt_gold)
        
        let isPhone = UserDefaults.standard.bool(forKey: Global.keyARGameIsPhone)
        if !isPhone {
            segment.selectedSegmentIndex = 1
        }
        else{
            segment.selectedSegmentIndex = 0
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
