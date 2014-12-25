//
//  MakeGuessesViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/25/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

protocol MakeGuessesDelegate {
    func makeGuessesCancelled(sender: AnyObject!)
    func makeGuessesDone(sender: AnyObject!)
}

class MakeGuessesViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var partnerProfilePictureView: FBProfilePictureView!
    @IBOutlet weak var userProfilePictureView: FBProfilePictureView!
    @IBOutlet weak var wordGuessField: UITextField!

    var game: Game!
    var round: Round!
    var delegate: MakeGuessesDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
    }

    func reloadData() {
        let partnerFirstName = game.getPartnerFirstName(PFUser.currentUser()).uppercaseString
        descriptionLabel.text = "GUESS \(partnerFirstName)'S WORD"
        partnerProfilePictureView.profileID = game.getPartnerFbId(PFUser.currentUser())
        userProfilePictureView.profileID = PFUser.currentUser().objectForKey("fbId") as String
    }
}
