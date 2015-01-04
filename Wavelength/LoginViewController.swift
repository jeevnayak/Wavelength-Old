//
//  LoginViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/12/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class LoginViewController: UIViewController {

    @IBAction func onLoginButtonTap(sender: AnyObject) {
        let permissions = ["public_profile", "user_friends", "email"]
        PFFacebookUtils.logInWithPermissions(permissions, { (user: PFUser!, error: NSError!) -> Void in
            if user == nil {
                Helpers.showNetworkErrorDialogFromViewController(self)
            } else {
                FBRequestConnection.startForMeWithCompletionHandler({ (connection, result, error) -> Void in
                    if error == nil {
                        PFUser.currentUser().setObject(result["id"], forKey: "fbId")
                        PFUser.currentUser().setObject(result["name"], forKey: "name")
                        PFUser.currentUser().setObject(result["first_name"], forKey: "firstName")
                        PFUser.currentUser().setObject(result["last_name"], forKey: "lastName")
                        PFUser.currentUser().saveInBackgroundWithTarget(nil, selector: nil)
                    } else {
                        // log the user out, show the login screen again, and pop up the network error dialog
                        PFUser.logOut()
                        let appDelegate = UIApplication.sharedApplication().delegate
                        let vc = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginViewController") as? UIViewController
                        appDelegate?.window??.rootViewController = vc
                        Helpers.showNetworkErrorDialogFromViewController(self)
                    }
                })

                let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController
                let mainVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as? UIViewController
                UIView.transitionFromView(rootVC!.view, toView: mainVC!.view, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
                    let appDelegate = UIApplication.sharedApplication().delegate
                    appDelegate?.window??.rootViewController = mainVC
                })
            }
        })
    }
}
