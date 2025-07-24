import SwiftUI
import SceneKit

struct IVSurfaceSceneView: UIViewRepresentable {
    @Binding var ivPointsByExpiration: [String: [OptionIVPoint]]
    @Binding var selectedExpiration: String?
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene()
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor.systemBackground
        
        setupCamera(for: scnView.scene!)
        setupLight(for: scnView.scene!)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene?.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        guard
            let selectedExpiration = selectedExpiration,
            let points = ivPointsByExpiration[selectedExpiration],
            !points.isEmpty
        else {
            return
        }
        
        let meshNode = createIVSurfaceNode(points: points)
        uiView.scene?.rootNode.addChildNode(meshNode)
    }
    
    private func setupCamera(for scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 20)
        cameraNode.camera?.zFar = 1000
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLight(for scene: SCNScene) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.eulerAngles = SCNVector3(-Float.pi/3, 0, 0)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.systemGray
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    private func createIVSurfaceNode(points: [OptionIVPoint]) -> SCNNode {
        // Simple mesh generation over strike and IV.
        // For smooth surface, consider spline interpolation here.
        // This demo creates a flat mesh with height = IV.
        
        // Create vertices
        let vertices: [SCNVector3] = points.map { point in
            SCNVector3(Float(point.strike), Float(point.iv * 10), 0)
        }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        
        // Create indices for triangles (simple fan)
        var indices: [Int32] = []
        let count = Int32(vertices.count)
        for i in 1..<count-1 {
            indices.append(0)
            indices.append(i)
            indices.append(i+1)
        }
        
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData,
                                         primitiveType: .triangles,
                                         primitiveCount: indices.count / 3,
                                         bytesPerIndex: MemoryLayout<Int32>.size)
        
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        geometry.firstMaterial?.diffuse.contents = UIColor.systemTeal.withAlphaComponent(0.7)
        geometry.firstMaterial?.isDoubleSided = true
        
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(-Float(vertices.map { $0.x }.reduce(0, +))/Float(vertices.count),
                                   0,
                                   0)
        return node
    }
}
