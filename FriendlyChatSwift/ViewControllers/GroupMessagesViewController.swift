import UIKit
import Foundation
import JSQMessagesViewController
import Firebase

class GroupMessagesViewController: JSQMessagesViewController {

    var messages = [Message]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    let outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    let incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    var senderImageUrl: String!
    var batchMessages = true
    var ref: FIRDatabaseReference!
    var sender: FIRUser!
    public var group: Group!
    
    
    // *** STEP 1: STORE FIREBASE REFERENCES
    var messagesRef: FIRDatabaseReference!
    
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
        messagesRef = FirebaseUtils.sharedInstance.groupMessageRefForGroup(group: group)
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
        messagesRef.queryLimited(toFirst: 25).observe(.childAdded , with: { (snapshot) in
            self.messages.append(Message(snapshot: snapshot))
            self.finishReceivingMessage()
        });
    }
    
    func sendMessage(text: String!) {
        // *** STEP 3: ADD A MESSAGE TO FIREBASE
        messagesRef.childByAutoId()
        messagesRef.childByAutoId().setValue(Message.newTextMessageWith(content: text).messageDictionary)
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = URL(string: stringUrl) {
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                    avatars[name] = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: diameter)
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name: name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        let initials : String? = name.substring(to: name.index(name.startIndex, offsetBy: min(3, nameLength)))
        let userImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: color, textColor: UIColor.black, font: UIFont.systemFont(ofSize: 13.0), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        navigationController?.navigationBar.topItem?.title = "Chat Groups"
        
        sender = FirebaseUtils.sharedInstance.authUser
        senderId = sender.uid
        senderDisplayName = sender.displayName
        
        let profileImageUrl = sender.photoURL?.absoluteString
        if let urlString = profileImageUrl {
            setupAvatarImage(name: sender.displayName!, imageUrl: urlString as String, incoming: false)
            senderImageUrl = urlString as String
        } else {
            setupAvatarColor(name: sender.displayName!, incoming: false)
            senderImageUrl = ""
        }
        
        setupFirebase()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // ACTIONS
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottom(animated: true)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text: text)
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("Camera pressed!")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.sid == senderId {
            return outgoingBubbleImageView
        }
        
        return incomingBubbleImageView
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.senderDisplayName()] {
            return avatar
        } else {
            setupAvatarImage(name: message.senderDisplayName(), imageUrl: message.photoUrl, incoming: true)
            return avatars[message.senderDisplayName()]
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.senderId() == sender.uid {
            cell.textView.textColor = UIColor.black
        } else {
            cell.textView.textColor = UIColor.white
        }
        
        let attributes : [String:Any] = [NSForegroundColorAttributeName:cell.textView.textColor!, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
        //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.sid == sender.uid {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sid == message.sid {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.name!)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.sid == sender.uid {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sid == message.sid {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}
