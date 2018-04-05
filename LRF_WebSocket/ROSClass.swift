//
//  ROSClass.swift
//  LRF_WebSocket
//
//  Created by AtsushiSaito on 2018/04/05.
//  Copyright © 2018年 AtsushiSaito. All rights reserved.
//

struct ROSOP: Codable {
    var op: String!
    var topic: String!
}

struct LightSensors_Msg: Codable {
    var right_forward: Int!
    var right_side: Int!
    var left_side: Int!
    var left_forward: Int!
    var sum_all: Int!
}

struct LightSensors: Codable{
    var op: String!
    var topic: String!
    var msg: LightSensors_Msg!
}
