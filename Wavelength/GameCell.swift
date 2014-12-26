//
//  GameCell.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class GameCell : UICollectionViewCell {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var partnerProfilePictureView: FBProfilePictureView!
    @IBOutlet weak var partnerNameLabel: UILabel!
    @IBOutlet weak var currentStreakLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!

    var game: Game! {
        didSet {
            reloadData()
        }
    }

    func reloadData() {
        let user = PFUser.currentUser()
        partnerProfilePictureView.profileID = game.getPartnerFbId(user)
        partnerNameLabel.text = game.getPartnerFirstName(user).uppercaseString
        if game.currentStreak == 1 {
            currentStreakLabel.text = "\(game.currentStreak) GAME"
        } else {
            currentStreakLabel.text = "\(game.currentStreak) GAMES"
        }
    }

    func highlight() {
        contentContainer.backgroundColor = UIColor.lightGrayColor()
    }

    func unhighlight() {
        contentContainer.backgroundColor = UIColor.whiteColor()
    }
}
