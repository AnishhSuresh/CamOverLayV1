//
//  CamOverLayV1App.swift
//  CamOverLayV1
//
//  Created by Anishh Suresh on 9/14/25.
//

import SwiftUI

@main
struct CamOverLayV1App: App {
    
    init() {
        print("\(OpenCVWrapper.openCVVersionString())")
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
