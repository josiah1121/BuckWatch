//
//  BuckWatchApp.swift
//  BuckWatch
//
//  Created by Josiah Clark on 6/28/24.
//

import SwiftUI

@main
struct BuckWatchApplicationApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
            ImageUploadView()
                .tabItem {
                    Label("Upload", systemImage: "plus.circle")
                }
            
            ImageListView()
                .tabItem {
                    Label("Images", systemImage: "photo")
                }
            
            MapView()
               .tabItem {
                   Label("Map", systemImage: "map")
               }
            }
        }
    }
}
