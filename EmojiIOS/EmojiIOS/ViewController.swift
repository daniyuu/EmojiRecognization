//
//  ViewController.swift
//  EmojiIOS
//
//  Created by 陈悦莹 on 27/06/2017.
//  Copyright © 2017 陈悦莹. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLConnectionDataDelegate {
    
    @IBOutlet weak var lableField: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var inputDataField: UITextField!
    @IBOutlet weak var dbDataField: UILabel!
    
    
    var db:SQLiteDB!
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    

    var uriBase = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0"
    var imgPath = "http://wx4.sinaimg.cn/large/62528dc5gy1ff15pgorhgj20rs0rsn1e.jpg";
    
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
        print(response)
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        print("receive data")
        print(data)
        var res = String.init(data: data, encoding: .utf8)
        print (res)
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
        
        let result = db.execute(sql: "create table if not exists t_user(uid integer primary key,uname varchar(20),mobile varchar(20))")
        print(result)

        
    }

    func showUser() {
        let data = db.query(sql: "select * from t_user")
        if data.count > 0 {
            //获取最后一行数据显示
            let user = data[data.count - 1]
            dbDataField.text = user["uname"] as? String
        }
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
        lableField.text = inputField.text
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
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following:\(info)");
        }
        
        photoImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setDefaultLabelText(_ sender: UIButton) {
        lableField.text = "Default text"
    }
    
    @IBAction func showAllPhotos(_ sender: UIButton) {
        lableField.text = "All Photos"
        let photosVC = BBAllPhotosViewController()
        self.present(photosVC, animated: true, completion: nil)
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        print("saveData")
        saveUser()
    }

    @IBAction func showData(_ sender: UIButton) {
        print("showData")
        showUser()
    }
   

}

