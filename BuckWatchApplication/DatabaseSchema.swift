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
    @objc dynamic var date: Date = Date()
    @objc dynamic var time: Date = Date()
    @objc dynamic var trailCamera: String = ""
    
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
