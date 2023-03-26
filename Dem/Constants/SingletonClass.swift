//
//  SingletonClass.swift
//  Dem
//
//  Created by Vishnu Prem on 25/08/22.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST

final class SingletonClass {
    static let sharedInstance = SingletonClass()
    private init() { }

    var inboxMessageArr = [MCOIMAPMessage]()
    var accessToken: String!
    var userName: String!
    var userEmail: String!
    var userPassword: String!
    var emailType: String!
    var userImage: String!
    var contactsCount: String!

    var contactsData = [GTLRPeopleService_Person]()
    
//    let signInConfig = GIDConfiguration(clientID: "410214579367-rc9psq4uk5d6m0p38hv5jpsc7d756bpd.apps.googleusercontent.com")
//    com.googleusercontent.apps.410214579367-rc9psq4uk5d6m0p38hv5jpsc7d756bpd
    let signInConfig = GIDConfiguration(clientID: "410214579367-rc9psq4uk5d6m0p38hv5jpsc7d756bpd.apps.googleusercontent.com")
//    let signInConfig = GIDConfiguration(clientID: 800358865591-uua58251t9pb1rgav937n8qanoi73st6.apps.googleusercontent.com) "762771324014-u1fet5mo8bcmnp8c2qeeo2t86ignh0gk.apps.googleusercontent.com")
}


public class DEMConstants{
    
    static let DEM_Local_Data = UserDefaults.standard
    
    struct Keys{
        static let accessToken = "access_token"
        static let loginType = "login_type"
        static let userEmail = "user_email"
        static let userName = "user_name"
        static let password = "password"
        static let userimage = "user_image"
        static let contactCount = "contact_count"
        static let contactsArray = "contactsArray"
    }
    
}
    
