//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Jimmy Ghelani on 2023-09-18.
//

import Foundation

enum Rates: String, Codable, CaseIterable, CodingKey {
    case CAD, CHF, GBP, JPY, TRY, USD
}

struct Currency: Codable {
    let rates: [Rates: Double]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let ratesContainer = try container.nestedContainer(keyedBy: Rates.self, forKey: .rates)
        
        var dictionary = [Rates: Double]()
        
        for rateKey in ratesContainer.allKeys {
            guard let rate = Rates(rawValue: rateKey.rawValue) else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Could not parse json key to an AnEnum object")
                throw DecodingError.dataCorrupted(context)
            }
            let value = try ratesContainer.decode(Double.self, forKey: rateKey)
            dictionary[rate] = value
        }
        
        self.rates = dictionary
    }
}
