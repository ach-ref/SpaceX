//
//  SpaceXRouter.swift
//  SpaceX
//
//  Created by Achref Marzouki on 08/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import Alamofire

enum SpaceXRouter: Routable {
    
    static var baseUrl = "https://api.spacexdata.com/v3"
    
    case lanches(limit: Int = 50, offset: Int)
    case launch(_ id: Int)
    case rocket(_ id: String)
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .lanches: return "launches"
        case .launch(let id): return "launches/\(id)"
        case .rocket(let id): return "rockets/\(id)"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .lanches(let limit, let offset):
            return [URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]
        default:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var token: String? {
        return nil
    }
}
