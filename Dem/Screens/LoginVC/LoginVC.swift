//
//  LoginVC.swift
//  Dem
//
//  Created by Vishnu Prem on 03/07/22.
//

import UIKit
import IQKeyboardManagerSwift
import ESTabBarController_swift
import Toaster
//import AppAuth
//import GTMAppAuth

class LoginVC: UIViewController, UITabBarControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var iv_img: UIImageView!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var view_password: UIView!
    @IBOutlet weak var view_Continue: UIView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var btn_continue: UIButton!

    var imgString: String!
    var nameString: String!
    var passwordIconClick = true
    var hostName: String!
    var hostPortName: Int?
    var recipients = ["hafildem@hotmail.com", "vishnuprem55ios@gmail.com", "vishnuprem55@gmail.com"]
    var inboxMessageArr = [MCOIMAPMessage]()
//    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    let kIssuer = "https://accounts.google.com"
    let kClientID = "499399450812-oeq06uhmqp5k9ck4vqi781m7j1a0gur7.apps.googleusercontent.com.apps.googleusercontent.com"
    let kRedirectURI = "com.googleusercontent.apps499399450812-oeq06uhmqp5k9ck4vqi781m7j1a0gur7.apps.googleusercontent.com:/oauthredirect"
    let kExampleAuthorizerKey = "googleOAuthCodingKey"
    var session = MCOIMAPSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        DEMConstants.DEM_Local_Data.removeObject(forKey: DEMConstants.Keys.accessToken)
        DEMConstants.DEM_Local_Data.removeObject(forKey: DEMConstants.Keys.userName)

        print(hostName ?? "")
        print(hostPortName ?? "")
        // Do any additional setup after loading the view.
        IQKeyboardManager.shared.enable = true

        tf_email.tintColor = UIColor(red: 244/255, green: 103/255, blue: 33/255, alpha: 1.0)
        tf_password.tintColor = UIColor(red: 244/255, green: 103/255, blue: 33/255, alpha: 1.0)
        iv_img.image = UIImage(named: imgString)
        lbl_name.text = nameString
//        "vishnuprem55ios@gmail.com"
//        tf_email.text = "hafildem@hotmail.com"
//        tf_password.text = "spiderweb*#123#"
        tf_email.text = "vishnutest555@outlook.com"
        tf_password.text = "Qwerty@1234"
//        SingletonClass.sharedInstance.userEmail = "hafildem@hotmail.com"
//        SingletonClass.sharedInstance.userPassword = "spiderweb*#123#"
        SingletonClass.sharedInstance.userEmail = "vishnutest555@outlook.com"
        SingletonClass.sharedInstance.userPassword = "Qwerty@1234"
//        SingletonClass.sharedInstance.userEmail = tf_email.text
//        SingletonClass.sharedInstance.userPassword = tf_password.text

    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func passwordBtn(_ sender: UIButton) {
        
        if(passwordIconClick == true) {
            sender.setImage(UIImage(named: "eye"), for: .normal)
            tf_password.isSecureTextEntry = false
        } else {
            tf_password.isSecureTextEntry = true
            sender.setImage(UIImage(named:"eye-slash-disabled"), for: .normal)
        }

        passwordIconClick = !passwordIconClick
    }
    
//    func authenticateGmail() {
//            let issuer = URL(string: kIssuer)!
//            let redirectURI = URL(string: kRedirectURI)!
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//            OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { (configuration, error) in
//                //handleError
//
//                if let configuration = configuration {
//                    let scopes = [OIDScopeOpenID, OIDScopeProfile, "https://mail.google.com/"]
//                    let request = OIDAuthorizationRequest(configuration: configuration, clientId: self.kClientID, scopes: scopes, redirectURL: redirectURI, responseType: OIDResponseTypeCode, additionalParameters: nil)
//
//                    appDelegate.currentAuthorizationFlow = OIDAuthState
//                    authState(byPresenting: request, externalUserAgent: self, callback: { (authState, error) in
//                        //handleError
//
//                        if let authState = authState {
//                            if let accessToken = authState.lastTokenResponse?.accessToken {
//                                NSLog("Successfully authenticated: %@", accessToken)
//                                self.fetchEmailsFromGmail(accessToken: accessToken)
//                            }
//                        }
//                    })
//                }
//            }
//        }
    
//    func fetchEmailsFromGmail(accessToken: String) {
//            let session = MCOIMAPSession()
//            session.hostname = "imap.gmail.com"
//            session.port = 993
//            session.username = "vishnuprem55ios@gmail.com"
//            session.authType = .xoAuth2
//            session.connectionType = .TLS
//            session.oAuth2Token = accessToken
//
//            let fetchFolderOperation = session.fetchAllFoldersOperation()
//            fetchFolderOperation?.start({ (error, folders) in
//                //handleError
//
//                if let folders = folders, !folders.isEmpty {
//                    print(folders)
//                }
//            })
//        }
    
    @IBAction func contine(_ sender: UIButton) {

        DemConstants.showActivityIndicator()
        
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let vc = sb.instantiateViewController(withIdentifier: "CustomTabViewVC") as? CustomTabViewVC
//        self.navigationController?.pushViewController(vc!, animated: true)
        session.hostname       = "outlook.office365.com"
        session.port           = 993
        session.connectionType = .TLS
        session.isVoIPEnabled = false
        session.username       = tf_email.text ?? ""
        session.password       = tf_password.text ?? ""
        session.authType = MCOAuthType.saslLogin

        if (tf_email.text != "" && tf_password.text != "") {
            if let op = session.checkAccountOperation() {
                op.start { err in
                    if let err = err {
                        print("IMAP Connect Error: \(err)")
                        Toast(text: err.localizedDescription).show()
                        DemConstants.hideActivityIndicator()
                    } else {
                        
                        SingletonClass.sharedInstance.userEmail = self.tf_email.text ?? ""
                        SingletonClass.sharedInstance.userPassword = self.tf_password.text ?? ""

                        print("Successful IMAP connection!")
                        Toast(text: "Successful IMAP connection!").show()
                        
                        DEMConstants.DEM_Local_Data.removeObject(forKey: DEMConstants.Keys.userimage)

                        
                        DEMConstants.DEM_Local_Data.set(self.tf_email.text ?? "", forKey: DEMConstants.Keys.userEmail)
                        
                        DEMConstants.DEM_Local_Data.set(self.tf_email.text ?? "", forKey: DEMConstants.Keys.userName)
                        SingletonClass.sharedInstance.userName = self.tf_email.text ?? ""
                        
                        DEMConstants.DEM_Local_Data.set(self.tf_password.text ?? "", forKey: DEMConstants.Keys.password)
                        DEMConstants.DEM_Local_Data.set("Outlook", forKey: DEMConstants.Keys.loginType)

                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sb.instantiateViewController(withIdentifier: "CustomTabViewVC") as? CustomTabViewVC
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                }
            }
        }
//               //     let kind = MCOIMAPMessagesRequestKind()
//              //      let headers = kind.union(MCOIMAPMessagesRequestKind.headers)
//                //    let request = headers.union(MCOIMAPMessagesRequestKind.flags)
//
//
////                    let requestKind = MCOIMAPMessagesRequestKindHeader as? MCOIMAPMessagesRequestKind
//////                    let inboxFolder = "INBOX"
//////                    let inboxFolderInfo = session.folderInfoOperation(inboxFolder)
//////
////                    let folder = "INBOX"
////                    let uids = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
////
////                    let fetchOperation = session.fetchMessagesOperation(withFolder: folder, requestKind: requestKind, uids: uids)
////
////                    fetchOperation?.start({ error, fetchedMessages, vanishedMessages in
////
////                    })
////                    if let op = session.fetchAllFoldersOperation() {
////                      op.start { error, folderList in
////
////                        if let err = error {
////                          print("Error fetching folders: \(err)")
////                        }
////
////                        if let folders = folderList {
////                            print("Listed all IMAP Folders: \(folders.description)")
////
////                            for AllM in folders {
////
////                                print(AllM)
////                                if AllM as! String == "INBOX" {
////                                    print(AllM)
////
////
////                                }
////
////                            }
////                        }
////
////                      }
////
////                    }
//
//
//                }
//              }
//            }
//        } else {
//
//            Toast(text: "Please enter valid credentials").show()
//        }
        
    }
    
    func useImapFetchContent(uidToFetch uid: UInt32)
    {

//        let operation = session.fetchParsedMessageOperation(withFolder: "INBOX", uid: UInt32(uid))
        let operation = session.fetchMessageByUIDOperation(withFolder: "INBOX", uid: UInt32(uid))

        operation?.start{( error, data)-> Void in
//            if error == nil {
//                let returnValue = messageParser!.plainTextBodyRenderingAndStripWhitespace(false)
//            }
            let messageParser = MCOMessageParser(data: data)
            let msgHTMLBody = messageParser!.mainPart().filename
//
//            if msgHTMLBody != nil {
//                print(msgHTMLBody)
//            }
//            let subject = messageParser?.header.subject
//            print(subject)
//            let from = messageParser?.header.from
//            print(from)
//            let to = messageParser?.header.to
//            print(to)
            let msgPlainBody = messageParser?.plainTextBodyRendering()
//            print("BODY")
            print(msgHTMLBody)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField == tf_email {
                view_email.borderWidth = 2
                view_email.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            } else if textField == tf_password {
                view_password.borderWidth = 2
                view_password.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            }
        
        
        if string != "" {
//            if tf_email.text != "" && tf_password.text != "" {
                view_Continue.backgroundColor = UIColor(red: 244/255, green: 103/255, blue: 33/255, alpha: 1.0)
                btn_continue.setTitleColor(UIColor.white, for: .normal)
//            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            // if implemented, called in place of textFieldDidEndEditing:
            print("TextField did end editing with reason method called")
        
        if textField == tf_email {
            view_email.borderWidth = 1
            view_email.borderColor = UIColor(red: 200/255, green: 204/255, blue: 208/255, alpha: 1.0)
        } else if textField == tf_password {
            view_password.borderWidth = 1
            view_password.borderColor = UIColor(red: 200/255, green: 204/255, blue: 208/255, alpha: 1.0)
        } else if tf_email.text != "" || tf_password.text != "" {
            
            print("Clear")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            print("TextField should return method called")
            textField.resignFirstResponder();
            return true;
        }
}

@IBDesignable
class BackView: UIView {
    
    var shadowcolor = UIColor(red: 0/255, green: 96/255, blue: 64/255, alpha: 1.0).cgColor
    var shadowopacity: Float = 0.1
    var bordercolor = UIColor(red: 0/255, green: 96/255, blue: 64/255, alpha: 0.1).cgColor
    
    @IBInspectable var cornerradius: CGFloat =  10 { didSet { layoutSubviews() }}
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerradius
        let shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: cornerradius, height: cornerradius))
        
        layer.masksToBounds = false
        layer.shadowColor = shadowcolor
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowOpacity = shadowopacity
        layer.shadowPath = shadowPath.cgPath
        layer.shadowRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = bordercolor
    }

}
