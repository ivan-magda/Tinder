//
//  ViewController.swift
//  Tinder
//
//  Created by Иван Магда on 30.12.15.
//  Copyright © 2015 Ivan Magda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = UIButton()
        loginButton.setTitle("Log In with Facebook", forState: .Normal)
        loginButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        loginButton.sizeToFit()
        loginButton.center = self.view.center
        loginButton.addTarget(self, action: Selector("login"), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(loginButton)
    }
    
    func login() {
        print("Login button pressed")
        
        let permission = ["public_profile"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permission) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let user = user {
                    print("Successfully loged in with user:\(user)")
                }
            }
        }
    }


}

