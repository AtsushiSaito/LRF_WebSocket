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

struct Time: Codable {
    var secs: Int32!
    var nsecs: Int32!
}

struct Header: Codable {
    var seq: Int!
    var stamp: Time!
    var frame_id: String!
}

/*------------------------------------*/

struct LaserScan_msg: Codable {
    var header: Header!
    var angle_min: Float32!
    var angle_max: Float32!
    var angle_increment: Float32!
    var time_increment: Float32!
    var scan_time: Float32!
    var range_min: Float32!
    var range_max: Float32!
    
    var ranges: [Float32?] = []
    var intensities: [Float32?] = []
}

struct LaserScan: Codable {
    var op: String!
    var topic: String!
    var msg: LaserScan_msg!
}

/*------------------------------------*/

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
