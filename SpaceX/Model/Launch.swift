//
//  Launch.swift
//  SpaceX
//
//  Created by Achref Marzouki on 08/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class Launch: NSObject {
    
    // MARK: - Properties
    
    var flightNumber = 0
    var date: Date?
    var year = ""
    var successful = false
    var site = ""
    var missionName = ""
    var missionPatchUrl: String?
    var details = ""
    var rocket: Rocket?
    
    // MARK: - Calculated properties
    
    var missionNameFirstLetter: String {
        guard let character = missionName.unicodeScalars.first else { return "" }
        return String(character)
    }
    
    // MARK: - Private
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    // MARK: - Initializers
    
    init(fromJson json: Json, downloadImage: Bool = false) {
        super.init()
        
        flightNumber = Int(truncating: json["flight_number"] as? NSNumber ?? 0)
        date = dateFormatter.date(from: json["launch_date_utc"] as? String ?? "")
        year = json["launch_year"] as? String ?? ""
        successful = Bool(truncating: json["launch_success"] as? NSNumber ?? 0)
        site = (json["launch_site"] as? Json)?["site_name_long"] as? String ?? ""
        missionName = json["mission_name"] as? String ?? ""
        details = json["details"] as? String ?? ""
        missionPatchUrl = (json["links"] as? Json)?["mission_patch_small"] as? String
    }
    
    // MARK: - Comparaison
    
    static func dateCompare(lhs: Launch, rhs: Launch) -> ComparisonResult {
        let now = Date()
        return (lhs.date ?? now).compare(rhs.date ?? now)
    }
    
    static func missionNameCompare(lhs: Launch, rhs: Launch) -> ComparisonResult {
        return lhs.missionName.compare(rhs.missionName)
    }
}
