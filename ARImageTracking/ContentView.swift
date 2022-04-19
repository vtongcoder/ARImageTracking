//
//  ContentView.swift
//  ARImageTracking
//
//  Created by Qi on 8/1/21.
//

import ARKit
import SwiftUI
import RealityKit

//Displays as a SwiftUI View
struct ContentView : View {
    var body: some View {
        return ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            VStack {
                Text("Scan to find image")
                Spacer()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @State private var selectedModel: String?
    var arView = ARView(frame: .zero)

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate{
        var parent: ARViewContainer
        var videoPlayer: AVPlayer!
        
        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let imageAnchor = anchors[0] as? ARImageAnchor else {
                print("Problems loading anchor.")
                return
            }
            guard let imageName = imageAnchor.name else {
                return
            }
            //Assigns reference image that will be detected
            if imageName  == "xs" {
                parent.arView.scene.anchors.removeAll()
                    // size of video plane depending of the image
                let width: Float = Float(imageAnchor.referenceImage.physicalSize.width * 1.03)
                let height: Float = Float(imageAnchor.referenceImage.physicalSize.height * 1.03)
//                    //Assigns video to be overlaid
                guard let path = Bundle.main.path(forResource: "iphonevideo", ofType: "mp4")else {
                    print("Unable to find video file.")
                    return
                }
                print("Dectect iphone")
                
                let videoURL = URL(fileURLWithPath: path)
                let playerItem = AVPlayerItem(url: videoURL)
                videoPlayer = AVPlayer(playerItem: playerItem)
                let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
                    //Sets the aspect ratio of the video to be played, and the corner radius of the video
                let videoPlane = ModelEntity(mesh: .generatePlane(width: width, depth: height, cornerRadius: 0.3), materials: [videoMaterial])
                //

                let anchor = AnchorEntity(anchor: imageAnchor)
                //Adds specified video to the anchor
                anchor.addChild(videoPlane)
                parent.arView.scene.addAnchor(anchor)
            }
            
            if imageName  == "MoringaBox" {
                // remove previous anchor
                
                parent.arView.scene.anchors.removeAll()
                
                let width: Float = Float(imageAnchor.referenceImage.physicalSize.width * 1.03)
                let height: Float = Float(imageAnchor.referenceImage.physicalSize.height * 1.03)
                
                    //Assigns video to be overlaid
                guard let path = Bundle.main.path(forResource: "Dory", ofType: "mov") else {
                    print("Unable to find video file.")
                    return
                }
                
                print("Dectect Moringa")
                
                let videoURL = URL(fileURLWithPath: path)
                let playerItem = AVPlayerItem(url: videoURL)
                videoPlayer = AVPlayer(playerItem: playerItem)
                let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
                    //Sets the aspect ratio of the video to be played, and the corner radius of the video
                let videoPlane = ModelEntity(mesh: .generatePlane(width: width, depth: height), materials: [videoMaterial])
                    //
                let anchor = AnchorEntity(anchor: imageAnchor)
                    //Adds specified video to the anchor
                anchor.addChild(videoPlane)
                parent.arView.scene.addAnchor(anchor)
                
                
            }
            if imageName == "PixyPE" {
                // Pixy F link: https://youtu.be/ofc3bCR-ZrM
                parent.selectedModel = "PixyPE"
                parent.arView.scene.anchors.removeAll()

                let width: Float = Float(imageAnchor.referenceImage.physicalSize.width * 1.03)
                let height: Float = Float(imageAnchor.referenceImage.physicalSize.height * 1.03)

                    //Assigns video to be overlaid
                guard let path = Bundle.main.path(forResource: "Dory", ofType: "mov") else {
                    print("Unable to find video file.")
                    return
                }

                let videoURL =  URL(fileURLWithPath: path)
                let playerItem = AVPlayerItem(url: videoURL)
                videoPlayer = AVPlayer(playerItem: playerItem)
                let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
//                    //Sets the aspect ratio of the video to be played, and the corner radius of the video
                let videoPlane = ModelEntity(mesh: .generatePlane(width: width, depth: height), materials: [videoMaterial])
//                    //
                let anchor = AnchorEntity(anchor: imageAnchor)
                    //Adds specified video to the anchor
//                anchor.addChild(videoPlane)
                let modelFileName = "toy_biplane.usdz"
                let gimbalEntity = try! ModelEntity.loadModel(named: modelFileName)
                let gimbalAnchorEntity = AnchorEntity(plane: .horizontal)
                                    gimbalAnchorEntity.position.z = 1.0
                anchor.addChild(gimbalEntity)
//                gimbalAnchorEntity.addChild(gimbalEntity)
//                parent.arView.scene.addAnchor(gimbalAnchorEntity)
                parent.arView.scene.addAnchor(anchor)
                
                                  

                
            }
            
            
            
//            let width: Float = Float(imageAnchor.referenceImage.physicalSize.width * 1.03)
//            let height: Float = Float(imageAnchor.referenceImage.physicalSize.height * 1.03)
//
//            let videoURL = URL(fileURLWithPath: videoPath)
//            let playerItem = AVPlayerItem(url: videoURL)
//            videoPlayer = AVPlayer(playerItem: playerItem)
//            let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
//                //Sets the aspect ratio of the video to be played, and the corner radius of the video
//            let videoPlane = ModelEntity(mesh: .generatePlane(width: width, depth: height), materials: [videoMaterial])
//                //
//
//            let anchor = AnchorEntity(anchor: imageAnchor)
//                //Adds specified video to the anchor
//            anchor.addChild(videoPlane)
//            parent.arView.scene.addAnchor(anchor)
        }
        
        //Checks for tracking status
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let imageAnchor = anchors[0] as? ARImageAnchor else {
                print("Problems loading anchor.")
                return
            }
            
//            Plays/pauses the video when tracked/loses tracking
            if imageAnchor.isTracked {
                videoPlayer.play()
            } else {
                videoPlayer.pause()
            }
        }
    }
    
    func makeUIView(context: Context) -> ARView {
        guard let referenceImages = ARReferenceImage.referenceImages(
                    inGroupNamed: "AR Resources", bundle: nil) else {
                    fatalError("Missing expected asset catalog resources.")
                }
        
        //Assigns coordinator to delegate the AR View
        arView.session.delegate = context.coordinator
        
        let configuration = ARImageTrackingConfiguration()
        configuration.isAutoFocusEnabled = true
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        
        //Enables People Occulusion on supported iOS Devices
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            print("People Segmentation not enabled.")
        }

        arView.session.run(configuration)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = selectedModel {
            if modelName == "PixyPE" {
                print("Load model")

                
                let biPlane = try! ToyBiplane.loadToy()
                uiView.scene.addAnchor(biPlane)
            }
           
        }
        
    }
}

