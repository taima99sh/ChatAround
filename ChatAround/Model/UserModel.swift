//
//  UserModel.swift
//  ChatAround
//
//  Created by taima on 3/23/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import Foundation
import MapKit
import FirebaseFirestore
import MessageKit

class UserModel: NSObject, Codable, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0)
    
    var name: String
    var email: String
    var token: String
    var isOnline: Bool?
    var type: String?
    var gender: String?
    var Db: String?
    var image: UIImage = #imageLiteral(resourceName: "homeImage")
    var geoPoint: GeoPoint?{
        didSet {
            self.coordinate = CLLocationCoordinate2D(latitude: geoPoint?.latitude ?? 0, longitude: geoPoint?.longitude ?? 0)
        }
    }
    
    init(name: String, email: String,token: String, geoPoint: GeoPoint, isOnline: Bool) {
        self.isOnline = isOnline
        self.name = name
        self.email = email
        self.token = token
        self.geoPoint = geoPoint
        self.coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    
    enum CodingKeys: String, CodingKey {
                case name = "name"
                case email = "email"
                case token = "token"
                case geoPoint = "geoPoint"
                case isOnline = "isOnline"
    }
}

struct MessageModel: Codable {
    
    let sender: String
    let message: String
    let senderName: String
    let date: Date
}

struct GeneralModel: Codable {
    let id: String
    let name: String
}

//
struct PlaceModel: Codable {
    let name: String
    let email: String
    let token: String
    let images: String
}






