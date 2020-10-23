//
//  Sphere.swift
//  ARWorld
//
//  Created by JinYingZhe on 2/17/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit
import Foundation
import ARKit

class Sphere: SCNNode {
    
    static let radius: CGFloat = 0.01
    
    let sphereGeometry: SCNSphere
    
    // Required but unused
    required init?(coder aDecoder: NSCoder) {
        sphereGeometry = SCNSphere(radius: Sphere.radius)
        super.init(coder: aDecoder)
    }
    
    // The real action happens here
    init(posFrom: SCNVector3, posTo: SCNVector3) {
        self.sphereGeometry = SCNSphere(radius: Sphere.radius)
        super.init()
        
        let sphereNode = SCNNode(geometry: self.sphereGeometry)
        sphereNode.position = posFrom
        let sphereParticle = createFire()
        sphereNode.addParticleSystem(sphereParticle)
        sphereNode.runAction(SCNAction.move(to: posTo, duration: 2.0))
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
            self.clear()
        }
        
        self.addChildNode(sphereNode)
    }
    
    func clear() {
        self.removeFromParentNode()
    }
    
    func createFire() -> SCNParticleSystem {
        let fireP = SCNParticleSystem(named: "attact.scnp", inDirectory: nil)!
        return fireP
    }
    
}
