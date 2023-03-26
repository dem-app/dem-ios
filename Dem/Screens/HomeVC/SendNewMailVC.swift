//
//  SendNewMailVC.swift
//  Dem
//
//  Created by Vishnu Prem on 14/09/22.
//

import UIKit
import MobileCoreServices
import GrowingTextView
import Toaster

class SendNewMailVC: UIViewController, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, GrowingTextViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lbl_attachment: UILabel!
    @IBOutlet weak var tf_userName: UITextField!
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var tf_subject: UITextField!
    @IBOutlet weak var tv_description: GrowingTextView!

    var attachmentArray = [String]()
    var imagePicker = UIImagePickerController()
    var selectedImage: UIImage!
    var selectedVideo: Data!
    var audioData:  Data!
    var documentData: Data!
    var selectedType: String!
    var arrOfDict = [[String :Any]]()
    var oneHeight = 0
    var loginType: String!

    var keyboardHeight = 0 {
        willSet {
            if newValue != 0 {
                tv_description.transform = CGAffineTransform(translationX: 0, y: -CGFloat(newValue) + tv_description.bounds.height - 10)
//                userImg.transform = CGAffineTransform(translationX: 0, y: -CGFloat(newValue) + userImg.bounds.height - 10)
//                postBtn.transform = CGAffineTransform(translationX: 0, y: -CGFloat(newValue) + postBtn.bounds.height - 10)
            } else {
                tv_description.transform = .identity
//                userImg.transform = .identity
//                postBtn.transform = .identity
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginType = UserDefaults.standard.object(forKey: "login_type") as? String

        tv_description.textContainer.lineFragmentPadding = 10
        tv_description.placeholder = "Compose mail..."
        
        collectionView.register(UINib(nibName: "AttachmentCell", bundle: nil), forCellWithReuseIdentifier: "AttachmentCell")
        collectionView.register(UINib(nibName: "DocumentAttachmentCell", bundle: nil), forCellWithReuseIdentifier: "DocumentAttachmentCell")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if arrOfDict.count == 0 {
            lbl_attachment.isHidden = true
        } else {
            lbl_attachment.isHidden = false
        }
    }
    
    // MARK:- DismissKeyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK;- UIDocument Picker
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        
        let data = self.handleFileSelection(inUrl: urls.first!)  // Here urls is array of URLs
        var dictToSaveDocu = [String :AnyObject]()

        if selectedType == "document" {
            if data.isEmpty
            {
                print("Empty : \(data)")
            }
            else
            {

                print("result : \(data)")
                documentData = data
                dictToSaveDocu .updateValue(documentData as AnyObject, forKey: "document")
                arrOfDict.append(dictToSaveDocu)
                self.lbl_attachment.isHidden = false
                self.lbl_attachment.text = "\(arrOfDict.count) Attachment"
                print("\(arrOfDict.count) Attachment")
                collectionView.reloadData()

            }
        } else {
            if data.isEmpty
            {
                print("Empty : \(data)")
            }
            else
            {

                print("result : \(data)")
                audioData = data
                dictToSaveDocu .updateValue(audioData as AnyObject, forKey: "audio")
                arrOfDict.append(dictToSaveDocu)
                self.lbl_attachment.isHidden = false
                self.lbl_attachment.text = "\(arrOfDict.count) Attachment"
                print("\(arrOfDict.count) Attachment")
                collectionView.reloadData()

            }
        }
           
        
    }

    func handleFileSelection(inUrl:URL) -> Data {
        do {
         // inUrl is the document's URL
            let data = try Data(contentsOf: inUrl) // Getting file data here
            return data
        } catch {
            print("document loading error")
            return Data()
        }
    }

    @objc public func documentMenu(_ documentMenu:UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func mailConfig() {
        DemConstants.showActivityIndicator()

        let smtpSession = MCOSMTPSession()
           
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
        builder.header.to = [MCOAddress(displayName: tf_userName.text!, mailbox: tf_email.text!) as Any]
        builder.header.from = MCOAddress(displayName: SingletonClass.sharedInstance.userName, mailbox: SingletonClass.sharedInstance.userEmail)
        builder.header.subject = "DEMNEWMSG \(tf_subject.text!)"
        builder.htmlBody = tv_description.text!
        
        if selectedImage != nil {
            let imgData = (selectedImage).jpegData(compressionQuality: 0.2)

            let attachment = MCOAttachment()
            attachment.mimeType =  "image/jpg"
            attachment.filename = "image.jpg"
            attachment.data = imgData
            builder.addAttachment(attachment)
        }
        
        if selectedVideo != nil {

            let attachment = MCOAttachment()
            attachment.mimeType =  "video/mp4"
            attachment.filename = "video.mp4"
            attachment.data = selectedVideo
            builder.addAttachment(attachment)
        }
        
        if audioData != nil {

            let attachment = MCOAttachment()
            attachment.mimeType =  "audio/mp3"
            attachment.filename = "audio.mp3"
            attachment.data = audioData
            builder.addAttachment(attachment)
        }
        
        if documentData != nil  {

            let attachment = MCOAttachment()
            attachment.mimeType =  "application/pdf"
            attachment.filename = "doc.pdf"
            attachment.data = documentData
            builder.addAttachment(attachment)
        }
            let rfc822Data = builder.data()
            let sendOperation = smtpSession.sendOperation(with: rfc822Data!)
            sendOperation?.start { (error) -> Void in
                if (error != nil) {
                    print("Error sending email: \(error?.localizedDescription)")
                    NSLog("Error sending email: \(error?.localizedDescription)")
                } else {
                    print("Successfully sent email!")
                    NSLog("Successfully sent email!")
                    Toast(text: "Successfully sent email!").show()

                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "CustomTabViewVC") as? CustomTabViewVC
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
                DemConstants.hideActivityIndicator()

            }
    }
    
    


    @IBAction func sendMail(_ sender: UIButton) {
        
        mailConfig()
        
    }
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func attachmentBtnClicked(_ sender: UIButton) {
        
        // 1. Create Alert
        let alert = UIAlertController(title: "Dem",
                                      message: "This attachment for uploading your gallery and files",
                                      preferredStyle: .actionSheet)

        // 2. Creeate Actions
        alert.addAction(UIAlertAction(title: "Photos",
                                      style: .default,
                                      handler: { _ in print("Download Now tap")
            
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.selectedType = "image"
            self.imagePicker.mediaTypes = ["public.image"]
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []

            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Videos",
                                      style: .default,
                                      handler: { _ in print("Videos tap")
            self.imagePicker.delegate = self
            self.selectedType = "video"
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
            self.imagePicker.mediaTypes = ["public.movie"]

//                self.imagePicker.sourceType = .savedPhotosAlbum
//                self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Audio File",
                                      style: .default,
                                      handler: { _ in print("Audio File tap")
            self.selectedType = "audio"

            let pickerController = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
            pickerController.delegate = self
            pickerController.modalPresentationStyle = .fullScreen
            self.present(pickerController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Document File",
                                      style: .default,
                                      handler: { _ in print("Document File tap")
            self.selectedType = "document"

            let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
                importMenu.delegate = self
                importMenu.modalPresentationStyle = .formSheet
                self.present(importMenu, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { _ in print("Cancel tap") }))

        // 3. Snow
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- UIImagePickerViewDelegate.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var dictToSaveNotest = [String :AnyObject]()

            if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    print("\(url.lastPathComponent)")
                print("\(url.pathExtension)")

            }
            
            if selectedType == "image"
            {
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
                //Setting image to your image view
//                self?.lbl_image.text = String(image)
//                let imageData = image.jpegData(compressionQuality: 0.05)
                self.selectedImage = image
                dictToSaveNotest .updateValue(image as AnyObject, forKey: "image")
                arrOfDict.append(dictToSaveNotest)
                self.lbl_attachment.isHidden = false
                self.lbl_attachment.text = "\(arrOfDict.count) Attachment"
                print("\(arrOfDict.count) Attachment")
                self.collectionView.reloadData()

                
//                self.lbl_image.text = "image"

//                self?.uploadDataDict = ["image" : image]
            }
            else
            {
                guard let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
                    return
                }
                do {
                    let data = try Data(contentsOf: videoUrl, options: .mappedIfSafe)
                    print(data)
                    self.selectedVideo = data
                    dictToSaveNotest.updateValue(data as AnyObject, forKey: "video")
                    arrOfDict.append(dictToSaveNotest)
                    self.lbl_attachment.isHidden = false
                    self.lbl_attachment.text = "\(arrOfDict.count) Attachment"
                    print("\(arrOfDict.count) Attachment")
                    self.collectionView.reloadData()
                } catch  {
                }
            }
            
            self.dismiss(animated: true) { [weak self] in
                
            }
        }

    
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
}

extension SendNewMailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOfDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dict = arrOfDict[indexPath.row]
            
            for (key, value) in dict {
                
                if key == "image" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCell", for: indexPath) as! AttachmentCell
                    
                    cell.imgView.image = value as? UIImage
                    return cell
                } else if key == "document" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentAttachmentCell", for: indexPath) as! DocumentAttachmentCell
                    
                    cell.lbl_title.text = key
                    
                    return cell
                } else if key == "video" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentAttachmentCell", for: indexPath) as! DocumentAttachmentCell
                    
                    cell.lbl_title.text = key
                    
                    return cell
                } else if key == "audio" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentAttachmentCell", for: indexPath) as! DocumentAttachmentCell
                    
                    cell.lbl_title.text = key
                    return cell
                }
        }
       
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 130)
    }
}
