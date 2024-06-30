//
//  WeatherAPI.swift
//  BuckWatchApplication
//
//  Created by Josiah Clark on 6/30/24.
//

import Foundation


var weatherApiKey: String = ""

struct WeatherData: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int
    let data: [WeatherDetail]

    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case timezone
        case timezoneOffset = "timezone_offset"
        case data
    }
}

struct WeatherDetail: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let uvi: Double?
    let clouds: Int
    let visibility: Int?
    let windSpeed: Double
    let windDeg: Int
    let windGust: Double?
    let weather: [Weather]
    let moonPhase: Double?
    let precipitation: Double?

    enum CodingKeys: String, CodingKey {
        case dt
        case sunrise
        case sunset
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case dewPoint = "dew_point"
        case uvi
        case clouds
        case visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather
        case moonPhase = "moon_phase"
        case precipitation = "rain"
    }
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}


func fetchWeatherData(latitude: Double, longitude: Double, dateTime: Date, completion: @escaping (WeatherData?) -> Void) {
    let dateTimeString = Int(dateTime.timeIntervalSince1970)
    let urlString = "https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=\(latitude)&lon=\(longitude)&dt=\(dateTimeString)&appid=\(weatherApiKey)&units=imperial"
    guard let url = URL(string: urlString) else {
        print("Invalid URL: \(urlString)")
        completion(nil)
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Failed to fetch weather data: \(error.localizedDescription)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            print("Received JSON: \(json)")

            let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            completion(weatherData)
        } catch {
            print("Failed to decode weather data: \(error.localizedDescription)")
            print("Received data: \(String(data: data, encoding: .utf8) ?? "N/A")")
            completion(nil)
        }
    }

    task.resume()
}
