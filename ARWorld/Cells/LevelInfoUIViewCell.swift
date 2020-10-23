//
//  LevelInfoUIViewCell.swift
//  ARWorld
//
//  Created by JinYingZhe on 1/29/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit
import SceneKit
import Alamofire
import JGProgressHUD
import SSZipArchive

class LevelInfoUIViewCell: UIView {

    @IBOutlet weak var dragonNameUL: UILabel!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var lockUIV: UIImageView!
    
    var isPassRound: Bool = true
    var dragon3D = DragonModel()
    var levelInfo: LevelInfo = LevelInfo()
    
    var lastAngleY: Float = 0.0
    var beganPosX: CGFloat = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Do any additional setup after loading the view.
        dragonNameUL.layer.cornerRadius = 5.0
        dragonNameUL.layer.borderColor = UIColor.darkGray.cgColor
        dragonNameUL.layer.borderWidth = 1.0
        
        sceneView.allowsCameraControl = false
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    func reloadUIView (name: String) {
        if isPassRound {
            lockUIV.isHidden = true
            loadModel(named: name)
            sceneView.scene?.rootNode.addChildNode(dragon3D)
            dragon3D.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(-pPai * 2), z: 0, duration: 45)))
        } else {
            dragonNameUL.isHidden = true
            sceneView.isHidden = true
        }
    }
    
    func loadModel(named name: String) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(name + ".zip") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                let modelPath = url.appendingPathComponent(name + "_View.dae")
                if fileManager.fileExists(atPath: (modelPath?.path)!) {
                    print("MODEL AVAILABLE")
                    self.createModel(modelURL: modelPath!)
                } else {
                    print("MODEL NOT AVAILABLE")
                }
            } else {
                print("FILE NOT AVAILABLE")
                let progressHUD = JGProgressHUD(style: .light)
                progressHUD.textLabel.text = "下载..."
                progressHUD.detailTextLabel.text = "0.0% 完成"
                progressHUD.show(in: self)
                
                let url1 = Global.downUrl + "dragons/" + name + ".zip"
                let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
                Alamofire.download(
                    url1,
                    method: .get,
                    parameters: nil,
                    encoding: JSONEncoding.default,
                    headers: nil,
                    to: destination).downloadProgress(closure: { (progress) in
                        //progress closure
                        print(progress)
                        let completedValue = progress.fractionCompleted
                        let loadString = String.init(format: "(%02d", Int(completedValue * 100)) + "% 完成)"
                        progressHUD.detailTextLabel.text = loadString
                    }).response(completionHandler: { (DefaultDownloadResponse) in
                        let inputPath = DefaultDownloadResponse.destinationURL?.path
                        
                        if fileManager.fileExists(atPath: inputPath!) {
                            print("Downlaod Success")
                        }
                        
                        let isEnable = SSZipArchive.unzipFile(atPath: inputPath!, toDestination: url.path!)
                        if isEnable {
                            print("Unzip Success")
                            let modelPath = url.appendingPathComponent(name + "_View.dae")
                            if fileManager.fileExists(atPath: (modelPath?.path)!) {
                                print("MODEL AVAILABLE")
                                self.createModel(modelURL: modelPath!)
                            } else {
                                print("MODEL NOT AVAILABLE")
                            }
                        }
                        progressHUD.dismiss(animated: true)
                    })
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    
    func createModel (modelURL url: URL) {
        print(url, "\n")
        guard let virtualObjectScene = try? SCNScene(url: url, options: nil) else { return }
        let wrapperNode = SCNNode()
        for child in (virtualObjectScene.rootNode.childNodes) {
            wrapperNode.addChildNode(child)
        }
        dragon3D.addChildNode(wrapperNode)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
}
