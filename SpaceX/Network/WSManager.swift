//
//  WSManager.swift
//  SpaceX
//
//  Created by Achref Marzouki on 08/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit
import Alamofire

class WSManager: NSObject {
    
    // MARK: - Shared instance
    
    static let shared = WSManager()
    
    // MARK: - Initializers
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public
    
    func fetchLaunches(limit: Int, offset: Int, completion: @escaping (Int, [Launch]) -> Void) {
        var launches: [Launch] = [], total = 0
        let url = SpaceXRouter.lanches(limit: limit, offset: offset)
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        Alamofire.request(url).validate().responseJSON(queue: queue, options: .allowFragments) { response in
            
            total = Int(response.response?.allHeaderFields["spacex-api-count"] as? String ?? "0")!
            
            if let result = response.value as? [Json] {
                for jsonLaunch in result {
                    let launch = Launch(fromJson: jsonLaunch)
                    launches.append(launch)
                }
            }
            
            completion(total, launches)
        }
    }
    
    func fetchDetailedLaunch(id: Int, completion: @escaping (Launch?) -> Void) {
        
        var launch: Launch?
        let url = SpaceXRouter.launch(id)
        let group = DispatchGroup(), queue = DispatchQueue.global(qos: .userInitiated)
        Alamofire.request(url).validate().responseJSON(queue: queue, options: .allowFragments) { response in
            if let jsonLaunch = response.value as? Json {
                
                launch = Launch(fromJson: jsonLaunch, downloadImage: true)
                
                // fetch detailed rocket info ----
                group.enter()
                let rocketId = (jsonLaunch["rocket"] as? Json)?["rocket_id"] as? String ?? ""
                self.fetchRocket(forId: rocketId) { rocket in
                    if let rocket = rocket {
                        launch!.rocket = rocket
                    }
                    group.leave()
                }
                group.wait()
                // -------------------------------
            }
            
            completion(launch)
        }
    }
    
    func fetchRocket(forId id: String, competion: @escaping (Rocket?) -> Void) {
        
        let url = SpaceXRouter.rocket(id)
        Alamofire.request(url).validate().responseJSON { response in
            if let jsonRocket = response.value as? Json {
                competion(Rocket(fromJson: jsonRocket))
            }
            else {
                competion(nil)
            }
        }
    }
}
