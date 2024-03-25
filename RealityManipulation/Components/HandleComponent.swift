//
//  ManipulateComponent.swift
//  HandInteraction
//
//  Created by Jazzen Chen on 2024/3/25.
//

import RealityKit

enum ManipulationType : Int {
    case scaling, rotating
}
enum RotationType: Int {
    case X, Y, Z
}
enum ScaleType: Int {
    case TopRightFront, TopRightBack, TopLeftFront, TopLeftBack,
         BottomRightFront, BottomRightBack, BottomLeftFront, BottomLeftBack
    
}

struct HandleComponent: Component {
    var manipulationType: ManipulationType
    
    var entity: Entity
    var target: Entity
    
    var nextHandlePoint: SIMD3<Float>
    var isManipulating: Bool = false
    
    init(_ entity: Entity, target: Entity, manipulationType: ManipulationType) {
        self.entity = entity
        self.target = target
        self.manipulationType = manipulationType
        self.nextHandlePoint = [0,0,0]
        
        switch manipulationType{
        case .scaling:
            entity.components.set(ScaleHandleComponent())
        case .rotating:
            entity.components.set(RotateHandleComponent(entity))
        }
    }
}

struct ScaleHandleComponent: Component {
    var maxScale: Float = 5.0
    var minScale: Float = 0.5
    
    init(){
        
    }
}

struct RotateHandleComponent: Component {
    var refPoint: SIMD3<Float> = [0,0,0]
    var refEntity: Entity
    var refEntity_p: Entity
    var axis: SIMD3<Float> = [0,0,0]
    
    init(_ entity: Entity) {
        let material = UnlitMaterial(color: .red)
        let sphere = MeshResource.generateSphere(radius: 0.01)
        refEntity = ModelEntity(mesh: sphere, materials: [material])
        refEntity.isEnabled = false
        entity.addChild(refEntity)
        
        refEntity_p = ModelEntity(mesh: sphere, materials: [material])
        refEntity_p.isEnabled = false
        entity.addChild(refEntity_p)
    }
}
