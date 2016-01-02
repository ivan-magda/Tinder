//
//  SignUpViewController.swift
//  Tinder
//
//  Created by Иван Магда on 01.01.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

enum UserFieldKeys: String {
    case gender
    case name
    case id
    case image
    case interestedInWomen
    case accepted
    case rejected
    case objectId
    case location
    case username
}

class SignUpViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var interestedInWomen: UISwitch!

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserDataFromFacebook()
    }
    
    // MARK: - Helper Methods
    
    private func loadUserDataFromFacebook() {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "\(UserFieldKeys.id.rawValue), \(UserFieldKeys.name.rawValue), \(UserFieldKeys.gender.rawValue)"])
        graphRequest.startWithCompletionHandler() { (connection, result, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let result = result {
                print(result)
                
                if let user = PFUser.currentUser() {
                    user[UserFieldKeys.gender.rawValue] = result[UserFieldKeys.gender.rawValue]
                    user[UserFieldKeys.name.rawValue] = result[UserFieldKeys.name.rawValue]
                    
                    user.saveInBackgroundWithBlock() { (succeeded, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("User info saved.")
                            
                            // Get user profile picture.
                            let userId = result["id"] as! String
                            let facebookProfileImageURL = NSURL(string: "https://graph.facebook.com/\(userId)/picture?type=large")
                            
                            if let facebookProfilePictureURL = facebookProfileImageURL {
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                                
                                let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfilePictureURL) { (data, response, error) in
                                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                    
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else if let data = data {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            let image = UIImage(data: data)
                                            self.userImage.image = image
                                            
                                            // Save user picture to parse.
                                            let imageFile = PFFile(data: data)
                                            user[UserFieldKeys.image.rawValue] = imageFile
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
            user[UserFieldKeys.interestedInWomen.rawValue] = self.interestedInWomen.on
            user.saveInBackground()
        }
    }
}
