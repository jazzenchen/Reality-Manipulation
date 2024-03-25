#  Reality Manipulation with Bounding Box

<image src="./Screenshot.png" width="600" alt="screenshot">

A simple implemetation of bounding box written purely in RealityKit, with entity manipulation capabilities, such as:

* Tap entity to select
* Bounding box displayed as edges
* Scale, rotate entity by dragging handles on corners and edges of the bounding box
* Drag entity to move it arround

## How to use

Entity initialization need to create an extra root entity to hold the target entity, and add **ManipulationComponent** to the root entity, and the rest will be done automatically.

```swift
    // Create a root entity to hold the target eneity
    let root = Entity()
    root.addChild(entity)
    root.position = .init(x:0, y:1, z:-1)
    
    // setup entity for receiving gesture
    entity.generateCollisionShapes(recursive: true)
    entity.components.set(InputTargetComponent(allowedInputTypes: indirect]))
    
    // init manipulation component on root entity
    let handleMaterial = UnlitMaterial(color: .cyan.withAlphaComponent(0.5))
    let manipulationComponent = await ManipulationComponent(roothandleMaterial: handleMaterial)
    root.components.set(manipulationComponent)
    
    // That's it, add the root entity to the scene
    content.add(root)
```
Make sure to attach views to the view, **dragMoveGesture** is used for moving the movenent and interacting with bounding box handles, ** selectGesture** is used for active and deactive the **ManipulationComponent**.

```swift
    RealityView { content in
        // Add the entity to the scene
    }
    .gesture(dragMoveGesture)
    .gesture(selectGesture)
```
