//
//  memeWidgetBundle.swift
//  memeWidget
//
//  Created by Pattiya Yiadram on 8/9/24.
//

import WidgetKit
import SwiftUI
import FirebaseCore // Import FirebaseCore for FirebaseApp
import FirebaseStorage // Import FirebaseStorage if you're using Firebase Storage

@main
struct memeWidgetBundle: WidgetBundle {
    init() {
            // Configure Firebase when the widget bundle is initialized
            FirebaseApp.configure()
        }
    var body: some Widget {
        memeWidget()
    }
}
