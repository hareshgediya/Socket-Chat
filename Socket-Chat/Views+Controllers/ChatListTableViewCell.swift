//
//  ChatListTableViewCell.swift
//  Socket-Chat
//
//  Created by Haresh Gediya on 10/03/20.
//  Copyright © 2020 Haresh Gediya. All rights reserved.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var lblUserName: UILabel!
    @IBOutlet private weak var imgProfile: UIImageView!
    @IBOutlet private weak var imgOnlineStatus: UIImageView!

    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgOnlineStatus.layer.cornerRadius = 5
        imgProfile.layer.cornerRadius = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(user: User) {
        lblUserName.text = user.nickname
    }
}
