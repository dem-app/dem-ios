//
//  HomeViewController.swift
//  Dem
//
//  Created by Vishnu Prem on 29/06/22.
//

import UIKit
import Toaster
import WebKit
import DropDown
import GoogleSignIn

class HomeViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var btn_email: UIButton!
    @IBOutlet weak var btn_posts: UIButton!
    @IBOutlet weak var lbl_no_data: UILabel!

    var userDetails: [UserDetails] = []
    var inboxMessageArr = [MCOIMAPMessage]()
    var searchMessageArr = [MCOIMAPMessage]()
    var loadInboxMessageArr = [MCOIMAPMessage]()
    var loadPostMessageArr = [MCOIMAPMessage]() 

    var session = MCOIMAPSession()
//    var kfgndfjkng = MCOIMAPMoveMessagesOperation()
//    var messBodyArray = [MCOMessageParser]()
    
    var messBodyArray = [String]()
    var attachmentArray = [Any]()
    
    var postBodyArray = [String]()
    var postAttachmentArray = [Any]()
    
    var tabSelected:String!
    var selectedIndex:Int? = nil
    var isPostAttachment: Bool = false

    var userImg = ["Michael", "William", "Linda", "profile", "Elizabeth", "James", "Robert", "Jonita", "Carolyne", "Christopher", "Jonathan", "Gilberto", "Keila Maney", "Sabine"]
    
    var userName = ["Michael", "William", "Linda", "David", "Elizabeth", "James", "Robert", "Jonita", "Carolyne", "Christopher", "Jonathan", "Gilberto", "Keila Maney", "Sabine"]
    
    var imagArray = [["apple1"], ["dks3331", "dks3332"], ["dks3333"], ["dks3334", "dks3335", "dks3336"], ["facebookapp1", "github1"],[ "github2"], ["instagram1", "instagram2"], ["dks3332"], ["dks3335", "facebookapp1", "apple1"], ["github1","dks3333"], ["dks3336"], ["instagram2","dks3331"], ["dks3334","github1", "dks3336"], ["apple1", "github2"]]
    
    var descriptionUser = ["Hello Everyone, welcome to NewsFeed. \nIf you have any question, open an issue on github or email me dingkaishan@gmail.com \nSupport with a star🌟", "Watch Tim Cook's video statement and learn about the actions we are taking", "Let's find more that brings us together. \nFacebook location", "#ShareBlackStories", "When we work together, we can work through anything", "Download and Play Free #leagueoflegends \nsignup.leagueoflegends.com", "A game about placing blocks and going on adventures. \nCreate! Explore! Survive! Here's how you do it! \nESRB Rating: Everyone 10+ with Fantasy Violence", "Music and podcasts for every moment \nPlay, discover and share for free", "Make Your Day \nbit.ly/TikTokProgressReport", "Communication App", "Like and subscribe. \nlinkin.bio/youtube", "How people build software. The home of Hithub design. \nvimeo.com/githubanimation", "Democratizing finance for all. \nSecurities by Robinhood Financial (Member SIPC) \nCrypto by Robinhood Crypto (licensed by NY Dept Financial Services)", "For information about the steps we are taking to help keep communities safe in the cities we serve go to -> \nuber.com"]
    
    var userHours = ["1 Day ago", "6 Day ago", "8 Day ago", "2 Weeks ago", "2 Weeks ago", "2 Weeks ago", "2 Weeks ago", "3 Weeks ago", "3 Weeks ago", "3 Weeks ago", "1 Month ago", "1 Month ago", "1 Month ago", "2 Month ago"]
    var emailType: String!
    var loginType = UserDefaults.standard.object(forKey: "login_type") as! String


    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_no_data.isHidden = true

        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 200
//        inboxMessageArr = SingletonClass.sharedInstance.inboxMessageArr.reversed()
        // Do any additional setup after loading the view.
        
//        cv_stories.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryCollectionViewCell")
        tableview.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTableViewCell")
        
        tableview.register(UINib(nibName: "MailListTableViewCell", bundle: nil), forCellReuseIdentifier: "MailListTableViewCell")
        tableview.sectionHeaderHeight = 0
        
        DemConstants.showActivityIndicator()
        
        if loginType == "Gmail" {
            
           if (GIDSignIn.sharedInstance.hasPreviousSignIn()) {
               GIDSignIn.sharedInstance.restorePreviousSignIn {user , error in 
                   SingletonClass.sharedInstance.accessToken = user?.authentication.accessToken
                   print("hey this is accesstoken " + (user?.authentication.accessToken ?? ""))
                   DEMConstants.DEM_Local_Data.set(user?.authentication.accessToken, forKey: DEMConstants.Keys.accessToken)
                   self.getUserGmailHostingDetails()
               }
           } else {
               DemConstants.hideActivityIndicator()
               
           }
        } else {
            getUserHostingDetails()
        }

    }
//
//    override func viewWillAppear(_ animated: Bool) {
//            }
    
    
   
    
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
                
//                let fetchOp2 = self.session.fetchSubscribedFoldersOperation()
//                   fetchOp2?.start({ error, folders in
//
//                       print("\(folders)")
//                   })
                let requestKind : MCOIMAPMessagesRequestKind =  .headers
                let requestSearch : MCOIMAPSearchKind =  .kindSubject
                let folder = "INBOX"
//                let uids : MCOIndexSet = MCOIndexSet(range: MCORangeMake(1, 10))
//                let uids : MCOIndexSet = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
//                let uids : MCOIndexSet = MCOIndexSet(range: MCORangeMake(1, UInt64.))

                let folderInfo = self.session.folderInfoOperation(folder)

                    folderInfo?.start({ error, info in
                        print("message count :- \(info?.messageCount ?? 0)")
            //                        let msgPlainBody = info?.plainTextBodyRendering()
//                        print(info.)
                        let messageCount = info?.messageCount ?? 0
//                        let messageCountData = UInt64(messageCount)
                        let latest = 10
                        let lowerbound = messageCount
                        
                        let  uidset: MCOIndexSet
                        
                        if messageCount < 20 {
                            uidset = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))

                        } else {
                            uidset = MCOIndexSet(range: MCORangeMake(UInt64(lowerbound) - UInt64(latest), UInt64(latest)))
                        }
                        
                        let fetchOperation  = self.session.fetchMessagesByNumberOperation(withFolder: folder, requestKind: requestKind, numbers: uidset)
    //                        (withFolder: folder, requestKind: requestKind, uids: uids)

                    fetchOperation?.start({ [self] error, messages, vanishedMessages in
                        if error == nil
                         {

                            self.inboxMessageArr = messages as! [MCOIMAPMessage]
                            self.inboxMessageArr = self.inboxMessageArr.reversed()
                            SingletonClass.sharedInstance.inboxMessageArr.removeAll()
                            SingletonClass.sharedInstance.inboxMessageArr = messages as! [MCOIMAPMessage]

                            self.loadData()
                         }
                    })
                })
                
                
                // Search the dem post data
                
                let folderInfo1 =  self.session.searchOperation(
                   withFolder: folder,
                   kind: requestSearch,
                   search: "DEMNEWPOST")
                folderInfo1?.start({ error, info in
//                    print("message count :- \(info?.messageCount ?? 0)")

                let fetchOperation2  = self.session.fetchMessagesOperation(withFolder: folder, requestKind: requestKind, uids: info)

                fetchOperation2?.start({ [self] error, messages, vanishedMessages in
                    if error == nil
                     {

                        self.searchMessageArr = messages as! [MCOIMAPMessage]
                        self.searchMessageArr = self.searchMessageArr.reversed()
//                        SingletonClass.sharedInstance.inboxMessageArr.removeAll()
//                        SingletonClass.sharedInstance.inboxMessageArr = messages as! [MCOIMAPMessage]

                        self.loadPostData()
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
        let userEmail = UserDefaults.standard.object(forKey: "user_email") as! String

        session.username = userEmail
        session.connectionType = .TLS
        session.authType = MCOAuthType.xoAuth2
        session.isVoIPEnabled = false
        print(SingletonClass.sharedInstance.accessToken)
        session.oAuth2Token = SingletonClass.sharedInstance.accessToken

        if let op = session.checkAccountOperation() {
          op.start { err in
            if let err = err {
              print("IMAP Connect Error: \(err)")
//                Toast(text: err.localizedDescription).show()
                
                DEMConstants.DEM_Local_Data.removeObject(forKey: DEMConstants.Keys.accessToken)
                DemConstants.hideActivityIndicator()

            } else {
                let requestKind : MCOIMAPMessagesRequestKind =  .headers
                let requestSearch : MCOIMAPSearchKind =  .kindSubject
                let folder = "INBOX"
//                let uids : MCOIndexSet = MCOIndexSet(range: MCORangeMake(1, 10))
//                let uids : MCOIndexSet = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
//                let uids : MCOIndexSet = MCOIndexSet(range: MCORangeMake(1, UInt64.))

                let folderInfo = self.session.folderInfoOperation(folder)

                    folderInfo?.start({ error, info in
                        print("message count :- \(info?.messageCount ?? 0)")
            //                        let msgPlainBody = info?.plainTextBodyRendering()

                        let messageCount = info?.messageCount ?? 0
//                        let messageCountData = UInt64(messageCount)
                        let latest = 100
                        let lowerbound = messageCount
                        let uidset: MCOIndexSet!
                        
                        if latest > messageCount {
                            uidset = MCOIndexSet(range: MCORangeMake(UInt64(lowerbound) - UInt64(messageCount), UInt64(messageCount)))
                        } else {
                            uidset = MCOIndexSet(range: MCORangeMake(UInt64(lowerbound) - UInt64(latest), UInt64(latest)))
                        }
//                         uidset = MCOIndexSet(range: MCORangeMake(UInt64(lowerbound) - UInt64(latest), UInt64(latest)))

                        let fetchOperation  = self.session.fetchMessagesByNumberOperation(withFolder: folder, requestKind: requestKind, numbers: uidset)
    //                        (withFolder: folder, requestKind: requestKind, uids: uids)

                    fetchOperation?.start({ [self] error, messages, vanishedMessages in
                        if error == nil
                         {

                            self.inboxMessageArr = messages as! [MCOIMAPMessage]
                            self.inboxMessageArr = self.inboxMessageArr.reversed()
                            SingletonClass.sharedInstance.inboxMessageArr.removeAll()
                            SingletonClass.sharedInstance.inboxMessageArr = messages as! [MCOIMAPMessage]

                            self.loadData()
                         }
                    })
                })
                
                
                // Search the dem post message data
                
                let folderInfo1 =  self.session.searchOperation(
                   withFolder: folder,
                   kind: requestSearch,
                   search: "DEMNEWPOST")
                folderInfo1?.start({ error, info in
//                    print("message count :- \(info?.messageCount ?? 0)")

                let fetchOperation2  = self.session.fetchMessagesOperation(withFolder: folder, requestKind: requestKind, uids: info)

                fetchOperation2?.start({ [self] error, messages, vanishedMessages in
                    if error == nil
                     {

                        self.searchMessageArr = messages as! [MCOIMAPMessage]
                        self.searchMessageArr = self.searchMessageArr.reversed()
//                        SingletonClass.sharedInstance.inboxMessageArr.removeAll()
//                        SingletonClass.sharedInstance.inboxMessageArr = messages as! [MCOIMAPMessage]

                        self.loadPostData()
                     }
                })
            
            })
            }
          }
        }
    }
    
    
    var isLoading = false
    var currentMsgCount = 0
    var LoadCount = 0

    func loadData() {
        DemConstants.showActivityIndicator()

        isLoading = true
        
        for i in LoadCount..<self.inboxMessageArr.count {
                
            print("LoadCount value",LoadCount)

            if (inboxMessageArr[i].header.subject != nil){
                if (inboxMessageArr[i].header.subject.description == "My message") || inboxMessageArr[i].header.subject.description == "DEMCMTS" || inboxMessageArr[i].header.subject.description == "DEMMSG" || inboxMessageArr[i].header.subject.description == "DEMPOSTCMTS" || inboxMessageArr[i].header.subject.description == "DEMNEWPOST" {
                    print("Removed value")
//
                }
                else
                {
                    guard let message = self.inboxMessageArr[i] as? MCOIMAPMessage else {
                                   continue
                               }
                    let array = self.inboxMessageArr[i].header.subject.description.components(separatedBy:" ")
//                    if array.contains("DEMCMTS") || array.contains("DEMPOSTCMTS") || array.contains("DEMNEWPOST")

                    if array.contains("DEMCMTS") || array.contains("DEMPOSTCMTS") || array.contains("DEMNEWPOST")
                    {
                        print("qwertyuiop: \(message)")
                    }
                    else
                    {
                        loadInboxMessageArr.append(message)
                        print("12345678 \(message)")

                        self.useImapFetchContent(uidToFetch:message.uid)
                        
                        
                        LoadCount += 1

                        if self.inboxMessageArr.count <= 10
                        {
                            if LoadCount == self.inboxMessageArr.count
                            {
                                isLoading = true
                                break
                            }
                        }
                        else
                        {
                            if LoadCount == 10
                            {
                                isLoading = false
                                break
                            }
                        }
                    }
                }
            } else {
             
            }
                        
        }
       
        DemConstants.hideActivityIndicator()

    }

    
    func loadMoreData() {
        DemConstants.showActivityIndicator()

        isLoading = true
        
        var cot = 0
        
        for i in LoadCount..<self.inboxMessageArr.count {
                
            print("LoadCount value",LoadCount)

            if (inboxMessageArr[i].header.subject != nil){
                if (inboxMessageArr[i].header.subject.description == "My message") || inboxMessageArr[i].header.subject.description == "DEMCMTS" || inboxMessageArr[i].header.subject.description == "DEMMSG" || inboxMessageArr[i].header.subject.description == "DEMPOSTCMTS" {
                    print("Removed value")
                }
                else
                {
                    guard let message = self.inboxMessageArr[i] as? MCOIMAPMessage else {
                                   continue
                               }
                    let array = self.inboxMessageArr[i].header.subject.description.components(separatedBy:" ")
                    
                    if array.contains("DEMCMTS") || array.contains("DEMPOSTCMTS")
                    {
                        print("qwertyuiop: \(message)")
                    }
                    else
                    {
                        loadInboxMessageArr.append(message)
                        print("12345678 \(message)")

                        self.useImapFetchContent(uidToFetch:message.uid)
                        
                        
                        
                        cot += 1
                        
                        LoadCount += 1

                        if cot == 10
                        {
                            isLoading = false
                            break
                        }
                        else
                        {
                            if self.loadInboxMessageArr.count <= LoadCount
                            {
                                isLoading = true
                            }
                        }
                    }
                }
            } else {
             
            }
        }
       
        DemConstants.hideActivityIndicator()

    }
    
    var isPostLoading = false
    var currentPostMsgCount = 10
    var LoadPostCount = 0
    
    func loadPostData() {
        DemConstants.showActivityIndicator()

        isPostLoading = true
        
        for i in LoadPostCount..<self.searchMessageArr.count {
                   
            guard let message = self.searchMessageArr[i] as? MCOIMAPMessage else {
                continue
            }
            loadPostMessageArr.append(message)

            print("\(message)")
           self.useImapPostFetchContent(uidToFetch: message.uid)
            
//            if i == (currentPostMsgCount - 10)
//            {
//                isPostLoading = false
////                self.tableview.reloadData()
//
//                break
//            }
//            DemConstants.hideActivityIndicator()
        }
        DemConstants.hideActivityIndicator()

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tabSelected == "posts" {
            let lastData = self.loadPostMessageArr.count - 1
            if !isPostLoading && indexPath.row == lastData {
                
                LoadPostCount = LoadPostCount + 1;
                currentPostMsgCount = currentPostMsgCount + 10;
                self.loadPostData()
            }

        } else {
            let lastData = self.loadInboxMessageArr.count - 1
            if !isLoading && indexPath.row == lastData {
                
                if LoadCount <= self.loadInboxMessageArr.count
                {
                    self.loadMoreData()
                }
                
            }
        }
        
        
    }
    
    
    func useImapFetchContent(uidToFetch uid: UInt32)
    {

//        let ind = IndexPath(row: senderTag, section: 0)
//        let cell = tableview.cellForRow(at: ind) as? MailListTableViewCell
        let operation = session.fetchParsedMessageOperation(withFolder: "INBOX", uid: UInt32(uid))

        operation?.start{( error, messageParser)-> Void in
            if error == nil {
                let returnValue = messageParser!.plainTextBodyRenderingAndStripWhitespace(false)
            }
//            let subject = messageParser?.header.from.mailbox
//            print(subject ?? ":")
//            let rep = messageParser?.header.inReplyTo
//            print("print ===---====---- \(rep)")
            let msgHTMLBody = messageParser?.attachments()
            
            if  (msgHTMLBody?.count != 0) && (msgHTMLBody != nil) {
                print(msgHTMLBody!)
//                let unWantedAttachment = msgHTMLBody![0] as! MCOAttachment
                
//                if unWantedAttachment.mimeType == "message/delivery-status" {
//
//                } else {
                    self.attachmentArray.append(msgHTMLBody!)
//                }
            }
            else
            {
                self.attachmentArray.append([Any]())
            }
            
//            let from = messageParser?.header.from
//            print(from)
//            let to = messageParser?.header.to
//            print(to)
//            let msgPlainBody = messageParser?.plainTextRendering()
//            cell?.lbl_body.text = msgPlainBody ?? ""
//            let msgPlainBody = messageParser?.plainTextBodyRendering()


//            let attachments = messageParser?.attachments() as? [MCOAttachment]

//            print(messageParser?.htmlBodyRendering()!)
//            print("DEMCMTS \(messageParser?.header.messageID.description ?? "")")

            if messageParser?.header.subject == "My message" || messageParser?.header.subject == "DEMCMTS \(messageParser?.header.messageID.description)" {
                
            } else {
                if messageParser != nil {
                    self.messBodyArray.append((messageParser?.htmlBodyRendering())!)
                } else {
    //                self.messBodyArray.append(contentsOf: [MCOMessageParser]())
                    self.messBodyArray.append("")
                }
            }
          
            self.tableview.reloadData()
        }
    }
    
    func useImapPostFetchContent(uidToFetch uid: UInt32) {
        
        let operation = session.fetchParsedMessageOperation(withFolder: "INBOX", uid: UInt32(uid))

        operation?.start{( error, messageParser)-> Void in
            if error == nil {
                let returnValue = messageParser!.plainTextBodyRenderingAndStripWhitespace(false)
            }
//            let subject = messageParser?.header.from.mailbox
//            print(subject ?? ":")
//
            let msgHTMLBody = messageParser?.attachments()
            
            if  (msgHTMLBody?.count != 0) && (msgHTMLBody != nil) {
//                print(msgHTMLBody!)
                self.postAttachmentArray.append(msgHTMLBody!)
//                DEMConstants.DEM_Local_Data.set(self.postAttachmentArray, forKey: "Attachment")
            }
            else
            {
                self.postAttachmentArray.append([Any]())
            }

//            let attachments = messageParser?.attachments() as? [MCOAttachment]

            
            if messageParser != nil {
//                print((messageParser?.plainTextBodyRendering())!)
                self.postBodyArray.append((messageParser?.plainTextBodyRendering())!)
            } else {
                self.postBodyArray.append("")
            }
            self.tableview.reloadData()
        }
    }
    
    // MARK:- Webview Images
//    func loadInlineImagesforWebView(_ webView: UIWebView?) {
//        let result = webView?.stringByEvaluatingJavaScript(from: "findCIDImageURL()")
//        let data = result?.data(using: .utf8)
//        var imagesURLStrings: [AnyHashable]? = nil
//        do {
//            if let data {
//                imagesURLStrings = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable]
//            }
//        } catch {
//        }
//
//        for urlString in imagesURLStrings ?? [] {
//            guard let urlString = urlString as? String else {
//                continue
//            }
//            var part: MCOAbstractPart? = nil
//            var url: URL? = nil
//
//            url = URL(string: urlString)
//            if isCID(url) {
//                part = part(forContentID: url.resourceSpecifier)
//            } else if isXMailcoreImage(url) {
//                let specifier = url.resourceSpecifier
//                let partUniqueID = specifier
//                part = part(forUniqueID: partUniqueID)
//            }
//
//            if part == nil {
//                continue
//            }
//
//            let partUniqueID = part!.uniqueID
//
//            let previewData = dataPart(forUniqueID: partUniqueID)
//
//            let inlineData = "data:image/jpg;base64,\(previewData?.base64EncodedString(options: .lineLength64Characters) ?? "")"
//
//            let args = [
//                "URLKey": urlString,
//                "InlineDataKey": inlineData
//            ]
//            let jsonString = _jsonEscapedString(fromDictionary: args)
//            let replaceScript = "replaceImageSrc(\(jsonString))"
//            webView.stringByEvaluatingJavaScript(from: replaceScript)
//        }
//    }
    
    // MARK: Private func Fetch User Data
//    private func fetchUserData() {
//        let path = Bundle.main.path(forResource: "user-details", ofType: "json")
//        let data = NSData(contentsOfFile: path ?? "") as Data?
//        do {
//            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
//            if let aUserDetails = json["userDetails"] as? [[String : Any]] {
//                for element in aUserDetails {
//                    userDetails += [UserDetails(userDetails: element)]
//                }
//            }
//        } catch let error as NSError {
//            print("Failed to load: \(error.localizedDescription)")
//        }
//    }
    
    @IBAction func tabButtonClicked(_ sender:UIButton) {
        
        if sender.tag == 0 {
            btn_email.backgroundColor = #colorLiteral(red: 0.01960784314, green: 0.0431372549, blue: 0.05882352941, alpha: 1)
            btn_email.setTitleColor(UIColor.white, for: .normal)
            btn_posts.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btn_posts.setTitleColor(UIColor(red: 5/255, green: 11/255, blue: 15/255, alpha: 1.0), for: .normal)
            tabSelected = "emails"
            
            if loadInboxMessageArr.count == 0 {
                self.lbl_no_data.isHidden = false
            } else {
                self.lbl_no_data.isHidden = true

            }
            print("Selecetd Email")
        } else {
            btn_posts.backgroundColor = #colorLiteral(red: 0.01960784314, green: 0.0431372549, blue: 0.05882352941, alpha: 1)
            btn_posts.setTitleColor(UIColor.white, for: .normal)
            btn_email.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btn_email.setTitleColor(UIColor(red: 5/255, green: 11/255, blue: 15/255, alpha: 1.0), for: .normal)
            tabSelected = "posts"
            
            if loadPostMessageArr.count == 0 {
                self.lbl_no_data.isHidden = false
            } else {
                self.lbl_no_data.isHidden = true

            }
            
            print("Selecetd Posts")
//            getUserGmailHostingDetails()
            
        }
        tableview.reloadData()
        DemConstants.hideActivityIndicator()

    }
    
    @IBAction func msgClicked(_ sender:UIButton) {
     
//        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard?.instantiateViewController(withIdentifier: "MessageListVC") as? MessageListVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tabSelected == "posts" {
            return loadPostMessageArr.count

        } else {
            return loadInboxMessageArr.count

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        if tabSelected == "posts" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath) as! FeedTableViewCell
            let userName = loadPostMessageArr[indexPath.row].header.from.displayName
                let userMail = loadPostMessageArr[indexPath.row].header.from.mailbox.description

            
            cell.usernameLbl.text = userName
            cell.userIdLbl.text = userMail
    //        cell.profileImgView.image = UIImage(named: userImg[indexPath.row])
            
            if indexPath.row <= (postBodyArray.count - 1)
            {
                if postBodyArray != nil
                {
                    
                    let htmlString = postBodyArray[indexPath.row]
                    let setHeightUsingCSS = "<head><meta name=\"viewport\" content=\"width=device-width, shrink-to-fit=YES\"></head><body>\(String(describing: htmlString))</body>"
                    cell.web_view.loadHTMLString(setHeightUsingCSS, baseURL: nil)

//                    cell.tv_caption.attributedText = postBodyArray[indexPath.row].html2AttributedString

                }
            }
//            cell.commentLbl.text = descriptionUser[indexPath.row]
//            cell.timeLbl.text = userHours[indexPath.row]
//            self.useImapFetchContent(uidToFetch: mailUserID)
            
            if postAttachmentArray.count == 0 {
                cell.cv_images.isHidden = true
                isPostAttachment = false
            } else {
                isPostAttachment = true
                cell.cv_images.isHidden = false
            }

            let attributedText = NSMutableAttributedString(string: "2", attributes: [NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 14)!])
            attributedText.append(NSAttributedString(string: " Likes by ", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 14)!]))
            attributedText.append(NSAttributedString(string: "\(userName ?? "")", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 14)!]))
            attributedText.append(NSAttributedString(string: " and others", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 14)!]))
            
            if indexPath.row <= (postAttachmentArray.count - 1)
            {
                cell.imagArray = postAttachmentArray[indexPath.row] as! [Any]
            }
            else
            {
                cell.imagArray = [Any]()
            }
            
            cell.likeLbl.attributedText = attributedText
            
            cell.moreBtn.tag = indexPath.row
            cell.moreBtn.addTarget(self, action: #selector(morePostBtn(sender:)), for: .touchUpInside)
            
            cell.cv_images.tag = indexPath.row
//            cell.imagArray = imagArray[indexPath.row]
//            cell.cv_images?.scrollToItem(at: IndexPath(row: indexPath.row, section: 0), at: .top, animated: true)
            cell.cv_images.reloadData()
            
            postConfigureGestures(index: indexPath.row, cell: cell)
            return cell
        } else {
            print(inboxMessageArr.count)
            let cell = tableView.dequeueReusableCell(withIdentifier: "MailListTableViewCell", for: indexPath) as! MailListTableViewCell
            
            let userName = loadInboxMessageArr[indexPath.row].header.from.displayName
                let userMail = loadInboxMessageArr[indexPath.row].header.from.mailbox.description
            let mailUserID = loadInboxMessageArr[indexPath.row].header.subject
                print("MsgId:- \(mailUserID)")
                
            
            cell.usernameLbl.text = userName
            cell.userIdLbl.text = userMail
            
            print(userName)
                        print(userMail)
            print(loadInboxMessageArr[indexPath.row].header.subject)

            cell.lbl_body.translatesAutoresizingMaskIntoConstraints = false
            
            if indexPath.row <= (messBodyArray.count - 1)
            {
                
//                cell.lbl_body.text = messBodyArray[indexPath.row]
                
                if messBodyArray != nil
                {
//                    let attrStr = try! NSAttributedString(
//                        data: (messBodyArray[indexPath.row].data(using: String.Encoding.unicode, allowLossyConversion: true)!),
//                                options: [.documentType : NSAttributedString.DocumentType.html],
//                                documentAttributes: nil)
////                    cell.tv_body. = true
//                    detailLabel.adjustsFontSizeToFitWidth = true
//                    cell.tv_body. = true
//                    let range = NSRange(location: cell.tv_body.text.count - 1, length: 0)
//                    cell.tv_body.scrollRangeToVisible(range)
//                    cell.tv_body.isScrollEnabled = false

//                    cell.tv_body.contentSize = cell.tv_body.bounds.size;
//                    cell.tv_body.attributedText = messBodyArray[indexPath.row].convertToAttributedFromHTML()
                    
                    let htmlString = messBodyArray[indexPath.row] 
//                    let setHeightUsingCSS = "<head><style type=\"text/css\"> img{ max-height: 600px; max-width: \(cell.tv_body.frame.size.width) !important; width: auto-10; height: auto;} </style> </head><body> \(String(describing: htmlString)) </body>"
                    let setHeightUsingCSS = "<head><meta name=\"viewport\" content=\"width=device-width, shrink-to-fit=YES\"></head><body>\(String(describing: htmlString))</body>"
//                    let setHeightUsingCSS = "<header><meta name='viewport' content='width=device-width, initial-scale=0.6, maximum-scale=0.6, minimum-scale=0.6, user-scalable=no, shrink-to-fit=NO'></header><body style='margin: 0px; padding: 0px; width:device-width; height:100%;\(String(describing: htmlString))'>"

                    cell.web_view.loadHTMLString(setHeightUsingCSS, baseURL: nil)

//                    let setHeightUsingCSS = "<head><style type=\"text/css\"> img{ max-height: 600px; max-width: \(cell.tv_body.frame.size.width) !important; width: auto-10; height: auto;} </style> </head><body> \(String(describing: htmlString)) </body>"
//                    var setHeightUsingCSS = "<header><meta name='viewport' content='width=device-width,height=device-height,initial-scale=1.0,user-scalable=0, maximum-scale=1.0, minimum-scale=1.0'></header>"
//                    setHeightUsingCSS.append(htmlString)
//                    cell.tv_body.frame = CGRectMake(0, 0, CGFloat(HUGE), 1)
//                    cell.tv_body.translatesAutoresizingMaskIntoConstraints = false
//                    cell.tv_body.sizeToFit()
//                    cell.tv_body.isScrollEnabled = false;
//                    cell.tv_body.attributedText = setHeightUsingCSS.html2AttributedString

                    
                   
//                    cell.tv_body.layoutIfNeeded()
                    
//                    let computedSize = cell.tv_body.attributedText.boundingRect(with: CGSize(width: 200, height: cell.tv_body.frame.size.height),
//                                                                       options: .usesLineFragmentOrigin,
//                                                                       context: nil)
//                    cell.tv_body.frame = computedSize
                    
                    
//                    let fixedWidth = CGFloat(100)
//                    let newSize = cell.tv_body.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//                    cell.tv_body.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)

//                    cell.lbl_body.text = messBodyArray[indexPath.row].plainTextBodyRendering()
                }
                
            }
            
            if selectedIndex == indexPath.row
            {
//                cell.tv_body.textContainer.maximumNumberOfLines = 0
//                cell.tv_body.isScrollEnabled = false;
                cell.web_view.scrollView.isScrollEnabled = true
                cell.view_moreBtn.setTitle("View less", for: .normal)
                cell.web_view_height.constant = 500
//                if indexPath.row <= (attachmentArray.count - 1)
//                {
//                    cell.attachmentArray = attachmentArray[indexPath.row] as! [Any]
//                    cell.initLoad()
//                }
//                else
//                {
//                    cell.attachmentArray = [Any]()
//                }
            }
            else
            {
//                cell.attachmentArray = [Any]()
//                cell.tv_body.isScrollEnabled = true;
//                textView.textContainer.lineBreakMode = .byTruncatingTail
//                cell.tv_body.textContainer.maximumNumberOfLines = 10
                cell.web_view.scrollView.isScrollEnabled = false
                cell.web_view_height.constant = 300
                cell.view_moreBtn.setTitle("View more", for: .normal)
//                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            }
            
            if indexPath.row <= (attachmentArray.count - 1)
            {
                cell.attachmentArray = attachmentArray[indexPath.row] as! [Any]
                cell.initLoad()
            }
            else
            {
                cell.attachmentArray = [Any]()
            }
            

            cell.view_moreBtn.tag = indexPath.row
            cell.view_moreBtn.addTarget(self, action: #selector(viewMoreBtn(sender:)), for: .touchUpInside)
            cell.moreBtn.tag = indexPath.row
            cell.moreBtn.addTarget(self, action: #selector(moreBtn(sender:)), for: .touchUpInside)
//            cell.moreBtn.addTarget(self, action: #selector(moreBtn(sender:)), for: .touchUpInside)

//                cell.profileImgView.image = UIImage(named: userImg[indexPath.row])
//                cell.captionLbl.text = descriptionUser[indexPath.row]
//                cell.timeLbl.text = userHours[indexPath.row]
            
            
//            let operation = session.fetchParsedMessageOperation(withFolder: "INBOX", uid: UInt32(mailUserID))
//            operation?.start{( error, messageParser)-> Void in
//                if error == nil {
//                    let returnValue = messageParser!.plainTextBodyRenderingAndStripWhitespace(false)
//                }
//    //            let subject = messageParser?.header.subject
//    //            print(subject)
//    //            let from = messageParser?.header.from
//    //            print(from)
//    //            let to = messageParser?.header.to
//    //            print(to)
//                let msgPlainBody = messageParser?.plainTextBodyRendering()
//                cell.lbl_body.text = msgPlainBody ?? ""
//
//                print("BODY")
//                print(msgPlainBody ?? "")
////                self.tableview.reloadData()
//            }
//            self.useImapFetchContent(uidToFetch: mailUserID, senderTag: indexPath.row)
                
                let attributedText = NSMutableAttributedString(string: "2", attributes: [NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 14)!])
                attributedText.append(NSAttributedString(string: " Likes by ", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 14)!]))
            attributedText.append(NSAttributedString(string: (String(describing: userName ?? "")), attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 14)!]))
                attributedText.append(NSAttributedString(string: " and others", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 14)!]))
                
                cell.lbl_likes.attributedText = attributedText
                cell.cv_attachment.tag = indexPath.row
                cell.cv_attachment.reloadData()
                
                emailConfigureGestures(index: indexPath.row, cell: cell)
            return cell
        }
      
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tabSelected == "posts" {
            if isPostAttachment == false {
                return 300

            } else {
                return 580

            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    @objc func viewMoreBtn(sender: UIButton) {
        
        let ind = IndexPath(row: sender.tag, section: 0)
//        let cell = tableview.cellForRow(at: ind) as! MailListTableViewCell
        
        if selectedIndex == sender.tag
        {
            selectedIndex = nil
        }
        else
        {
            selectedIndex = sender.tag
        }
        
        tableview.scrollToRow(at: ind, at: .top, animated: false)

        
//        if cell.isSelected {
//            cell.lbl_body.numberOfLines = 0
//
//        } else {
//            cell.lbl_body.numberOfLines = 10
//        }
        self.tableview.reloadData()
    }
    
    @objc func moreBtn(sender: UIButton) {
        
        let ind = IndexPath(row: sender.tag, section: 0)
        let cell = tableview.cellForRow(at: ind) as! MailListTableViewCell
        
        if cell.view_delete.isHidden == true {
            cell.view_delete.isHidden = false
        } else {
            cell.view_delete.isHidden = true
        }
    }
    
    @objc func deleteEmailClickBtn(sender: CustomTapGesture) {
        let ind = IndexPath(row: sender.index, section: 0)
        let cell = tableview.cellForRow(at: ind) as! MailListTableViewCell
        
        let uid = loadInboxMessageArr[sender.index].uid
        let uids: MCOIndexSet = MCOIndexSet(index: UInt64(uid))
        
        if loginType == "Gmail" {
            let localCopyMessageOperation = session.copyMessagesOperation(withFolder: "INBOX", uids: uids, destFolder: "[Gmail]/Trash")
            
            localCopyMessageOperation!.start { (error, uidMapping) -> Void in
                
              if let error = error {
                  NSLog("error in deleting email : \(error.localizedDescription)")
              } else {
                  NSLog("email deleted")
                  print(uidMapping?.description ?? "")
                  self.loadInboxMessageArr.remove(at: sender.index)
                  self.messBodyArray.remove(at: sender.index)
                  cell.view_delete.isHidden = true
                  Toast(text: "Mail Deleted Successfully").show()
                  self.tableview.reloadData()
              }
          }
        } else {
            let localCopyMessageOperation = session.copyMessagesOperation(withFolder: "INBOX", uids: uids, destFolder: "Deleted")
            
            localCopyMessageOperation!.start { (error, uidMapping) -> Void in
                
              if let error = error {
                  NSLog("error in deleting email : \(error.localizedDescription)")
              } else {
                  NSLog("email deleted")
                  print(uidMapping?.description ?? "")
                  self.loadInboxMessageArr.remove(at: sender.index)
                  self.messBodyArray.remove(at: sender.index)
                  cell.view_delete.isHidden = true
                  Toast(text: "Mail Deleted Successfully").show()
                  self.tableview.reloadData()
              }
          }
        }
    }
    
    // Post Configurations
    @objc func morePostBtn(sender: UIButton) {
        
        let ind = IndexPath(row: sender.tag, section: 0)
        let cell = tableview.cellForRow(at: ind) as! FeedTableViewCell
        
        if cell.view_delete.isHidden == true {
            cell.view_delete.isHidden = false
        } else {
            cell.view_delete.isHidden = true
        }
    }
    
    @objc func deletePostClickBtn(sender: CustomTapGesture) {
        print("Btn Clicked true")
        let ind = IndexPath(row: sender.index, section: 0)
        let cell = tableview.cellForRow(at: ind) as! FeedTableViewCell

        let uid = loadPostMessageArr[sender.index].uid
        let uids: MCOIndexSet = MCOIndexSet(index: UInt64(uid))

        if loginType == "Gmail" {
            let localCopyMessageOperation = session.copyMessagesOperation(withFolder: "INBOX", uids: uids, destFolder: "[Gmail]/Trash")

            localCopyMessageOperation!.start { (error, uidMapping) -> Void in

              if let error = error {
                  NSLog("error in deleting email : \(error.localizedDescription)")
              } else {
                  NSLog("email deleted")
                  print(uidMapping?.description ?? "")
                  self.loadPostMessageArr.remove(at: sender.index)
                  self.postAttachmentArray.remove(at: sender.index)
                  cell.view_delete.isHidden = true
                  Toast(text: "Mail Deleted Successfully").show()
                  self.tableview.reloadData()
              }
          }
        } else {
            let localCopyMessageOperation = session.copyMessagesOperation(withFolder: "INBOX", uids: uids, destFolder: "Deleted")

            localCopyMessageOperation!.start { (error, uidMapping) -> Void in

              if let error = error {
                  NSLog("error in deleting email : \(error.localizedDescription)")
              } else {
                  NSLog("email deleted")
                  print(uidMapping?.description ?? "")
                  self.loadInboxMessageArr.remove(at: sender.index)
                  self.messBodyArray.remove(at: sender.index)
                  cell.view_delete.isHidden = true
                  Toast(text: "Mail Deleted Successfully").show()
                  self.tableview.reloadData()
              }
          }
        }
    }
    
    @objc func handleTap(sender: CustomTapGesture) {
        
        let vc = storyboard?.instantiateViewController(identifier: "LikeVC") as? LikeVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func handleTapProfile(sender: CustomTapGesture) {
        
        let vc = storyboard?.instantiateViewController(identifier: "ProfileViewController") as? ProfileViewController
        vc?.userNameString = userName[sender.index]
        vc?.userImgString = userImg[sender.index]
        vc?.userDesString = descriptionUser[sender.index]
        vc?.isHome = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @objc func handleCommentTap(sender: CustomTapGesture) {
        
        let vc = storyboard?.instantiateViewController(identifier: "PostDetailViewController") as? PostDetailViewController
        
        if loginType == "Gmail" {
            let fromMailID = loadInboxMessageArr[sender.index].header.from.mailbox.description
            let senderName = loadInboxMessageArr[sender.index].header.from.displayName.description
            let mailUserID = loadInboxMessageArr[sender.index].header.messageID.description
            let mailUserIDdd = loadInboxMessageArr[sender.index].gmailMessageID.description

            print(senderName)
            print(fromMailID)
            print(mailUserID)
            vc?.toUserName = senderName
            vc?.senderEMail = fromMailID
            vc?.senderMsgID = mailUserID
            vc?.tabSelected = tabSelected
        } else {
            let fromMailID = loadPostMessageArr[sender.index].header.from.mailbox.description
            let senderName = loadPostMessageArr[sender.index].header.from.displayName.description
            let mailUserID = loadPostMessageArr[sender.index].header.messageID.description
            let mailUserIDdd = loadPostMessageArr[sender.index].gmailMessageID.description

            print(senderName)
            print(fromMailID)
            print(mailUserID)
            vc?.toUserName = senderName
            vc?.senderEMail = fromMailID
            vc?.senderMsgID = mailUserID
            vc?.tabSelected = tabSelected
        }
        
        
//        let msg1 = loadInboxMessageArr[sender.index].header.to[0] as! MCOAddress
       

//        print(userName[sender.index])
//        print(userImg[sender.index])
//        vc?.userImgString = userImg[sender.index]
//        tableview.reloadData()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    func postConfigureGestures(index: Int, cell: FeedTableViewCell) {
        let commentTapGesture = CustomTapGesture(target: self, action: #selector(self.handleTap(sender:)))
        commentTapGesture.index = index
        let commentTapGesture1 = CustomTapGesture(target: self, action: #selector(self.handleCommentTap(sender:)))
        commentTapGesture1.index = index
        let commentTapGesture2 = CustomTapGesture(target: self, action: #selector(self.handleCommentTap(sender:)))
        commentTapGesture2.index = index
        let commentTapGesture3 = CustomTapGesture(target: self, action: #selector(self.deletePostClickBtn(sender:)))
        commentTapGesture3.index = index
        let commentTapGesture4 = CustomTapGesture(target: self, action: #selector(self.deletePostClickBtn(sender:)))
        commentTapGesture4.index = index

//        let commentTapGesture3 = CustomTapGesture(target: self, action: #selector(self.handleTapProfile(sender:)))
//        commentTapGesture3.index = index
//        profileTapGesture.index = index
        cell.likeView.addGestureRecognizer(commentTapGesture)
        cell.commentBtn.addGestureRecognizer(commentTapGesture1)
        cell.view_delete.addGestureRecognizer(commentTapGesture4)

        cell.commentTextLbl.addGestureRecognizer(commentTapGesture1)
        cell.commentLbl.addGestureRecognizer(commentTapGesture2)
//        cell.profileSectionView.addGestureRecognizer(commentTapGesture3)
    }
    
    
    func emailConfigureGestures(index: Int, cell: MailListTableViewCell) {
        let commentTapGesture = CustomTapGesture(target: self, action: #selector(self.handleTap(sender:)))
        commentTapGesture.index = index
        let commentTapGesture1 = CustomTapGesture(target: self, action: #selector(self.handleCommentTap(sender:)))
        commentTapGesture1.index = index
        let commentTapGesture2 = CustomTapGesture(target: self, action: #selector(self.handleCommentTap(sender:)))
        commentTapGesture2.index = index
        let commentTapGesture4 = CustomTapGesture(target: self, action: #selector(self.deleteEmailClickBtn(sender:)))
        commentTapGesture4.index = index
        let commentTapGesture5 = CustomTapGesture(target: self, action: #selector(self.deleteEmailClickBtn(sender:)))
        commentTapGesture5.index = index
//        let commentTapGesture3 = CustomTapGesture(target: self, action: #selector(self.handleTapProfile(sender:)))
//        commentTapGesture3.index = index
//        profileTapGesture.index = index
        cell.commentsView.addGestureRecognizer(commentTapGesture)
        cell.lbl_likes.addGestureRecognizer(commentTapGesture1)
        cell.commentLbl.addGestureRecognizer(commentTapGesture1)
//        cell.comme.addGestureRecognizer(commentTapGesture2)
//        cell.profileSectionView.addGestureRecognizer(commentTapGesture3)
        cell.commentBtn.addGestureRecognizer(commentTapGesture2)
        cell.view_delete.addGestureRecognizer(commentTapGesture4)
//        cell.view_delete.

    }
    
}

//extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return userDetails.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as! StoryCollectionViewCell
//
//        if indexPath.row == 0 {
//            cell.view_add.isHidden = false
//        } else {
//            cell.view_add.isHidden = true
//
//        }
//
//        cell.lbl_user_name.text = userDetails[indexPath.row].name
//        cell.iv_image.imageFromServerURL(userDetails[indexPath.row].imageUrl)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 62, height: 100)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
//    }
    
    // MARK: - UICollectionViewDelegate
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        DispatchQueue.main.async {
//
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContentView") as! ContentViewController
//            vc.modalPresentationStyle = .overFullScreen
//            vc.pages = self.userDetails
//            vc.currentIndex = indexPath.row
//            self.present(vc, animated: true, completion: nil)
//        }
//
//        print("Collection view selection")
//    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.presentAlert(message: "Story function has not been implemented")
//    }
    
    
//}

class CustomTapGesture: UITapGestureRecognizer {
    var index = Int()
}

extension String {
    func convertToAttributedFromHTML() -> NSAttributedString? {
        var attributedText: NSAttributedString?
//        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
//        if let data = data(using: .unicode, allowLossyConversion: true), let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
//            attributedText = attrStr
//        }
        
        if let htmlData = data(using: .utf8) {
            if let attributedString = try? NSAttributedString(
                data: htmlData,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil) {

                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .center
//                paragraph.lineBreakMode = .byWordWrapping
                
                let formatted = NSMutableAttributedString(attributedString: attributedString)
                formatted.addAttributes([
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                    NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel,
                    NSAttributedString.Key.paragraphStyle: paragraph
                ], range: NSRange.init(location: 0, length: attributedString.length))

                attributedText = formatted
                
//                print(formatted)
            }
        }
        
        return attributedText
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
