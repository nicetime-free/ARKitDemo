//
//  WDARSCNViewController.swift
//  ARKitDemo
//
//  Created by cby on 2018/7/10.
//  Copyright © 2018年 cby. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class WDARSCNViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // AR相关
    private lazy var arSCNView: ARSCNView? = {
        let scnView = ARSCNView(frame: view.bounds)
        scnView.session = self.arSession!
        scnView.automaticallyUpdatesLighting = true
        scnView.delegate = self
        return scnView
    }()
    private lazy var arSession: ARSession? = {
        let session = ARSession()
        session.delegate = self
        return session
    }()
    private var arSessionConfiguration: ARWorldTrackingConfiguration? = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        configuration.isLightEstimationEnabled = true
        return configuration
    }()

    // 按钮操作
    private lazy var backBtn: UIButton? = {
        let btn = UIButton(frame: CGRect(x: 10, y: 30, width: 60, height: 30))
        btn.backgroundColor = .red
        btn.alpha = 0.5
        btn.setTitle("返回", for: .normal)
        btn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
        return btn
    }()
    private lazy var addChatBox: UIButton? = {
        let btn = UIButton(frame: CGRect(x: 20, y: view.frame.size.height - 40 , width: 150, height: 30))
        btn.backgroundColor = UIColor.magenta
        btn.alpha = 0.5
        btn.setTitle("添加3D机器人", for: .normal)
        btn.addTarget(self, action: #selector(addChatBoxClick(sender:)), for: .touchUpInside)
        return btn
    }()
    private lazy var addAnimation: UIButton? = {
        let btn = UIButton(frame: CGRect(x: W_SCREEN - 100, y: view.frame.size.height - 40 , width: 80, height: 30))
        btn.backgroundColor = UIColor.orange
        btn.alpha = 0.5
        btn.setTitle("添加动作", for: .normal)
        btn.addTarget(self, action: #selector(addAnimationClick(sender:)), for: .touchUpInside)
        return btn
    }()
    private lazy var scaleLabel: UILabel? = {
        let label = UILabel(frame: CGRect(x: 20, y: H_SCREEN - 75, width: W_SCREEN - 40, height: 30))
        label.text = "调整大小:"
        label.alpha = 0.5
        label.backgroundColor = UIColor.darkGray
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    private lazy var scaleSlider: UISlider? = {
        let slider = UISlider(frame: CGRect(x: 80, y: H_SCREEN - 75, width: W_SCREEN - 110, height: 30))
        slider.isContinuous = true
        slider.tag = 100
        slider.maximumTrackTintColor = UIColor.white
        slider.minimumTrackTintColor = UIColor.green
        slider.minimumValue = 0
        slider.maximumValue = 2
        slider.setThumbImage(UIImage.init(named: "slider_point"), for: .normal)
        slider.setValue(Float(lastScale), animated: false)
        slider.addTarget(self, action: #selector(scaleSliderValueChanged(slider:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(resetValue(slider:)), for: .touchUpInside)
        return slider
    }()
    private lazy var distanceLabel: UILabel? = {
        let label = UILabel(frame: CGRect(x: 20, y: H_SCREEN - 110, width: W_SCREEN - 40, height: 30))
        label.text = "调整远近:"
        label.alpha = 0.5
        label.backgroundColor = UIColor.darkGray
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    private lazy var distanceSlider: UISlider? = {
        let slider = UISlider(frame: CGRect(x: 80, y: H_SCREEN - 110, width: W_SCREEN - 110, height: 30))
        slider.isContinuous = false
        slider.tag = 101
        slider.minimumValue = 0
        slider.maximumValue = 500
        slider.maximumTrackTintColor = UIColor.white
        slider.minimumTrackTintColor = UIColor.green
        slider.setThumbImage(UIImage.init(named: "slider_point"), for: .normal)
        slider.isContinuous = true
        slider.setValue(Float(lastDistance), animated: false)
        slider.addTarget(self, action: #selector(disntanceSliderValueChanged(slider:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(resetValue(slider:)), for: .touchUpInside)
        return slider
    }()
    private lazy var locationVeLabel: UILabel? = {
        let label = UILabel(frame: CGRect(x: 20, y: H_SCREEN - 145, width: W_SCREEN - 40, height: 30))
        label.text = "调整上下:"
        label.alpha = 0.5
        label.backgroundColor = UIColor.darkGray
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    private lazy var locationVeSlider: UISlider? = {
        let slider = UISlider(frame: CGRect(x: 80, y: H_SCREEN - 145, width: W_SCREEN - 110, height: 30))
        slider.isContinuous = false
        slider.tag = 102
        slider.minimumValue = -200
        slider.maximumValue = 200
        slider.maximumTrackTintColor = UIColor.white
        slider.minimumTrackTintColor = UIColor.green
        slider.setThumbImage(UIImage.init(named: "slider_point"), for: .normal)
        slider.isContinuous = true
        slider.setValue(Float(lastLocationVe), animated: false)
        slider.addTarget(self, action: #selector(locationVeSliderValueChanged(slider:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(resetValue(slider:)), for: .touchUpInside)
        return slider
    }()
    private lazy var locationHeLabel: UILabel? = {
        let label = UILabel(frame: CGRect(x: 20, y: H_SCREEN - 180, width: W_SCREEN - 40, height: 30))
        label.text = "调整左右:"
        label.alpha = 0.5
        label.backgroundColor = UIColor.darkGray
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    private lazy var locationHeSlider: UISlider? = {
        let slider = UISlider(frame: CGRect(x: 80, y: H_SCREEN - 180, width: W_SCREEN - 110, height: 30))
        slider.isContinuous = false
        slider.tag = 103
        slider.minimumValue = -200
        slider.maximumValue = 200
        slider.maximumTrackTintColor = UIColor.white
        slider.minimumTrackTintColor = UIColor.green
        slider.setThumbImage(UIImage.init(named: "slider_point"), for: .normal)
        slider.isContinuous = true
        slider.setValue(Float(lastLocationHe), animated: false)
        slider.addTarget(self, action: #selector(locationHeSliderValueChanged(slider:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(resetValue(slider:)), for: .touchUpInside)
        return slider
    }()
    
    private lazy var isHiddeBtn: UIButton? = {
        let btn = UIButton(frame: CGRect(x: W_SCREEN - 70, y: 30, width: 60, height: 30))
        btn.setTitle("UIControl", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.purple
        btn.addTarget(self, action: #selector(isHiddenUI(sneder:)), for: .touchUpInside)
        return btn
    }()
    
    private var animalScene = SCNScene()
    private var planeNode: SCNNode?
    private var wrapperNode: SCNNode?
    private var animalRootNode: SCNNode?
    
    private var animalArray: [String] = ["lion", "cat", "dog", "giraffe", "owl"]
    private var animalKindActionArray: [[String]] = [["Idle", "Idle_2", "Jump_Up", "Land", "Roll", "Run", "Sleep", "Talk", "Victory", "Walk", "Failure", "Fall"]]
    private var animalRow = 0
    private var acionRow = 0
    private var scaleValueObserver: NSKeyValueObservation?
    private var distanceValueObserver: NSKeyValueObservation?
    private var lastScale = 0.2
    private var lastDistance = 60
    private var lastLocationVe = -5
    private var lastLocationHe = 0
    private var isSlidering = false
    private var isShowUI = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        ///
        arSCNView?.addSubview(backBtn!)
        
        arSCNView?.addSubview(addChatBox!)
        
        arSCNView?.addSubview(addAnimation!)
        
        arSCNView?.addSubview(scaleLabel!)
        
        arSCNView?.addSubview(scaleSlider!)
        
        arSCNView?.addSubview(distanceLabel!)
        
        arSCNView?.addSubview(distanceSlider!)
        
        arSCNView?.addSubview(locationVeLabel!)
        
        arSCNView?.addSubview(locationVeSlider!)
        
        arSCNView?.addSubview(locationHeLabel!)
        
        arSCNView?.addSubview(locationHeSlider!)
        
//        scaleValueObserver = scaleSlider?.observe(\UISlider.value, options: [.new], changeHandler: { [weak self] (slider, _) in
//            print("大小:",slider.value)
//            if let strongSelf = self {
//
//            }
//        })
//        distanceValueObserver = distanceSlider?.observe(\UISlider.value, options: [.new], changeHandler: { [weak self] (slider, _) in
//            if let strongSelf = self {
//                print("远近:",slider.value)
//            }
//        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isShowUI {
            hiddenUI()
            isShowUI = false
        }else {
            showUI()
            isShowUI = true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isMember(of: UISlider.self))! {
            return false
        }else {
            return true
        }
    }
    
    // 缩放值变化
    @objc func scaleSliderValueChanged(slider: UISlider) {
        isSlidering = true
        if wrapperNode != nil {
            wrapperNode?.scale = SCNVector3Make(slider.value, slider.value, slider.value)
            lastScale = Double(slider.value)
        }
    }
    
    // 距离变化
    @objc func disntanceSliderValueChanged(slider: UISlider) {
        isSlidering = true
        if wrapperNode != nil {
            wrapperNode?.position = SCNVector3Make(Float(lastLocationHe), Float(lastLocationVe), Float(-Int(slider.value)))
            lastDistance = Int(slider.value)
        }
    }
    
    // 上下位置变化
    @objc func locationVeSliderValueChanged(slider: UISlider) {
        isSlidering = true
        if wrapperNode != nil {
            wrapperNode?.position = SCNVector3Make(Float(lastLocationHe), Float(slider.value), Float(-lastDistance))
            lastLocationVe = Int(slider.value)
        }
    }
    
    // 左右位置变化
    @objc func locationHeSliderValueChanged(slider: UISlider) {
        isSlidering = true
        if wrapperNode != nil {
            wrapperNode?.position = SCNVector3Make(Float(slider.value), Float(lastLocationVe), Float(-lastDistance))
            lastLocationHe = Int(slider.value)
        }
    }
    
    @objc func isHiddenUI(sneder: UIButton) {
        
    }
    
    // 恢复初始状态
    @objc func resetValue(slider: UISlider) {
        
        isSlidering = false
        guard wrapperNode == nil else {
            return
        }
        switch slider.tag {
        case 100:
            slider.setValue(Float(lastScale), animated: false)
        case 101:
            slider.setValue(Float(lastDistance), animated: false)
        case 102:
            slider.setValue(Float(lastLocationVe), animated: false)
        case 103:
            slider.setValue(Float(lastLocationHe), animated: false)
        default:
            break
        }
    }
    
    func hiddenUI() {
        backBtn?.isHidden = true
        addChatBox?.isHidden = true
        addAnimation?.isHidden = true
        scaleLabel?.isHidden = true
        scaleSlider?.isHidden = true
        distanceLabel?.isHidden = true
        distanceSlider?.isHidden = true
        locationVeLabel?.isHidden = true
        locationVeSlider?.isHidden = true
        locationHeLabel?.isHidden = true
        locationHeSlider?.isHidden = true
    }
    
    func showUI() {
        backBtn?.isHidden = false
        addChatBox?.isHidden = false
        addAnimation?.isHidden = false
        scaleLabel?.isHidden = false
        scaleSlider?.isHidden = false
        distanceLabel?.isHidden = false
        distanceSlider?.isHidden = false
        locationVeLabel?.isHidden = false
        locationVeSlider?.isHidden = false
        locationHeLabel?.isHidden = false
        locationHeSlider?.isHidden = false
    }
    
    // 添加动作
    @objc func addAnimationClick(sender: UIButton) {
        
        guard wrapperNode != nil else {
            return
        }
        let pullMenuView = ZWPullMenuView.pullMenuAnchorView(sender, titleArray: animalKindActionArray[0])
        pullMenuView?.zwPullMenuStyle = .PullMenuLightStyle
        pullMenuView?.blockSelectedMenu = { [weak self] (row) in
            if let strongSelf = self {
                strongSelf.animalRootNode?.childNodes[0].removeAllAnimations()
                let roll = SCNAnimation.fromFile(named: strongSelf.animalArray[strongSelf.animalRow] + strongSelf.animalKindActionArray[0][row], inDirectory: "Animals.scnassets")
                strongSelf.animalRootNode?.childNodes[0].addAnimation(roll!, forKey: roll?.keyPath)
            }
        }
    }
    
    private var currentAngleY: Float = 0.0
    private var currentAngleX: Float = Float(Double.pi/2)
    private var wrapperfinalTransform: SCNMatrix4?
    private var animalFinalTeansform: SCNMatrix4 = SCNMatrix4MakeRotation(Float(-Double.pi/2),1,0,0)
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        
        guard isSlidering != true else {
            return
        }
        
        let translation = sender.translation(in: sender.view!)
        var newAngleY: Float = 0.0
        var newAngleX: Float = 0.0
//        print(translation.x,translation.y)
        
        if abs(translation.x) > abs(translation.y) {
            newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
            newAngleY += currentAngleY
            
            wrapperNode?.transform = SCNMatrix4MakeRotation(newAngleY, 0, 1, 0)
            wrapperNode?.position = SCNVector3Make(Float(lastLocationHe), Float(lastLocationVe), Float(-lastDistance))
            wrapperNode?.scale = SCNVector3Make(Float(lastScale), Float(lastScale), Float(lastScale))
            wrapperfinalTransform = SCNMatrix4MakeRotation(newAngleY, 0, 1, 0)
        }else {
            newAngleX = (Float)(translation.y)*(Float)(Double.pi)/180.0
            newAngleX += currentAngleX
            
            animalRootNode?.transform = SCNMatrix4MakeRotation(Float(-newAngleX),1,0,0)
            animalFinalTeansform = SCNMatrix4MakeRotation(Float(-newAngleX),1,0,0)
        }

        if(sender.state == UIGestureRecognizer.State.ended) {
            if translation.x > translation.y  {
                currentAngleY = newAngleY
            }else {
                currentAngleX = newAngleX
            }
        }
    }
    
    @objc func addChatBoxClick(sender: UIButton) {
        
        let pullMenuView = ZWPullMenuView.pullMenuAnchorView(sender, titleArray: animalArray)
        pullMenuView?.zwPullMenuStyle = .PullMenuLightStyle
        pullMenuView?.blockSelectedMenu = { [weak self] (row) in

            if let strongSelf = self {
                strongSelf.animalRow = row
                if strongSelf.wrapperNode != nil {

                    strongSelf.wrapperNode?.removeFromParentNode()
                    strongSelf.wrapperNode = nil
                }

                let name = strongSelf.animalArray[row] + strongSelf.animalKindActionArray[0][0]
                let scene = SCNScene(named: "Animals.scnassets/\(name).dae")
//                let scene = SCNScene(named: "\(name).dae", inDirectory: "Animals.scnassets", options: [SCNSceneSource.LoadingOption.preserveOriginalTopology: true])
                strongSelf.wrapperNode = SCNNode()
                strongSelf.animalRootNode = SCNNode()
                for child in (scene?.rootNode.childNodes)! {
                    child.removeAllAnimations()
                    strongSelf.animalRootNode?.addChildNode(child)
                }
                
                if strongSelf.wrapperfinalTransform != nil {
                    strongSelf.wrapperNode?.transform = strongSelf.wrapperfinalTransform!
                }
                strongSelf.animalRootNode?.transform = strongSelf.animalFinalTeansform
                strongSelf.wrapperNode?.position = SCNVector3Make(Float(strongSelf.lastLocationHe), Float(strongSelf.lastLocationVe), Float(-strongSelf.lastDistance))
                strongSelf.wrapperNode?.scale = SCNVector3Make(Float(strongSelf.lastScale), Float(strongSelf.lastScale), Float(strongSelf.lastScale))
                strongSelf.arSCNView?.addGestureRecognizer(UIPanGestureRecognizer(target: strongSelf, action: #selector(strongSelf.panGesture(sender:))))
                
                strongSelf.animalScene.rootNode.addChildNode(strongSelf.wrapperNode!)
                strongSelf.wrapperNode?.addChildNode(strongSelf.animalRootNode!)
                
                strongSelf.arSCNView?.scene = strongSelf.animalScene
            }
        }
        
        
//        if planeNode != nil {
//            return
//        }
//        let scene = SCNScene(named: "art.scnassets/Run.dae")
//        let scene = SCNScene(named: "Animals.scnassets/\(lionActionArray[0]).dae")
//        let scene = SCNScene(named: "owl.scnassets/tigger1.scn")
//        let results: [ARHitTestResult] = (arSCNView?.hitTest(view.center, types: ARHitTestResult.ResultType.featurePoint))!
        // 转为三维坐标
//        let centerVector3 = SCNVector3Make(0, 0, -0.1)
//        if results.count > 0 {
//            centerVector3 = SCNVector3Make(results[0].worldTransform.columns.3.x, results[0].worldTransform.columns.3.y, results[0].worldTransform.columns.3.z)
//        }
//        planeNode = scene?.rootNode.childNodes[0]
//        planeNode?.scale = SCNVector3Make(1, 1, 1)
//        planeNode?.position = centerVector3
//        self.arSCNView?.scene = scene!
//        wrapperNode = SCNNode()
//        for child in (scene?.rootNode.childNodes)! {
////            child.removeAllAnimations()
//            wrapperNode?.addChildNode(child)
//        }
//        wrapperNode?.transform = SCNMatrix4MakeRotation(Float(-Double.pi/3),1,0,0)
//        wrapperNode?.position = centerVector3
//        wrapperNode?.scale = SCNVector3Make(0.1, 0.1, 0.1)
//        self.arSCNView?.scene.rootNode.addChildNode(wrapperNode!)
        
        
        
//        self.arSCNView?.scene.rootNode.addChildNode(planeNode!)
        
//        let ship = scene?.rootNode.childNode(withName: "default", recursively: true)
//        ship?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 0.2)))
////         添加渲染
//        ship?.geometry?.firstMaterial?.lightingModel = .blinn
//        ship?.geometry?.firstMaterial?.diffuse.contents = UIImage.init(named: "owl.scnassets/woman/T_Shirt_Diffuse.jpg")
//        ship?.geometry?.firstMaterial?.lightingModel = .blinn
//        ship?.scale = SCNVector3Make(0.1, 0.1, 0.1)
//        ship?.position = centerVector3
//        self.arSCNView?.scene.rootNode.addChildNode(ship!)
        
        
        
        
//        let max = planeNode?.boundingBox.max
//        let min = planeNode?.boundingBox.min
//        let x = (min?.x)! + ((max?.x)! - (min?.x)!) / 2.0
//        let y = (min?.y)! + ((max?.y)! - (min?.y)!) / 2.0
//        let z = (min?.z)! + ((max?.z)! - (min?.z)!) / 2.0
//        planeNode?.position = SCNVector3Make(-x * 0.03, -y * 0.03, -z * 0.03)
//
//        let rotationYNode = SCNNode()
//        rotationYNode.addChildNode(planeNode!)
//
//        let superNode = SCNNode()
//        superNode.addChildNode(rotationYNode)
//        arSCNView?.scene.rootNode.addChildNode(superNode)
//        arSCNView?.scene.rootNode.addChildNode((arSCNView?.pointOfView)!)
//
//        // 增加一个指向约束 让其指向相机节点
//        let lookAt = SCNLookAtConstraint(target: (arSCNView?.pointOfView)!)
//        lookAt.isGimbalLockEnabled = true
//        // 将这个约束添加给父节点
//        superNode.constraints = [lookAt]
        
//        arSCNView?.anchor(for: planeNode!)
    }
    /*
     
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.addSubview(self.arSCNView!)
        
        arSCNView?.session.run(self.arSessionConfiguration!)
        
        self.arSCNView?.session.run(arSessionConfiguration!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.arSCNView?.session.pause()
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
        if planeNode != nil {
            return
        }
        
        let touch: UITouch = touches.first!
        let point = touch.location(in: view)
        let hitResults = arSCNView?.hitTest(CGPoint(x: point.x, y: point.y), types: ARHitTestResult.ResultType.estimatedHorizontalPlane)
        for hitResult in hitResults! {
            print(hitResult.localTransform)
        }
        
        let scene = SCNScene(named: "art.scnassets/ship.scn")
        planeNode = scene?.rootNode.childNodes[0]
        planeNode?.position = SCNVector3Make(0, 0, -0.01)
        planeNode?.scale = SCNVector3Make(0.1, 0.1, 0.1)
        self.arSCNView?.scene.rootNode.addChildNode(planeNode!)

        arSCNView?.anchor(for: planeNode!)
        */
        
        /// 自动绕旋转
//        let scene = SCNScene(named: "art.scnassets/file.dae")
//        planeNode = scene?.rootNode.childNodes[0]
//        planeNode?.scale = SCNVector3Make(0.5, 0.5, 0.5)
//        planeNode?.position = SCNVector3Make(0, -15, -100)
//        for node in (planeNode?.childNodes)! {
//            node.scale = SCNVector3Make(0.5, 0.5, 0.5)
//            node.position = SCNVector3Make(0, -15, -100)
//        }
//
//        planeNode?.position = SCNVector3Make(0, 0, -20)
//
//        let node1 = SCNNode()
//        node1.position = (arSCNView?.scene.rootNode.position)!
//        arSCNView?.scene.rootNode.addChildNode(node1)
//        node1.addChildNode(planeNode!)
//        let moonRotationAnimation = CABasicAnimation(keyPath: "rotation")
//        moonRotationAnimation.duration = 30
//        moonRotationAnimation.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0, Float(Double.pi * 2)))
//        moonRotationAnimation.repeatCount = Float.greatestFiniteMagnitude
//        node1.addAnimation(moonRotationAnimation, forKey: "moon ratation around earth")
        
//    }
    
    @objc func backBtnClick(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension WDARSCNViewController: ARSCNViewDelegate {
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor.isMember(of: ARPlaneAnchor.classForCoder()) {
            print("捕捉到平面")
            
            /*
            //添加一个3D平面模型，ARKit只有捕捉能力，锚点只是一个空间位置，要想更加清楚看到这个空间，我们需要给空间添加一个平地的3D模型来渲染他
            //1.获取捕捉到的平地锚点
            let planeAnchor: ARPlaneAnchor = anchor as! ARPlaneAnchor
            //2.创建一个3D物体模型 （系统捕捉到的平地是一个不规则大小的长方形，这里笔者将其变成一个长方形，并且是否对平地做了一个缩放效果）
            //参数分别是长宽高和圆角
            let plane: SCNBox = SCNBox(width: CGFloat(planeAnchor.extent.x * 0.3), height: 0, length: CGFloat(planeAnchor.extent.x * 0.3), chamferRadius: 0)
            //3.使用Material渲染3D模型
            plane.firstMaterial?.diffuse.contents = UIColor.orange
            //4.创建一个基于3D物体模型的节点
            let planeNode: SCNNode = SCNNode(geometry: plane)
            //5.设置节点的位置为捕捉到的平地的锚点的中心位置 SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
            node.addChildNode(planeNode)
            //2.当捕捉到平地时，2s之后开始在平地上添加一个3D模型
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                //1.创建一个花瓶场景
                let scene = SCNScene(named: "art.scnassets/chameleon.dae")
                //2.获取花瓶节点（一个场景会有多个节点，此处我们只写，花瓶节点则默认是场景子节点的第一个） //所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
                let pNode = SCNNode()
                for child in (scene?.rootNode.childNodes)! {
                    child.removeAllAnimations()
                    pNode.addChildNode(child)
                }
                //4.设置花瓶节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置，也就是相机位置
                pNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
                //5.将花瓶节点添加到当前屏幕中 //!!!此处一定要注意：花瓶节点是添加到代理捕捉到的节点中，而不是AR试图的根节点。因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
                node.addChildNode(pNode)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    let roll = SCNAnimation.fromFile(named: "anim_turnleft", inDirectory: "art.scnassets")
                    node.childNodes[0].addAnimation(roll!, forKey: roll?.keyPath)
                }
            }
            */
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
}

extension WDARSCNViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        print(frame.capturedImage)
        if planeNode != nil {
            print("移动相机")
//            planeNode?.position = SCNVector3Make(frame.camera.transform.columns.3.x, frame.camera.transform.columns.3.y, frame.camera.transform.columns.3.z)
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        
    }
    
}
