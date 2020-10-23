//
//  Ground3DModel.swift
//  ARWorld
//
//  Created by JinYingZhe on 2/18/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit
import ARKit

class Ground3DModel: SCNNode {
    func loadModel() {
        guard let virtualObjectScene = SCNScene(named: "ground.scn") else { return }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        // Set up some properties
        addChildNode(wrapperNode)
    }
}
