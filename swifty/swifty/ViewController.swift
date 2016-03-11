//
//  ViewController.swift
//  swifty
//
//  Created by Sebastien PARIAUD on 2/24/16.
//  Copyright © 2016 Sebastien PARIAUD. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    let saved = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var loadUser: UIActivityIndicatorView!
    
    @IBAction func searchUser() {
        self.loginInput.resignFirstResponder()
        self.loadUser.startAnimating()
        getData()
    }
    
    var token = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedToken = saved.stringForKey("token") {
            token = savedToken
            print("got the saved token:\n" + token)
        }
        self.loginInput.becomeFirstResponder()
        self.loginInput.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchUser()
        return true
    }
    
    
    func getToken () {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.intra.42.fr/oauth/token")!)
        request.HTTPMethod = "POST"
        let postString = "grant_type=client_credentials&client_id="client_id"&client_secret="client_secret""
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                return
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
        var login = String()
        if (self.loginInput.text != "") {
            login = self.loginInput.text!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        }else {
            dispatch_async(dispatch_get_main_queue()) {
                self.loadUser.stopAnimating()
            }
            dispatch_async(dispatch_get_main_queue()) {
                let alert = UIAlertController(title: "⚠️You must enter a login !⚠️", message: "😓 Before searching for a login you must provide one 🙄", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Close", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            return
        }
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.intra.42.fr/v2/users/" + login + "?access_token=" + self.token)!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                print("error=\(error)")
                self.loadUser.stopAnimating()
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
            self.loadUser.stopAnimating()
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                if (httpStatus.statusCode == 404) {
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: "⚠️Login not found⚠️", message: "The login that you tried to search does not exist", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Close", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    return
                }
                if (httpStatus.statusCode == 401) {
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

