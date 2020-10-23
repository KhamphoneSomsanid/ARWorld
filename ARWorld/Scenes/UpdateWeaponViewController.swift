//
//  UpdateWeaponViewController.swift
//  ARWorld
//
//  Created by JinYingZhe on 1/16/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit
import SceneKit
import Alamofire

class UpdateWeaponViewController: UIViewController, GetCrystalModalViewDelegate {
    // Title Bar UI
    @IBOutlet weak var avatarUIV: UIImageView!
    @IBOutlet weak var nameUL: UILabel!
    @IBOutlet weak var levelUL: UILabel!
    @IBOutlet weak var goldUL: UILabel!
    @IBOutlet weak var goldUV: UIView!
    @IBOutlet weak var crystalUL: UILabel!
    @IBOutlet weak var crystalUV: UIView!
    
    // Weapon Information View UI
    @IBOutlet weak var damageUPV: UIProgressView!
    @IBOutlet weak var stabilityUPV: UIProgressView!
    @IBOutlet weak var volumnUPV: UIProgressView!
    @IBOutlet weak var reloadUPV: UIProgressView!
    @IBOutlet weak var damageUL: UILabel!
    @IBOutlet weak var stabilityUL: UILabel!
    @IBOutlet weak var volumnUL: UILabel!
    @IBOutlet weak var reloadUL: UILabel!
    
    // Select View UI
    @IBOutlet weak var damageUB: UIButton!
    @IBOutlet weak var stabilityUB: UIButton!
    @IBOutlet weak var volumnUB: UIButton!
    @IBOutlet weak var reloadUB: UIButton!
    
    // Increase View UI
    @IBOutlet weak var levelValueUL: UILabel!
    @IBOutlet weak var valueCurrentUL: UILabel!
    @IBOutlet weak var plusUL: UILabel!
    @IBOutlet weak var valueAddUL: UILabel!
    @IBOutlet weak var crystalLostUL: UILabel!
    
    @IBOutlet var sceneView: SCNView!
    var crystalModalView: GetCrystalModalView = GetCrystalModalView()
    
    var gun3D = Gun3DModel()
    var lastAngleY: Float = 0.0
    var beganPosX: CGFloat = 0.0
  
    var gunID: Int = 0
    var selectedGun = GunInfo()
    var valueKind: Int = 0
    
    var currentValue: Int = 0
    var addValue: Int = 0
    var level: Int = 0
    var crystalValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initTitleBar()
        
        sceneView.allowsCameraControl = false
        //Create instance of scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        self.initDatas()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panDetected(tapGestureRecognizer:)));
        sceneView.addGestureRecognizer(gesture);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDatas() {
        gunID = UserDefaults.standard.integer(forKey: Global.keyARGameSelectedGunID)
        selectedGun = Global.allGuns[gunID]

        addGun3D()
        initViews()
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
    
    func initSelectBtns () {
        damageUB.backgroundColor = UIColor.lightGray
        stabilityUB.backgroundColor = UIColor.lightGray
        volumnUB.backgroundColor = UIColor.lightGray
        reloadUB.backgroundColor = UIColor.lightGray
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
        
        // Weapon View UI
        damageUPV.transform = damageUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        stabilityUPV.transform = stabilityUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        volumnUPV.transform = volumnUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        reloadUPV.transform = reloadUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
    }
    
    func initViews() {
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

        let volumnValue = (selectedGun.volumn.level + 1) * (selectedGun.volumn.max - selectedGun.volumn.min) / 5 + selectedGun.volumn.min
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
        
        let validateKey = UserDefaults.standard.object(forKey: Global.keyARGameAmmoNumber)
        if validateKey == nil {
            UserDefaults.standard.set(15, forKey: Global.keyARGameAmmoNumber)
            Global.playInfo.number = 15
        } else {
            Global.playInfo.number = UserDefaults.standard.integer(forKey: Global.keyARGameAmmoNumber)
        }
        showUpdateInfo()
    }
    
    func getCurrentValue(parm prop: PropParam) -> Int {
        let step = (prop.max - prop.min) / 15
        let value = step * (prop.level + 1) * prop.level / 2 + prop.min
        return value
    }
    
    func showUpdateInfo() {
        switch valueKind {
        case 0:
            let step = (selectedGun.attact.max - selectedGun.attact.min) / 15
            level = selectedGun.attact.level
            currentValue = selectedGun.attact.min + (level + 1) * level / 2 * step
            addValue = step * (level + 1)
            crystalValue = Int(Float(addValue) * 7.5 * (1.0 + 0.2 * Float(level) + 1))
            break
        case 1:
            let step = (selectedGun.ability.max - selectedGun.ability.min) / 15
            level = selectedGun.ability.level
            currentValue = selectedGun.ability.min + (level + 1) * level / 2 * step
            addValue = step * (level + 1)
            crystalValue = Int(Float(addValue) * 7.0 * (1.0 + 0.2 * Float(level + 1)))
            break
        case 2:
            let step = (selectedGun.volumn.max - selectedGun.volumn.min) / 5
            level = selectedGun.volumn.level
            currentValue = selectedGun.volumn.min + (level + 1) * step
            addValue = step
            crystalValue = Int(Float(addValue) * 8.5 * (1.0 + 0.2 * Float(level + 1)))
            break
        case 3:
            let step = (selectedGun.reload.min - selectedGun.reload.max) / 15
            level = selectedGun.reload.level
            currentValue = selectedGun.reload.min - (level + 1) * level / 2 * step
            addValue = step * (level + 1)
            crystalValue = Int(Float(addValue) * (1.0 + 0.2 * Float(level + 1)))
            
            valueCurrentUL.text = "\(CGFloat(currentValue) / 100.0)"
            valueAddUL.text = "\(CGFloat(addValue) / 100.0)"
            levelValueUL.text = "层  \(level + 1)"
            plusUL.text = "-"
            
            crystalLostUL.text = "\(crystalValue)"
            
            break
        default:
            break
        }
        
        valueCurrentUL.text = "\(currentValue)"
        valueAddUL.text = "\(addValue)"
        levelValueUL.text = "层  \(level + 1)"
        plusUL.text = "+"
        
        crystalLostUL.text = "\(crystalValue)"
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

    func addShoppingPopView() {
        crystalModalView = Bundle.main.loadNibNamed("GetCrystalModalView", owner: self, options: nil)?.first as! GetCrystalModalView
        crystalModalView.delegate = self
        crystalModalView.frame = self.view.frame
        
        self.view.addSubview(crystalModalView)
    }
    
    func updateUserInfo () {
        Global.userInfo.cnt_crystal = Global.userInfo.cnt_crystal - crystalValue
        crystalUL.text = String(Global.userInfo.cnt_crystal)
        switch valueKind {
        case 0:
            selectedGun.attact.level = selectedGun.attact.level + 1
            break
        case 1:
            selectedGun.ability.level = selectedGun.ability.level + 1
            break
        case 2:
            selectedGun.volumn.level = selectedGun.volumn.level + 1
            break
        case 3:
            selectedGun.reload.level = selectedGun.reload.level + 1
            break
        default:
            break
        }
        selectedGun.saveInfo()
        initViews()
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
    
    @IBAction func onClickDamageUB(_ sender: Any) {
        initSelectBtns()
        damageUB.backgroundColor = UIColor.orange
        
        valueKind = 0
        showUpdateInfo()
    }
    
    @IBAction func onClickStabilityUB(_ sender: Any) {
        initSelectBtns()
        stabilityUB.backgroundColor = UIColor.orange
        
        valueKind = 1
        showUpdateInfo()
    }
    
    @IBAction func onClickVolumnUB(_ sender: Any) {
        initSelectBtns()
        volumnUB.backgroundColor = UIColor.orange
        
        valueKind = 2
        showUpdateInfo()
    }
    
    @IBAction func onClickReloadUB(_ sender: Any) {
        initSelectBtns()
        reloadUB.backgroundColor = UIColor.orange
        
        valueKind = 3
        showUpdateInfo()
    }
    
    @IBAction func onClickGetUpdateUB(_ sender: Any) {
        if Global.userInfo.cnt_crystal < crystalValue {
            // Your crystal count is not enought.
            self.addShoppingPopView()
            return
        }

        let param = [
            "id" : "\(Global.userInfo.id)",
            "cnt_crystal" : crystalLostUL.text ?? "0"
            ] as [String : String]
        
        Global.apiConnection(param: param, url: "crystal_update", method: .get, success: {(json) in
            self.updateUserInfo()
        })
    }
    
    // Mark: GetCrystalModalViewDelegate
    func popGetCrystalModalViewDismissal() {
        self.crystalModalView.removeFromSuperview()
    }
    
    func popGetCrystalModalViewBtnClick() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopSceneViewController") as? ShopSceneViewController {
            if let navigator = navigationController {
                self.crystalModalView.removeFromSuperview()
                navigator.pushViewController(viewController, animated: false)
            }
        }
    }
    
}
