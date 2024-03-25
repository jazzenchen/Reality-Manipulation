//
//  ImmersiveView.swift
//  RealityManipulation
//
//  Created by Jazzen Chen on 2024/3/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            guard let entity = try? await Entity(named: "toy_biplane_idle") else {return}
            
            let root = Entity()
            root.addChild(entity)
            root.position = .init(x:0, y:1, z:-1)
            
            // gesture
            entity.generateCollisionShapes(recursive: true)
            entity.components.set(InputTargetComponent(allowedInputTypes: [.indirect]))
            
            // manipulation
            let handleMaterial = UnlitMaterial(color: .cyan.withAlphaComponent(0.5))
            let manipulationComponent = await ManipulationComponent(root, handleMaterial: handleMaterial)
            root.components.set(manipulationComponent)
            
            content.add(root)
        }
        .gesture(dragMoveGesture)
        .gesture(selectGesture)
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
