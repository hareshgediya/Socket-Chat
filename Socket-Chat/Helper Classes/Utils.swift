//
//  Utils.swift
//  Socket-Chat
//
//  Created by Haresh Gediya on 10/03/20.
//  Copyright © 2020 Haresh Gediya. All rights reserved.
//

import Foundation

class Utils {
    static func jsonData(from object: Any) -> Data? {
        return try? JSONSerialization.data(withJSONObject: object, options: [])
    }
}
