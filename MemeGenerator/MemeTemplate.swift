import Foundation

struct MemeTemplates: Codable {
    var success: Bool
    var data: Memes
    
}

struct Meme: Codable {
    let id, name: String
    let url: String
    let width, height, boxCount, captions: Int
    
    enum CodingKeys: String, CodingKey {
            case id, name, url, width, height, captions
            case boxCount = "box_count"
        }
    
}

struct Memes: Codable {
    var memes: [Meme]
    
}
