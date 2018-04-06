//
//  ViewController.swift
//  LRF_WebSocket
//
//  Created by AtsushiSaito on 2018/04/05.
//  Copyright © 2018年 AtsushiSaito. All rights reserved.
//

import UIKit
import Starscream

extension ViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("WebSocket is connected!")
        
        var newROSOP = ROSOP()
        newROSOP.op = "subscribe"
        newROSOP.topic = "/scan"
        
        let SendData = try! JSONEncoder().encode(newROSOP)
        let SendJson = String(data: SendData, encoding: .utf8)!
        self.MyWebSocket.write(string: SendJson)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("WebSocket is disconnected!")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let LaserScanData = try! JSONDecoder().decode(LaserScan.self, from: text.data(using: .utf8)!)
        //print(LaserScanData.msg.ranges.count)
        
        for i in 0..<LaserScanData.msg.ranges.count {
            let num: CGFloat
            if(LaserScanData.msg.ranges[i] == nil){
                num = 0
            }else{
                num = CGFloat(LaserScanData.msg.ranges[i]! * 100)
            }
            let CenterPoint = CGPoint(x: self.screenWidth/2, y: self.screenHeight/2 + 50)
            let MovePoint = CGPoint(x: CenterPoint.x + (num * cos(radianFrom(deg: i))), y: CenterPoint.y + (num * sin(radianFrom(deg: i))))
            
            let UiPath = UIBezierPath()
            UiPath.move(to: CenterPoint)
            UiPath.addLine(to: MovePoint)
            
            self.Layers[i].path = UiPath.cgPath
            //self.Layers[i].frame = CGRectMake(self.screenWidth/2 - num, self.screenHeight/2 + 100 - num, self.interval, num)
        }
        //let LightSensor = try! JSONDecoder().decode(LightSensors.self, from: text.data(using: .utf8)!)
        
        /*self.Layers[0].frame = CGRectMake(0, 150, self.interval, CGFloat(LightSensor.msg.left_side!) * 0.15)
        self.Layers[1].frame = CGRectMake(self.interval, 150, self.interval, CGFloat(LightSensor.msg.left_forward!) * 0.15)
        self.Layers[2].frame = CGRectMake(self.interval*2, 150, self.interval, CGFloat(LightSensor.msg.right_forward!) * 0.15)
        self.Layers[3].frame = CGRectMake(self.interval*3, 150, self.interval, CGFloat(LightSensor.msg.right_side!) * 0.15)*/
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data:", data.count)
    }
}

class ViewController: UIViewController{
    var HomeLabel: UILabel!
    var ConnectButon: UIButton!
    var ResultLabel: UILabel!
    
    var MyWebSocket: WebSocket!
    
    var Layers: [CAShapeLayer] = []
    
    var ls_Layer: CALayer!
    var lf_Layer: CALayer!
    var rs_Layer: CALayer!
    var rf_Layer: CALayer!
    
    var screenWidth = CGFloat(0.0)
    var screenHeight = CGFloat(0.0)
    
    var SensorNum = CGFloat(360)
    
    var interval: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MyWebSocket = WebSocket(url: URL(string: "ws://192.168.22.26:9000/")!)
        self.MyWebSocket.delegate = self
        
        self.screenWidth = self.view.bounds.width
        self.screenHeight = self.view.bounds.height
        
        self.interval = self.screenWidth / SensorNum
        
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.HomeLabel = UILabel()
        self.HomeLabel.text = "LRF(Laser RangeFinder)"
        self.HomeLabel.frame = CGRect(x:0 , y: 50, width: self.view.bounds.width, height: 50)
        self.HomeLabel.textAlignment = .center
        
        self.ConnectButon = UIButton()
        self.ConnectButon.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        self.ConnectButon.setTitle("Connect", for: .normal)
        self.ConnectButon.frame = CGRect(x:0 , y: 100, width: self.view.bounds.width, height: 50)
        self.ConnectButon.addTarget(self, action: #selector(self.ConnectWebSocket(sender:)), for: .touchUpInside)
        
        self.ResultLabel = UILabel()
        self.ResultLabel.text = "Result"
        self.ResultLabel.frame = CGRect(x:0 , y: self.view.bounds.height / 2 - 100, width: self.view.bounds.width, height: 50)
        self.ResultLabel.textAlignment = .center
        
        self.view.addSubview(self.HomeLabel)
        self.view.addSubview(self.ConnectButon)
        
        let BackLayer = CALayer()
        BackLayer.frame = CGRectMake(0, 150 , self.screenWidth, screenHeight)
        BackLayer.backgroundColor = #colorLiteral(red: 0.03277932029, green: 0, blue: 0.100815383, alpha: 1)
        
        self.view.layer.addSublayer(BackLayer)
        
        for i in 0..<360 {
            let hei = Frandom()*100
            self.makeSensorLayer(theta: radianFrom(deg: i), radius: hei)
            self.Layers[i].backgroundColor = UIColor(red: Frandom(), green: Frandom(), blue: Frandom(), alpha: 1.0).cgColor
            self.view.layer.addSublayer(self.Layers[i])
        }
    }
    
    func radianFrom(deg: Int) -> CGFloat {
        return CGFloat.pi / 180.0 * CGFloat(deg)
    }
    
    func Frandom() -> CGFloat{
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    func makeSensorLayer(theta: CGFloat, radius: CGFloat){
        let ShapeLayer = CAShapeLayer()
        let UiPath = UIBezierPath()
        
        let CenterPoint = CGPoint(x: self.screenWidth/2, y: self.screenHeight/2 + 50)
        let MovePoint = CGPoint(x: CenterPoint.x + (radius * cos(theta)), y: CenterPoint.y + (radius * sin(theta)))
        
        UiPath.move(to: CenterPoint)
        UiPath.addLine(to: MovePoint)
        
        //ShapeLayer.strokeColor = UIColor(red: Frandom(), green: Frandom(), blue: Frandom(), alpha: 1.0).cgColor
        ShapeLayer.strokeColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        ShapeLayer.path = UiPath.cgPath
        ShapeLayer.lineDashPattern = [1, 1]
        ShapeLayer.lineWidth = 1.0
        
        self.Layers.append(ShapeLayer)
    }
    
    @objc func ConnectWebSocket(sender: Any){
        self.MyWebSocket.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }


}
