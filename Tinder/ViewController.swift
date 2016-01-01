//
//  ViewController.swift
//  Tinder
//
//  Created by Иван Магда on 30.12.15.
//  Copyright © 2015 Ivan Magda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let push = PFPush()
        push.setChannel("Giants")
        push.setMessage("The Giants just scored!")
        push.sendPushInBackground()
        
        let loginButton = UIButton()
        loginButton.setTitle("Log In with Facebook", forState: .Normal)
        loginButton.setTitleColor(self.view.tintColor, forState: .Normal)
        loginButton.sizeToFit()
        loginButton.center = self.view.center
        loginButton.addTarget(self, action: Selector("login"), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(loginButton)
    }
    
    // MARK: - Log In
    
    func login() {
        print("Login button pressed")
        
        let permission = ["public_profile"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permission) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let user = user {
                print(user)
                
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "", message: "You have successfully loged in", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
}

