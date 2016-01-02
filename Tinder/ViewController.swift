//
//  ViewController.swift
//  Tinder
//
//  Created by Иван Магда on 30.12.15.
//  Copyright © 2015 Ivan Magda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Types 
    
    private enum SegueIdentifiers: String {
        case showSignin
        case logUserIn
    }
    
    // MARK: - Properties
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = PFUser.currentUser()?.username {
            performSegueForSingedUser(PFUser.currentUser()!)
        }
    }
    
    // MARK: - Navigation
    
    private func performSegueForSingedUser(user: PFUser) {
        if let _ = user[UserFieldKeys.interestedInWomen.rawValue] {
            self.performSegueWithIdentifier(SegueIdentifiers.logUserIn.rawValue, sender: self)
        } else {
            self.performSegueWithIdentifier(SegueIdentifiers.showSignin.rawValue, sender: self)
        }
    }
    
    // MARK: - Log In
    
    @IBAction func signIn() {
        let permission = ["public_profile", "email"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permission) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let user = user {
                self.performSegueForSingedUser(user)
            }
        }
    }
}

