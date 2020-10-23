//
//  ManInfoSceneViewController.swift
//  ARWorld
//
//  Created by JinYingZhe on 1/15/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit
import SceneKit
import Alamofire

class ManInfoSceneViewController: UIViewController, GetCrystalModalViewDelegate {
    // Title Bar UI
    @IBOutlet weak var avatarUIV: UIImageView!
    @IBOutlet weak var nameUL: UILabel!
    @IBOutlet weak var levelUL: UILabel!
    @IBOutlet weak var goldUL: UILabel!
    @IBOutlet weak var crystalUL: UILabel!
    
    // Information View UI
    @IBOutlet weak var healthUPV: UIProgressView!
    @IBOutlet weak var attackUPV: UIProgressView!
    @IBOutlet weak var defendUPV: UIProgressView!
    @IBOutlet weak var healthUL: UILabel!
    @IBOutlet weak var attactUL: UILabel!
    @IBOutlet weak var defendUL: UILabel!
    
    // Select View UI
    @IBOutlet weak var healthUB: UIButton!
    @IBOutlet weak var attactUB: UIButton!
    @IBOutlet weak var defendUB: UIButton!
    
    // Increase View UI
    @IBOutlet weak var levelValueUL: UILabel!
    @IBOutlet weak var valueCurrentUL: UILabel!
    @IBOutlet weak var plusUL: UILabel!
    @IBOutlet weak var valueAddUL: UILabel!
    @IBOutlet weak var crystalLostUL: UILabel!
    
    @IBOutlet var sceneView: SCNView!
    var crystalModalView: GetCrystalModalView = GetCrystalModalView()
    
    var human3D = Human3DModel()
    var animations = [String: CAAnimation]()
    
    var lastAngleY: Float = 0.0
    var beganPosX: CGFloat = 0.0
    
    var attract: Int  = 0
    var blood: Int  = 0
    var defend: Int  = 0
    var attractLevel: Int  = 0
    var bloodLevel: Int  = 0
    var defendLevel: Int  = 0
    var attractDelta: Int  = 0
    var bloodDelta: Int  = 0
    var defendDelta: Int  = 0
    
    var selItem: Int = 0
    
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
        
        addHuman3DModel()
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
        
        //Rifle View UI
        healthUPV.transform = healthUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        attackUPV.transform = attackUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        defendUPV.transform = defendUPV.transform.scaledBy(x: 1, y: CGFloat(progressScale))
        
        showUpdateInfo()
    }
    
    func addShoppingPopView() {
        crystalModalView = Bundle.main.loadNibNamed("GetCrystalModalView", owner: self, options: nil)?.first as! GetCrystalModalView
        crystalModalView.delegate = self
        crystalModalView.frame = self.view.frame
        
        self.view.addSubview(crystalModalView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addHuman3DModel () {
        human3D.loadModel()
        // Add the node to the scene
        sceneView.scene?.rootNode.addChildNode(human3D)
    }
    
    func initSelectBtns () {
        healthUB.backgroundColor = UIColor.lightGray
        attactUB.backgroundColor = UIColor.lightGray
        defendUB.backgroundColor = UIColor.lightGray
    }

    @objc func panDetected(tapGestureRecognizer gesture: UITapGestureRecognizer) {
        let tapView = gesture.view
        let touchPoint = gesture.location(in: tapView)
        switch gesture.state {
        case .began:
            beganPosX = touchPoint.x
            lastAngleY = human3D.eulerAngles.y
            break
        case .changed:
            let rotation = (touchPoint.x - beganPosX) / sceneView.bounds.size.width * CGFloat(pPai / 2.0)
            human3D.eulerAngles.y = lastAngleY + Float(rotation)
            break
        case .ended:
            lastAngleY = human3D.eulerAngles.y
            break
        default:
            break
        }
    }
    
    func showUpdateInfo () {
        blood = UserDefaults.standard.integer(forKey: Global.keyARGameManBlood)
        attract = UserDefaults.standard.integer(forKey: Global.keyARGameManAttract)
        defend = UserDefaults.standard.integer(forKey: Global.keyARGameManDefend)
        bloodLevel = UserDefaults.standard.integer(forKey: Global.keyARGameManBloodLevel)
        attractLevel = UserDefaults.standard.integer(forKey: Global.keyARGameManAttractLevel)
        defendLevel = UserDefaults.standard.integer(forKey: Global.keyARGameManDefendLevel)
        
        if blood == 0 {
            blood = 500
            UserDefaults.standard.set(blood, forKey: Global.keyARGameManBlood)
        }
        bloodDelta = Int(Float(blood) * 0.1 * Float(bloodLevel + 1))
        if attract == 0 {
            attract = 3
            UserDefaults.standard.set(attract, forKey: Global.keyARGameManAttract)
        }
        attractDelta = attractLevel + 1
        if defend == 0 {
            defend = 50
            UserDefaults.standard.set(defend, forKey: Global.keyARGameManDefend)
        }
        defendDelta = Int(Float(defend) * 0.1 * Float(defendLevel + 1))
        
        healthUL.text = "\(blood)"
        attactUL.text = "\(attract)"
        defendUL.text = "\(defend)"
        
        switch selItem {
        case 0:
            valueCurrentUL.text = "\(blood)"
            valueAddUL.text = "\(bloodDelta)"
            crystalLostUL.text = "\(bloodDelta)"
            levelValueUL.text = "层  \(bloodLevel + 1)"
            break
        case 1:
            valueCurrentUL.text = "\(attract)"
            valueAddUL.text = "\(attractDelta)"
            crystalLostUL.text = "\(attractDelta)"
            levelValueUL.text = "层  \(attractLevel + 1)"
            break
        case 2:
            valueCurrentUL.text = "\(defend)"
            valueAddUL.text = "\(defendDelta)"
            crystalLostUL.text = "\(defendDelta)"
            levelValueUL.text = "层  \(defendLevel + 1)"
            break
        default:
            break
        }
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
    
    @IBAction func onClickHealthUB(_ sender: Any) {
        initSelectBtns()
        healthUB.backgroundColor = UIColor.orange
        
        selItem = 0
        showUpdateInfo()
    }
    
    @IBAction func onClickAttactUB(_ sender: Any) {
        initSelectBtns()
        attactUB.backgroundColor = UIColor.orange
        
        selItem = 1
        showUpdateInfo()
    }
    
    @IBAction func onClickDefendUB(_ sender: Any) {
        initSelectBtns()
        defendUB.backgroundColor = UIColor.orange
        
        selItem = 2
        showUpdateInfo()
    }
    
    @IBAction func onClickGetItUB(_ sender: Any) {
        let crystalValue: Int = Int(crystalLostUL.text!)!
        if Global.userInfo.cnt_crystal < crystalValue {
            self.addShoppingPopView()
            return
        }
        
        let param = [
            "id" : "\(Global.userInfo.id)",
            "cnt_crystal" : crystalLostUL.text ?? "0"
            ] as [String : String]
        
        Global.apiConnection(param: param, url: "crystal_update", method: .get, success: {(json) in
            self.updateInfo()
        })
    }
    
    func updateInfo() {
        Global.userInfo.cnt_crystal = Global.userInfo.cnt_crystal - Int(crystalLostUL.text!)!
        crystalUL.text = String(Global.userInfo.cnt_crystal)
        
        switch selItem {
        case 0:
            blood += bloodDelta
            bloodLevel += 1
            UserDefaults.standard.set(blood, forKey: Global.keyARGameManBlood)
            UserDefaults.standard.set(bloodLevel, forKey: Global.keyARGameManBloodLevel)
            break
        case 1:
            attract += attractDelta
            attractLevel += 1
            UserDefaults.standard.set(attract, forKey: Global.keyARGameManAttract)
            UserDefaults.standard.set(attractLevel, forKey: Global.keyARGameManAttractLevel)
            break
        case 2:
            defend += defendDelta
            defendLevel += 1
            UserDefaults.standard.set(defend, forKey: Global.keyARGameManDefend)
            UserDefaults.standard.set(defendLevel, forKey: Global.keyARGameManDefendLevel)
            break
        default:
            break
        }
        showUpdateInfo()
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
