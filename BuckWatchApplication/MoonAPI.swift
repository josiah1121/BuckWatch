//
//  MoonAPI.swift
//  BuckWatchApplication
//
//  Created by Josiah Clark on 6/30/24.
//

import Foundation
import CoreLocation
import MapKit

var moonApiKey: String = ""

struct MoonPhaseData: Codable {
    let days: [Day]
    
    struct Day: Codable {
        let datetime: String
        let moonphase: Double
    }
}

func fetchMoonPhase(latitude: Double, longitude: Double, date: String, completion: @escaping (Result<Double, Error>) -> Void) {
    let urlString = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(latitude),\(longitude)/\(date)?key=\(moonApiKey)&include=days"
    
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "InvalidURL", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "NoData", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }

        do {
            let moonPhaseData = try JSONDecoder().decode(MoonPhaseData.self, from: data)
            if let moonPhase = moonPhaseData.days.first?.moonphase {
                completion(.success(moonPhase))
            } else {
                completion(.failure(NSError(domain: "InvalidResponse", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
            }
        } catch {
            completion(.failure(error))
        }
    }

    task.resume()
}
