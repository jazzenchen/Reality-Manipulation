//
//  RealityManipulationApp.swift
//  RealityManipulation
//
//  Created by Jazzen Chen on 2024/3/25.
//

import SwiftUI

@main
struct RealityManipulationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
