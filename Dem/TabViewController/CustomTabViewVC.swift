//
//  CustomTabViewVC.swift
//  Dem
//
//  Created by Vishnu Prem on 05/07/22.
//

import UIKit

class CustomTabViewVC: UIViewController {

    @IBOutlet weak var view_main: UIView!
    @IBOutlet weak var btn_home: UIButton!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var btn_like: UIButton!
    @IBOutlet weak var btn_profile: UIButton!
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var view_create: UIView!
    @IBOutlet weak var view_Shadow_Create: UIView!

    var selectedBtn: Int = 0
    var token: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view_Shadow_Create.isHidden = true
        view_Shadow_Create.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)

        if selectedBtn == 0 {
            let child = self.storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            addChild(child)
            btn_home.setImage(UIImage(named: "home_icon"), for: .normal)

            // add the child's view to your view hierarchy however appropriate for your app
            child.view.frame = CGRect(x:0, y:0, width:self.view_main.frame.size.width, height:self.view_main.frame.size.height);
            self.view_main.addSubview(child.view)

            child.didMove(toParent: self)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        view_create.layer.mask = maskLayer

    }
    
    @IBAction func CancelBtnClicked(_ sender: UIButton) {
        view_Shadow_Create.isHidden = true

    }
    
    @IBAction func EmailBtnClicked(_ sender: UIButton) {
        view_Shadow_Create.isHidden = true
        let sb = UIStoryboard(name: "Main", bundle: nil)
       let vc = sb.instantiateViewController(withIdentifier: "SendNewMailVC") as? SendNewMailVC
       self.navigationController?.pushViewController(vc!, animated: true)

    }
    
    @IBAction func PostBtnClicked(_ sender: UIButton) {
        view_Shadow_Create.isHidden = true
        let sb = UIStoryboard(name: "Main", bundle: nil)
       let vc = sb.instantiateViewController(withIdentifier: "NewPostVC") as? NewPostVC
       self.navigationController?.pushViewController(vc!, animated: true)

    }
    
    @IBAction func tabBarBtnAction(_ sender: UIButton) {
        view_Shadow_Create.isHidden = true
        
        if sender.tag == 0 {
            btn_home.setImage(UIImage(named: "home_icon"), for: .normal)
//            btn_search.setImage(UIImage(named: "search-normal"), for: .normal)
//            btn_like.setImage(UIImage(named: "heart"), for: .normal)
            btn_profile.setImage(UIImage(named: "user"), for: .normal)
            let child = self.storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            addChild(child)

            // add the child's view to your view hierarchy however appropriate for your app
            child.view.frame = CGRect(x:0, y:0, width:self.view_main.frame.size.width, height:self.view_main.frame.size.height);
            self.view_main.addSubview(child.view)
           
            child.didMove(toParent: self)
            selectedBtn = 0
        } else if sender.tag == 1 {
            view_Shadow_Create.isHidden = false
//            btn_home.setImage(UIImage(named: "linear-home"), for: .normal)
//            btn_search.setImage(UIImage(named: "bold-search"), for: .normal)
//            btn_like.setImage(UIImage(named: "heart"), for: .normal)
//            btn_profile.setImage(UIImage(named: "user"), for: .normal)
//            let child = self.storyboard!.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
//            addChild(child)
//
//            // add the child's view to your view hierarchy however appropriate for your app
//            child.view.frame = CGRect(x:0, y:0, width:self.view_main.frame.size.width, height:self.view_main.frame.size.height);
//            self.view_main.addSubview(child.view)
//            child.didMove(toParent: self)
//            selectedBtn = 1
//        } else if sender.tag == 2 {
//
//        } else if sender.tag == 3 {
//            btn_home.setImage(UIImage(named: "linear-home"), for: .normal)
//            btn_search.setImage(UIImage(named: "search-normal"), for: .normal)
//            btn_like.setImage(UIImage(named: "bold-heart"), for: .normal)
//            btn_profile.setImage(UIImage(named: "user"), for: .normal)
//            let child = self.storyboard!.instantiateViewController(withIdentifier: "LikesAndFollowingVC") as! LikesAndFollowingVC
//            addChild(child)
//
//            // add the child's view to your view hierarchy however appropriate for your app
//            child.view.frame = CGRect(x:0, y:0, width:self.view_main.frame.size.width, height:self.view_main.frame.size.height);
//            self.view_main.addSubview(child.view)
//            child.didMove(toParent: self)
//            selectedBtn = 3
        } else if sender.tag == 2 {

            btn_home.setImage(UIImage(named: "linear-home"), for: .normal)
//            btn_search.setImage(UIImage(named: "search-normal"), for: .normal)
//            btn_like.setImage(UIImage(named: "heart"), for: .normal)
            btn_profile.setImage(UIImage(named: "bold-user"), for: .normal)
            let child = self.storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            addChild(child)

            // add the child's view to your view hierarchy however appropriate for your app
            child.view.frame = CGRect(x:0, y:0, width:self.view_main.frame.size.width, height:self.view_main.frame.size.height);
            self.view_main.addSubview(child.view)
            child.didMove(toParent: self)
            selectedBtn = 2
        }
        
        
    }
    

   
}
