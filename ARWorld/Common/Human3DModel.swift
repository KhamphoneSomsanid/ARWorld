//
//  Human3DModel.swift
//  ARWorld
//
//  Created by JinYingZhe on 1/15/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit
import ARKit

class Human3DModel: SCNNode {
    func loadModel() {
        guard let virtualObjectScene = SCNScene(named: "human.dae") else { return }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        // Set up some properties
        addChildNode(wrapperNode)
    }
}
