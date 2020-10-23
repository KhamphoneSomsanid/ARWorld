
//
//  WeChatResponseHandller.swift
//  SuperAV
//
//  Created by Apple on 5/24/17.
//  Copyright © 2017 dip kasyap dpd.ghimire@gmail.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import Alamofire

let paymentBackEndUrl = "https://api.mch.weixin.qq.com/pay/unifiedorder"
private let appID = "wxb89c848276248cb8"
private let appSecret = "e97cb22266e2b6d5b944bcccf3aa7cb0"

private let accessTokenPrefix = "https://api.weixin.qq.com/sns/oauth2/access_token?"
private let userInfoPrefix = "https://api.weixin.qq.com/sns/userinfo?"

enum AlipayStatus {
    case success,userCancelled,failed,pending
}

enum PayMentMethod:String {
    case alipay,wechat
}

enum WeChatPaymentResult {
    case success,failed,userCancelled
}

protocol WeChatResponseHandllerDelegate:class {
    func weChatPaymnetDidCompleted(_ result:WeChatPaymentResult,withResponseData response:String?)
}

/**********************************************************************************************************************************/


class WeChatResponseHandller: NSObject, WXApiDelegate {
    
    static let shared = WeChatResponseHandller()
    var delegate:WeChatResponseHandllerDelegate?
    var accessToken = ""
    var openID = ""
    var nickName = ""
    var headUrl = ""

    
    func onReq(_ req: BaseReq) {
        //
    }
    
    func onResp(_ resp: BaseResp!) {
        if Global.shared.isLoginMode == 1 {
            if let authResp = resp as? SendAuthResp {
                if authResp.code != nil {
                    let dict = ["response": authResp.code]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WeChatAuthCodeResp"), object: nil, userInfo: dict as [AnyHashable : Any])
                    let _: HTTPHeaders = [
                        "Content-Type": "application/json"
                    ]
                    let authocode = dict["response"];
                    
                    let param = [
                        "appid" : appID,
                        "secret" : appSecret,
                        "code" : authocode!!,
                        "grant_type" : "authorization_code"
                    ]  as [String : String]
                    print(param)

                    Alamofire.request(accessTokenPrefix, method: .post, parameters: param).validate().responseJSON { response in
                        switch response.result {
                        case .success:
                            do {
                                print(response)
                                let dic=(response.result.value) as! NSDictionary
                                self.accessToken = dic["access_token"] as! String
                                self.openID = dic["openid"] as! String
                                self.getUserInfo()
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                    
                } else {
                    let dict = ["response": "Fail"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WeChatAuthCodeResp"), object: nil, userInfo: dict as [AnyHashable : Any])
                }
            } else {
                let dict = ["response": "Fail"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WeChatAuthCodeResp"), object: nil, userInfo: dict as [AnyHashable : Any])
            }
        }
        else
        {
            if let response = resp {
                switch (response.errCode) {
                case 0:
                    if let delegate = WeChatResponseHandller.shared.delegate {
                        delegate.weChatPaymnetDidCompleted(.success, withResponseData: response.errStr)
                    }
                    //success
                    break
                case -2:
                    //user canceled
                    if let delegate = WeChatResponseHandller.shared.delegate {
                        delegate.weChatPaymnetDidCompleted(.userCancelled, withResponseData: response.errStr)
                    }
                    break
                default:
                    // other all fail
                    if let delegate = WeChatResponseHandller.shared.delegate {
                        delegate.weChatPaymnetDidCompleted(.failed, withResponseData: response.errStr)
                    }
                    break
                }
            }
            else
            {
                // value nil show failure messes
            }
        }
    }
    
    private func buildAccessTokenLink(withCode code: String) -> String {
        return accessTokenPrefix + "appid=" + appID + "&secret=" + appSecret + "&code=" + code + "&grant_type=authorization_code"
    }
    
    private func buildUserInfoLink(withOpenID openID: String, accessToken: String) -> String {
        return userInfoPrefix + "access_token=" + accessToken + "&openid=" + openID
    }
    
    
    func getUserInfo(){
        let param: Parameters = [
            "access_token" : self.accessToken,
            "openid" : appSecret
        ]
        let _: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(userInfoPrefix, method: .post, parameters: param).validate().responseJSON { response in
            switch response.result {
            case .success:
                print(response)
                let dic = (response.result.value) as! NSDictionary
                self.nickName = dic["nickname"] as! String
                self.headUrl = dic["headimgurl"] as! String

                self.login()
                print(dic)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func login() {
        Global.userInfo.nickname = nickName
        Global.userInfo.openID = openID
        Global.userInfo.headUrl = headUrl
        
        let param = [
            "openid" : Global.userInfo.openID,
            "headurl" : Global.userInfo.headUrl,
            "nickname" : Global.userInfo.nickname
        ] as [String : String]
        
        Global.apiConnection(param: param, url: "user_login", method: .get, success: {(json) in          
            Global.userInfo.id = json["id"].intValue
            Global.userInfo.cnt_crystal = json["cnt_crystal"].intValue
            Global.userInfo.cnt_gold = json["cnt_gold"].intValue
            Global.userInfo.cnt_ammo = json["cnt_ammo"].intValue
            Global.userInfo.payed = json["payed"].intValue
            Global.userInfo.name = json["name"].stringValue
            Global.userInfo.level = json["level"].intValue
            Global.userInfo.passround = json["passround"].intValue

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.playMainScene()
        })
    }
}
