//
//  DatabaseSchema.swift
//  BuckWatch
//
//  Created by Josiah Clark on 6/28/24.
//

import Foundation
import RealmSwift

class ImageData: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var imageName: String = ""
    @objc dynamic var imageData: Data?
    @objc dynamic var animalType: String = ""
    @objc dynamic var isBuck: Bool = false
    @objc dynamic var buckSize: String?
    @objc dynamic var date: Date = Date()
    @objc dynamic var time: Date = Date()
    @objc dynamic var trailCamera: String = ""
    @objc dynamic var temperature: String = ""
    @objc dynamic var feelsLike: String = ""
    @objc dynamic var wind: String = ""
    @objc dynamic var windDirection: String = ""
    @objc dynamic var precipitation: String = ""
    @objc dynamic var sunrise: String = ""
    @objc dynamic var sunset: String = ""
    @objc dynamic var weatherDescription: String = ""
    @objc dynamic var moonPhase: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Camera: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
