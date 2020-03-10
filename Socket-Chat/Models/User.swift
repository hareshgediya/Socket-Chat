//
//  User.swift
//  Socket-Chat
//
//  Created by Haresh Gediya on 10/03/20.
//  Copyright © 2020 Haresh Gediya. All rights reserved.
//

import Foundation
import MessageKit

struct User: Codable, SenderType {
    var senderId: String {
        return id
    }
    
    var displayName: String {
        return nickname
    }
    
    let id: String
    let nickname: String
    let isConnected: Bool
}
