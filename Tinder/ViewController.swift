//
//  ViewController.swift
//  Tinder
//
//  Created by Иван Магда on 30.12.15.
//  Copyright © 2015 Ivan Magda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Properties
    
    private let signinSegueIdentifier = "showSignin"
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = PFUser.currentUser()?.username {
            performSegueWithIdentifier(signinSegueIdentifier, sender: self)
        }
    }
    
    // MARK: - Log In
    
    @IBAction func login() {
        print("Login button pressed")
        
        let permission = ["public_profile"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permission) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let user = user {
                print(user)
                
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "", message: "You have successfully loged in", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { action in
                        self.performSegueWithIdentifier(self.signinSegueIdentifier, sender: self)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

