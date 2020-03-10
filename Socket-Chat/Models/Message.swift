//
//  Message.swift
//  Socket-Chat
//
//  Created by Haresh Gediya on 10/03/20.
//  Copyright © 2020 Haresh Gediya. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType {
        return user
    }
    
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    let user: User
    
    private init(kind: MessageKind, user: User, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(text: String, user: User, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }
}
