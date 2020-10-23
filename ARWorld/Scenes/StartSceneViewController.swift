//
//  StartSceneViewController.swift
//  ARWorld
//
//  Created by JinYingZhe on 12/7/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import Alamofire

class StartSceneViewController: UIViewController {
    @IBOutlet weak var loginUV: UIView!
    @IBOutlet weak var loginUB: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginUV.layer.cornerRadius = 10.0
        loginUB.layer.cornerRadius = 10.0
    }

    @IBAction func onLogin(_ sender: Any) {
        Global.shared.isLoginMode = 1;
        self.wechatLogin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func wechatLogin() {
        let wechatHooks = "weixin://"
        let wechatUrl = NSURL(string: wechatHooks)
        if UIApplication.shared.canOpenURL(wechatUrl! as URL)
        {
            let req = SendAuthReq()
            req.scope = "snsapi_userinfo" //Important that this is the same
            req.state = "co.company.yourapp_wx_login" //This can be any random value
            WXApi.send(req)
        } else {
            //redirect to safari because the user doesn't have Wechat
            let alert = UIAlertController(title: "警告", message: "请安装并登录微信。再试一次。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: { action in
                switch action.style{
                case .default:
                    UIApplication.shared.open(NSURL(string: "https://itunes.apple.com/us/app/wechat/id414478124?mt=8")! as URL)
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                }}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func userlogin(_ sender: Any) {
        let alert = UIAlertController(title: "登  录", message: "请输入您的用户名。", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "随机名"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            var name: String = (textField?.text)!
            if name == "" {
                name = "随机名"
            }
            let nickname: String = (UIDevice.current.identifierForVendor?.uuidString)!
            
            let param = [
                "name" : name,
                "nickname" : nickname,
                "headurl" : Global.downUrl + "profile.png"
            ]
            
            Global.apiConnection(param: param, url: "user_clogin", method: .get, success: {(json) in
                Global.userInfo.name = name
                Global.userInfo.nickname = nickname
                Global.userInfo.openID = ""
                
                Global.userInfo.id = json["id"].intValue
                Global.userInfo.cnt_crystal = json["cnt_crystal"].intValue
                Global.userInfo.cnt_gold = json["cnt_gold"].intValue
                Global.userInfo.cnt_ammo = json["cnt_ammo"].intValue
                Global.userInfo.payed = json["payed"].intValue
                Global.userInfo.level = json["level"].intValue
                Global.userInfo.passround = json["passround"].intValue
                Global.userInfo.headUrl = Global.downUrl + "profile.png"
                
                self.playMainScene()
            })
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func playMainScene () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainSceneViewController") as! MainSceneViewController
        self.navigationController?.pushViewController(mainVC, animated: false)
    }
    
}
