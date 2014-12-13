//
//  LoginViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/12/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

import Foundation

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
            NSLog("Already logged in")
            // TODO(rajeev): show main view
        }
    }

    @IBAction func onLoginButtonTap(sender: AnyObject) {
        let permissions = ["public_profile", "user_friends", "email"]
        PFFacebookUtils.logInWithPermissions(permissions, { (user: PFUser!, error: NSError!) -> Void in
            if user == nil {
                // TODO(rajeev): handle error
                NSLog("Facebook login cancelled")
            } else {
                FBRequestConnection.startForMeWithCompletionHandler({ (connection, result, error) -> Void in
                    if error == nil {
                        PFUser.currentUser().setObject(result["id"], forKey: "fbId")
                        PFUser.currentUser().setObject(result["name"], forKey: "name")
                        PFUser.currentUser().setObject(result["first_name"], forKey: "firstName")
                        PFUser.currentUser().setObject(result["last_name"], forKey: "lastName")
                        PFUser.currentUser().saveInBackgroundWithTarget(nil, selector: nil)
                    }
                })
                NSLog("Facebook login successful")
                // TODO(rajeev): show main view
            }
        })
    }
}
