//
//  SettingSceneViewController.swift
//  ARWorld
//
//  Created by JinYingZhe on 12/8/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import Alamofire

class SettingSceneViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var avatarUIV: UIImageView!
    @IBOutlet weak var backMusicUV: UIView!
    @IBOutlet weak var effectMusicUV: UIView!
    @IBOutlet weak var controlMethodUV: UIView!
    @IBOutlet weak var backMusicUS: UISlider!
    @IBOutlet weak var effectMusicUS: UISlider!
    @IBOutlet weak var methodUSC: UISegmentedControl!
    @IBOutlet weak var nameUL: UILabel!
    @IBOutlet weak var levelUL: UILabel!
    @IBOutlet weak var goldUL: UILabel!
    @IBOutlet weak var crystalUL: UILabel!
    @IBOutlet weak var goldUV: UIView!
    @IBOutlet weak var crystalUV: UIView!
    
    @IBOutlet weak var saveUB: UIButton!
    @IBOutlet weak var logoutUB: UIButton!
    @IBOutlet weak var nicknameUL: UILabel!
    @IBOutlet weak var paymentUL: UILabel!
    @IBOutlet weak var openIDUL: UILabel!
    @IBOutlet weak var nameUTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Global.userInfo.openID == "" {
            let alert = UIAlertController(title: "警  告", message: "如果您打开此页面，请使用微信帐户重新登录。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    self.navigationController?.popToRootViewController(animated: true)
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                }}))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                case .cancel:
                    print("cancel")
                    self.navigationController?.popViewController(animated: true)
                case .destructive:
                    print("destructive")
                }}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        initTitleBar()
        
        saveUB.layer.cornerRadius = 10.0
        saveUB.layer.borderWidth = 1
        saveUB.layer.borderColor = UIColor.white.cgColor
        
        logoutUB.layer.cornerRadius = 10.0
        logoutUB.layer.borderWidth = 1
        logoutUB.layer.borderColor = UIColor.red.cgColor
        
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 18.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as [NSObject : AnyObject] as [NSObject : AnyObject] as? [NSAttributedString.Key : Any] , for: .normal)
        
        let backVolumn = UserDefaults.standard.integer(forKey: Global.keyARGameBackVolumn)
        backMusicUS.value = Float(backVolumn)
        
        let effectVolumn = UserDefaults.standard.integer(forKey: Global.keyARGameEffectVolumn)
        effectMusicUS.value = Float(effectVolumn)
        
        let isPhone = UserDefaults.standard.bool(forKey: Global.keyARGameIsPhone)
        if !isPhone {
            methodUSC.selectedSegmentIndex = 1
        }
        else{
            methodUSC.selectedSegmentIndex = 0
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        goldUV.layer.borderColor = UIColor.lightGray.cgColor
        goldUV.layer.borderWidth = 1.0
        goldUV.layer.cornerRadius = 5.0
        
        crystalUV.layer.borderColor = UIColor.lightGray.cgColor
        crystalUV.layer.borderWidth = 1.0
        crystalUV.layer.cornerRadius = 5.0
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
        nameUTF.resignFirstResponder()
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func backMusicUSChange(_ sender: Any) {
        UserDefaults.standard.set(Int(backMusicUS.value), forKey: Global.keyARGameBackVolumn)
    }
    
    @IBAction func effectMusicUSChange(_ sender: Any) {
        UserDefaults.standard.set(Int(effectMusicUS.value), forKey: Global.keyARGameEffectVolumn)
    }
    
    @IBAction func methodUSCChange(_ sender: Any) {
        var isPhone = true
        if methodUSC.selectedSegmentIndex == 1 {
            isPhone = false
        }
        UserDefaults.standard.set(isPhone, forKey: Global.keyARGameIsPhone)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        nameUTF.resignFirstResponder()
    }
    
    @IBAction func saveUBClick(_ sender: Any) {
        nameUTF.resignFirstResponder()
        
        if Global.userInfo.name == nameUTF.text {
            let alert = UIAlertController(title: "华   林", message: "配置文件数据不会更改。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好   的", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    self.nameUTF.becomeFirstResponder()
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                }}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let param = [
            "id" : "\(Global.userInfo.id)",
            "name" : nameUTF.text ?? ""
            ] as [String : String]
        
        Global.apiConnection(param: param, url: "user_update", method: .get, success: {(json) in
            Global.userInfo.name = self.nameUTF.text!
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onClickLogoutBtn(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)  
    }
    
}
