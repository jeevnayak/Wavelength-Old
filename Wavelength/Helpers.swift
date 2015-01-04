//
//  Helpers.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 1/3/15.
//  Copyright (c) 2015 jeev. All rights reserved.
//

class Helpers {

    class func showNetworkErrorDialogFromViewController(vc: UIViewController) {
        let alert = UIAlertController(title: "Network error", message: "A network error occurred, please try again.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        vc.presentViewController(alert, animated: true, completion: nil)
    }
}
