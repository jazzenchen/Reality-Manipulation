//
//  Entity+Extends.swift
//  RealityManipulation
//
//  Created by Jazzen Chen on 2024/3/25.
//

import RealityKit

extension Entity {
    func applyMaterial(_ material: Material) {
        if let modelEntity = self as? ModelEntity {
            modelEntity.model?.materials = [material]
        }
        for child in children {
            child.applyMaterial(material)
        }
    }
}
