//
//  ChatViewController.swift
//  ChatAround
//
//  Created by taima on 3/31/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Sender: SenderType {
    
    var senderId: String
    var displayName: String
}

struct MyMessage: MessageType {
    
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    init(_ message: MessageModel) {
        self.sender = Sender(senderId: message.sender, displayName: message.senderName)
        messageId = "id"
        sentDate = message.date
        kind = .text(message.message)
    }
}

class ChatViewController: MessagesViewController {
    
    let currentUser = Sender(senderId: UserProfile.shared.userID ?? "", displayName: "you")
    
    var messages: [MessageType] = []
    
    var user: UserModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configurCollectionView()
        setupView()
        localized()
        setupData()
        //fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchData()
    }
}
extension ChatViewController {
    func setupView(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
//        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
//          layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
//          layout.textMessageSizeCalculator.incomingAvatarSize = .zero
//        }
    }
    func localized(){}
    func setupData(){
        if let user = self.user {
            let chatRef = db.collection("User").document(user.token).collection("ChatRoom").order(by: "date", descending: false)
            chatRef.addSnapshotListener(includeMetadataChanges: false) { (querySnapshot, error) in
                guard let snapshot = querySnapshot else {
                  print("Error fetching document: \(error!)")
                  return
                }
                snapshot.documentChanges.forEach { (change) in
                    print(change)
                    let result = Result {
                        try change.document.data(as: MessageModel.self)
                    }
                    switch result {
                    case .success(let message):
                        if let message = message {
                            self.messages.append(MyMessage(message))
                        } else {
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
                }
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    func fetchData(){
        self.messages.removeAll()
        if let user = self.user {
            let chatRef = db.collection("User").document(user.token).collection("ChatRoom")
            chatRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let querySnapshot = querySnapshot {
                    for doc in querySnapshot.documents {
                        let result = Result {
                            try doc.data(as: MessageModel.self)
                        }
                        switch result {
                        case .success(let message):
                            if let message = message {
                                self.messages.append(MyMessage(message))
                            } else {
                                print("Document does not exist")
                            }
                        case .failure(let error):
                            print("Error decoding user: \(error)")
                        }
                    }
                    self.messages.sort {
                        $0.sentDate < $1.sentDate
                    }
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    func sendMessage(_ message: MessageModel) {
        if let user = self.user {
            let ref = db.collection("User").document(user.token).collection("ChatRoom")
            do {
                try ref.addDocument(from: message)
                print("Success")
            } catch let error {
                print("Failure \(error.localizedDescription)")
            }
        }
    }

    // MARK: - configureMessagesCollectionView
    func configurCollectionView(){
        messageInputBar.inputTextView.becomeFirstResponder()
        messageInputBar.inputTextView.textColor = .black
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return message.sender.senderId == "\(UserProfile.shared.userID ?? " ")" ? .blue: .gray
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = MessageModel(sender: UserProfile.shared.userID ?? "", message: text, senderName: UserProfile.shared.userName ?? "", date: Date())
//        messages.append(MyMessage(message))
//        self.messagesCollectionView.reloadData()
        messageInputBar.inputTextView.text = ""
        sendMessage(message)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.image = self.user?.image 
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      let name = message.sender.displayName
      return NSAttributedString(
        string: name,
        attributes: [
          .font: UIFont.preferredFont(forTextStyle: .caption1),
          .foregroundColor: UIColor(white: 0.3, alpha: 1)
        ]
      )
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 35
    }
}
