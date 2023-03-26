//
//  PostDetailViewController.swift
//  Dem
//
//  Created by Vishnu Prem on 01/07/22.
//

import UIKit
import GrowingTextView
import Toaster
import SDWebImage

class PostDetailViewController: UIViewController, GrowingTextViewDelegate, MCOHTMLRendererDelegate {

    @IBOutlet weak var tbview: UITableView!
    @IBOutlet weak var textview: GrowingTextView!
//    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var lbl_no_comments: UILabel!

    var inboxMessageArr = [MCOIMAPMessage]()
    var FullMsgBodyArray = [MCOMessageParser]()
    
    var session = MCOIMAPSession()
    var inboxFolder = "INBOX"
    var senderEMail: String!
    var senderMsgID: String!
    var toUserName: String!
    var tabSelected:String!
    var profileImg: String!
    var userName: String!
    var userDes: String!
    var userTime: String!
    var userImgString: String!
    var myMsgArray = [[String :Any]]()

    var oneHeight = 0
    
    var keyboardHeight = 0 {
        willSet {
            if newValue != 0 {
                textview.transform = CGAffineTransform(translationX: 0, y: -CGFloat(newValue) + textview.bounds.height - 10)
                userImg.transform = CGAffineTransform(translationX: 0, y: -CGFloat(newValue) + userImg.bounds.height - 10)
                postBtn.transform = CGAffineTransform(translationX: 0, y: -CGFloat(newValue) + postBtn.bounds.height - 10)
            } else {
                textview.transform = .identity
                userImg.transform = .identity
                postBtn.transform = .identity
            }
        }
    }
    
    var loginType: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lbl_no_comments.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        tbview.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        
        let attributedText = NSMutableAttributedString(string: toUserName, attributes: [NSAttributedString.Key.font : UIFont.init(name: "Avenir-Heavy", size: 14) ?? ""])
        attributedText.append(NSAttributedString(string: " \(userDes ?? "")", attributes: [NSAttributedString.Key.font: UIFont.init(name: "Avenir-Medium", size: 14) ?? ""]))
        captionLabel.attributedText = attributedText
        
        postTimeLabel.attributedText = NSMutableAttributedString(string: userTime ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .regular)])

        textview.textContainer.lineFragmentPadding = 10
        textview.placeholder = "Add a comment"

//        profileImg.image = UIImage(named: userImgString)
        
        profileImg = UserDefaults.standard.object(forKey: "user_image") as? String
        userImg.sd_setImage(with: URL(string: profileImg), placeholderImage: UIImage(named: "user.png"))

//        captionLabel.text = userName
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        DemConstants.showActivityIndicator()
        loginType = UserDefaults.standard.object(forKey: "login_type") as? String

        if loginType == "Gmail" {
            getUserGmailHostingDetails()

        } else {
            getUserHostingDetails()
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            if let height = UserDefaults.standard.value(forKey: "KeyboardHeight"){
                oneHeight = height as! Int
            } else {
                oneHeight = Int(keyboardSize.height + 30 - view.safeAreaInsets.bottom)
                UserDefaults.standard.set(oneHeight, forKey: "KeyboardHeight")
            }
            keyboardHeight = isKeyboardShowing ? oneHeight : 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.setTabBarVisible(visible: true, animated: true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        super.viewWillDisappear(animated)
    }
    
    // MARK: Private func Other Email Fetch User Hosting
    func getUserHostingDetails() {
        
        session.hostname       = "outlook.office365.com"
        session.port           = 993
        session.connectionType = .TLS
        session.isVoIPEnabled = false
        session.username = SingletonClass.sharedInstance.userEmail
        session.password = SingletonClass.sharedInstance.userPassword

        if let op = session.checkAccountOperation() {
          op.start { err in
            if let err = err {
              print("IMAP Connect Error: \(err)")
                Toast(text: err.localizedDescription).show()

            } else {
                let requestKind : MCOIMAPMessagesRequestKind =  .headers
                let requestSearch : MCOIMAPSearchKind =  .kindSubject

                let folderInfo2 =  self.session.searchOperation(
                    withFolder: self.inboxFolder,
                   kind: requestSearch,
                    search: "DEMCMTS \(self.senderMsgID ?? "")")
                folderInfo2?.start({ error, info in
//                    print("message count :- \(info?.count() ?? 0)")
                    
                    if info?.count() == 0 {
                        self.lbl_no_comments.isHidden = false
                    } else {
                        self.lbl_no_comments.isHidden = true
                    }

                let fetchOperation2 = self.session.fetchMessagesOperation(withFolder: self.inboxFolder, requestKind: requestKind, uids: info)

                fetchOperation2?.start({ [self] error, messages, vanishedMessages in
                    if error == nil
                     {
                        self.inboxMessageArr = messages as! [MCOIMAPMessage]
                        self.loadData()

                     } else {
                         DemConstants.hideActivityIndicator()

                     }
                })
            
            })
                
            }
          }
        }
    }
    
    
    // MARK: Private func Google mail Fetch User Hosting
    func getUserGmailHostingDetails() {
        
        session.hostname       = "imap.gmail.com"
        session.port           = 993
        session.connectionType = .TLS
        session.username = SingletonClass.sharedInstance.userEmail
        session.connectionType = .TLS
        session.authType = MCOAuthType.xoAuth2
        session.isVoIPEnabled = false
//        print(SingletonClass.sharedInstance.accessToken)
        session.oAuth2Token = SingletonClass.sharedInstance.accessToken

        if let op = session.checkAccountOperation() {
          op.start { err in
            if let err = err {
              print("IMAP Connect Error: \(err)")
//                Toast(text: err.localizedDescription).show()
                DemConstants.hideActivityIndicator()
            } else {
                let requestKind : MCOIMAPMessagesRequestKind =  .headers
                let requestSearch : MCOIMAPSearchKind =  .kindSubject

                if self.tabSelected == "posts" {
                    let folderInfo2 =  self.session.searchOperation(
                        withFolder: self.inboxFolder,
                       kind: requestSearch,
                        search: "DEMPOSTCMTS \(self.senderMsgID ?? "")")
                    
                    folderInfo2?.start({ error, info in
    //                    print("message count :- \(info?.messageCount ?? 0)")

                        if info?.count() == 0 {
                            self.lbl_no_comments.isHidden = false
                        } else {
                            self.lbl_no_comments.isHidden = true
                        }
    //
                        
                    let fetchOperation2 = self.session.fetchMessagesOperation(withFolder: self.inboxFolder, requestKind: requestKind, uids: info)

                    fetchOperation2?.start({ [self] error, messages, vanishedMessages in
                        if error == nil
                         {
                            self.inboxMessageArr = messages as! [MCOIMAPMessage]
    //                        self.toSearchMessageArr = self.toSearchMessageArr.reversed()
                            self.loadData()
                         } else {
                             DemConstants.hideActivityIndicator()

                         }
                    })
                
                })
                    
                } else {
                    let folderInfo2 =  self.session.searchOperation(
                        withFolder: self.inboxFolder,
                       kind: requestSearch,
                        search: "DEMCMTS \(self.senderMsgID ?? "")")
                    
                    folderInfo2?.start({ error, info in
    //                    print("message count :- \(info?.messageCount ?? 0)")

                        if info?
                            .count() == 0 {
                            self.lbl_no_comments.isHidden = false
                        } else {
                            self.lbl_no_comments.isHidden = true
                        }
    //
                        
                    let fetchOperation2 = self.session.fetchMessagesOperation(withFolder: self.inboxFolder, requestKind: requestKind, uids: info)

                    fetchOperation2?.start({ [self] error, messages, vanishedMessages in
                        if error == nil
                         {
                            self.inboxMessageArr = messages as! [MCOIMAPMessage]
    //                        self.toSearchMessageArr = self.toSearchMessageArr.reversed()
                            self.loadData()
                         } else {
                             DemConstants.hideActivityIndicator()

                         }
                    })
                
                })
                }
                
                

                
            }
          }
        }
    }
    
    var isLoading = false
    var currentMsgCount = 10
    var LoadCount = 0
    
    func loadData() {
        DemConstants.showActivityIndicator()

        isLoading = true
        
        var tempArr = [UInt32]()
        
        for i in LoadCount..<self.inboxMessageArr.count {
                   
            guard let message = self.inboxMessageArr[i] as? MCOIMAPMessage else {
                continue
            }
            
            if tempArr.contains(message.uid)
            {
                
            }
            else
            {
                tempArr.append(message.uid)
                self.useImapFromFetchContent(uidToFetch: message.uid)
            }
            
//            loadFromMessageArr.append(message)

//            if message.uid == senderEMailID {
//                print("\(message)")

//            }
            
            
//            if i == (currentFromMsgCount - 10)
//            {
//                isFromLoading = false
////                self.tableview.reloadData()
//
//                break
//            }
            DemConstants.hideActivityIndicator()
        }
        DemConstants.hideActivityIndicator()

    }
    
    func useImapFromFetchContent(uidToFetch uid: UInt32) {
        
        let operation = session.fetchParsedMessageOperation(withFolder: inboxFolder, uid: UInt32(uid))
//        session.fetch

        operation?.start{( error, messageParser)-> Void in
            if error == nil {
                let returnValue = messageParser!.plainTextBodyRenderingAndStripWhitespace(false)
            }
            if messageParser != nil {
                
                let dict = ["Comment":messageParser?.plainTextBodyRendering() ?? "", "date": messageParser?.header.date.description ?? "", "userName": messageParser?.header.from.displayName.description ?? ""]
                
                self.myMsgArray.append(dict)
//                self.myMsgArray.
//                if messageParser.
//                print((messageParser?.plainTextBodyRendering())!)
//                self.FullMsgBodyArray.append(messageParser ?? MCOMessageParser())
                
//                print(messageParser?.header)
                

//                self.msgFromBodyArray.append(messageParser ?? MCOMessageParser())
            } else {
//                self.msgFromBodyArray.append(MCOMessageParser())
            }
            
            
           
            self.tbview.reloadData()
        }
    }
    
    func arraySort ()
    {
        
        let sorted = FullMsgBodyArray.sorted(by: { ($0.header.date.description) < ($1.header.date.description)})

        FullMsgBodyArray = sorted
        
//        print(FullMsgBodyArray);
                                             
    }
    
    
    func mailConfig() {
        DemConstants.showActivityIndicator()

        var smtpSession = MCOSMTPSession()
        
        if loginType == "Gmail" {
            smtpSession.hostname = "smtp.gmail.com"
            smtpSession.username = SingletonClass.sharedInstance.userEmail
            smtpSession.port = 465
            smtpSession.authType = MCOAuthType.xoAuth2
            smtpSession.oAuth2Token = SingletonClass.sharedInstance.accessToken
            smtpSession.connectionType = MCOConnectionType.TLS

        } else {
            smtpSession.hostname = "smtp-mail.outlook.com"
            smtpSession.username = SingletonClass.sharedInstance.userEmail
            smtpSession.password = SingletonClass.sharedInstance.userPassword
            smtpSession.port = 587
            smtpSession.authType = MCOAuthType.saslLogin
            smtpSession.connectionType = MCOConnectionType.startTLS
        }
        
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }

        let builder = MCOMessageBuilder()
        let userEmail = UserDefaults.standard.object(forKey: "user_email") as! String
        let userName = UserDefaults.standard.object(forKey: "user_name") as! String
        
        builder.header.to = [MCOAddress(displayName: toUserName, mailbox: senderEMail) as Any, MCOAddress(displayName: userName, mailbox: userEmail) as Any]
        
        builder.header.from = MCOAddress(displayName: userName, mailbox: userEmail)
        if self.tabSelected == "posts" {
            builder.header.subject = "DEMPOSTCMTS \(self.senderMsgID ?? "")"
        } else {
            builder.header.subject = "DEMCMTS \(self.senderMsgID ?? "")"
        }

        builder.htmlBody = textview.text!
        
            let rfc822Data = builder.data()
            let sendOperation = smtpSession.sendOperation(with: rfc822Data!)
            sendOperation?.start { (error) -> Void in
                if (error != nil) {
                    print("Error sending email: \(error?.localizedDescription)")
                    NSLog("Error sending email: \(error?.localizedDescription)")
                } else {
                    print("Successfully sent email!")
                    NSLog("Successfully sent email!")

                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
          
                    let dateTime = Date()
                    let currentTime = dateFormatterGet.string(from: dateTime)
                    
                    let dict = ["Comment": self.textview.text!, "date": currentTime , "userName": SingletonClass.sharedInstance.userName]
                    
                    self.myMsgArray.append(dict as [String : Any])
                    self.lbl_no_comments.isHidden = true
                    self.tbview.reloadData()
                    self.textview.text = ""
                
                }
                DemConstants.hideActivityIndicator()
            }
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func postAction(_ sender: Any) {
        if !textview.text.isEmpty {
            let commentContent = textview.text.trimmingCharacters(in: .whitespacesAndNewlines)
            mailConfig()

            textview.endEditing(true)
        }
    }
   

}

extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myMsgArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        
        let commentuu = myMsgArray[indexPath.row]["Comment"] as! String
        let username = myMsgArray[indexPath.row]["userName"] as? String
        
        let attributedText = NSMutableAttributedString(string: username ?? "", attributes: [NSAttributedString.Key.font : UIFont.init(name: "Avenir-Heavy", size: 14) ?? ""])
        attributedText.append(NSAttributedString(string: " \(commentuu)", attributes: [NSAttributedString.Key.font: UIFont.init(name: "Avenir-Medium", size: 14) ?? ""]))
        cell.commentLbl.attributedText = attributedText
//        cell.commentLbl.text = commentArray[indexPath.row]
//        print(FullMsgBodyArray[indexPath.row])
        
//        cell.commentLbl.text =   ?? "" + " " + commentuu
        
//        cell.commentLbl.text = FullMsgBodyArray[indexPath.row].header.from.displayName.description + " " + FullMsgBodyArray[indexPath.row].plainTextBodyRendering()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let dateTime = myMsgArray[indexPath.row]["date"] as? String ?? ""
        let date: Date? = dateFormatterGet.date(from: dateTime)
        cell.commentTimeLbl.text = dateFormatter.string(from: date!)
        
        if username == SingletonClass.sharedInstance.userName {
            cell.profileImgView.sd_setImage(with: URL(string: profileImg), placeholderImage: UIImage(named: "user.png"))

        } else {
            cell.profileImgView.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "user.png"))
//            cell.profileImgView.backgroundColor = UIColor.red
        }

        
        return cell
    }
    
    
    
}
