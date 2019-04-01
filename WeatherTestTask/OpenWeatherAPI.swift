//
//  OpenWeatherAPI.swift
//  IntelityTestTask
//
//  Created by Oleksandr Marchenko on 3/31/19.
//  Copyright © 2019 Oleksandr Marchenko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum CityID: String, CaseIterable {
    case Kiev = "703448"
    case London = "2643743"
    case Toronto = "6167865"
}


private let appID = "a1d1dc41d71e2b1c1d329e64770bf088"

final class OpenWeatherAPI {
    enum Error: Swift.Error {
        case invalidFormat
    }

    private static func urlForCities(ids: [CityID]) -> URL {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/group")!
        components.queryItems = [URLQueryItem(name: "id", value: ids.map { $0.rawValue }.joined(separator: ",") ),
                                 URLQueryItem(name: "APPID", value:appID),
                                 URLQueryItem(name: "units", value: "metric")]
        return components.url!
    }

    static func fetchWeather(for ids: [CityID])  -> Observable<[Weather]> {
        assert(!ids.isEmpty, "City ids array is empty")

        let request = URLRequest(url: OpenWeatherAPI.urlForCities(ids: ids))

        return URLSession.shared.rx.data(request: request).map { data in
            let decoder = JSONDecoder()
            let weatherGroupResponse = try decoder.decode(WeatherGroupResponse.self, from: data)
            let weather = try weatherGroupResponse.list.map { try Weather(response: $0) }
            return weather
        }
    }

    static func fetchIcon(id: String) -> Observable<UIImage?> {
        let url = URL(string: "https://openweathermap.org/img/w")!.appendingPathComponent(id).appendingPathExtension("png")

        let request = URLRequest(url: url)

        return URLSession.shared.rx.data(request: request).map { data in
            return UIImage(data: data)
        }
    }
}

struct Weather: Codable {
    let description: String
    let temperature: Measurement<UnitTemperature>
    let iconID: String
    let cityName: String
    let date: Date
}

private extension Weather {
    init(response: WeatherResponse) throws {
        guard let weather = response.weather.first else {
            throw OpenWeatherAPI.Error.invalidFormat
        }

        self.init(description: weather.description,
                  temperature: .init(value: response.main.temp, unit: .celsius),
                       iconID: weather.icon,
                       cityName: response.name,
                       date: Date())
    }
}

private struct WeatherGroupResponse: Decodable {
    let list: [WeatherResponse]
}

private struct WeatherResponse: Decodable {
    struct Weather: Decodable {
        let description: String
        let icon: String
    }

    struct Main: Decodable {
        let temp: Double
    }

    let weather: [Weather]
    let main: Main
    let name: String
}
