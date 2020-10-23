//
//  ShopSceneViewController.swift
//  ARWorld
//
//  Created by JinYingZhe on 12/7/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftyXMLParser

import StoreKit

private let appID = "wxb89c848276248cb8"
private let appSecret = "e97cb22266e2b6d5b944bcccf3aa7cb0"
private let PartnerId = "1511744901"
private let APIKey = "nianxing123nianxing588nianxing00"
private let getPrePayIdUrl = "https://api.mch.weixin.qq.com/pay/unifiedorder"

class ShopSceneViewController: UIViewController, XMLParserDelegate, WXApiDelegate, GoodUIViewCellDelegate{
    
    @IBOutlet weak var goodsListUSV: UIScrollView!
    @IBOutlet weak var avatarUIV: UIImageView!
    @IBOutlet weak var nameUL: UILabel!
    @IBOutlet weak var levelUL: UILabel!
    @IBOutlet weak var crystalUL: UILabel!
    @IBOutlet weak var goldUL: UILabel!
    @IBOutlet weak var ammoUL: UILabel!
    @IBOutlet weak var goldUV: UIView!
    @IBOutlet weak var crystalUV: UIView!
    @IBOutlet weak var ammoUV: UIView!
    
    var goodCnt = 10
    var goods = [GoodModel]()
    var selGood = GoodModel()
    
    var products: [SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initTitleBar()
        
        WeChatResponseHandller.shared.delegate = self
        self.getAllGoods()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reload()
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
        ammoUL.text = String(Global.userInfo.cnt_ammo)
        
        goldUV.layer.borderColor = UIColor.lightGray.cgColor
        goldUV.layer.borderWidth = 1.0
        goldUV.layer.cornerRadius = 5.0
        
        crystalUV.layer.borderColor = UIColor.lightGray.cgColor
        crystalUV.layer.borderWidth = 1.0
        crystalUV.layer.cornerRadius = 5.0
        
        ammoUV.layer.borderColor = UIColor.lightGray.cgColor
        ammoUV.layer.borderWidth = 1.0
        ammoUV.layer.cornerRadius = 5.0
    }
    
    func initView() {
        let heightUSV = goodsListUSV.frame.size.height
        let widthSUV = heightUSV * 2 / 3
        goodsListUSV.contentSize = CGSize(width: widthSUV * CGFloat(goodCnt), height: heightUSV)
        for i in 0...goodCnt - 1 {
            let goodUVC = Bundle.main.loadNibNamed("GoodUIViewCell", owner: self, options: nil)?.first as! GoodUIViewCell
            goodUVC.good = goods[i]
            goodUVC.frame = CGRect(x: widthSUV * CGFloat(i), y: 0, width: widthSUV, height: heightUSV)
            goodUVC.goodNameUL.text = goods[i].name
            goodUVC.crystalCntUL.text = String(goods[i].cnt_crystal)
            goodUVC.costUL.text = "\(CGFloat(goods[i].cost) / 100.0) 元"
            let url = URL(string: goods[i].imageUrl)
            let data = try? Data(contentsOf: url!)
            if let imageData = data {
                let image = UIImage(data: imageData)
                goodUVC.crystalUIV.image = image
            }
            if goods[i].name == "得到弹药" {
                goodUVC.gettingIcoImg.image = UIImage(named: "ico_ammo")
            }
            goodUVC.delegate = self
            
            goodsListUSV.addSubview(goodUVC)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShopSceneViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
    }
    
    @objc func reload() {
        products = []
        
        ARworldProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                let count: Int = (products?.count)!
                if count > 0 {
                    self.products = products!
                }
            }
        }
    }
    
    @objc func restoreTapped(_ sender: AnyObject) {
        ARworldProducts.store.restorePurchases()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let index = products.index(where: { product -> Bool in
                product.productIdentifier == productID
            })
            else { return }
        
//        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    func getAllGoods() {
        Global.apiConnection(param: [:], url: "get_allgoods", method: .get, success: {(json) in
            Global.allGuns.removeAll()
            let result = json["result"].arrayValue
            for n in 0...result.count - 1 {
                let good = GoodModel()
                
                let dicGood = result[n]
                good.cnt_crystal = dicGood["cnt_crystal"].intValue
                good.id = dicGood["id"].intValue
                good.cost = dicGood["cost"].intValue
                good.detail = dicGood["detail"].stringValue
                good.imageUrl = dicGood["imageUrl"].stringValue
                good.name = dicGood["name"].stringValue
                good.other = dicGood["other"].stringValue
                
                self.goods.append(good)
            }
            self.goodCnt = result.count
            self.initView()
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onClickBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func onClickPurchaseDelegate(withGood good: GoodModel) {
        if Global.userInfo.openID == "" {
            let alert = UIAlertController(title: "警  告", message: "如果您使用此功能，请使用您的微信帐户重新登录。", preferredStyle: .alert)
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
        selGood = good
        
        let locale = NSLocale.current.languageCode
        if locale == "zh" {
            self.getWeChatPaywithOrderName(name: "Buy Items", price: String(good.cost))
        } else {
            let product = products[good.id - 1]
            ARworldProducts.store.buyProduct(product)
        }
    }

    func buyItems () {
        let param = [
            "user_id" : "\(Global.userInfo.id)",
            "good_id" : "\(selGood.id)",
            "cnt_crystal" : "\(selGood.cnt_crystal)",
            "cost" : "\(selGood.cost)"
            ] as [String : String]
        
        Global.apiConnection(param: param, url: "user_pay", method: .get, success: {(json) in
            Global.userInfo.cnt_crystal = json["cnt_crystal"].intValue
            Global.userInfo.cnt_ammo = json["cnt_ammo"].intValue
            Global.userInfo.payed += self.selGood.cost
            self.crystalUL.text = String(Global.userInfo.cnt_crystal)
            self.ammoUL.text = String(Global.userInfo.cnt_ammo)
        })
    }
    
    func getWeChatPaywithOrderName( name: String?, price: String?) {
        Global.shared.isLoginMode = 0
        let orderName = name
        // 订单金额,单位（分）, 1是0.01元
        let orderPrice = price
        // 支付类型，固定为APP
        let orderType = "APP"
        // 随机数串
        let noncestr = genNonceStr()
        // 商户订单号
        let orderNO = genOutTradNo()
        //================================
        //预付单参数订单设置
        //================================
        var packageParams: [AnyHashable : Any] = [:]
        
        packageParams["appid"] = appID //开放平台appid
        packageParams["mch_id"] = PartnerId //商户号
        packageParams["nonce_str"] = noncestr //随机串
        packageParams["trade_type"] = orderType //支付类型，固定为APP
        packageParams["body"] = orderName //订单描述，展示给用户
        packageParams["out_trade_no"] = orderNO //商户订单号
        packageParams["total_fee"] = orderPrice //订单金额，单位为分
        packageParams["spbill_create_ip"] = "127.0.0.1"
        packageParams["notify_url"] = "http://weixin.qq.com" //支付结果异步通知
        
        //        let prePayid = sendPrepay(packageParams)
        let send = self.genPackage(packageParams)
        var prepay_id = ""
        var request = URLRequest(url: URL(string: getPrePayIdUrl)!)
        request.httpMethod = "POST"
        request.httpBody = send?.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            let newString = (responseString! as String).replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
            let xml = try! XML.parse(newString)
            
            // access xml element
            let prepayid = xml["xml"]["prepay_id"].text
            print(prepayid!)
            prepay_id = prepayid! as String
            
            let timeStamp = self.genTimeStamp()
            // 调起微信支付
            
            let request = PayReq()
            request.partnerId = PartnerId
            request.prepayId = prepay_id
            request.package = "Sign=WXPay"
            request.nonceStr = noncestr!
            request.timeStamp = UInt32(timeStamp!) ?? 0
            
            var signParams: [AnyHashable : Any] = [:]
            signParams["appid"] = appID
            signParams["partnerid"] = PartnerId
            signParams["noncestr"] = request.nonceStr
            signParams["package"] = request.package
            signParams["timestamp"] = timeStamp
            signParams["prepayid"] = request.prepayId
            
            //生成签名
            let sign = self.genSign(signParams as NSDictionary)
            
            //添加签名
            request.sign = sign!
            
            WXApi.send(request)
            
        }
        task.resume()
        
    }
    
    func genPackage(_ packageParams: [AnyHashable : Any]?) -> String? {
        var sign = ""
        var reqPars = ""
        
        // 生成签名
        sign = self.genSign(packageParams! as NSDictionary) ?? ""
        
        let keys =  ((packageParams! as NSDictionary).allKeys as! [String])
        reqPars += "<xml>"
        for categoryId: String? in keys {
            if ((categoryId?.count) != nil){
                if let anId = packageParams?[categoryId ?? ""] {
                    reqPars += "<\(categoryId ?? "")>\(anId)</\(categoryId ?? "")>"
                }
                
            }
            else{
                break
            }
        }
        reqPars += "<sign>\(sign)</sign></xml>"
        
        return reqPars
    }
    
    func sendPrepay(_ prePayParams: [AnyHashable : Any]?) -> String? {
        let send = self.genPackage(prePayParams)
        
        var prepay_id = ""
        
        var request = URLRequest(url: URL(string: getPrePayIdUrl)!)
        request.httpMethod = "POST"
        request.httpBody = send?.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            let newString = (responseString! as String).replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
            let xml = try! XML.parse(newString)
            
            // access xml element
            let prepayid = xml["xml"]["prepay_id"].text
            print(prepayid!)
            prepay_id = prepayid! as String
            
            
        }
        task.resume()
        
        return prepay_id
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func MD5(_ string: String) -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = string.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    func genTimeStamp() -> String? {
        return String(format: "%.0f", Date().timeIntervalSince1970)
    }
    
    func genNonceStr() -> String? {
        return self.MD5("\(Int(arc4random()) % 10000)")
    }
    
    func genOutTradNo() -> String? {
        return self.MD5("\(Int(arc4random()) % 10000)")
    }
    
    func genSign(_ signParams:NSDictionary) -> String? {
        
        //        let keys = signParams.allKeys
        let sortedKeys =  (signParams.allKeys as! [String]).sorted()
        var sign = ""
        for key: String in sortedKeys {
            sign += key
            sign += "="
            sign += signParams[key] as? String ?? ""
            sign += "&"
        }
        
        let signString = (sign.copy() as AnyObject).substring(with: NSRange(location: 0, length: sign.count - 1))
        let result = "\(signString)&key=\(APIKey)"
        
        var signMD5 = self.MD5(result)
        // 微信规定签名英文大写
        signMD5 = signMD5?.uppercased()
        
        return signMD5
    }

    
}

extension ShopSceneViewController:WeChatResponseHandllerDelegate {
    
    //Wechat response paymnet handllerdelegate
    func weChatPaymnetDidCompleted(_ result:WeChatPaymentResult,withResponseData response:String?) {
        
        let paymentAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        print(result)
        print(response ?? "Default respose")
        
        switch result {
        case .success:
            //do clear cart of particuler caller and pop srceen to toot view controller

            self.buyItems()
            paymentAlert.message = "付款成功。"
            paymentAlert.title = "成功"
            paymentAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            break
            
        case .userCancelled:
            //show user cancelled message do nothing
            paymentAlert.message = "付款已取消。"
            paymentAlert.title = "取消"
            paymentAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            break
            
        default:
            //this is error case so show seero message ans do nothing
            paymentAlert.message = "付款失败请重试或稍后再试。"
            paymentAlert.title = "失败"
            paymentAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            break
        }
        
        self.present(paymentAlert, animated: true, completion: nil)
    }
}
