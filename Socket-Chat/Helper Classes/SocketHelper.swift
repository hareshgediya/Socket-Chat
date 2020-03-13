//
//  SocketHelper.swift
//  Socket-Chat
//
//  Created by Haresh Gediya on 10/03/20.
//  Copyright © 2020 Haresh Gediya. All rights reserved.
//

import SocketIO

let kHost = "http://127.0.0.1:3001"
let kConnectUser = "connectUser"
let kExitUser = "exitUser"
let kUserList = "userList"
let kNewChatMessage = "newChatMessage"
let kChatMessage = "chatMessage"
let kStartType = "startType"
let kStopType = "stopType"
let kUserTypingUpdate = "userTypingUpdate"

typealias CompletionHandler = () -> Void
typealias UserCompletionHandler = (Result<[User], Error>) -> Void
typealias MessageCompletionHandler = (Message) -> Void

extension Notification.Name {
    static let userTyping = Notification.Name("userTypingNotification")
}

final class SocketHelper: NSObject {
    static var shared = SocketHelper()
    
    private var _manager: SocketManager?
    private var _socket: SocketIOClient?
    
    override init() {
        super.init()
        configureSocketClient()
    }
    
    private func configureSocketClient() {
        _manager = SocketManager(socketURL: URL(string: kHost)!, config: [.log(true), .compress])
        _socket = _manager?.defaultSocket
    }
    
    func establishConnection() {
        _socket?.connect()
    }
    
    func closeConnection() {
        _socket?.disconnect()
    }
    
    func joinChatRoom(name: String, completion: CompletionHandler) {
        _socket?.emit(kConnectUser, name)
        listenForOtherMessages()
        completion()
    }
    
    func leaveChatRoom(name: String, completion: CompletionHandler) {
        _socket?.emit(kExitUser, name)
        completion()
    }
    
    private func userList() {
        _socket?.on(kUserList, callback: { (result, ack) in
            guard result.count > 0 else {
                return
            }
        })
    }
    
    func userList(comletion: @escaping UserCompletionHandler) {
        _socket?.on(kUserList, callback: { (result, ack) in
            guard result.count > 0, let data = Utils.jsonData(from: result[0]) else {
                return
            }
            
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                comletion(.success(users))
            } catch {
                comletion(.failure(error))
            }
            
        })
    }
    
    func getMessages(completion: @escaping MessageCompletionHandler) {
        _socket?.on(kNewChatMessage, callback: { (result, ack) in
            
            guard let userJSON = result[0] as? [String : Any],
                let message = result[1] as? String,
                let date = result[2] as? String else {
                    return
            }
            completion(Message(text: message, user: User(id: userJSON["id"] as! String, nickname: userJSON["nickname"] as! String, isConnected: true), messageId: date, date: Date()))
            
        })
    }
    
    func sendMessage(message: String, withNickname nickname: String) {
        _socket?.emit(kChatMessage, nickname, message)
    }

    func sendStartTypingMessage(nickname: String) {
        _socket?.emit(kStartType, nickname)
    }
    
    func sendStopTypingMessage(nickname: String) {
        _socket?.emit(kStopType, nickname)
    }
    
    private func listenForOtherMessages() {
        _socket?.on(kUserTypingUpdate, callback: { (result, ack) in
            NotificationCenter.default.post(name: .userTyping, object: result[0] as? [String : AnyObject])
        })
    }
    
}
