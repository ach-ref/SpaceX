//
//  Sequence+MultiCriteriaSort.swift
//  SpaceX
//
//  Created by Achref Marzouki on 09/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import Foundation

extension Sequence {
    
    /// A type that represents a closure taking two elements and returns a ComparisonResult.
    typealias ClosureCompare = (_ lhs: Iterator.Element, _ rhs: Iterator.Element) -> ComparisonResult
    
    /// Sort a sequence using an array of ClosureCompare type.
    ///
    /// - Parameter comparaisons: Array of ClosureCompare type
    /// - Returns: The sequence sorted
    func sorted(by comparaisons: ClosureCompare...) -> [Iterator.Element] {
        return self.sorted(by: {
            for comparaison in comparaisons {
                let comparaisonResult = comparaison($0, $1)
                guard comparaisonResult == .orderedSame else {
                    return comparaisonResult == .orderedAscending
                }
            }
            
            return false
        })
    }
}
