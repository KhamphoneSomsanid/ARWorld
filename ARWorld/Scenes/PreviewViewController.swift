//
//  PreviewViewController.swift
//  ARWorld
//
//  Created by JinYingZhe on 12/9/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import Alamofire
import SceneKit
import SwiftyJSON

class PreviewViewController: UIViewController {
    // Title Bar UI
    @IBOutlet weak var avatarUIV: UIImageView!
    @IBOutlet weak var nameUL: UILabel!
    @IBOutlet weak var levelUL: UILabel!
    @IBOutlet weak var goldUL: UILabel!
    @IBOutlet weak var goldUV: UIView!
    @IBOutlet weak var crystalUL: UILabel!
    @IBOutlet weak var crystalUV: UIView!
    
    //Rifle View UI
    @IBOutlet weak var damageUPV: UIProgressView!
    @IBOutlet weak var stabilityUPV: UIProgressView!
    @IBOutlet weak var volumnUPV: UIProgressView!
    @IBOutlet weak var reloadUPV: UIProgressView!
    @IBOutlet weak var numberUPV: UIProgressView!
    @IBOutlet weak var damageUL: UILabel!
    @IBOutlet weak var stabilityUL: UILabel!
    @IBOutlet weak var volumnUL: UILabel!
    @IBOutlet weak var reloadUL: UILabel!
    @IBOutlet weak var numberUL: UILabel!
    
    @IBOutlet weak var gunNameUV: UIView!
    @IBOutlet weak var gunNameUL: UILabel!
    
    @IBOutlet var sceneView: SCNView!
    
    var gun3D = Gun3DModel()
    var gunID: Int = 0
    var selectedGun = GunInfo()
    
    var lastAngleY: Float = 0.0
    var beganPosX: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Rifle View UI
        damageUPV.transform = damageUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        stabilityUPV.transform = stabilityUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        volumnUPV.transform = volumnUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        reloadUPV.transform = reloadUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        numberUPV.transform = numberUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        
        sceneView.allowsCameraControl = false
        //Create instance of scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panDetected(tapGestureRecognizer:)));
        sceneView.addGestureRecognizer(gesture);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initTitleBar()
        getAllGuns()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func panDetected(tapGestureRecognizer gesture: UITapGestureRecognizer) {
        let tapView = gesture.view
        let touchPoint = gesture.location(in: tapView)
        switch gesture.state {
        case .began:
            beganPosX = touchPoint.x
            lastAngleY = gun3D.eulerAngles.y
            break
        case .changed:
            let rotation = (touchPoint.x - beganPosX) / sceneView.bounds.size.width * CGFloat(pPai / 2.0)
            gun3D.eulerAngles.y = lastAngleY + Float(rotation)
            break
        case .ended:
            lastAngleY = gun3D.eulerAngles.y
            break
        default:
            break
        }
    }
    
    func initTitleBar () {
        // Title Bar UI
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
        
        // 3D View UI
        gunNameUV.layer.borderColor = UIColor.lightGray.cgColor
        gunNameUV.layer.borderWidth = 1.0
        gunNameUV.layer.cornerRadius = 5.0
    }
    
    func addGun3D() {
        gun3D.removeAllActions()
        gun3D.removeAllAnimations()
        gun3D.removeFromParentNode()
        gun3D = Gun3DModel()
        
        gun3D.loadModel(named: selectedGun.name, backView: self.view)
        sceneView.scene?.rootNode.addChildNode(gun3D)
        
//        gun3D.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: -pPai * 2, z: 0, duration: 90)))
    }
    
    func getAllGuns() {
        Global.apiConnection(param: [:], url: "get_allguns", method: .get, success: {(json) in
            Global.allGuns.removeAll()
            let result = json["result"].arrayValue
            for n in 0...result.count - 1 {
                let gun = GunInfo()
                
                let dicGood = result[n]
                gun.id = dicGood["id"].intValue
                gun.name = dicGood["name"].stringValue
                gun.level = dicGood["level"].intValue
                gun.crystal = dicGood["crystal"].intValue
                gun.attact.min = dicGood["attact_min"].intValue
                gun.attact.max = dicGood["attact_max"].intValue
                gun.volumn.min = dicGood["volumn_min"].intValue
                gun.volumn.max = dicGood["volumn_max"].intValue
                gun.ability.min = dicGood["ability_min"].intValue
                gun.ability.max = dicGood["ability_max"].intValue
                gun.reload.min = dicGood["reload_min"].intValue
                gun.reload.max = dicGood["reload_max"].intValue
                
                gun.loadInfo()
                if (n == 0 && !gun.enable) {
                    gun.enable = true
                    gun.saveInfo()
                }
                
                Global.allGuns.append(gun)
            }
            self.initDatas()
        })
    }
    
    func initDatas() {
        gunID = UserDefaults.standard.integer(forKey: Global.keyARGameSelectedGunID)
        selectedGun = Global.allGuns[gunID]
        initViews()
    }
    
    func initViews() {
        addGun3D()
        gunNameUL.text = selectedGun.name
        
        let attactValue = getCurrentValue(parm: selectedGun.attact)
        Global.playInfo.attact = attactValue
        damageUL.text = "\(attactValue)"
        let attactPValue = (Float(attactValue) - Float(selectedGun.attact.min) / 2.0) / (Float(selectedGun.attact.max) - Float(selectedGun.attact.min) / 2.0)
        damageUPV.progress = attactPValue
        
        let abilityValue = getCurrentValue(parm: selectedGun.ability)
        Global.playInfo.ability = abilityValue
        stabilityUL.text = "\(abilityValue)%"
        let abilityPValue = (Float(abilityValue) - Float(selectedGun.ability.min) / 2.0) / (Float(selectedGun.ability.max) - Float(selectedGun.ability.min) / 2.0)
        stabilityUPV.progress = abilityPValue
        
        let volumnValue = getCurrentValue(parm: selectedGun.volumn)
        Global.playInfo.volumn = volumnValue
        volumnUL.text = "\(volumnValue)"
        let volumnPValue = (Float(volumnValue) - Float(selectedGun.volumn.min) / 2.0) / (Float(selectedGun.volumn.max) - Float(selectedGun.volumn.min) / 2.0)
        volumnUPV.progress = volumnPValue
        
        let step = (selectedGun.reload.min - selectedGun.reload.max) / 15
        let value = selectedGun.reload.min - step * (selectedGun.reload.level + 1) * selectedGun.reload.level / 2
        let reloadValue = Float(value) / 100.0
        Global.playInfo.reload = reloadValue
        reloadUL.text = "\(reloadValue)s"
        let reloadPValue = (Float(selectedGun.reload.min) * 1.3 - Float(value)) / (Float(selectedGun.reload.min) * 1.3 - Float(selectedGun.reload.max))
        reloadUPV.progress = reloadPValue
        
        numberUL.text = "\(Global.userInfo.cnt_ammo)"
        
        Global.playInfo.attact = attactValue
        Global.playInfo.ability = abilityValue
        Global.playInfo.volumn = volumnValue
        Global.playInfo.reload = reloadValue
        Global.playInfo.number = Global.userInfo.cnt_ammo        
    }
    
    func getCurrentValue(parm prop: PropParam) -> Int {
        let step = (prop.max - prop.min) / 15
        let value = step * (prop.level + 1) * prop.level / 2 + prop.min
        return value
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
    
}

