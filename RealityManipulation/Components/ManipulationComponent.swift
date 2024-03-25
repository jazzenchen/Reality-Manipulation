//
//  SelectComponent.swift
//  HandInteraction
//
//  Created by Jazzen Chen on 2024/3/25.
//
import RealityKit
import RealityKitContent

enum Axis:String, CaseIterable {
    case x = "x"
    case y = "y"
    case z = "z"
}

@MainActor
struct ManipulationComponent: Component {
    var isSelected: Bool
    var transform: Transform
    var scaleHandles: [Entity]
    var rotateHandles: [Entity]
    var boundingEdges: [Entity]
    var handleScaleFactor: Float
    
    var offsetX:Float
    var offsetY:Float
    var offsetZ:Float
    
    // MARK: record last transform for next manipulation
    var lastPosition: SIMD3<Float>? = nil
    
    init(_ entity: Entity, 
         handleMaterial: Material,
         handleScaleFactor:Float = 0.0003,
         drawBounds: Bool = true,
         boundsOffsetX:Float = 0.03, boundsOffsetY:Float = 0.03, boundsOffsetZ:Float = 0.03) async {
        self.isSelected = false
        self.transform = entity.transform
        self.scaleHandles = []
        self.rotateHandles = []
        self.boundingEdges = []
        
        self.handleScaleFactor = handleScaleFactor
        self.offsetX = boundsOffsetX
        self.offsetY = boundsOffsetY
        self.offsetZ = boundsOffsetZ
        
        // MARK: draw bounding box
        // TODO: Add bounding boxe
        
        // MARK: draw handles
        
        let bounds = entity.visualBounds(relativeTo: entity)
        
        await setupScaleHandles(entity, bounds, handleMaterial)
        await setupRotateHandles(entity,bounds, handleMaterial)
        setupBoundingEdges(entity, bounds, handleMaterial)
    }
    
    mutating func setupScaleHandles(_ entity:Entity, _ bounds:BoundingBox, _ handleMaterial: Material) async {
        guard let scale_manipulator = try? await Entity(named: "Manipulator_Scale") else {return}
        
        // add scale handles
        for x in 0...1 {
            for y in 0...1 {
                for z in 0...1 {
                    let scaleHandle = scale_manipulator.clone(recursive: true)
                    scaleHandle.scale = .one * handleScaleFactor
                    scaleHandle.applyMaterial(handleMaterial)
                    scaleHandle.generateCollisionShapes(recursive: true)
                    scaleHandle.components.set(InputTargetComponent(allowedInputTypes: [.indirect]))
                    scaleHandle.components.set(HandleComponent(scaleHandle, target: entity, manipulationType: .scaling))
                    scaleHandle.components.set(HoverEffectComponent())
                    
                    let positionX = x == 0 ? bounds.min.x - offsetX : bounds.max.x + offsetX;
                    let positionY = y == 0 ? bounds.min.y - offsetY : bounds.max.y + offsetY;
                    let positionZ = z == 0 ? bounds.min.z - offsetZ : bounds.max.z + offsetZ;
                    
                    scaleHandle.position = [positionX, positionY, positionZ]
                    scaleHandle.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(Float(x),0,0))
                    scaleHandle.isEnabled = false
                    scaleHandles.append(scaleHandle)
                    entity.addChild(scaleHandle)
                }
            }
        }
        
        // manually setup scale handle rotation
        scaleHandles[0].transform.rotation = simd_quatf(angle: .pi , axis: SIMD3<Float>(1,0,0))
        scaleHandles[1].transform.rotation = simd_quatf(angle: .pi / 2 , axis: SIMD3<Float>(0,0,1))
        scaleHandles[2].transform.rotation = simd_quatf(angle: -.pi / 2 , axis: SIMD3<Float>(0,1,0))
        scaleHandles[3].transform.rotation = simd_quatf(angle: 0 , axis: SIMD3<Float>(1,0,0))
        
        scaleHandles[4].transform.rotation = simd_quatf(angle: .pi , axis: SIMD3<Float>(0,1,0))
        * simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0,0,1))
        scaleHandles[5].transform.rotation = simd_quatf(angle: .pi , axis: SIMD3<Float>(0,0,1))
        scaleHandles[6].transform.rotation = simd_quatf(angle: .pi , axis: SIMD3<Float>(0,1,0))
        scaleHandles[7].transform.rotation = simd_quatf(angle: .pi/2 , axis: SIMD3<Float>(0,1,0))
    }
    
    mutating func setupRotateHandles(_ entity:Entity, _ bounds:BoundingBox, _ handleMaterial: Material) async {
        guard let rotate_manipulator = try? await Entity(named: "Manipulator_Rotate") else {return}
        
        for axis in Axis.allCases {
            // 1st + + - -
            for i in 0...1 {
                // 2nd + - + -
                for j in 0...1{
                    let rotateHandle = rotate_manipulator.clone(recursive: true)
                    rotateHandle.scale = .one * handleScaleFactor
                    rotateHandle.applyMaterial(handleMaterial)
                    rotateHandle.generateCollisionShapes(recursive: true)
                    rotateHandle.components.set(InputTargetComponent(allowedInputTypes: [.indirect]))
                    rotateHandle.components.set(HandleComponent(rotateHandle, target: entity, manipulationType: .rotating))
                    rotateHandle.components.set(HoverEffectComponent())
                    
                    switch axis {
                    case .x:
                        rotateHandle.position = [(bounds.max.x + bounds.min.x)/2,
                                                 i == 0 ? bounds.max.y + offsetY: bounds.min.y - offsetY,
                                                 j == 0 ? bounds.max.z + offsetZ: bounds.min.z - offsetZ]
                        rotateHandle.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(0,0,1))
                        
                        rotateHandle.components[RotateHandleComponent.self]?.axis = [1,0,0]
                        rotateHandle.components[RotateHandleComponent.self]?.refPoint = [bounds.max.x, rotateHandle.position.y, rotateHandle.position.z]
                    case .y:
                        rotateHandle.position = [i == 0 ? bounds.max.x + offsetX: bounds.min.x - offsetX,
                                                 (bounds.max.y + bounds.min.y)/2,
                                                 j == 0 ? bounds.max.z + offsetZ: bounds.min.z - offsetZ]
                        
                        rotateHandle.components[RotateHandleComponent.self]?.axis = [0,1,0]
                        rotateHandle.components[RotateHandleComponent.self]?.refPoint = [rotateHandle.position.x, bounds.max.y, rotateHandle.position.z]
                    case .z:
                        rotateHandle.position = [i == 0 ? bounds.max.x + offsetX: bounds.min.x - offsetX,
                                                 j == 0 ? bounds.max.y + offsetY: bounds.min.y - offsetY,
                                                 (bounds.max.z + bounds.min.z)/2,]
                        rotateHandle.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(1,0,0))
                        
                        rotateHandle.components[RotateHandleComponent.self]?.axis = [0,0,1]
                        rotateHandle.components[RotateHandleComponent.self]?.refPoint = [rotateHandle.position.x, rotateHandle.position.y, bounds.max.z]
                    }
                    rotateHandle.isEnabled = false
                    rotateHandles.append(rotateHandle)
                    entity.addChild(rotateHandle)
                }
            }
        }
    }
    
    mutating func setupBoundingEdges(_ entity:Entity, _ bounds:BoundingBox, _ handleMaterial: Material) {
        let mesh = MeshResource.generateCylinder(height: 1, radius: 0.001)
        
        for axis in Axis.allCases {
            // 1st + + - -
            for i in 0...1 {
                // 2nd + - + -
                for j in 0...1{
                    let edge = ModelEntity(mesh: mesh, materials: [handleMaterial])
                    
                    updateObjectOnEdge(edge, axis, i, j, bounds, true)
                    boundingEdges.append(edge)
                    entity.addChild(edge)
                }
            }
        }
    }
    
    func updateObjectOnEdge(_ object:Entity, _ axis:Axis, _ i:Int, _ j:Int,
                            _ bounds:BoundingBox, _ alignScale:Bool = false) {
        switch axis {
        case .x:
            object.position = [(bounds.max.x + bounds.min.x)/2,
                               i == 0 ? bounds.max.y + offsetY: bounds.min.y - offsetY,
                               j == 0 ? bounds.max.z + offsetZ: bounds.min.z - offsetZ]
            object.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(0,0,1))
            
            if(alignScale)
            {
                object.scale = [1, bounds.max.x - bounds.min.x + offsetX + offsetX, 1]
            }
        case.y:
            object.position = [i == 0 ? bounds.max.x + offsetX: bounds.min.x - offsetX,
                               (bounds.max.y + bounds.min.y)/2,
                               j == 0 ? bounds.max.z + offsetZ: bounds.min.z - offsetZ]
            if(alignScale)
            {
                object.scale = [1,bounds.max.y - bounds.min.y + offsetY + offsetY, 1]
            }
        case.z:
            object.position = [i == 0 ? bounds.max.x + offsetX: bounds.min.x - offsetX,
                               j == 0 ? bounds.max.y + offsetY: bounds.min.y - offsetY,
                               (bounds.max.z + bounds.min.z)/2,]
            object.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(1,0,0))
            if(alignScale)
            {
                object.scale = [1, bounds.max.z - bounds.min.z + offsetZ + offsetZ, 1]
            }
        }
    }
}
