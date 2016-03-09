//
//  ViewController.swift
//  swifty
//
//  Created by Sebastien PARIAUD on 2/24/16.
//  Copyright © 2016 Sebastien PARIAUD. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let saved = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var loginInput: UITextField!
    
    @IBAction func searchUser() {
        getData()
        self.loginInput.resignFirstResponder()
    }
    
    var token = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedToken = saved.stringForKey("token") {
            token = savedToken
            print("got the saved token:\n" + token)
        }
        self.loginInput.becomeFirstResponder()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getToken () {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.intra.42.fr/oauth/token")!)
        request.HTTPMethod = "POST"
        let postString = "grant_type=client_credentials&client_id=7c3f61b91fd0a586210cf47977f2c1d542c40cbfa3818a124dd6bf611b615be8&client_secret=4ffd3b3f77f7a5b7a8b97cd2ffa09fbd5c0915cd2b6e23198272c57e63316295"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String: AnyObject]
                if let access_token = json!["access_token"] as? String {
                    self.token = access_token
                    print(self.token)
                    self.saved.setObject(self.token, forKey: "token")
                    self.getData()
                }
            } catch {
                print(error)
            }
            
            
        }
        task.resume()
        
    }
    
    func getData () {
        print("getting user data")
        var login = String()
        if (self.loginInput.text != "") {
            login = self.loginInput.text!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        }else {
            print("loginInput vide")
            return
        }
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.intra.42.fr/v2/users/" + login + "?access_token=" + self.token)!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                if httpStatus.statusCode == 401 {
                    self.getToken()
                }
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String: AnyObject]
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("viewUser", sender: json)
                }
            } catch {
                print(error)
            }

        }
        task.resume()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewUser" {
            if let destination = segue.destinationViewController as? UserViewController {
                destination.data = sender as! [String: AnyObject]
            }
        }
    }


}

