//
//  Place.swift
//  QueroConhecer
//
//  Created by mac on 01/02/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import MapKit
struct Place : Codable {
    
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let address: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func getFormatedAddress(with placemark: CLPlacemark) -> String {
        var address = ""
        if let street = placemark.thoroughfare {
          address += street //rua
        }
        
        if let number = placemark.subThoroughfare {
            address += " \(number)" //Numero
        }
        if let subLocality = placemark.subLocality {
            address += ", \(subLocality)" //bairro
        }
        
        if let state = placemark.administrativeArea {
            address += " - \(state)" // Cidade
        }
        
        if let postalCode = placemark.postalCode {
            address += "\nCEP: \(postalCode)"
        }
        
        if let country = placemark.country {
            address += "\n\(country)"
        }
        return address
        
    }
    
}
// (Equatable )-> Define regra a ser utilizada para comparacao de places
extension Place : Equatable{
    
    static func ==(lhs: Place, rhs: Place)-> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
