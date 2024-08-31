//
//  AppInfo.swift
//  MemeGenerator
//
//  Created by Pattiya Yiadram on 29/8/24.
//

import Foundation

struct MemeResponse: Codable {
    var success: Bool
    var data: MemeData
}

struct MemeData: Codable {
    var memes: [Meme]
}

struct Meme: Codable {
    var id: String
    var name: String
    var url: String
    var width: Int
    var height: Int
    var boxCount: Int
    
    private enum CodingKeys: String, CodingKey {
            case id
            case name
            case url
            case width
            case height
            case boxCount = "box_count" 
        // Ensure this matches the JSON key
        
        }
}
