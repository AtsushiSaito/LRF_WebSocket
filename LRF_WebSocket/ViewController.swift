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
        print("LS:", LightSensor.msg.left_side!, "LF:", LightSensor.msg.left_forward!, "RF:", LightSensor.msg.right_forward!, "RS:", LightSensor.msg.right_side!)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data:", data.count)
    }
}

class ViewController: UIViewController{
    
    
    var HomeLabel: UILabel!
    var ConnectButon: UIButton!
    var MyWebSocket: WebSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MyWebSocket = WebSocket(url: URL(string: "ws://192.168.3.180:9000/")!)
        self.MyWebSocket.delegate = self
        
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.HomeLabel = UILabel()
        self.HomeLabel.text = "Heelo! WebSocketApp for LRF"
        self.HomeLabel.frame = CGRect(x:0 , y: 100, width: self.view.bounds.width, height: 50)
        self.HomeLabel.textAlignment = .center
        
        self.ConnectButon = UIButton()
        self.ConnectButon.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        self.ConnectButon.setTitle("Connect", for: .normal)
        self.ConnectButon.frame = CGRect(x:0 , y: 300, width: self.view.bounds.width, height: 50)
        self.ConnectButon.addTarget(self, action: #selector(self.ConnectWebSocket(sender:)), for: .touchUpInside)
        
        self.view.addSubview(self.HomeLabel)
        self.view.addSubview(self.ConnectButon)
    }
    
    @objc func ConnectWebSocket(sender: Any){
        self.MyWebSocket.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

