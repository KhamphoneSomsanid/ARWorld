//
//  GetWeaponViewController.swift
//  ARWorld
//
//  Created by JinYingZhe on 1/16/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit
import SceneKit
import Alamofire

class GetWeaponViewController: UIViewController, UIScrollViewDelegate, GetCrystalModalViewDelegate  {
    // Title Bar UI
    @IBOutlet weak var avatarUIV: UIImageView!
    @IBOutlet weak var nameUL: UILabel!
    @IBOutlet weak var levelUL: UILabel!
    @IBOutlet weak var goldUL: UILabel!
    @IBOutlet weak var crystalUL: UILabel!
    @IBOutlet weak var goldUV: UIView!
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
    
    // Increase View UI
    @IBOutlet weak var crystalLostUL: UILabel!
    @IBOutlet weak var weaponUSV: UIScrollView!
    @IBOutlet weak var selectedUV: UIView!
    @IBOutlet weak var purchaseUV: UIView!
    @IBOutlet weak var gettingUB: UIButton!
    @IBOutlet weak var gotUL: UILabel!
    
    @IBOutlet var sceneView: SCNView!
    var crystalModalView: GetCrystalModalView = GetCrystalModalView()
    
    var gun3D = Gun3DModel()
    var selectIndex = 0
    var selectGunIndex = 0
    var selectedGun = GunInfo()
    
    var lastAngleY: Float = 0.0
    var beganPosX: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initTitleBar()
        
        sceneView.allowsCameraControl = false
        //Create instance of scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panDetected(tapGestureRecognizer:)));
        sceneView.addGestureRecognizer(gesture);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initView()
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
    
    func showWeaponInfo(withIndex index: Int) {
        selectedGun = Global.allGuns[selectIndex]
        addGun3D()
        
        damageUL.text = "\(selectedGun.attact.min)~\(selectedGun.attact.max)"
        stabilityUL.text = "\(selectedGun.ability.min)~\(selectedGun.ability.max)%"
        volumnUL.text = "\(selectedGun.volumn.min)~\(selectedGun.volumn.max)"
        reloadUL.text = "\(CGFloat(selectedGun.reload.min) / 100.0)~\(CGFloat(selectedGun.reload.max) / 100.0)s"
        
        crystalLostUL.text = "\(selectedGun.crystal)"
        
        if selectedGun.enable {
            purchaseUV.isHidden = true
            if selectGunIndex == selectIndex {
                gotUL.isHidden = false
                gettingUB.isHidden = true
            } else {
                gotUL.isHidden = true
                gettingUB.isHidden = false
            }
        } else {
            purchaseUV.isHidden = false
            gettingUB.isHidden = true
            gotUL.isHidden = true
        }
    }
    
    func initView() {
        selectedUV.layer.borderWidth = 3
        selectedUV.layer.borderColor = UIColor.green.cgColor
        
        goldUV.layer.borderColor = UIColor.lightGray.cgColor
        goldUV.layer.borderWidth = 1.0
        goldUV.layer.cornerRadius = 5.0
        
        crystalUV.layer.borderColor = UIColor.lightGray.cgColor
        crystalUV.layer.borderWidth = 1.0
        crystalUV.layer.cornerRadius = 5.0
        
        gettingUB.setPopItemViewStyle(cornerRadius: 15.0, title: .small)
        
        selectGunIndex = UserDefaults.standard.integer(forKey: Global.keyARGameSelectedGunID)
        selectedGun = Global.allGuns[selectGunIndex]
        
        let heightSUV = weaponUSV.frame.size.height
        let widthSUV = weaponUSV.frame.size.width
        weaponUSV.contentSize = CGSize(width: widthSUV * CGFloat(Global.allGuns.count), height: heightSUV)
        for i in 0...Global.allGuns.count - 1 {
            let weaponUVC = Bundle.main.loadNibNamed("WeaponNameUIViewCell", owner: self, options: nil)?.first as! WeaponNameUIViewCell
            weaponUVC.frame = CGRect(x: widthSUV * CGFloat(i), y: 0, width: widthSUV, height: heightSUV)
            let gun = Global.allGuns[i]
            weaponUVC.nameUL.text = gun.name
            weaponUVC.levelUL.text = "\(gun.level) 级"
            if !gun.enable {
                weaponUVC.isEnableUL.isHidden = true
            }
            weaponUSV.addSubview(weaponUVC)
        }
        showWeaponInfo(withIndex: selectIndex)
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
        
        // Weapon View UI
        damageUPV.transform = damageUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        stabilityUPV.transform = stabilityUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        volumnUPV.transform = volumnUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        reloadUPV.transform = reloadUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
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
        selectedGun.enable = true
        selectedGun.saveInfo()
        
        Global.userInfo.cnt_crystal = Global.userInfo.cnt_crystal - selectedGun.crystal
        crystalUL.text = String(Global.userInfo.cnt_crystal)
        
        initView()
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = weaponUSV.frame.size.width
        let offsetX = weaponUSV.contentOffset.x
        selectIndex = Int(offsetX / width)
        print(selectIndex)
        showWeaponInfo(withIndex: selectIndex)
    }
    
    @IBAction func onClickGettingUB (_ sender: Any) {
        selectGunIndex = selectIndex
        UserDefaults.standard.set(selectGunIndex, forKey: Global.keyARGameSelectedGunID)
        selectedGun = Global.allGuns[selectGunIndex]
        
        showWeaponInfo(withIndex: selectGunIndex)
    }
    
    @IBAction func onClickGetUpdateUB(_ sender: Any) {
        if Global.userInfo.cnt_crystal < selectedGun.crystal {
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
