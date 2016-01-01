//
//  SwipingViewController.swift
//  Tinder
//
//  Created by Иван Магда on 01.01.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

class SwipingViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    private var currentDisplayedUserId = ""
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSwipeGestureRecognizer()
        updateUserImage()
    }
    
    // MARK: - Helper Methods
    
    private func updateUserImage() {
        let query = PFUser.query()!
        
        var interestedIn = "male"
        if let interest = PFUser.currentUser()?[UserFieldKeys.interestedInWomen.rawValue] as? Bool where interest == true {
            interestedIn = "female"
        }
        
        var isFemale = true
        if let gender = PFUser.currentUser()?[UserFieldKeys.gender.rawValue] as? String where gender == "male" {
            isFemale = false
        }
        
        query.whereKey(UserFieldKeys.gender.rawValue, equalTo: interestedIn)
        query.whereKey(UserFieldKeys.interestedInWomen.rawValue, equalTo: isFemale)
        
        var ignoredUsers = [""]
        if let acceptedUsers = PFUser.currentUser()?[UserFieldKeys.accepted.rawValue] {
            ignoredUsers.appendContentsOf(acceptedUsers as! Array)
        }
        
        if let rejectedUsers = PFUser.currentUser()?[UserFieldKeys.rejected.rawValue] {
            ignoredUsers.appendContentsOf(rejectedUsers as! Array)
        }
        
        query.whereKey(UserFieldKeys.objectId.rawValue, notContainedIn: ignoredUsers)
        query.limit = 1
        
        query.findObjectsInBackgroundWithBlock() { (users, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let users = users {
                for user in users {
                    self.currentDisplayedUserId = user.objectId!
                    if let imageFile = user[UserFieldKeys.image.rawValue] as? PFFile {
                        imageFile.getDataInBackgroundWithBlock() { (data, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else if let data = data {
                                let image = UIImage(data: data)
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.userImageView.alpha = 0.0
                                    self.userImageView.image = image
                                    UIView.animateWithDuration(0.45) {
                                        self.userImageView.alpha = 1.0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Gesture Recognizing
    
    private func addSwipeGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        self.userImageView.addGestureRecognizer(panGesture)
        self.userImageView.userInteractionEnabled = true
    }
    
    func wasDragged(recognizer: UIPanGestureRecognizer) {
        // Distance from the original point.
        let translation = recognizer.translationInView(self.view)
        
        let imageView = recognizer.view!
        
        let xFromCenter = imageView.center.x - CGRectGetWidth(self.view.bounds) / 2.0
        
        let scale = min(1, 100 / abs(xFromCenter))
        
        var rotation = CGAffineTransformMakeRotation(xFromCenter / 200.0)
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        imageView.transform = stretch
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            var acceptedOrRejected = ""
            if imageView.center.x < 100 {
                acceptedOrRejected = UserFieldKeys.rejected.rawValue
            } else if imageView.center.x > CGRectGetWidth(self.view.bounds) - 100 {
                acceptedOrRejected = UserFieldKeys.accepted.rawValue
            }
            
            if acceptedOrRejected != "" {
                let user = PFUser.currentUser()!
                user.addUniqueObject(currentDisplayedUserId, forKey: acceptedOrRejected)
                
                user.saveInBackgroundWithBlock() { (succeeded, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if succeeded {
                        self.updateUserImage()
                    }
                }
            }
            
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1.0, 1.0)
            
            UIView.animateWithDuration(0.25) {
                imageView.transform = stretch
                imageView.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds) / 2.0)
            }
        } else {
            imageView.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0 + translation.x, CGRectGetHeight(self.view.bounds) / 2.0 + translation.y)
        }
    }


    // MARK: - Actions
    
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock() { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}
