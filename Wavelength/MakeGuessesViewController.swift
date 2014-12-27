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

class MakeGuessesViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var partnerProfilePictureView: FBProfilePictureView!
    @IBOutlet weak var userProfilePictureView: FBProfilePictureView!
    @IBOutlet weak var wordGuessField: UITextField!
    @IBOutlet weak var clue1Label: UILabel!
    @IBOutlet weak var clue2Label: UILabel!
    @IBOutlet weak var clue3Label: UILabel!
    @IBOutlet weak var clue4Label: UILabel!
    @IBOutlet weak var guess1Label: UILabel!
    @IBOutlet weak var guess2Label: UILabel!
    @IBOutlet weak var guess3Label: UILabel!
    @IBOutlet weak var guess4Label: UILabel!
    @IBOutlet weak var wavelength2GuessField: UITextField!
    @IBOutlet weak var wavelength3GuessField: UITextField!
    @IBOutlet weak var wavelength4GuessField: UITextField!
    @IBOutlet weak var wavelength2Background: UIView!
    @IBOutlet weak var wavelength3Background: UIView!
    @IBOutlet weak var wavelength4Background: UIView!
    @IBOutlet weak var doneButton: UIButton!

    var game: Game!
    var round: Round!
    var delegate: MakeGuessesDelegate?

    var clueLabels: [UILabel]!
    var guessLabels: [UILabel]!
    var wavelengthGuessFields: [UITextField]!
    var wavelengthBackgrounds: [UIView]!

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        clueLabels = [clue1Label, clue2Label, clue3Label, clue4Label]
        guessLabels = [guess1Label, guess2Label, guess3Label, guess4Label]
        wavelengthGuessFields = [wavelength2GuessField, wavelength3GuessField, wavelength4GuessField]
        wavelengthBackgrounds = [wavelength2Background, wavelength3Background, wavelength4Background]

        let partnerFirstName = game.getPartnerFirstName(PFUser.currentUser()).uppercaseString
        descriptionLabel.text = "GUESS \(partnerFirstName)'S WORD"
        partnerProfilePictureView.profileID = game.getPartnerFbId(PFUser.currentUser())
        userProfilePictureView.profileID = PFUser.currentUser().objectForKey("fbId") as String

        wordGuessField.delegate = self
        for wavelengthGuessField in wavelengthGuessFields {
            wavelengthGuessField.delegate = self
        }

        reloadData()
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let guessResult = round.submitGuess(textField.text)
        switch guessResult {
        case .Empty:
            let alert = UIAlertController(title: "Invalid", message: "You must make a guess", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return false
        case .Incorrect:
            let alert = UIAlertController(title: "Incorrect", message: "Maybe next time.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        case .Correct:
            let alert = UIAlertController(title: "Correct", message: "Good job!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }

        reloadData()

        return false
    }

    // MARK: event handlers

    @IBAction func onBackButtonTap(sender: AnyObject) {
        delegate?.makeGuessesCancelled(self)
    }

    @IBAction func onDoneButtonTap(sender: AnyObject) {
        delegate?.makeGuessesDone(self)
    }

    // MARK: helpers

    func reloadData() {
        wordGuessField.text = ""
        wordGuessField.hidden = false
        for (i, clueLabel) in enumerate(clueLabels) {
            clueLabel.text = round.clues[i] as? String
            clueLabel.hidden = false
        }
        for (i, guessLabel) in enumerate(guessLabels) {
            guessLabel.hidden = true
        }
        for (i, wavelengthGuessField) in enumerate(wavelengthGuessFields) {
            wavelengthGuessField.hidden = true
        }
        for (i, wavelengthBackground) in enumerate(wavelengthBackgrounds) {
            wavelengthBackground.hidden = true
        }
        doneButton.hidden = true

        let guessStates = round.guessStates()
        assert(guessStates.count == guessLabels.count, "incorrect number of guess states")

        for (i, guessState) in enumerate(guessStates) {
            let clueLabel = clueLabels[i]
            let guessLabel = guessLabels[i]

            switch guessState {
            case .Empty:
                clueLabel.hidden = true
            case .Pending:
                wordGuessField.becomeFirstResponder()
            case .Incorrect:
                guessLabel.text = round.guesses[i] as? String
                guessLabel.textColor = UIColor.grayColor()
                guessLabel.hidden = false
            case .Correct:
                guessLabel.text = round.guesses[i] as? String
                guessLabel.textColor = UIColor.blackColor()
                guessLabel.hidden = false
            case .WavelengthPending:
                wordGuessField.hidden = true
                clueLabel.text = getPlaceholderTextForClue(round.clues[i] as String)
                wavelengthGuessFields[i - 1].hidden = false
                wavelengthGuessFields[i - 1].becomeFirstResponder()
            case .WavelengthIncorrect:
                guessLabel.text = round.guesses[i] as? String
                guessLabel.textColor = UIColor.grayColor()
                guessLabel.hidden = false
                wavelengthBackgrounds[i - 1].backgroundColor = UIColor.redColor()
                wavelengthBackgrounds[i - 1].hidden = false
            case .WavelengthCorrect:
                guessLabel.text = round.guesses[i] as? String
                guessLabel.textColor = UIColor.blackColor()
                guessLabel.hidden = false
                wavelengthBackgrounds[i - 1].backgroundColor = UIColor.lightGreenColor()
                wavelengthBackgrounds[i - 1].hidden = false
            default:
                assertionFailure("invalid state for guess \(i): \(guessState)")
            }
        }

        if guessStates.last != Round.GuessState.Empty && guessStates.last != Round.GuessState.Pending && guessStates.last != Round.GuessState.WavelengthPending {
            view.endEditing(true)
            wordGuessField.hidden = true
            doneButton.hidden = false
        }
    }

    func getPlaceholderTextForClue(clue: String) -> String {
        var ret = ""
        for char in clue {
            ret += "_ "
        }
        return ret
    }
}
