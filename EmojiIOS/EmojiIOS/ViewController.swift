//
//  ViewController.swift
//  EmojiIOS
//
//  Created by 陈悦莹 on 27/06/2017.
//  Copyright © 2017 陈悦莹. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLConnectionDataDelegate, PHPhotoLibraryChangeObserver {
    
    @IBOutlet weak var lableField: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var inputDataField: UITextField!
    @IBOutlet weak var dbDataField: UILabel!
    
    
    var db:SQLiteDB!
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    var subscriptionKey = "c3a5d67bf4c34e8fa133e1c1fcf487d2"
    var uriBase = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0"
    var imgPath = "http://wx4.sinaimg.cn/large/62528dc5gy1ff15pgorhgj20rs0rsn1e.jpg";
    
    var uri: String!
    var photosArray = PHFetchResult<PHAsset>()
    var photoIndex = 0
    
    var statusCode = 200
    
    func asycnhronousPost(){
        let url:URL! = URL(string: uriBase + "/ocr?language=zh-Hans")
        var urlRequest:URLRequest = URLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        let requestParams: [String:Any] = [
            "url": imgPath
        ]
        
        let requestObject = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted)
        urlRequest.httpBody = requestObject
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
     
        var conn:NSURLConnection!
        conn = NSURLConnection.init(request: urlRequest, delegate: self)
        conn.start()
       
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        print("request success")
//        print(response)
        let httpResponse = response as! HTTPURLResponse
        statusCode = httpResponse.statusCode

    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        var content = "";
        let res = String.init(data: data, encoding: .utf8)
        let resData = res?.data(using: .utf8)
        var resJson = try? JSONSerialization.jsonObject(with: resData!) as! [String: Any]
        if (statusCode == 200) {
            let regions = resJson?["regions"] as! [[String:AnyObject]]
            let data = regions
            
            for item in data {
                let lines = item["lines"] as! [[String:AnyObject]]
                for line in lines {
                    let words = line["words"] as! [[String:String]]
                    for word in words {
                        let text = word["text"]!
                        content += text
                    }
                    
                }
                
            }
            if(content.characters.count > 1) {
                print(content)
                saveTag(content: content)
            }
            
            
        }
        
        photoIndex += 1
        if (photoIndex < photosArray.count){
            getPhotoDescription(photoAsset: photosArray[photoIndex])
        }
        
    }
    
    @IBAction func sendRequestButton(_ sender: UIButton) {
        asycnhronousPost()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputField.delegate = self
        inputDataField.delegate = self
        
        db = SQLiteDB.shared
        _ = db.openDB()
        

        let result = db.execute(sql: "create table if not exists t_emoji_v1(uid integer primary key,imgPath varchar(255),tag varchar(255))")
//        print(result)
//        dropTable()
    }
    
    func dropTable(){
        let result = db.execute(sql: "DROP TABLE t_emoji_v1")
        print("drop table: ", result)
    }
    
    
    @IBAction func getAllPhotoButton(_ sender: UIButton) {
        getAllPhotos()
        getPhotoDescription(photoAsset: photosArray[photoIndex])
    }
    
    private func getPhotoDescription(photoAsset: PHAsset){
        let manager = PHImageManager.default();
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        manager.requestImage(for: photoAsset, targetSize: CGSize.zero, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void  in
            let selectedImage = result;
            
            manager.requestImageData(for: photoAsset, options: nil) { (data, _, _, info) in
                let nsurl = info!["PHImageFileURLKey"] as! NSURL
                self.uri = nsurl.absoluteString as! String
                let subscriptionKey = "c3a5d67bf4c34e8fa133e1c1fcf487d2"
                let uriBase = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0"
                
                let binaryData = UIImageJPEGRepresentation(selectedImage!, 1)
                let binaryString = binaryData?.base64EncodedData()
                
                let url:URL! = URL(string: uriBase + "/ocr?language=zh-Hans")
                var urlRequest:URLRequest = URLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
                
                let requestParams = binaryData;
                
                urlRequest.httpBody = requestParams
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
                
                var conn:NSURLConnection!
                conn = NSURLConnection.init(request: urlRequest, delegate: self)
                conn.start()
                
                
            }
            
            
        })

        
    }
    
    private func getAllPhotos(){
        
        PHPhotoLibrary.shared().register(self)
        
        let allOptions = PHFetchOptions()
        
        allOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        
        let allResults = PHAsset.fetchAssets(with: allOptions)
//        print(allResults.count)
        photosArray = allResults
        
        getPhotoDescription(photoAsset: photosArray[0])
        
        
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        getAllPhotos()
    }
    
    func showUser() {
        let data = db.query(sql: "select * from t_user")
        if data.count > 0 {
            //获取最后一行数据显示
            let user = data[data.count - 1]
            dbDataField.text = user["uname"] as? String
        }
    }
    
    func searchPhotoByTag() {
        let tag = self.inputDataField.text!
        let data = db.query(sql: "select * from t_emoji_v1 where tag='\(tag)'")
        if data.count > 0 {
            let info = data[data.count - 1]
            let imgPath = info["imgPath"] as! String
            let imageNSURL = NSURL.init(string: imgPath as! String)
//            print("search result: ", imageNSURL)
            let selectedImage:NSData = try! NSData.init(contentsOf: imageNSURL as! URL)
            self.photoImageView.image = UIImage.init(data: selectedImage as Data)
        }
    }
    
    func saveTag(content: String) {
//        let tag = self.inputField.text!
        let tag = content
        let imgPath = self.uri as! String
        let sql = "insert into t_emoji_v1(imgPath,tag) values('\(imgPath)','\(tag)')"
        print("sql: \(sql)")
        let result = db.execute(sql: sql)
        print(result)
    }
    
    func saveUser() {
        let uname = self.inputDataField.text!
        let mobile = "12345678"
        //插入数据库，这里用到了esc字符编码函数，其实是调用bridge.m实现的
        let sql = "insert into t_user(uname,mobile) values('\(uname)','\(mobile)')"
        print("sql: \(sql)")
        //通过封装的方法执行sql
        let result = db.execute(sql: sql)
        print(result)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
//        lableField.text = inputField.text
    }

    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        inputField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedURL:NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [pickedURL as URL], options: nil)
        
        let asset:PHAsset = fetchResult.firstObject as! PHAsset
        
        PHImageManager.default()
            .requestImageData(for: asset, options: nil, resultHandler: { (imageData, dataUTI, orientation, info) in
                let imageNSURL: NSURL = info!["PHImageFileURLKey"] as! NSURL
//                print("imageURL: ",imageNSURL)
                self.uri = imageNSURL.absoluteString as! String
                let selectedImage:NSData = try! NSData.init(contentsOf: imageNSURL as URL)
                self.photoImageView.image = UIImage.init(data: selectedImage as Data)
                
                
            
            })
        
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setDefaultLabelText(_ sender: UIButton) {
//        lableField.text = "Default text"
    }
    
    @IBAction func showAllPhotos(_ sender: UIButton) {
//        lableField.text = "All Photos"
        let photosVC = BBAllPhotosViewController()
        self.present(photosVC, animated: true, completion: nil)
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        print("saveData")
        let tag = self.inputField.text!
        saveTag(content: tag)
    }

    @IBAction func showData(_ sender: UIButton) {
        print("showData")
        searchPhotoByTag()
    }
   

}

