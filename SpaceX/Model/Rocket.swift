//
//  Rocket.swift
//  SpaceX
//
//  Created by Achref Marzouki on 08/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class Rocket: NSObject {
    
    // MARK: - Properties
    
    var id = 0
    var name = ""
    var details = ""
    var wikiLink = ""
    var active = false
    var stages = 0
    var successRate = 0
    var firstFlight: Date?
    var country = ""
    var company = ""
    var height = 0.0
    var diameter = 0.0
    var mass = 0.0
    var enginesNumber = 0
    var landingLegs = 0
    
    // MARK: - Private
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: - Initializers
    
    init(fromJson json: Json) {
        super.init()
        
        id = Int(truncating: json["id"] as? NSNumber ?? 0)
        name = json["rocket_name"] as? String ?? ""
        details = json["description"] as? String ?? ""
        wikiLink = json["wikipedia"] as? String ?? ""
        active = Bool(truncating: json["active"] as? NSNumber ?? 0)
        stages = Int(truncating: json["stages"] as? NSNumber ?? 0)
        successRate = Int(truncating: json["success_rate_pct"] as? NSNumber ?? 0)
        firstFlight = dateFormatter.date(from: json["first_flight"] as? String ?? "")
        country = json["country"] as? String ?? ""
        company = json["company"] as? String ?? ""
        height = Double(truncating: (json["height"] as? Json)?["meters"] as? NSNumber ?? 0)
        diameter = Double(truncating: (json["diameter"] as? Json)?["meters"] as? NSNumber ?? 0)
        mass = Double(truncating: (json["mass"] as? Json)?["kg"] as? NSNumber ?? 0)
        enginesNumber = Int(truncating: (json["engines"] as? Json)?["number"] as? NSNumber ?? 0)
        landingLegs = Int(truncating: (json["landing_legs"] as? Json)?["number"] as? NSNumber ?? 0)
    }
}
