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
        newROSOP.topic = "/lightsensors"
        
        let SendData = try! JSONEncoder().encode(newROSOP)
        let SendJson = String(data: SendData, encoding: .utf8)!
        self.MyWebSocket.write(string: SendJson)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("WebSocket is disconnected!")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let LightSensor = try! JSONDecoder().decode(LightSensors.self, from: text.data(using: .utf8)!)
        //print("LS:", LightSensor.msg.left_side!, "LF:", LightSensor.msg.left_forward!, "RF:", LightSensor.msg.right_forward!, "RS:", LightSensor.msg.right_side!)
        self.ResultLabel.text =
        "LS: " + String(LightSensor.msg.left_side!) + ", " +
        "LF: " + String(LightSensor.msg.left_forward!) + ", " +
        "RF: " + String(LightSensor.msg.right_forward!) + ", " +
        "RS: " + String(LightSensor.msg.right_side!)
        
        self.ls_Layer.frame = CGRectMake(0, 150, self.interval, CGFloat(LightSensor.msg.left_side!) * 0.15)
        self.lf_Layer.frame = CGRectMake(self.interval, 150, self.interval, CGFloat(LightSensor.msg.left_forward!) * 0.15)
        self.rf_Layer.frame = CGRectMake(self.interval*2, 150, self.interval, CGFloat(LightSensor.msg.right_forward!) * 0.15)
        self.rs_Layer.frame = CGRectMake(self.interval*3, 150, self.interval, CGFloat(LightSensor.msg.right_side!) * 0.15)
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
    
    var ls_Layer: CALayer!
    var lf_Layer: CALayer!
    var rs_Layer: CALayer!
    var rf_Layer: CALayer!
    
    var screenWidth = CGFloat(0.0)
    var screenHeight = CGFloat(0.0)
    
    var interval: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MyWebSocket = WebSocket(url: URL(string: "ws://192.168.3.180:9000/")!)
        self.MyWebSocket.delegate = self
        
        self.screenWidth = self.view.bounds.width
        self.screenHeight = self.view.bounds.height
        
        self.interval = self.screenWidth / 4
        
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.HomeLabel = UILabel()
        self.HomeLabel.text = "Sensor on RaspberryPI Mouse"
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
        //self.view.addSubview(self.ResultLabel)
        
        self.ls_Layer = CALayer()
        self.ls_Layer.frame = CGRectMake(0, 150 , self.interval, 0)
        self.ls_Layer.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        
        self.lf_Layer = CALayer()
        self.lf_Layer.frame = CGRectMake(self.interval, 150, self.interval, 0)
        self.lf_Layer.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        
        self.rf_Layer = CALayer()
        self.rf_Layer.frame = CGRectMake(self.interval*2, 150, self.interval, 0)
        self.rf_Layer.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        
        self.rs_Layer = CALayer()
        self.rs_Layer.frame = CGRectMake(self.interval*3, 150, self.interval, 0)
        self.rs_Layer.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        self.view.layer.addSublayer(self.ls_Layer)
        self.view.layer.addSublayer(self.lf_Layer)
        self.view.layer.addSublayer(self.rf_Layer)
        self.view.layer.addSublayer(self.rs_Layer)
        
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
