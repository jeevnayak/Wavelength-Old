//
//  GameCell.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class GameCell : UICollectionViewCell {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var opponentProfilePictureView: FBProfilePictureView!
    @IBOutlet weak var opponentNameLabel: UILabel!
    @IBOutlet weak var currentStreakLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!

    var game: Game! {
        didSet {
            reloadData()
        }
    }

    func reloadData() {
        if game.player1.objectId == PFUser.currentUser().objectId {
            opponentProfilePictureView.profileID = game.player2FbId
            opponentNameLabel.text = game.player2FirstName.uppercaseString
        } else {
            opponentProfilePictureView.profileID = game.player1FbId
            opponentNameLabel.text = game.player1FirstName.uppercaseString
        }
    }

    func highlight() {
        contentContainer.backgroundColor = UIColor.lightGrayColor()
    }

    func unhighlight() {
        contentContainer.backgroundColor = UIColor.whiteColor()
    }
}
