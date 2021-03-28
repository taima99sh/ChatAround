//
//  UserProfile.swift
//  ChatAround
//
//  Created by taima on 3/24/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import Foundation
import FirebaseAuth

class UserProfile {
    static let shared = UserProfile()
    
    // get userID
    var userID: String? {
        get {
            return UserDefaults.standard.value(forKey: "userID") as? String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "userID")
            UserDefaults.standard.synchronize()
        }
    }
    
    func isUserLogin() -> Bool {
        return  Auth.auth().currentUser != nil
    }
}

extension UserDefaults {
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
    }
}
