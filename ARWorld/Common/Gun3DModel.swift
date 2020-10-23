//
//  Gun3DModel.swift
//  ARWorld
//
//  Created by JinYingZhe on 1/15/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit
import ARKit
import Alamofire
import JGProgressHUD
import SSZipArchive

class Gun3DModel: SCNNode {
    func loadModel(named name: String = "AK47", backView view: UIView) {
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
                
                let url1 = Global.downUrl + "guns/" + name + ".zip"
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
        
        runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(-pPai * 2), z: 0, duration: 90)))
    }
    
}
