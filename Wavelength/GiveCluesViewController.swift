//
//  GiveCluesViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/24/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

protocol GiveCluesDelegate {
    func giveCluesCancelled(sender: AnyObject!)
    func giveCluesDone(sender: AnyObject!)
}

class GiveCluesViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var clue1Field: UITextField!
    @IBOutlet weak var clue2Field: UITextField!
    @IBOutlet weak var clue3Field: UITextField!
    @IBOutlet weak var clue4Field: UITextField!

    var game: Game!
    var round: Round!
    var delegate: GiveCluesDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
    }

    func reloadData() {
        let partnerFirstName = game.getPartnerFirstName(PFUser.currentUser()).uppercaseString
        descriptionLabel.text = "PICK CLUES SO \(partnerFirstName)\nWILL GUESS THE WORD"
        wordLabel.text = round.word
    }

    @IBAction func onBackButtonTap(sender: AnyObject) {
        delegate?.giveCluesCancelled(self)
    }

    @IBAction func onSubmitButtonTap(sender: AnyObject) {
    }
}
