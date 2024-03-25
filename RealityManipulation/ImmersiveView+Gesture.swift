//
//  AppRealitySpace+Gestures.swift
//  Reality-Collabo-Vision
//
//  Created by Jazzen Chen on 2024/3/25.
//

import SwiftUI
import RealityKit

extension ImmersiveView {
    var dragMoveGesture: some Gesture{
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                
                // check if current enity is handle
                guard let manipulateHandle = getParentByComponent(entity: value.entity, componentType: HandleComponent.self),
                      var component = manipulateHandle.components[HandleComponent.self]else {
                    // get exactly entity with ManipulationComponent, otherwise only some child mesh of entity will be moved
                    guard let entity = getParentByComponent(entity: value.entity, componentType: ManipulationComponent.self),
                          let parent = entity.parent,
                          var manipulation = entity.components[ManipulationComponent.self] else { return }
                    
                    // move entity if drag target is not handle
                    if manipulation.isSelected {
                        if manipulation.lastPosition == nil {
                            manipulation.lastPosition = entity.position
                            entity.components.set(manipulation)
                        }
                        else
                        {
                            entity.position = simd_mix(entity.position, value.convert(value.translation3D, from: .local, to: parent) + manipulation.lastPosition!, .one * 0.25)
                        }
                    }
                    return
                }
                
                // operate with handle
                component.isManipulating = true
                let point = value.convert(value.location3D, from: .local, to: component.target)
                component.nextHandlePoint = point
                manipulateHandle.components.set(component)
            }
            .onEnded{ value in
                
                // check if current enity is handle
                guard let manipulateHandle = getParentByComponent(entity: value.entity, componentType: HandleComponent.self) else {
                    guard let entity = getParentByComponent(entity: value.entity, componentType: ManipulationComponent.self),
                          var manipulation = entity.components[ManipulationComponent.self] else { return }
                    manipulation.lastPosition = entity.position
                    entity.components.set(manipulation)
                    return
                }
                
                guard var component = manipulateHandle.components[HandleComponent.self] else {return}
                
                component.isManipulating = false
                manipulateHandle.components.set(component)
            }
    }
    
    var selectGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded{value in
                
                // active or deactive the manipulation component
                guard let entity = getParentByComponent(entity: value.entity, componentType: ManipulationComponent.self),
                    var manipulation = entity.components[ManipulationComponent.self] else {return}
                manipulation.isSelected = (manipulation.isSelected) ? false : true
                entity.components[ManipulationComponent.self] = manipulation
            }
    }
    
    // query the root entity might has certain component
    func getParentByComponent<T: Component>(entity: Entity?, componentType:T.Type) -> Entity? {
        var current = entity
        while(current != nil) {
            guard let _ = current!.components[T.self] else {
                current = current!.parent
                continue
            }
            break
        }
        return current
    }
}
