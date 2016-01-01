//
//  SignUpViewController.swift
//  Tinder
//
//  Created by Иван Магда on 01.01.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    // MARK: - Types
    
    private enum FieldKeys: String {
        case gender
        case name
        case id
        case image
        case interestedInWomen
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var interestedInWomen: UISwitch!

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "\(FieldKeys.id.rawValue), \(FieldKeys.name.rawValue), \(FieldKeys.gender.rawValue)"])
        graphRequest.startWithCompletionHandler() { (connection, result, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let result = result {
                print(result)
                
                if let user = PFUser.currentUser() {
                    user[FieldKeys.gender.rawValue] = result[FieldKeys.gender.rawValue]
                    user[FieldKeys.name.rawValue] = result[FieldKeys.name.rawValue]
                    
                    user.saveInBackgroundWithBlock() { (succeeded, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("User info saved.")
                            
                            // Get user profile pic
                            let userId = result["id"] as! String
                            let facebookProfileImageURL = NSURL(string: "https://graph.facebook.com/\(userId)/picture?type=large")
                            
                            if let facebookProfileImageURL = facebookProfileImageURL {
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                                
                                let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileImageURL) { (data, response, error) in
                                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else if let data = data {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            let image = UIImage(data: data)
                                            self.userImage.image = image
                                            
                                            // Save user picture to parse.
                                            let imageFile = PFFile(data: data)
                                            user[FieldKeys.image.rawValue] = imageFile
                                            user.saveInBackground()
                                        }
                                    }
                                }
                                task.resume()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func signUp(sender: AnyObject) {
        if let user = PFUser.currentUser() {
            user[FieldKeys.interestedInWomen.rawValue] = self.interestedInWomen.on
            user.saveInBackground()
        }
    }
}
