//
//  ChatMessagesViewController.swift
//  Socket-Chat
//
//  Created by Haresh Gediya on 10/03/20.
//  Copyright © 2020 Haresh Gediya. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatMessagesViewController: MessagesViewController, MessagesDataSource {
    
    var currentUser: User?
    private var _arrMessages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageInputBar()
        configureMessageCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserTyping(_:)), name: .userTyping, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketHelper.shared.getMessages { [weak self] message in
            self?.insertMessage(message)
        }
    }

    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        if let flowLayout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            flowLayout.collectionView?.backgroundColor = .systemBackground
            flowLayout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            flowLayout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
            flowLayout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            flowLayout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor.primaryColor.withAlphaComponent(0.3), for: .highlighted)
        messageInputBar.inputTextView.textColor = .label
        messageInputBar.inputTextView.placeholderLabel.textColor = .secondaryLabel
        messageInputBar.backgroundView.backgroundColor = .systemBackground
    }
    
    private func insertMessage(_ message: Message) {
        _arrMessages.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([_arrMessages.count - 1])
            if _arrMessages.count >= 2 {
                messagesCollectionView.reloadSections([_arrMessages.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    private func isLastSectionVisible() -> Bool {
        
        guard !_arrMessages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: _arrMessages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    @objc func handleUserTyping(_ notification: Notification) {
        if let dict = notification.object as? [String : AnyObject] {
            var names = ""
            var totalTypingUsers = 0
            for (typingUser, _) in dict {
                if typingUser != currentUser!.nickname {
                    names = (names == "") ? typingUser : "\(names), \(typingUser)"
                    totalTypingUsers += 1
                }
            }
            
            setTypingIndicatorViewHidden(!(totalTypingUsers > 0), animated: true)
        }
    }
    
    func currentSender() -> SenderType {
        return currentUser!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return _arrMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return _arrMessages.count
    }

}

extension ChatMessagesViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

//        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        
        DispatchQueue.global(qos: .default).async {
            SocketHelper.shared.sendMessage(message: text, withNickname: self.currentUser!.nickname)
            
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text.isEmpty {
            SocketHelper.shared.sendStopTypingMessage(nickname: currentUser!.nickname)
        } else {
            SocketHelper.shared.sendStartTypingMessage(nickname: currentUser!.nickname)
        }
    }

}

extension ChatMessagesViewController: MessageCellDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
}

extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
}
