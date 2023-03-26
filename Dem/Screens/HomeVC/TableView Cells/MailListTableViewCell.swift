//
//  MailListTableViewCell.swift
//  Dem
//
//  Created by Vishnu Prem on 25/08/22.
//

import UIKit
import WebKit
//import DropDown

class MailListTableViewCell: UITableViewCell, WKNavigationDelegate {

    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var userIdLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var border_view: UIView!
    @IBOutlet weak var lbl_body: UILabel!
    @IBOutlet weak var view_moreBtn: UIButton!
    @IBOutlet weak var view_delete: UIView!
    @IBOutlet weak var btn_delete: UIButton!

    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var bookMarkBtn: UIButton!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var lbl_likes: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var cv_attachment: UICollectionView!
    @IBOutlet weak var view_attachment: UIView!
    @IBOutlet weak var lbl_attachment: UILabel!
    @IBOutlet weak var tv_body: UITextView!
    @IBOutlet weak var web_view: WKWebView!
    @IBOutlet weak var web_view_height: NSLayoutConstraint!

    var attachmentArray = [Any]()
    var selectedIndex: Int!
    
//    var deleteDropDown = DropDown()
//    var deleteString = ["Delete"]
//    var deleteSelected = [Int]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view_delete.isHidden = true
        cv_attachment.register(UINib(nibName: "AttachmentCell", bundle: nil), forCellWithReuseIdentifier: "AttachmentCell")
        cv_attachment.register(UINib(nibName: "DocumentAttachmentCell", bundle: nil), forCellWithReuseIdentifier: "DocumentAttachmentCell")
        view_attachment.isHidden = true
    
//        web_view.translatesAutoresizingMaskIntoConstraints = false
        
        web_view.navigationDelegate = self
        web_view.scrollView.alwaysBounceVertical = false
        web_view.scrollView.alwaysBounceHorizontal = false
//        web_view.scrollView.showsVerticalScrollIndicator = false
//        web_view.scrollView.alwaysBounceHorizontal = false
//        web_view.scrollView.alwaysBounceVertical = fa
//        let pref = WKWebpagePreferences.init()
//        pref.preferredContentMode = .mobile
//        web_view.configuration.defaultWebpagePreferences = pref

//        var webView = WKWebView()
//        let webConfiguration = WKWebViewConfiguration()
//        let pref = WKWebpagePreferences.init()
//        pref.preferredContentMode = .mobile
//        webConfiguration.defaultWebpagePreferences = pref
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.navigationDelegate = self
//        web_view = webView
        web_view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let dataTypes = NSSet(array: [
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeOfflineWebApplicationCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeIndexedDBDatabases,
            WKWebsiteDataTypeWebSQLDatabases])
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        web_view.customUserAgent = "Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5"
        web_view.reloadFromOrigin()
        
//        dropDownViews()
    }
    
//    func dropDownViews() {
//        deleteDropDown.anchorView = moreBtn
//        deleteDropDown.dataSource = deleteString
//        deleteDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
////            self.btn_design.setTitle(item, for: .normal)
//            self.deleteSelected = [index]
//        }
//    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard case .linkActivated = navigationAction.navigationType,
                  let url = navigationAction.request.url
            else {
                decisionHandler(.allow)
                return
            }
            decisionHandler(.cancel)
        UIApplication.shared.open(url)
       }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // Here write down you logic to dismiss controller
        
        view_delete.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initLoad() {
        
        lbl_attachment.text = "Attachment \(attachmentArray.count)"
//        let key = attachmentArray as! MCOAttachment
//        if key.mimeType = ""
        if attachmentArray.count != 0 {
            
//            if attachmentArray.count == 1
//            {
//                view_attachment.isHidden = true
//            }
//            else
//            {
                view_attachment.isHidden = false
                cv_attachment.reloadData()
//            }
            
        } else {
            view_attachment.isHidden = true
        }
    }
    
}
extension MailListTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let key = attachmentArray[indexPath.row] as! MCOAttachment
//            for key in dict as! [MCOAttachment] {
//        print(key.data)
        if key.mimeType == "image/jpeg" || key.mimeType == "image/jpg" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCell", for: indexPath) as! AttachmentCell

                    cell.imgView.image = UIImage(data: key.data)

                    return cell
                } else if key.mimeType == "application/pdf" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentAttachmentCell", for: indexPath) as! DocumentAttachmentCell

                    cell.lbl_title.text = key.filename

                    return cell
                } else if key.mimeType == "video/mp4" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentAttachmentCell", for: indexPath) as! DocumentAttachmentCell

                    cell.lbl_title.text = key.filename

                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentAttachmentCell", for: indexPath) as! DocumentAttachmentCell

                    cell.lbl_title.text = key.filename

                    return cell
                }
//            }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width-80, height: 130)
    }
    
//    func c
    
    
    
//    private func store(image: Data,
//                        forKey key: String) {
////        if let pngRepresentation = image.pngData() {
//
//            if let filePath = filePath(forKey: key) {
//                do  {
//                    try image.write(to: filePath,
//                                                options: .atomic)
//                } catch let err {
//                    print("Saving file resulted in error: ", err)
//                }
//            }
////        }
//    }
//
//    private func filePath(forKey key: String) -> URL? {
//        let fileManager = FileManager.default
//        guard let documentURL = fileManager.urls(for: .documentDirectory,
//                                                in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
//
//        return documentURL.appendingPathComponent(key )
//    }
//
    
}
