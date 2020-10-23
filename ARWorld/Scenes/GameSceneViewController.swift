//
//  GameSceneViewController.swift
//  ARAction
//
//  Created by JinYingZhe on 12/12/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SVProgressHUD

let kAnimationDurationMoving: TimeInterval = 0.2
let kMovingLengthPerLoop: CGFloat = 0.05
let kRotationRadianPerLoop: CGFloat = 0.2
let pPai = 3.141592654

class GameSceneViewController: UIViewController,
    ARSCNViewDelegate,
    ARSessionDelegate,
    UITextFieldDelegate,
    DragonModelDelegate,
    GameFailedModalViewDelegate,
    GameSuccessModalViewDelegate,
    GetTreasureModalViewDelegate,
    GetAddressModalViewDelegate
{
    @IBOutlet weak var fitUV: UIView!
    @IBOutlet weak var ammoUV: UIView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var fitsUB: UIButton!
    @IBOutlet weak var shutUB: UIButton!
    @IBOutlet weak var targetUIV: UIImageView!
    @IBOutlet weak var manUIV: UIImageView!
    @IBOutlet weak var manUPB: UIProgressView!
    @IBOutlet weak var monsterUPB: UIProgressView!
    @IBOutlet weak var gunFireUIV: UIImageView!
    @IBOutlet weak var bloodUIV: UIImageView!
    @IBOutlet weak var downTimeUL: UILabel!
    @IBOutlet weak var ammoCountUL: UILabel!
    @IBOutlet weak var downTimeUV: UIView!
    @IBOutlet weak var showGunUV: UIView!
    @IBOutlet weak var fireUV: UIView!
    @IBOutlet weak var gameControlUV: UIView!
    @IBOutlet weak var ammoVolumnUL: UILabel!
    
    var dragon = DragonModel()
    
    var downCountTimer: Timer?
    var gameCenterTimer: Timer?
    var fireTimer: Timer?
    var reloadTimer: Timer?
    var dragonAttactTimer: Timer?
    var attactActionTimer: Timer?
    
    let allMB = 500.0
    var currentMB = 500.0
    let allPB = 500.0
    var currentPB = 500.0
    var ammoCount = Global.playInfo.number
    
    var leastTime = 150
    var leastAmmo = Global.playInfo.volumn
    
    enum GameStatu {
        case Reload
        case Loaded
        case Started
        case Successed
        case Failed
        case Ended
    }
    
    var gameStatu = GameStatu.Started
    var successModalView: GameSuccessModalView = GameSuccessModalView()
    var failedModalView: GameFailedModalView = GameFailedModalView()
    var treasureModalView: GetTreasureModalView = GetTreasureModalView()
    var addressModalView: GetAddressModalView = GetAddressModalView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.startDownCount()
        
        gameCenterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            switch self.gameStatu {
            case .Reload:
                self.gameStateReloadedAction()
                break
            case .Failed:
                self.gameStateFailedAction()
                break
            case .Successed:
                self.gameStateSuccessedAction()
                break
            case .Started:
                self.gameStateStartedAction()
                break
            case .Loaded: break
            case .Ended: break
            }
        }
        
        self.addDragon()
    }
    
    func startDownCount () {
        downCountTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.gameStatu == .Failed || self.gameStatu == .Successed {
                timer.invalidate()
                return
            }
            self.leastTime = self.leastTime - 1
            let min = self.leastTime / 60
            let sec = self.leastTime % 60
            let showTxt = String(format: "%02d : %02d", min, sec)
            self.downTimeUL.text = showTxt
            if self.leastTime == 30 {
                self.downTimeUL.textColor = UIColor.red
            }
            if self.leastTime == 0 {
                self.gameStatu = .Failed
            }
        }
    }
    
    func initUI () {
//        leastTime = Global.levelInfo.
        
        if Global.playInfo.number > Global.playInfo.volumn {
            ammoCount = Global.playInfo.number - Global.playInfo.volumn
            leastAmmo = Global.playInfo.volumn
        } else {
            ammoCount = 0
            leastAmmo = Global.playInfo.number
        }
        
        fitsUB.layer.cornerRadius = 15.0
        shutUB.layer.cornerRadius = 15.0
        
        downTimeUV.layer.cornerRadius = 5.0
        showGunUV.layer.cornerRadius = 5.0
        fireUV.layer.cornerRadius = 5.0
        gameControlUV.layer.cornerRadius = 5.0
        
        manUIV.layer.cornerRadius = 15.0
        manUIV.layer.borderWidth = 1
        manUIV.layer.borderColor = UIColor.white.cgColor
        
        ammoCountUL.text = "\(ammoCount)"
        ammoVolumnUL.text = "\(leastAmmo)"
        
        manUPB.transform = manUPB.transform.scaledBy(x: 1, y: 2.0)
        monsterUPB.transform = monsterUPB.transform.scaledBy(x: 1, y: 2.0)
        
        fitUV.layer.cornerRadius = 37.5
        ammoUV.layer.cornerRadius = 37.5
        
        gunFireUIV.isHidden = true
        
        let url = URL(string: Global.userInfo.headUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data {
            let image = UIImage(data: imageData)
            manUIV.image = image
        }
        
        bloodUIV.alpha = 0.0
        
        sceneView.session.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    func addDragon() {
        let ground = Ground3DModel()
        ground.loadModel()
        ground.position = SCNVector3(0, -200, 0)
        sceneView.scene.rootNode.addChildNode(ground)
        
        dragon.loadModel(named: "Hulong", backView: self.view)
        dragon.delegate = self
        dragon.position = SCNVector3(0, -4.5, -15)
        dragon.scale = SCNVector3(0.04, 0.04, 0.04)
        
        sceneView.scene.rootNode.addChildNode(dragon)
        
        initProgressBar()
    }

    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func initProgressBar() {
        let valueMB = currentMB / allMB
        monsterUPB.setProgress(Float(valueMB), animated: true)
        if currentMB == 0 {
            gameStatu = .Successed
            return
        }
        
        let valuePB = currentPB / allPB
        manUPB.setProgress(Float(valuePB), animated: true)
        if currentPB == 0 {
            gameStatu = .Failed
            return
        }
    }
    
    func gameStateStartedAction () {
        if shutUB.isTouchInside == true {
            print("Shutting Selected.")
            if leastAmmo == 0 {
                gameStatu = .Reload
                return
            }
            let centerTarget = CGPoint(x: targetUIV.frame.origin.x - targetUIV.frame.size.width / 2, y: targetUIV.frame.origin.y - targetUIV.frame.size.height / 2)
            if isHitsMonster(pos: centerTarget) {
                currentMB -= 5
                if currentMB < 0 {
                    currentMB = 0
                }
                initProgressBar()
                
                gunFireUIV.isHidden = false
                fireTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: false) { timer in
                    self.gunFireUIV.isHidden = true
                    self.fireTimer?.invalidate()
                    self.fireTimer = nil
                }
            }
            leastAmmo = leastAmmo - 1
            ammoVolumnUL.text = "\(leastAmmo)"
            if leastAmmo == 0 {
                gameStatu = .Reload
            }
        }
    }
    
    func gameStateSuccessedAction () {
        sceneView.scene.isPaused = true
        dragon.state = .stop
        downCountTimer?.invalidate()
        downCountTimer = nil
        
        addSuccessModalView()
        gameStatu = .Ended
        
    }
    
    func gameStateFailedAction () {
        sceneView.scene.isPaused = true
        dragon.state = .stop
        bloodUIV.alpha = 1.0
        downCountTimer?.invalidate()
        downCountTimer = nil
        
        addFailedModalView()
        gameStatu = .Ended
    }
    
    func gameStateReloadedAction () {
        if ammoCount == 0 {
            gameStatu = .Started
            return
        }
        gameStatu = .Loaded
        Global.onShowProgressView(name: "龙攻击。。。")
        reloadTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Global.playInfo.reload), repeats: false) { timer in
            self.ammoCount = self.ammoCount - Global.playInfo.volumn + self.leastAmmo
            if self.ammoCount < 0 {
                self.ammoCount = 0
                self.leastAmmo = self.leastAmmo + self.ammoCount
            } else {
                self.leastAmmo = Global.playInfo.volumn
            }
            self.ammoCountUL.text = "\(self.ammoCount)"
            
            self.gameStatu = .Started
            SVProgressHUD.dismiss()
            
            self.reloadTimer?.invalidate()
            self.reloadTimer = nil
        }
    }
    
    func isHitsMonster(pos: CGPoint) -> Bool {
        // Let's test if a 3D Object was touch
        var hitOptions = [SCNHitTestOption: Any]()
        hitOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(pos, options: hitOptions)
        if hitResults.first != nil {
            return true
        }
        return false
    }
    
    func addSuccessModalView() {
        successModalView = Bundle.main.loadNibNamed("GameSuccessModalView", owner: self, options: nil)?.first as! GameSuccessModalView
        successModalView.delegate = self
//        successModalView.rewardUL.text = ""
        successModalView.frame = self.view.frame
        
        self.view.addSubview(successModalView)
    }
    
    func addFailedModalView() {
        failedModalView = Bundle.main.loadNibNamed("GameFailedModalView", owner: self, options: nil)?.first as! GameFailedModalView
        failedModalView.delegate = self
//        failedModalView.descriptionUL.text = ""
        failedModalView.frame = self.view.frame
        
        self.view.addSubview(failedModalView)
    }
    
    func addTreasureModalView() {
        treasureModalView = Bundle.main.loadNibNamed("GetTreasureModalView", owner: self, options: nil)?.first as! GetTreasureModalView
        treasureModalView.delegate = self
        treasureModalView.frame = self.view.frame
        
        self.view.addSubview(treasureModalView)
    }
    
    func addAddressModalView() {
        addressModalView = Bundle.main.loadNibNamed("GetAddressModalView", owner: self, options: nil)?.first as! GetAddressModalView
        addressModalView.delegate = self
        addressModalView.frame = self.view.frame
        addressModalView.addressUF.delegate = self
        
        self.view.addSubview(addressModalView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupConfiguration()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do something with the new transform
//        let currentTransform = frame.camera.transform
//        print(currentTransform)
    }
    
    @IBAction func onClickReloadUB(_ sender: Any) {
        if gameStatu != .Started {
            return
        }
        gameStatu = .Reload
    }
    
    // delegate --- DragonModelDelegate
    func attactDragon (fired fire: Sphere) {
        sceneView.scene.rootNode.addChildNode(fire)
        dragonAttactTimer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false) { timer in
            if (self.gameStatu != .Started && self.gameStatu != .Loaded  && self.gameStatu != .Reload) {
                return
            }
            
            self.bloodUIV.alpha = 1.0
            UIView.animate(withDuration: 3.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.bloodUIV.alpha = 0.0
            }, completion: nil)
            
            self.currentPB -= 45
            if self.currentPB < 0 {
                self.currentPB = 0
            }
            self.initProgressBar()
            if self.currentPB == 0 {
                self.gameStatu = .Failed
                return
            }
            
            self.gameStatu = .Loaded
            if !SVProgressHUD.isVisible() {
                Global.onShowProgressView(name: "龙攻击。。。")
            }
            
            self.attactActionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                if (self.gameStatu != .Started && self.gameStatu != .Loaded  && self.gameStatu != .Reload) {
                    return
                }
                self.gameStatu = .Started
                if SVProgressHUD.isVisible() {
                    SVProgressHUD.dismiss()
                }
                self.attactActionTimer?.invalidate()
                self.attactActionTimer = nil
            }
            self.dragonAttactTimer?.invalidate()
            self.dragonAttactTimer = nil
        }        
    }
    
    // delegate --- GameFailedModalViewDelegate
    func onClickFailedQuitUB () {
        let param = [
            "id" : "\(Global.userInfo.id)",
            "cnt_ammo" : "\(self.ammoCount)",
            "pass" : "0"
            ] as [String : String]

        Global.apiConnection(param: param, url: "user_update_ammo", method: .get, success: {(json) in
            Global.userInfo.cnt_ammo = self.ammoCount
            Global.playInfo.number = Global.userInfo.cnt_ammo
            self.navigationController?.popViewController(animated: false)
        })
        
        gameCenterTimer?.invalidate()
        gameCenterTimer = nil
    }
    
    func onClickFailedRetryUB () {
        let param = [
            "id" : "\(Global.userInfo.id)",
            "cnt_ammo" : "\(self.ammoCount)",
            "pass" : "0"
            ] as [String : String]
        
        Global.apiConnection(param: param, url: "user_update_ammo", method: .get, success: {(json) in
            Global.userInfo.cnt_ammo = self.ammoCount
            Global.playInfo.number = Global.userInfo.cnt_ammo
            self.navigationController?.popViewController(animated: false)
        })
        
        gameCenterTimer?.invalidate()
        gameCenterTimer = nil
    }
    
    // delegate --- GameSuccessModalViewDelegate
    func onClickSuccessNextUB () {
        let param = [
            "id" : "\(Global.userInfo.id)",
            "cnt_ammo" : "\(self.ammoCount + self.leastAmmo)",
            "pass" : "1"
            ] as [String : String]
        
        Global.apiConnection(param: param, url: "user_update_ammo", method: .get, success: {(json) in
            Global.userInfo.cnt_ammo = self.ammoCount + self.leastAmmo
            Global.playInfo.number = Global.userInfo.cnt_ammo
            self.successModalView.removeFromSuperview()
            self.addTreasureModalView()
        })
        
        gameCenterTimer?.invalidate()
        gameCenterTimer = nil
    }
    
    // delegate --- GetTreasureModalViewDelegate
    func popGetTreasureOpenClick() {
        if Global.userInfo.cnt_crystal > 9 {
            let param = [
                "id" : "\(Global.userInfo.id)",
                "price" : "\(Global.levelInfo.gold)",
                "open" : "1",
                "type" : "1"
                ] as [String : String]
            
            Global.apiConnection(param: param, url: "save_history", method: .get, success: {(json) in
                Global.userInfo.cnt_crystal = Global.userInfo.cnt_crystal - 10
                
                self.treasureModalView.removeFromSuperview()
                self.addAddressModalView()
            })
        } else {
            self.treasureModalView.removeFromSuperview()
            addAddressModalView()
        }
    }
    
    func popGetTreasurePutClick() {
        let param = [
            "id" : "\(Global.userInfo.id)",
            "price" : "\(Global.levelInfo.gold)",
            "open" : "0",
            "type" : "1"
            ] as [String : String]
        
        Global.apiConnection(param: param, url: "save_history", method: .get, success: {(json) in
            self.treasureModalView.removeFromSuperview()
            self.addAddressModalView()
        })
    }
    
    func popGetTreasureViewDismissal() {
        let param = [
            "id" : "\(Global.userInfo.id)",
            "price" : "\(Global.levelInfo.gold)",
            "open" : "0",
            "type" : "1"
            ] as [String : String]
        
        Global.apiConnection(param: param, url: "save_history", method: .get, success: {(json) in
            self.treasureModalView.removeFromSuperview()
            self.addAddressModalView()
        })
    }
    
    // delegate --- GetAddressModalViewDelegate
    func popGetAddressConfirmClick() {
        self.navigationController?.popViewController(animated: false)
        gameCenterTimer?.invalidate()
        gameCenterTimer = nil
    }
    
    func popGetAddressViewDismissal() {
        self.navigationController?.popViewController(animated: false)
        gameCenterTimer?.invalidate()
        gameCenterTimer = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
