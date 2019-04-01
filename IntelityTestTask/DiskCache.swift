//
//  Cache.swift
//  IntelityTestTask
//
//  Created by Oleksandr Marchenko on 3/31/19.
//  Copyright © 2019 Oleksandr Marchenko. All rights reserved.
//

import Foundation
import UIKit

class DiskCache {
    private init() { }

    static let shared = DiskCache()

    private let directoryURL: URL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

    private var cachedWeatherURL: URL {
        return directoryURL.appendingPathComponent("weather")
    }

    func cachedWeather() -> [Weather]? {
        guard let data = try? Data(contentsOf: cachedWeatherURL) else {
            return nil
        }

        let result = try? JSONDecoder().decode([Weather].self, from: data)

        return result
    }

    func saveWeather(_ weatherArray: [Weather]) {
        let encoder = JSONEncoder()

        try? encoder.encode(weatherArray).write(to: cachedWeatherURL)
    }

    private func iconURL(id: String) -> URL {
        return directoryURL.appendingPathComponent(id)
    }

    func cachedIcon(id: String) -> UIImage? {
        guard let data = try? Data(contentsOf: iconURL(id: id)) else {
            return nil
        }

        return UIImage(data: data)
    }

    func saveIcon(_ icon: UIImage, id: String) {
        try? icon.pngData()?.write(to: iconURL(id: id))
    }
}
