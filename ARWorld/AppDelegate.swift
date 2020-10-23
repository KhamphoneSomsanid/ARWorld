//
//  AppDelegate.swift
//  ARWorld
//
//  Created by JinYingZhe on 12/7/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?
    var accessToken = ""
    var openID = ""
    var nickName = ""
    private let appID = "wxb89c848276248cb8"
    private let appSecret = "e97cb22266e2b6d5b944bcccf3aa7cb0"
    
    private let accessTokenPrefix = "https://api.weixin.qq.com/sns/oauth2/access_token?"
    private let userInfoPrefix = "https://api.weixin.qq.com/sns/userinfo?"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        WXApi.registerApp(appID)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: WeChatResponseHandller.shared)
    }
    
    internal func application(_ app: UIApplication,
                             open url: URL,
                             options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        WXApi.handleOpen(url, delegate: WeChatResponseHandller.shared)
        return true        
    }
    
    // no equiv. notification. return NO if the application can't open for some reason
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let isSuccess = WXApi.handleOpen(url, delegate: WeChatResponseHandller.shared)
        return isSuccess
    }
    
    func onReq(_ req: BaseReq) {
        // Unused
    }
    
    func onResp(_ resp: BaseResp) {
        // Where the magic happens
        if let authResp = resp as? SendAuthResp {
            if authResp.code != nil {
                let dict = ["response": authResp.code]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WeChatAuthCodeResp"), object: nil, userInfo: dict as [AnyHashable : Any])
                
                let authocode = dict["response"];
                let param: Parameters = [
                    "appid" : appID,
                    "secret" : appSecret,
                    "code" : authocode!!,
                    "grant_type" : "authorization_code"
                ]
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

        Alamofire.request(userInfoPrefix, method: .post, parameters: param).validate().responseJSON { response in
            switch response.result {
            case .success:
                print(response)
                let dic = (response.result.value) as! NSDictionary
                self.nickName = dic["nickname"] as! String
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
        Global.userInfo.headUrl = "http://thirdwx.qlogo.cn/mmopen/vi_32/7fia1rhibUk9Beokh82088p0IuVDZmmzLpMTdicFIuialdbuI0VltbmMmQicicXsvWavwEYd8K1XvUiapZvTCzzLaeyuQ/132"
        
        let param = [
            "openid" : Global.userInfo.openID,
            "headurl" : Global.userInfo.headUrl,
            "nickname" : Global.userInfo.nickname
        ]
        
        Global.apiConnection(param: param, url: "user_login", method: .get, success: {(json) in
            Global.userInfo.id = json["id"].intValue
            Global.userInfo.cnt_crystal = json["cnt_crystal"].intValue
            Global.userInfo.cnt_gold = json["cnt_gold"].intValue
            Global.userInfo.cnt_ammo = json["cnt_ammo"].intValue
            Global.userInfo.payed = json["payed"].intValue
            Global.userInfo.name = json["name"].stringValue
            Global.userInfo.level = json["level"].intValue
            Global.userInfo.passround = json["passround"].intValue
            
            self.playMainScene()
        })
    }
    
    func playMainScene() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainSceneViewController") as! MainSceneViewController
        
        let nav = UINavigationController(rootViewController: mainVC)
        nav.navigationBar.isHidden = true
        window?.rootViewController = nav
    }

}

