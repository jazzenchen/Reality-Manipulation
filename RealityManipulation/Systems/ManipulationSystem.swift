//
//  MoveSystem.swift
//  HandInteraction
//
//  Created by Jazzen Chen on 2024/3/25.
//

import RealityKit

struct ManipulationSystem: System {
    static let selectionQuery = EntityQuery(where: .has(ManipulationComponent.self))
    
    public init(scene: Scene) {

    }
    
    public func update(context: SceneUpdateContext) {
        let entities = context.scene.performQuery(Self.selectionQuery)
        
        for entity in entities {
            guard let manipulationComponent = entity.components[ManipulationComponent.self] else { continue }
            
            if manipulationComponent.isSelected {
                for handle in manipulationComponent.scaleHandles {
                    handle.isEnabled = true
                }
                for handle in manipulationComponent.rotateHandles {
                    handle.isEnabled = true
                }
                for edge in manipulationComponent.boundingEdges {
                    edge.isEnabled = true
                }
            }
            else {
                for handle in manipulationComponent.scaleHandles {
                    handle.isEnabled = false
                }
                for handle in manipulationComponent.rotateHandles {
                    handle.isEnabled = false
                }
                for edge in manipulationComponent.boundingEdges {
                    edge.isEnabled = false
                }
            }
        }
    }
}
