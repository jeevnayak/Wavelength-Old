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

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
    }

    // MARK: event handlers

    @IBAction func onBackButtonTap(sender: AnyObject) {
        delegate?.giveCluesCancelled(self)
    }

    @IBAction func onSubmitButtonTap(sender: AnyObject) {
        let clue1 = clue1Field.text
        let clue2 = clue2Field.text
        let clue3 = clue3Field.text
        let clue4 = clue4Field.text
        if clue1.isEmpty || clue2.isEmpty || clue3.isEmpty || clue4.isEmpty {
            let alert = UIAlertController(title: "Invalid", message: "You must fill out all 4 words", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            round.clues = [clue1, clue2, clue3, clue4]
            // TODO(rajeev): modifying the round and game together should be atomic
            round.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                if error == nil {
                    self.game.currentPlayer = self.game.getPartner(PFUser.currentUser())
                    self.game.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                        if error == nil {
                            self.delegate?.giveCluesDone(self)
                        } else {
                            Helpers.showNetworkErrorDialogFromViewController(self)
                        }
                    })
                } else {
                    Helpers.showNetworkErrorDialogFromViewController(self)
                }
            })
        }
    }

    // MARK: helpers

    func reloadData() {
        let partnerFirstName = game.getPartnerFirstName(PFUser.currentUser()).uppercaseString
        descriptionLabel.text = "PICK CLUES SO \(partnerFirstName)\nWILL GUESS THE WORD"
        wordLabel.text = round.word
    }
}
