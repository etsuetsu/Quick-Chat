//
//  ConversationsVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 12/18/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class ConversationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var items = [Conversation]()
    var isTableEmpty: Bool!
    lazy var leftButton: UIBarButtonItem = {
        let image = UIImage.init(named: "default profile")?.withRenderingMode(.alwaysOriginal)
        let button  = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(ConversationsVC.showProfile))
        return button
    }()
    var name = ""
        
    //MARK: Methods
    func customization()  {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        //NavigationBar customization
        let navigationTitleFont = UIFont(name: "AvenirNext-Regular", size: 18)!
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationTitleFont, NSForegroundColorAttributeName: UIColor.white]
        // notification setup
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToUserMesssages(notification:)), name: NSNotification.Name(rawValue: "showUserMessages"), object: nil)
        //right bar button
        let icon = UIImage.init(named: "compose")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(ConversationsVC.showContacts))
        self.navigationItem.rightBarButtonItem = rightButton
        //left bar button image fetching
        self.navigationItem.leftBarButtonItem = self.leftButton
        self.tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        if let id  = FIRAuth.auth()?.currentUser?.uid {
            GlobalVariables.users.child(id).observe(.value, with: { (snapshot) in
                let value = snapshot.value as! [String : String]
                let image = UIImage.downloadImagewith(link: value["profilePicLink"]!)
                    let contentSize = CGSize.init(width: 30, height: 30)
                    UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
                    let _  = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: contentSize), cornerRadius: 14).addClip()
                    image.draw(in: CGRect(origin: CGPoint(x: 0, y :0), size: contentSize))
                    let path = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: contentSize), cornerRadius: 14)
                    path.lineWidth = 2
                    UIColor.white.setStroke()
                    path.stroke()
                    let finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
                    UIGraphicsEndImageContext()
                    self.leftButton.image = finalImage
            })
        }
    }
    
    func fetchData() {
        let item = Conversation.init(profilePic: UIImage.init(named: "1")!, name: "Steve Jobs", lastMessage: "Hello there, how are you doing", time: Date.init(timeIntervalSinceNow: 10), isRead: true)
        let item2 = Conversation.init(profilePic: UIImage.init(named: "2")!, name: "William Brown", lastMessage: "Wonderful day, how is it there?", time: Date.init(timeIntervalSinceNow: 15), isRead: false)
        let item3 = Conversation.init(profilePic: UIImage.init(named: "3")!, name: "Conan", lastMessage: "random text", time: Date.init(timeIntervalSinceNow: 15), isRead: true)
       self.items.append(item)
       self.items.append(item2)
       self.items.append(item3)
    }
    
    func showProfile() {
        let info = ["viewType" : ShowExtraView.profile]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
        self.inputView?.isHidden = true
    }
    
    func showContacts() {
        let info = ["viewType" : ShowExtraView.contacts]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
    }
    
    func pushToUserMesssages(notification: NSNotification) {
        if let name = notification.userInfo?["username"] as? String {
            self.name = name
            self.performSegue(withIdentifier: "segue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            let vc = segue.destination as! ChatVC
            vc.userName = self.name
        }
    }

    //MARK: Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.items.count == 0 {
            self.isTableEmpty = true
            return 1
        } else {
            self.isTableEmpty = false
            return self.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.items.count == 0 {
            return self.tableView.bounds.height
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.isTableEmpty {
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConversationsTBCell
            cell.profilePic.image = self.items[indexPath.row].profilePic
            cell.nameLabel.text = self.items[indexPath.row].name
            cell.messageLabel.text = self.items[indexPath.row].lastMessage
            let dataformatter = DateFormatter.init()
            dataformatter.timeStyle = .short
            let date = dataformatter.string(from: self.items[indexPath.row].time)
            cell.timeLabel.text = date
            if self.items[indexPath.row].isRead == false {
                cell.nameLabel.font = UIFont(name:"AvenirNext-DemiBold", size: 17.0)
                cell.messageLabel.font = UIFont(name:"AvenirNext-DemiBold", size: 14.0)
                cell.timeLabel.font = UIFont(name:"AvenirNext-DemiBold", size: 13.0)
                cell.profilePic.layer.borderColor = GlobalVariables.blue.cgColor
                cell.messageLabel.textColor = GlobalVariables.purple
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Empty Cell")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.items.count > 0 {
            self.name = "from conversation"
            self.performSegue(withIdentifier: "segue", sender: self)
        }
    }
       
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchData()
    }
}

class ConversationsTBCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePic.layer.borderWidth = 2
        self.profilePic.layer.borderColor = GlobalVariables.purple.cgColor
    }
    
}



