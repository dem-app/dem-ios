//
//  Constants.swift
//  Dem
//
//  Created by Vishnu Prem on 30/06/22.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UIImage {
    func resize(size: CGSize) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: size)
        let result = renderer.image { _ in
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        return result.withRenderingMode(self.renderingMode)
    }
}

public class DemConstants {
    
    static func showActivityIndicator() {
            let size = CGSize(width: 48, height: 48)
            let data = ActivityData(size: size, message: "", messageFont: UIFont.systemFont(ofSize: 12), messageSpacing: 1.0, type:  NVActivityIndicatorType(rawValue: 32)!, color:#colorLiteral(red: 0.2745098039, green: 1, blue: 0.862745098, alpha: 1), padding: 1.0, displayTimeThreshold: 3, minimumDisplayTime: 3, backgroundColor: #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 0.9), textColor: UIColor.black)
            
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, NVActivityIndicatorView.DEFAULT_FADE_IN_ANIMATION)
    }
        
    static func hideActivityIndicator(){
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(NVActivityIndicatorView.DEFAULT_FADE_OUT_ANIMATION)
    } 
}


extension UIViewController {
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem?.title = ""
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "DiffBgColor")
    }
    
    var isTabBarVisible: Bool {
        return (self.tabBarController?.tabBar.frame.origin.y ?? 0) < self.view.frame.maxY
    }
    
    func setTabBarVisible(visible: Bool, animated: Bool) {
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        // bail if the current state matches the desired state
        if (isTabBarVisible == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration: TimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }
        }
    }
    
    func setupBasicViews(title: String){
        self.title = title
        navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor(named: "diffBgColor")
    }
    
    func presentAlert(message: String){
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Fine", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}
