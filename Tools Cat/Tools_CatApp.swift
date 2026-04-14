//
//  Tools_CatApp.swift
//  Tools Cat
//
//  Created by hailinpan on 2025/10/19.
//

import SwiftUI

@main
struct Tools_CatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}
