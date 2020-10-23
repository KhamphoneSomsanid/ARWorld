//
//  Global.swift
//  ARWorld
//
//  Created by JinYingZhe on 12/7/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

// This game const parameter
let runMode = "Test"

let progressScale = 3
let rotationGun: Float = Float(-pPai / 15)
let levelDatas:[NSDictionary] = [
    ["id": "1", "dragons":
        [
            ["id": "1", "count": "3", "level": "0"]
        ]
    ],
    ["id": "2", "dragons":
        [
            ["id": "2", "count": "5", "level": "0"]
        ]
    ],
    ["id": "3", "dragons":
        [
            ["id": "1", "count": "3", "level": "1"],
            ["id": "2", "count": "2", "level": "0"]
        ]
    ],
    ["id": "4", "dragons":
        [
            ["id": "1", "count": "1", "level": "0"],
            ["id": "1", "count": "2", "level": "1"],
            ["id": "2", "count": "2", "level": "0"]
        ]
    ],
    ["id": "5", "dragons":
        [
            ["id": "1", "count": "1", "level": "0"],
            ["id": "1", "count": "2", "level": "1"],
            ["id": "2", "count": "2", "level": "1"]
        ]
    ]
]

class Global: NSObject {
    static let shared: Global = Global()
    static var baseUrl = "http://arworld.gulfamtechnical.com/Backend/"
    static var downUrl = "http://arworld.gulfamtechnical.com/uploads/"
    
//    static var baseUrl = "http://192.168.8.102/Backend/"
//    static var downUrl = "http://192.168.8.102/uploads/"

    var isLoginMode = 0
    
    static var userInfo = UserModel()
    static var levelInfo = LevelInfo()
    static var allGuns = [GunInfo]()
    static var playInfo = PlayInfo()
    static var allMonsters = [MonsterInfo]()
    
    static var keyARGameIsPhone = "KEYISPHONE"
    static var keyARGameBackVolumn = "KEYBACKVOLUMN"
    static var keyARGameEffectVolumn = "KEYEFFECTVOLUMN"
    static var keyARGameSelectedGunID = "KEYSELECTEDGUNID"
    static var keyARGameManBlood = "KEYMANBLOOD"
    static var keyARGameManAttract = "KEYMANATTRACT"
    static var keyARGameManDefend = "KEYMANDEFEND"
    static var keyARGameAmmoNumber = "KEYAMMONUMBER"
    static var keyARGameManAttractLevel = "KEYMANATTRACTLEVEL"
    static var keyARGameManDefendLevel = "KEYMANDEFENDLEVEL"
    static var keyARGameManBloodLevel = "KEYMANBLOODLEVEL"
    
    static func apiConnection(param: [String: String], url: String, method: HTTPMethod, success: @escaping ((JSON) -> Void)) {
        onShowProgressView(name: "服务器连接...")
        Alamofire.request(baseUrl + url, method: method, parameters: param).validate().responseJSON { (response) in
            if response.error != nil {
                onhideProgressView()
                return
            }
            if let data = response.result.value {
                let json = JSON.init(data)
                success(json)
            }
            onhideProgressView()
        }
    }

    static func onShowProgressView (name: String) {
        SVProgressHUD.show(withStatus: name)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setForegroundColor (UIColor.blue)
        SVProgressHUD.setBackgroundColor (UIColor.black.withAlphaComponent(0.0))
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setRingNoTextRadius(20)
        SVProgressHUD.setRingThickness(3)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.flat)
    }
    
    static func onhideProgressView() {
        SVProgressHUD.dismiss()
    }
}

class MonsterInfo: NSObject {
    var id: Int = 0
    var attact: Int = 0
    var defend: Int = 0
    var blood: Int = 0
    var speed: Int = 0
    var name: String = ""
    var nickname: String = ""
    var srcUrl: String = ""
    var regdate: String = ""
    var other: String = ""
}

class PropParam: NSObject {
    var min : Int = 0
    var max : Int = 1
    var level : Int = 1
    
    override init() {
        min = 0
        max = 1
        level = 1
    }
}

class GoodModel: NSObject {
    var cnt_crystal : Int = 0
    var cost : Int = 0
    var id : Int = 0
    var detail : String = ""
    var imageUrl : String = ""
    var name : String = ""
    var other : String = ""
}

class UserModel: NSObject {
    var id : Int = 0
    var name : String = ""
    var nickname : String = ""
    var openID : String = ""
    var headUrl : String = ""
    var cnt_crystal : Int = 100
    var cnt_gold : Int = 100
    var cnt_ammo : Int = 100
    var payed : Int = 0
    var level : Int = 1
    var passround : Int = 1
}

class GunInfo: NSObject {    
    var id : Int
    var name : String
    var level : Int = 0
    var crystal : Int = 0
    var attact : PropParam
    var volumn : PropParam
    var ability : PropParam
    var reload : PropParam
    var enable : Bool = false
    
    override init() {
        id = 0
        name = ""
        attact = PropParam.init()
        volumn = PropParam.init()
        ability = PropParam.init()
        reload = PropParam.init()
    }
    
    func loadInfo() {
        let baseKey = name + "_\(id)_"
        attact.level = UserDefaults.standard.integer(forKey: baseKey + "attact")
        volumn.level = UserDefaults.standard.integer(forKey: baseKey + "volumn")
        ability.level = UserDefaults.standard.integer(forKey: baseKey + "ability")
        reload.level = UserDefaults.standard.integer(forKey: baseKey + "reload")
        enable = UserDefaults.standard.bool(forKey: baseKey + "enable")
    }
    
    func saveInfo() {
        let baseKey = name + "_\(id)_"
        UserDefaults.standard.set(attact.level, forKey: baseKey + "attact")
        UserDefaults.standard.set(volumn.level, forKey: baseKey + "volumn")
        UserDefaults.standard.set(ability.level, forKey: baseKey + "ability")
        UserDefaults.standard.set(reload.level, forKey: baseKey + "reload")
        UserDefaults.standard.set(enable, forKey: baseKey + "enable")
    }
    
}

class LevelInfo: NSObject {    
    var level_description: String = ""
    var id: Int = 0
    var gold: Int = 0
    var name: String = ""
    var task: String = ""
    var other : String = "" 
}

class PlayInfo: NSObject {
    var attact: Int = 0
    var ability: Int = 0
    var volumn: Int = 0
    var reload: Float = 0.0
    var number: Int = 0
}

class HistoryInfo: NSObject {
    var id: Int = 0
    var gift: String = ""
    var datetime: String = ""
    var isOpened = false
    var type: Int = 0
    
    override init () {
        id = 0
        gift = ""
        datetime = ""
        isOpened = false
        type = 1
    }
    
    init (data json: JSON) {
        id = json["id"].intValue
        let value = json["category"].stringValue
        let vals = value.split(separator: ",")
        gift = json["price"].stringValue
        datetime = json["datetime"].stringValue
        type = Int(vals[1])!
        if vals[0] != "1" {
            isOpened = true
        }
    }
}
