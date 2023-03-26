//
//  AccountVC.swift
//  Dem
//
//  Created by Vishnu Prem on 03/07/22.
//

import UIKit
//import Auth0
import GoogleSignIn
import GoogleAPIClientForREST
import Toaster
import WebKit

class AccountVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var iv_top_blur: UIImageView!
    @IBOutlet weak var iv_bottom_blur: UIImageView!

    var imagesArray = ["gmail-logo", "outlook-logo", "exchange-logo", "office 365-logo", "hotmail-logo", "Yahoo-logo", "iCloud-logo", "Aol-logo", "GMX-logo", "Apple-logo", "twitter-logo", "linkedIn-logo"]
    var titleArray = ["Gmail", "Outlook", "Exchange", "Office 365", "Hotmail", "Yahoo!", "iCloud", "Aol.", "GMX", "Apple", "Twitter", "LinkedIn"]
    var imapHostMail = ["imap.gmail.com", "outlook.office365.com"]
    var smtpHostMail = ["smtp.gmail.com", "smtp-mail.outlook.com", "partner.outlook.cn.", "smtp.office365.com", "smtp.live.com", "smtp.mail.yahoo.com", "smtp.mail.me.com", "smtp.aol.com", "mail.gmx.com"]
    var smtpPortMail = ["465", "25", "691", "587", "587", "465", "587", "587", "587"]
    var imapPortMAil = ["993", "993", ""]
    var lastContentOffset: CGFloat = 0
    var myToken = ""
    var session = MCOIMAPSession()
    private let services = GTLRPeopleServiceService()
    var contactsNameArray = [String]()
    var contactsPicArray = [String]()
    var contactsEmailArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        DEMConstants.DEM_Local_Data.removeObject(forKey: DEMConstants.Keys.accessToken)
        DEMConstants.DEM_Local_Data.set(nil, forKey: DEMConstants.Keys.accessToken)
        DEMConstants.DEM_Local_Data.set(nil, forKey: "ArrayName")
        DEMConstants.DEM_Local_Data.set(nil, forKey: "ArrayEmail")
        DEMConstants.DEM_Local_Data.set(nil, forKey: "ArrayPic")
        
        collectionView.register(UINib(nibName: "AccountsCell", bundle: nil), forCellWithReuseIdentifier: "AccountsCell")
        self.iv_top_blur.isHidden = true
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        self.collectionView = scrollView as? UICollectionView

            self.lastContentOffset = self.collectionView.contentOffset.y

            if (self.lastContentOffset > 10)
            {
                // move up
                self.iv_top_blur.isHidden = false
                self.iv_bottom_blur.isHidden = true

            }
            else if (self.lastContentOffset < 10)
            {
               // move down
                self.iv_top_blur.isHidden = true
                self.iv_bottom_blur.isHidden = false

            }
            // update the new position acquired
        }
    
    func fetchContacts() {

        let query = GTLRPeopleServiceQuery_PeopleConnectionsList.query(withResourceName: "people/me")
        let formattedToken = String(format: "Bearer %@", SingletonClass.sharedInstance.accessToken)
        let headers = ["Authorization": formattedToken, "3.0": "GData-Version"]
        query.additionalHTTPHeaders = headers
        query.personFields = "names,emailAddresses,photos"
        query.pageSize = 2000 //max
        services.shouldFetchNextPages = true
        services.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(getCreatorFromTicket(ticket:finishedWithObject:error:)))
    }
    
    @objc func getCreatorFromTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response: GTLRPeopleService_ListConnectionsResponse,
        error: NSError?) {

        if let error = error {
            print(error.localizedDescription)
            Toast(text: error.localizedDescription).show()
//            showAlert(title: " Error", message: error.localizedDescription)
            return
        }

        if let connections = response.connections, !connections.isEmpty {
            print(connections)
            
            DEMConstants.DEM_Local_Data.set("\(connections.count)", forKey: DEMConstants.Keys.contactCount)

            SingletonClass.sharedInstance.contactsCount = "\(connections.count)"
            
            SingletonClass.sharedInstance.contactsData = connections
            for connection in connections {
                if let names = connection.names, !names.isEmpty {
                    for name in names {
                        if let _ = name.metadata?.primary {
                            print(name.displayName ?? "")
                            contactsNameArray.append(name.displayName ?? "")
                            DEMConstants.DEM_Local_Data.set(contactsNameArray, forKey: "ArrayName")

                        }
                    }
                } else {
                    contactsEmailArray.append("")
                    DEMConstants.DEM_Local_Data.set(contactsEmailArray, forKey: "ArrayName")

                }
                if let emailAddresses = connection.emailAddresses, !emailAddresses.isEmpty {
                    for email in emailAddresses {
                            if let _ = email.metadata?.primary {
                        print(email.value ?? "")
                                
//                                if email.value != nil || email.value != "" {
                                    contactsEmailArray.append(email.value ?? "")
//                                } else {
//                                    contactsEmailArray.append("")
//                                }
                                
                                DEMConstants.DEM_Local_Data.set(contactsEmailArray, forKey: "ArrayEmail")

                            }
                        

                    } 
                } else {
                    contactsEmailArray.append("")
                    DEMConstants.DEM_Local_Data.set(contactsEmailArray, forKey: "ArrayEmail")

                }
                if let photos = connection.photos, !photos.isEmpty {
                    for photo in photos {
                        if let _ = photo.metadata?.primary {
                            print(photo.url ?? "")
                            contactsPicArray.append(photo.url ?? "")
                            DEMConstants.DEM_Local_Data.set(contactsPicArray, forKey: "ArrayPic")

                        }
                    }
                } else {
                    contactsEmailArray.append("")
                    DEMConstants.DEM_Local_Data.set(contactsEmailArray, forKey: "ArrayPic")

                }
            }
        }
    }

}

extension AccountVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccountsCell", for: indexPath) as! AccountsCell
        
        if (indexPath.row == 0) {
            cell.view_blur.isHidden = true
//        } else if (indexPath.row == 1) {
//            cell.view_blur.isHidden = true
        } else {
            cell.view_blur.isHidden = false

        }
        
        cell.iv_image.image = UIImage(named: imagesArray[indexPath.row])
        cell.lbl_title.text = titleArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.bounds.width/3), height: 120)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
//    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.row == 0 {
            GIDSignIn.sharedInstance.signIn(with: SingletonClass.sharedInstance.signInConfig, presenting: self, hint: "", additionalScopes:["https://mail.google.com", "https://www.googleapis.com/auth/contacts"]) { user, error in
               guard error == nil else { return }
                guard let user = user else { return }
                print(user.grantedScopes)
                
                //                , "https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile"
                print(["1,2"].map({$0}))
//                let driveScope = "https://mail.google.com"
//                let grantedScopes = user.grantedScopes
//                if grantedScopes == nil || !grantedScopes!.contains(driveScope) {
//                  // Request additional Drive scope.
//                    print(" no scope request ")
//
//                }
                
                user.authentication.do { authentication, error in
                    guard error == nil else { return }
                    guard let authentication = authentication else { return }
                    print(authentication.refreshToken)
                    // Get the access token to attach it to a REST or gRPC request.
                    let accessToken = authentication.accessToken
                    
                    if let imgurl = user.profile?.imageURL(withDimension: 100) {
                        let absoluteurl : String = imgurl.absoluteString
                        //HERE CALL YOUR SERVER API
                        SingletonClass.sharedInstance.userImage = absoluteurl
                        DEMConstants.DEM_Local_Data.set(absoluteurl, forKey: DEMConstants.Keys.userimage)

                        print(absoluteurl)
                    }

                    SingletonClass.sharedInstance.accessToken = accessToken
                    
                    DEMConstants.DEM_Local_Data.set(accessToken, forKey: DEMConstants.Keys.accessToken)
                    DEMConstants.DEM_Local_Data.set("Gmail", forKey: DEMConstants.Keys.loginType)
                    DEMConstants.DEM_Local_Data.set(user.profile?.email ?? "", forKey: DEMConstants.Keys.userEmail)
                    DEMConstants.DEM_Local_Data.set(user.profile?.name ?? "", forKey: DEMConstants.Keys.userName)

                    SingletonClass.sharedInstance.userEmail = user.profile?.email ?? ""
                    SingletonClass.sharedInstance.userName = user.profile?.name ?? ""
                    SingletonClass.sharedInstance.emailType = "Gmail"
                    print(authentication.accessTokenExpirationDate)
                    self.fetchContacts()
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                   let vc = sb.instantiateViewController(withIdentifier: "CustomTabViewVC") as? CustomTabViewVC

                   self.navigationController?.pushViewController(vc!, animated: true)
                    // Or, get an object that conforms to GTMFetcherAuthorizationProtocol for
                    // use with GTMAppAuth and the Google APIs client library.
                    let authorizer = authentication.fetcherAuthorizer()

                }
            }
                
                
//        } else if indexPath.row == 1 {
//            let sb = UIStoryboard(name: "Main", bundle: nil)
//            let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
//            vc?.imgString = imagesArray[indexPath.row]
//            vc?.nameString = titleArray[indexPath.row]
//            vc?.hostName = smtpHostMail[indexPath.row]
//            vc?.hostPortName = Int(smtpPortMail[indexPath.row])
//            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            
        }

        print("Collection view selection")
    }
    
}
