//
//  ProfileSceneViewController.swift
//  ARWorld
//
//  Created by JinYingZhe on 12/8/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import Alamofire

class ProfileSceneViewController: UIViewController
    , UITableViewDelegate
    , UITableViewDataSource
{
    @IBOutlet weak var avatarUIV: UIImageView!
    @IBOutlet weak var nameUL: UILabel!
    @IBOutlet weak var levelUL: UILabel!
    @IBOutlet weak var goldUL: UILabel!
    @IBOutlet weak var crystalUL: UILabel!
    @IBOutlet weak var goldUV: UIView!
    @IBOutlet weak var crystalUV: UIView!

    @IBOutlet weak var unReadUCB: CheckBox!
    @IBOutlet weak var historyUTV: UITableView!
    
    var allHistories = [HistoryInfo]()
    var showHistories = [HistoryInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Global.userInfo.openID == "" {
            let alert = UIAlertController(title: "警  告", message: "如果您打开此页面，请使用微信帐户重新登录。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: { action in
                if action.style == .default {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
                if action.style == .cancel {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        initTitleBar()
        getAllHistory()
        
        crystalUL.text = String(Global.userInfo.cnt_crystal)
        
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 18.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as [NSObject : AnyObject] as [NSObject : AnyObject] as? [NSAttributedString.Key : Any] , for: .normal)
        
        registerTableViewCell()
    }
    
    func registerTableViewCell () {
        let cell = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        historyUTV.register(cell, forCellReuseIdentifier: "HistoryTableViewCell")
    }
    
    func getAllHistory() {
        let param = [
            "user_id" : "\(Global.userInfo.id)"
        ]
        
        Global.apiConnection(param: param, url: "get_allHistories", method: .get, success: {(json) in
            let result = json["result"].arrayValue
            for n in 0...result.count - 1 {
                let dicHistory = result[n]
                let history = HistoryInfo(data: dicHistory)
                self.allHistories.append(history)
            }
            self.historyUTV.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initTitleBar () {
        avatarUIV.layer.cornerRadius = 20.0
        avatarUIV.layer.borderWidth = 1
        avatarUIV.layer.borderColor = UIColor.white.cgColor
        let url = URL(string: Global.userInfo.headUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data {
            let image = UIImage(data: imageData)
            avatarUIV.image = image
        }
        
        nameUL.text = Global.userInfo.name
        levelUL.text = "层.\(Global.userInfo.level)"
        crystalUL.text = String(Global.userInfo.cnt_crystal)
        goldUL.text = String(Global.userInfo.cnt_gold)
        
        goldUV.layer.borderColor = UIColor.lightGray.cgColor
        goldUV.layer.borderWidth = 1.0
        goldUV.layer.cornerRadius = 5.0
        
        crystalUV.layer.borderColor = UIColor.lightGray.cgColor
        crystalUV.layer.borderWidth = 1.0
        crystalUV.layer.cornerRadius = 5.0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func backUBClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showHistories.removeAll()
        if unReadUCB.isChecked {
            
        } else {
            showHistories = allHistories
        }
        
        if showHistories.count == 0 {
            return 0
        }
        
        return showHistories.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyUTV.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as! HistoryTableViewCell
        if indexPath.row > 0 {
            cell.data = showHistories[indexPath.row - 1]
            cell.reload()
        } else {
            cell.noUL.text = "No"
            cell.typeUL.text = "分 类"
            cell.typeUL.textColor = .white
            cell.priceUL.text = "金 额"
            cell.datetimeUL.text = "时 间"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        let history = showHistories[indexPath.row - 1]
        if history.isOpened {
            return
        }
        if Global.userInfo.cnt_crystal < 10 {
            let shopViewController = ShopSceneViewController()
            navigationController?.pushViewController(shopViewController, animated: false)
        } else {
            let param = [
                "user_id" : "\(Global.userInfo.id)",
                "id" : "\(history.id)",
                "price" : history.gift,
                "type" : "\(history.type)"
            ]
            
            Global.apiConnection(param: param, url: "open_history", method: .get, success: {(json) in
                history.isOpened = true
                Global.userInfo.cnt_crystal = Global.userInfo.cnt_crystal - 10
                Global.userInfo.cnt_gold = Global.userInfo.cnt_gold + Int(history.gift)!
                self.crystalUL.text = "\(Global.userInfo.cnt_crystal)"
                self.goldUL.text = "\(Global.userInfo.cnt_gold)"
                self.historyUTV.reloadData()
            })
        }
    }
}
