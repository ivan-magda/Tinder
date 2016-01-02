//
//  ContactsTableViewController.swift
//  Tinder
//
//  Created by Иван Магда on 02.01.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {
    // MARK: - Properties
    
    private var usernames = [String]()
    private var emails = [String]()
    private var images = [UIImage]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContacts()
    }
    
    // MARK: - Helpers Methods
    
    private func loadContacts() {
        if let acceptedUsers = PFUser.currentUser()?[UserFieldKeys.accepted.rawValue] as? [String] {
            let query = PFUser.query()!
            query.whereKey(UserFieldKeys.accepted.rawValue, equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey(UserFieldKeys.objectId.rawValue, containedIn: acceptedUsers)
            query.orderByAscending(UserFieldKeys.username.rawValue)
            
            query.findObjectsInBackgroundWithBlock() { (users, error) in
                if let error = error {
                    print("Error finding accepted users: \(error.localizedDescription)")
                } else if let users = users as? [PFUser] where users.count > 0 {
                    for user in users {
                        self.usernames.append(user.username!)
                        self.emails.append(user.email!)
                        
                        if let imageFile = user[UserFieldKeys.image.rawValue] as? PFFile {
                            imageFile.getDataInBackgroundWithBlock() { (data, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if let data = data {
                                    self.images.append(UIImage(data: data)!)
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = usernames[indexPath.row]
        cell.detailTextLabel?.text = emails[indexPath.row]
        
        if indexPath.row < images.count {
            cell.imageView?.image = images[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Send an email to selected user.
        let url = NSURL(string: "mailto:\(emails[indexPath.row])")
        if let url = url {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
