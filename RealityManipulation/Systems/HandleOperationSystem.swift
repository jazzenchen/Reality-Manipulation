//
//  ManipulateSystem.swift
//  HandInteraction
//
//  Created by Jazzen Chen on 2024/3/25.
//

import RealityKit

struct HandleOperationSystem: System {
    static let manipulateQuery = EntityQuery(where: .has(HandleComponent.self))
    
    init(scene: Scene) {
        
    }
    
    func update(context: SceneUpdateContext) {
        let entities = context.scene.performQuery(Self.manipulateQuery)
        
        for entity in entities {
            guard let manipulate = entity.components[HandleComponent.self],
                  manipulate.isManipulating else { continue }
            
            switch manipulate.manipulationType {
            case .scaling:
                scale(manipulate: manipulate)
            case .rotating:
                rotate(manipulate: manipulate)
            }
        }
    }
    
    func scale(manipulate: HandleComponent) {
        guard let scale = manipulate.entity.components[ScaleHandleComponent.self] else { return }
        
        // vectors
        let _ = manipulate.target.position
        let a = manipulate.nextHandlePoint
        let b = manipulate.entity.position
        // project
        let dotProduct = simd_dot(a,b)
        let length_b_squared = simd_length_squared(b) // use square to omit calculation of b normalize
        let projection = (dotProduct / length_b_squared) * b
        
        let length_projection_squared = simd_length_squared(projection)
        // speed
        let speedFactor = abs(length_projection_squared - length_b_squared)
        
        let speedUnit:Float = simd_dot(projection - b, b) > 0 ? 1: -1
        let scaleSpeed:Float = speedUnit * (speedFactor > 0.01 ? speedFactor : 0)
        // scale
        let currentScale = manipulate.target.scale.x
        if ((currentScale <= scale.maxScale && scaleSpeed > 0) ||
            (currentScale >= scale.minScale && scaleSpeed < 0))
        {
            manipulate.target.scale = simd_mix(manipulate.target.scale, manipulate.target.scale + [1,1,1]*scaleSpeed, [1,1,1]*0.1)
        }
    }
    
    func rotate(manipulate: HandleComponent) {
        guard let rotate = manipulate.entity.components[RotateHandleComponent.self] else { return }
        
        // draw refrence point
        //        rotate.refEntity.setPosition(rotate.refPoint, relativeTo: manipulate.target)
        //        rotate.refEntity.isEnabled = true
        
        // vectors
        let a = manipulate.nextHandlePoint
        let b = simd_cross(manipulate.entity.position, rotate.refPoint)
        
        // project
        let dotProduct = simd_dot(a,b)
        let length_b_squared = simd_length_squared(b) // use square to omit calculation of b normalize
        let projection = (dotProduct / length_b_squared) * b
        
        // draw projection point
        //                let actual_projection = projection + manipulate.entity.position
        //                rotate.refEntity_p.setPosition(actual_projection , relativeTo: manipulate.target)
        //                rotate.refEntity_p.isEnabled = true

        let direction:Float = simd_dot(projection, b) > 0 ? -0.05 : 0.05
        
        // rotate
        manipulate.target.transform.rotation = simd_slerp(
            manipulate.target.transform.rotation,
            manipulate.target.transform.rotation * simd_quatf(angle: .pi * direction, axis: rotate.axis), 0.1)
    }
}

