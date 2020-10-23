//
//  DragonModel.swift
//  ARAction
//
//  Created by JinYingZhe on 12/13/18.
//  Copyright © 2018 JinYingZhe. All rights reserved.
//

import UIKit
import ARKit
import Alamofire
import JGProgressHUD
import SSZipArchive

protocol DragonModelDelegate {
    func attactDragon (fired fire: Sphere)
}

enum DragonState {
    case action
    case stop
}

class DragonModel: SCNNode {
    var dragonName: String = ""
    var delegate: DragonModelDelegate?
    var state: DragonState = .action
    
    func loadModel(named name: String = "Hulong", backView view: UIView) {
        self.dragonName = name
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(name + ".zip") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                let modelPath = url.appendingPathComponent(name + ".dae")
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
                progressHUD.show(in: view)
                
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
                            let modelPath = url.appendingPathComponent(name + ".dae")
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
        addChildNode(wrapperNode)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.dragonAction()
        }
    }
    
    func dragonAction () {
        switch state {
        case .action:
            let number = arc4random()
            if number % 5 == 0 {
                print("Dragon Attact --- \(number)")
                self.setAnimation(named: "Attact")
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                    self.createAttactFire()
                }
            }
            break
        case .stop:
            self.isPaused = true
            break
        }
    }
    
    func animationFromSceneNamed (name: String) -> CAAnimation? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let modelPath = url.appendingPathComponent(dragonName + "_" + name + ".dae")

        guard let scene = try? SCNScene(url: modelPath!, options: nil) else { return nil }
        
        var animation:CAAnimation?
        scene.rootNode.enumerateChildNodes({ child, stop in
            if let animKey = child.animationKeys.first {
                animation = child.animation(forKey: animKey)
                stop.pointee = true
            }
        })
        return animation
    }
    
    func setAnimation(named name: String) {
        if let animationObject = animationFromSceneNamed(name: name) {
            animationObject.repeatCount = 1
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            addAnimation(animationObject, forKey: name)
        }
    }
    
    func createAttactFire () {
        let pos = SCNVector3(x: position.x, y: position.y + 2, z: position.z)
        let fire = Sphere(posFrom: pos, posTo: SCNVector3(x: 0.0, y: 0.0, z: 0.0))
        self.delegate?.attactDragon(fired: fire)
    }

}
