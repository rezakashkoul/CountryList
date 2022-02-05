//
//  Country.swift
//  CountryList
//
//  Created by Reza Kashkoul on 16/Bahman/1400 .
//

import Foundation

struct Country: Codable, Comparable {
    static func == (lhs: Country, rhs: Country) -> Bool {
        return rhs.name.official.lowercased() == lhs.name.official.lowercased()
    }
    
    static func < (lhs: Country, rhs: Country) -> Bool {
        return rhs.name.official.lowercased() > lhs.name.official.lowercased()
    }
    
    let name: Name
    //    let flag: String
}

struct Name: Codable {
    
    let official: String
}
