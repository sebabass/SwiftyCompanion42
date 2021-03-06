//
//  UserViewController.swift
//  swifty
//
//  Created by Sebastien PARIAUD on 2/24/16.
//  Copyright © 2016 Sebastien PARIAUD. All rights reserved.
//

import UIKit
import QuartzCore
import Foundation

class UserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var correctPointLabel: UILabel!
    @IBOutlet weak var cursusLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var xpLabel: UILabel!

    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var xpProgressBar: UIProgressView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var data = [String: AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        getLogin()
        getInfos()
        getProgressBar()
        collectionView.layer.cornerRadius = 10
        self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadImage() {
        let url = NSURL(string: data["image_url"] as! String)
        getDataFromUrl(url!) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.ProfileImage.layer.cornerRadius = 50
                self.ProfileImage.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func getLogin() {
        let displayName = data["displayname"] as! String
        let login = data["login"] as! String
        loginLabel.text =  displayName + " - " + login
    }
    
    func getInfos() {
        self.infoView.layer.cornerRadius = 5
        self.walletLabel.text = String(data["wallet"]!) + " ₳"
        self.correctPointLabel.text = String(data["correction_point"]!)
        self.cursusLabel.text = String(data["cursus"]![0]["cursus"]!!["name"]!!)
        self.gradeLabel.text = String(data["cursus"]![0]["grade"]!!)
    }
    
    func getProgressBar() {
        let progress = data["cursus"]![0]["level"]!!
        let level = String(progress).stringByReplacingOccurrencesOfString(".", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let xp = Float(progress as! NSNumber) % 1
        self.xpProgressBar.transform = CGAffineTransformScale(self.xpProgressBar.transform, 1, 7)
        self.xpProgressBar.layer.cornerRadius = 3
        self.xpProgressBar.clipsToBounds = true
        self.xpProgressBar.progress = xp
        self.xpLabel.text = "level " + level + "%"
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data["cursus"]![0]["skills"]!!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! collectionViewCell
        
        cell.skillTypeLabel.text = String(self.data["cursus"]![0]["skills"]!![indexPath.row]["name"]!!)
        cell.xpSkillLabel.text = String(Float(self.data["cursus"]![0]["skills"]!![indexPath.row]["level"] as! NSNumber))
        cell.xpSkillProgressBar.progress = Float(self.data["cursus"]![0]["skills"]!![indexPath.row]["level"] as! NSNumber) * 5 / 100
        
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data["cursus"]![0]["projects"]!!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath) as! tableViewCell
        var isInprogress = false
        
        //Check extend name
        cell.projectNameLabel.text = String(self.data["cursus"]![0]["projects"]!![indexPath.row]["name"]!!)
        if (String(self.data["cursus"]![0]["projects"]!![indexPath.row]["name"]!!).lowercaseString != String(self.data["cursus"]![0]["projects"]!![indexPath.row]["slug"]!!).lowercaseString) {
            cell.projectNameLabel.text = cell.projectNameLabel.text! + " (" + String(self.data["cursus"]![0]["projects"]!![indexPath.row]["slug"]!!) + ")"
        }
        // Check final mark
        if (String(self.data["cursus"]![0]["projects"]!![indexPath.row]["final_mark"]!!) == "<null>") {
            cell.noteLabel.text = "in progress"
            isInprogress = true
        } else {
            cell.noteLabel.text = String(self.data["cursus"]![0]["projects"]!![indexPath.row]["final_mark"]!!)
        }
        // Check row
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColorFromRGB("202026")
            cell.noteLabel.textColor = (isInprogress) ? UIColorFromRGB("E6B291") : UIColorFromRGB("FFFFFF")
        } else {
            cell.backgroundColor = UIColorFromRGB("FFFFFF")
            cell.noteLabel.textColor = (isInprogress) ? UIColorFromRGB("E6B291") : UIColorFromRGB("202026")
        }
        
        return cell
    }
    
    func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor {
        let scanner = NSScanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
