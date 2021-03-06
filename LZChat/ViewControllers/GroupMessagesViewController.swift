import UIKit
import Foundation
import JSQMessagesViewController
import Firebase

class GroupMessagesViewController: JSQMessagesViewController {

    var messages = [Message]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    let outgoingBubbleImageDataSource = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    let incomingBubbleImageDataSource = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    var senderImageUrl: String!
    var batchMessages = true
    var autoChatMode = false
    var ref: FIRDatabaseReference!
    var sender: FIRUser!
    fileprivate var _refHandle: FIRDatabaseHandle!
    fileprivate var _modHandle: FIRDatabaseHandle!
    public var group: Group!
    var pluginsViewController: PluginsViewController?
    var showingAccessoryView: Bool? {
        didSet {
            var auxViewHeight:CGFloat = 0;
            if (showingAccessoryView)! {
                auxViewHeight = 250;
                if (oldValue != showingAccessoryView) {
                    pluginsViewController = PluginsViewController(nibName: "PluginsViewController", bundle: Bundle.main, sendMessageDelegate: self)
                    self.addChildViewController(pluginsViewController!)
                    self.view.addSubview((pluginsViewController?.view)!)
                    pluginsViewController?.view.frame = CGRect(x: 0, y: self.view.frame.height - auxViewHeight, width: self.view.frame.width, height: auxViewHeight)
                }
            } else {
                pluginsViewController?.removeFromParentViewController()
                self.pluginsViewController?.view?.removeFromSuperview()
            }
            
            self.jsq_setToolbarBottomLayoutGuideConstant(auxViewHeight)
        }
    }
    
    // *** STEP 1: STORE FIREBASE REFERENCES
    var messagesRef: FIRDatabaseReference!
    
    deinit {
        messagesRef.removeObserver(withHandle: _refHandle)
        messagesRef.removeObserver(withHandle: _modHandle)
    }
    
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
        messagesRef = FirebaseUtils.sharedInstance.groupMessageRefForGroup(group: group)
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
        _refHandle = messagesRef.queryOrdered(byChild: "ts").queryLimited(toLast: 25).observe(.childAdded , with: { [weak self] (snapshot) in
            guard let strongSelf = self else {return}
            let newMessage = Message(snapshot: snapshot)
            strongSelf.messages.append(newMessage)
            strongSelf.finishReceivingNewMessage(newMessage)
        });
        
        _modHandle = messagesRef.observe(.childChanged, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {return}
            
            let newMessage = Message(snapshot: snapshot)
            let newMessageMid = newMessage.mid
            
            for i in 0...strongSelf.messages.count-1 {
                if (newMessageMid == strongSelf.messages[i].mid) {
                    strongSelf.messages.remove(at: i)
                    strongSelf.messages.append(newMessage)
                    strongSelf.finishReceivingNewMessage(newMessage)
                }
            }
        })
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
        //inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        navigationController?.navigationBar.topItem?.title = "Back"
        
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
        registerNibsForSpecialCells()
        showingAccessoryView = false
        populateNavBar()
        bindViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func populateNavBar() {
        self.title = "\(group.displayTitle!)"
    }
    
    // ACTIONS
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottom(animated: true)
    }
    
    func toggleAutoMode(sender : UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            autoChatMode = !autoChatMode
            self.navigationItem.title = autoChatMode ? "Auto" : ""
        }
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(Message.newMessageWith(payload: text, messageType: .Text))
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        showingAccessoryView = !showingAccessoryView!
        self.inputToolbar.contentView.textView.endEditing(true)
    }
    
    func finishReceivingNewMessage(_ newMessage: Message) {
        super.finishReceivingMessage()
        if (autoChatMode) {
            AutoResponder.sharedInstance.sendMessageIfNeededWith(inputMessage: newMessage, messageSendingDelegate: self)
        }
    }
}

extension GroupMessagesViewController: SendMessageProtocol {
    func sendMessage(_ message: Message) {
        // *** STEP 3: ADD A MESSAGE TO FIREBASE
        FirebaseUtils.sharedInstance.sendMessage(in: group, messageToSend: message)
    }
    
    func updateMessage(_ message: Message) {
        FirebaseUtils.sharedInstance.updateMessage(in: group, messageToSend: message)
    }
    
}

// for Plugins
extension GroupMessagesViewController {
    
    func bindViews() {
        let longTapGR = UILongPressGestureRecognizer(target: self, action: #selector(toggleAutoMode(sender:)))
        self.inputToolbar.contentView.leftBarButtonItem.addGestureRecognizer(longTapGR)
        let collectionViewTapGR = UITapGestureRecognizer(target: self, action: #selector(dimissKeyboardAndPlugins(sender:)))
        self.collectionView.addGestureRecognizer(collectionViewTapGR)
    }
    
    func dimissKeyboardAndPlugins(sender : UITapGestureRecognizer) {
        self.showingAccessoryView = false
        self.inputToolbar.contentView.textView.endEditing(true)
    }
    
    func registerNibsForSpecialCells() -> Void{
        collectionView.register(UINib(nibName: MovieMessageCollectionViewCell.xibFileName, bundle: Bundle.main), forCellWithReuseIdentifier: MovieMessageCollectionViewCell.cellReuseIdentifier)
        collectionView.register(UINib(nibName: TicTacToeMessageCollectionViewCell.xibFileName, bundle:Bundle.main), forCellWithReuseIdentifier: TicTacToeMessageCollectionViewCell.cellReuseIdentifier)
    }
    
    func sizeForSpecialMessage(_ message: Message, width: CGFloat) -> CGSize {
        if (message.msgType == .Movie) {
            return CGSize(width: width, height: 280)
        }
        return CGSize(width: width, height: 210)
    }
    
    func collectionViewCellForSpecialMessage(_ message: Message, indexPath: IndexPath ) -> UICollectionViewCell {
        var specialCell: UICollectionViewCell?;
        if (message.msgType == .Movie) {
            specialCell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieMessageCollectionViewCell.cellReuseIdentifier , for: indexPath)
        } else if (message.msgType == .TicTacToe){
            specialCell = collectionView.dequeueReusableCell(withReuseIdentifier: TicTacToeMessageCollectionViewCell.cellReuseIdentifier, for: indexPath)
        }
        
        if let specialCell = specialCell as? MessageCollectionViewCell {
            specialCell.message = message
            specialCell.messageSendingDelegate = self
            configureSpecialCell(cell: specialCell, indexPath: indexPath)
            return specialCell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    }
    
    func configureSpecialCell(cell: MessageCollectionViewCell, indexPath: IndexPath ) -> Void {
        let message = messages[indexPath.row]
        let avatarDataSource = collectionView(collectionView, avatarImageDataForItemAt: indexPath)
        let bubbleDataSource = collectionView(collectionView, messageBubbleImageDataForItemAt: indexPath)
        let isIncomingMessage = message.sid != senderId
        let topSpacing = heightForMessageBubbleTopLabelAt(indexPath: indexPath)
        
        cell.configureCellWith(avatarDataSource: avatarDataSource, bubbleImageDataSource: bubbleDataSource, isIncomingMessage: isIncomingMessage, topSpacing: topSpacing)
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        showingAccessoryView = false
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        if (showingAccessoryView!) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(500)
            
            DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
                self.showingAccessoryView = true
            })
        }
    }
}

// CollectionView Delegates
extension GroupMessagesViewController {
    // needed for calculating height
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.row]
        if (message.isSpecialMessage) {
            let width = (collectionViewLayout as! JSQMessagesCollectionViewFlowLayout).itemWidth
            return sizeForSpecialMessage(message, width: width)
        }
        
        return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath);
    }
    
    // called from collectionViewCellForItemAtIndexPath
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.sid == senderId {
            return outgoingBubbleImageDataSource
        }
        
        return incomingBubbleImageDataSource
    }
    
    // called from collectionViewCellForItemAtIndexPath
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
    
    // normal collectionView Delegate
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        
        if message.isSpecialMessage {
            return collectionViewCellForSpecialMessage(message, indexPath: indexPath)
        }
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        if message.senderId() == sender.uid {
            cell.textView.textColor = UIColor.black
        } else {
            cell.textView.textColor = UIColor.white
        }
        
        let attributes : [String:Any] = [NSForegroundColorAttributeName:cell.textView.textColor!, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
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
    
    // Top bubble height
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return heightForMessageBubbleTopLabelAt(indexPath: indexPath)
    }
    
    func heightForMessageBubbleTopLabelAt(indexPath: IndexPath!) -> CGFloat {
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
