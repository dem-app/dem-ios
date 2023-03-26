//
//  ViewController.swift
//  Dem
//
//  Created by Vishnu Prem on 29/06/22.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController {

    @IBOutlet weak var view_main: UIView!
    @IBOutlet weak var btn_social: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        setNeedsStatusBarAppearanceUpdate()

//        setGradientBackground()
        
        if (GIDSignIn.sharedInstance.hasPreviousSignIn()) {
            GIDSignIn.sharedInstance.restorePreviousSignIn {user , error in
                SingletonClass.sharedInstance.accessToken = user?.authentication.accessToken
//                print("hey this is accesstoken " + (user?.authentication.accessToken)!)
                DEMConstants.DEM_Local_Data.set(user?.authentication.accessToken, forKey: DEMConstants.Keys.accessToken)

            }
        } else {
            DEMConstants.DEM_Local_Data.set(nil, forKey: DEMConstants.Keys.accessToken)
        }

        let accessToken = UserDefaults.standard.object(forKey: "access_token")
        let emailType = UserDefaults.standard.object(forKey: "login_type")
        let userName = UserDefaults.standard.object(forKey: "user_name")
        let userEmail = UserDefaults.standard.object(forKey: "user_email")
        let userPassword = UserDefaults.standard.object(forKey: "password")

        if accessToken != nil {
            SingletonClass.sharedInstance.emailType = emailType as? String
            SingletonClass.sharedInstance.userName = userName as? String
            SingletonClass.sharedInstance.userEmail = userEmail as? String
            SingletonClass.sharedInstance.userPassword = userPassword as? String
            SingletonClass.sharedInstance.accessToken = accessToken as? String

            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "CustomTabViewVC") as! CustomTabViewVC
            navigationController?.pushViewController(vc, animated: true)
        } else {
            
            if emailType != nil {
                if emailType as! String == "Outlook" {
                    
                    SingletonClass.sharedInstance.userEmail = userEmail as? String
                    SingletonClass.sharedInstance.userPassword = userPassword as? String
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "CustomTabViewVC") as! CustomTabViewVC
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
                       // TODO: - whatever you want
                    self.update()
                    }
                }
            } else {
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
                   // TODO: - whatever you want
                self.update()
                }
            }
            
        }
        
    }

    @objc func update() {
        // Something cool
        print("Timer start")
        let sb = UIStoryboard(name: "Main", bundle: nil)
//        AccountVC
//        let vc = sb.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController
//        self.navigationController?.pushViewController(vc!, animated: true)
        let vc = sb.instantiateViewController(withIdentifier: "AccountVC") as? AccountVC
        self.navigationController?.pushViewController(vc!, animated: true)

    }
//    func GradientLayer()
//      {
//          let gradient = CAGradientLayer()
//
//          gradient.frame = self.bounds
//          gradient.colors = [BoardVisionConstants.MENUBG1COLOR.cgColor, BoardVisionConstants.MENUBG2COLOR.cgColor]
//          gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
//          gradient.endPoint   = CGPoint(x: 1.0, y: 0.5)
//
//          let maskPath = UIBezierPath(roundedRect: self.bounds,
//                                      byRoundingCorners: [.topLeft],
//                                      cornerRadii: CGSize(width: 10.0, height: 10.0))
//
//          let shape = CAShapeLayer()
//          shape.path = maskPath.cgPath
//          gradient.mask = shape
//
//
//          self.layer.insertSublayer(gradient, at: 0)
//      }
    
//    func setGradientBackground() {
//        let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
//        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [colorTop, colorBottom]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.frame = self.view_main.bounds
//
//        self.view_main.layer.addSublayer(gradientLayer)
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
    
}

