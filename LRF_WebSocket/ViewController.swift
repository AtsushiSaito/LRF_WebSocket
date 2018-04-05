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
        print(LaserScanData.msg.ranges.count)
        
        for i in 0..<LaserScanData.msg.ranges.count {
            let num: CGFloat
            if(LaserScanData.msg.ranges[i] == nil){
                num = 0
            }else{
                num = CGFloat(LaserScanData.msg.ranges[i]! * 200)
            }
            self.Layers[i].frame = CGRectMake(self.interval*CGFloat(i), 150, self.interval, num)
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
    
    var Layers: [CALayer] = []
    
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
        self.MyWebSocket = WebSocket(url: URL(string: "ws://192.168.3.180:9000/")!)
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
        BackLayer.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        
        self.view.layer.addSublayer(BackLayer)
        
        for i in 0..<360 {
            self.makeSensorLayer(frame: CGRectMake(self.interval*CGFloat(i), 150 , self.interval, 0))
            self.Layers[i].backgroundColor = UIColor(red: Frandom(), green: Frandom(), blue: Frandom(), alpha: 1.0).cgColor
            self.view.layer.addSublayer(self.Layers[i])
        }
    }
    
    func Frandom() -> CGFloat{
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    func makeSensorLayer(frame: CGRect){
        let Layer = CALayer()
        Layer.frame = frame
        Layer.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        self.Layers.append(Layer)
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
