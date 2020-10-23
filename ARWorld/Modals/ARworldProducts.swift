//
//  ARworldProducts.swift
//  ARWorld
//
//  Created by JinYingZhe on 5/4/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

class ARworldProducts {
    public static let ammoShop = "com.myxh.coolshopping.arworld_ammo_01"
    public static let crystalShop01 = "com.myxh.coolshopping.arworld_crystal_01"
    public static let crystalShop02 = "com.myxh.coolshopping.arworld_crystal_02"
    public static let crystalShop03 = "com.myxh.coolshopping.arworld_crystal_03"
    public static let crystalShop04 = "com.myxh.coolshopping.arworld_crystal_04"
    public static let crystalShop05 = "com.myxh.coolshopping.arworld_crystal_05"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [
        ARworldProducts.crystalShop01,
        ARworldProducts.crystalShop02,
        ARworldProducts.crystalShop03,
        ARworldProducts.crystalShop04,
        ARworldProducts.crystalShop05,
        ARworldProducts.ammoShop
    ]
    
    public static let store = IAPHelper(productIds: ARworldProducts.productIdentifiers)
}

func resourceNameForProductIdentifiers(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
