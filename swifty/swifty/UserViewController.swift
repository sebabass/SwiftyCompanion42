//
//  UserViewController.swift
//  swifty
//
//  Created by Sebastien PARIAUD on 2/24/16.
//  Copyright © 2016 Sebastien PARIAUD. All rights reserved.
//

import UIKit
import QuartzCore

class UserViewController: UIViewController {

    @IBOutlet weak var ProfileImage: UIImageView!
    var data = [String: AnyObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue()) { self.ProfileImage.layer.cornerRadius = 65 }
        print(data)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
