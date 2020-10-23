//
//  LevelSceneViewController.swift
//  ARWorld
//
//  Created by Polestar517 on 12/13/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import Alamofire
import SceneKit

let levelDragaonName: [String] = ["Hulong", "Hulong", "Hulong"]
let levelDragaonDescription: [String] = ["虎  龙", "洪  龙", "洪  龙"]

class LevelSceneViewController: UIViewController, UIScrollViewDelegate {
    // TitleView Show
    @IBOutlet weak var avatarUIV: UIImageView!
    @IBOutlet weak var nameUL: UILabel!
    @IBOutlet weak var levelUL: UILabel!
    @IBOutlet weak var crystalUL: UILabel!
    @IBOutlet weak var goldUL: UILabel!
    @IBOutlet weak var ammoUL: UILabel!
    
    @IBOutlet weak var goldUV: UIView!
    @IBOutlet weak var crystalUV: UIView!
    @IBOutlet weak var ammoUV: UIView!
    
    @IBOutlet weak var levelInfoSCV: UIScrollView!
    
    // Level Info View Show
    @IBOutlet weak var currentLevelUL: UILabel!
    @IBOutlet weak var beforeUB: UIButton!
    @IBOutlet weak var forwardUB: UIButton!
    @IBOutlet weak var storyUL: UILabel!
    @IBOutlet weak var taskUL: UILabel!
    @IBOutlet weak var goldBonusUL: UILabel!
    
    var levels = [LevelInfo]()
    var screenWidth = UIScreen.main.bounds.size.height
    
    var dragon3D = DragonModel()
    var selectIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getAllLevels()
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
    
    func getAllLevels()
    {
        Global.apiConnection(param: [:], url: "get_allrounds", method: .get, success: {(json) in
            Global.allGuns.removeAll()
            let result = json["result"].arrayValue
            for n in 0...result.count - 1 {
                let level = LevelInfo()
                
                let levelinfo = result[n]
                level.level_description = levelinfo["description"].stringValue
                level.id = levelinfo["id"].intValue
                level.gold = levelinfo["gold"].intValue
                level.name = levelinfo["name"].stringValue
                level.task = levelinfo["task"].stringValue
                level.other = levelinfo["other"].stringValue
                self.levels.append(level)
            }
            self.initUIView(withIndex: 0)
            self.initUIScrollView()
        })
    }
    
    func initUIView (withIndex index: Int) {
        let levelInfo: LevelInfo = levels[index]
        currentLevelUL.text = "\(index + 1) / \(levels.count)"
        storyUL.text = levelInfo.level_description
        taskUL.text = levelInfo.task
        goldBonusUL.text = "\(levelInfo.gold)"
    }
    
    func initUIScrollView () {
        let cWidth = levelInfoSCV.frame.size.width
        let cHeight = levelInfoSCV.frame.size.height
        levelInfoSCV.contentSize = CGSize(width: cWidth * CGFloat(levels.count), height: cHeight)
        for i in 0...levels.count - 1 {
            let cLevelUV = Bundle.main.loadNibNamed("LevelInfoUIViewCell", owner: self, options: nil)?.first as! LevelInfoUIViewCell
            cLevelUV.levelInfo = levels[i]
            cLevelUV.frame = CGRect(x: cWidth * CGFloat(i), y: 0, width: cWidth, height: cHeight)
            if Global.userInfo.passround < i + 1 {
                cLevelUV.isPassRound = false
            }
            cLevelUV.reloadUIView(name: levelDragaonName[i])
            cLevelUV.dragonNameUL.text = levelDragaonDescription[i]
            
            levelInfoSCV.addSubview(cLevelUV)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initTitleBar()
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = levelInfoSCV.frame.size.width
        let offsetX = levelInfoSCV.contentOffset.x
        selectIndex = Int(offsetX / width)
        print(selectIndex)
        initUIView(withIndex: selectIndex)
    }
    
    @IBAction func onClickBeforeUB(_ sender: Any) {
        if selectIndex == 0 {
            return
        }
        selectIndex -= 1
        initUIView(withIndex: selectIndex)
        let width = levelInfoSCV.frame.size.width
        levelInfoSCV.contentOffset = CGPoint(x: width * CGFloat(selectIndex), y: 0.0)
    }
    
    @IBAction func onClickForwardUB(_ sender: Any) {
        if selectIndex == levels.count - 1 {
            return
        }
        selectIndex += 1
        initUIView(withIndex: selectIndex)
        let width = levelInfoSCV.frame.size.width
        levelInfoSCV.contentOffset = CGPoint(x: width * CGFloat(selectIndex), y: 0.0)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        Global.levelInfo = levels[selectIndex]
    }
    
}
