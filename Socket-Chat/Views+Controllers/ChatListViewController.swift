//
//  ChatListViewController.swift
//  Socket-Chat
//
//  Created by Haresh Gediya on 10/03/20.
//  Copyright © 2020 Haresh Gediya. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController {
    
    @IBOutlet weak var tblChatList: UITableView!

    private var _arrUsers = [User]()
    private var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Welcome"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(joinChatRoom))
        
        tblChatList.delegate = self
        tblChatList.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketHelper.shared.userList { result in
            switch result {
            case .success(let users):
                self._arrUsers = users.filter { $0.nickname != self.name }
                self.tblChatList.reloadData()
            case .failure(_ ):
                break
            }
        }
    }

    @objc private func joinChatRoom() {
        let alertController = UIAlertController(title: "Socket", message: "Please enter a name:", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            
            guard let textFields = alertController.textFields else {
                return
            }
            
            let textfield = textFields[0]
            
            if textfield.text?.count == 0 {
                self.joinChatRoom()
            } else {
                
                guard let nickName = textfield.text else{
                    return
                }
                
                SocketHelper.shared.joinChatRoom(name: nickName) {
                    
                    guard let nickName = textfield.text else {
                        return
                    }
                    
                    self.title = nickName
                    self.name = nickName
                }
            }
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _arrUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.identifier, for: indexPath) as! ChatListTableViewCell
        cell.configure(user: _arrUsers[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatMessagesViewController()
        chatVC.currentUser = _arrUsers[indexPath.row]
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
