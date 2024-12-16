//
//  DrinkDataManager.swift
//  Barman
//
//  Created by Carlos Padilla on 2024 december 13.
//

import Foundation

struct DrinkDataManager {

    static func loadDrinks() -> [Drink]? {
        // The JSON file is loaded from the Bundle.
        if let file = Bundle.main.url(forResource: File.main.name, withExtension: File.main.extension) {
            guard let data = try? Data(contentsOf: file) else { return nil }
            return try? JSONDecoder().decode([Drink].self, from: data)
        } else {
            return nil
        }
    }
    
    static func update(drinks: [Drink]) {
        // The updated drinks array is written to the Documents directory.
        guard let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let filePath = directoryPath.appendingPathComponent("drinks.json")
        let json = try? JSONEncoder().encode(drinks)
        try? json?.write(to: filePath)
    }
}
