//
//  MenuViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/23/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class MenuViewController: UIViewController {

    @IBAction func onLogoutButtonTap(sender: AnyObject) {
        PFUser.logOut()

        let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController
        let loginVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginViewController") as? UIViewController
        UIView.transitionFromView(rootVC!.view, toView: loginVC!.view, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate
            appDelegate?.window??.rootViewController = loginVC
        })
    }
}
