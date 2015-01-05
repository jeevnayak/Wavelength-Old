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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var waveView: AnimatingSineWaveView!
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

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
        // TODO(rajeev): figure out when to toast and what the text should be
        switch guessResult {
        case .Empty:
            let alert = UIAlertController(title: "Invalid", message: "You must make a guess", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return false
        case .Incorrect:
            showWavelengthToastWithText("INCORRECT")
        case .Correct:
            showWavelengthToastWithText("NAILED IT")
            animateSineWaveForCorrectAnswer()
        case .WavelengthIncorrect:
            showWavelengthToastWithText("INCORRECT")
        case .WavelengthCorrect:
            showWavelengthToastWithText("WAVELENGTH")
            animateSineWaveForCorrectAnswer()
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

    func keyboardWasShown(aNotification: NSNotification) {
        let info = aNotification.userInfo!
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0)
    }

    func keyboardWillHide(aNotification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
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

    func showWavelengthToastWithText(toastText: String) {
        let background = UIImage(named: "WavelengthToast")!
        // TODO(rajeev): the y-offset is hardcoded here, maybe it should be centered (taking into account the keyboard)
        let container: UIView = UIView(frame: CGRectMake((view.frame.width - background.size.width) / 2, 125, background.size.width, background.size.height))
        container.addSubview(UIImageView(image: background))

        let label = UILabel(frame: container.bounds)
        label.font = UIFont(name: "Montserrat-Bold", size: 32)
        label.text = toastText
        label.textAlignment = NSTextAlignment.Center
        container.addSubview(label)

        view.addSubview(container)

        container.transform = CGAffineTransformMakeScale(0, 0)
        UIView.animateWithDuration(0.75, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
            container.transform = CGAffineTransformMakeScale(1, 1)
        }) { (complete) -> Void in
            UIView.animateWithDuration(0.2, delay: 0.25, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                container.transform = CGAffineTransformMakeTranslation(container.frame.width, 0)
            }, completion: { (complete) -> Void in
                container.removeFromSuperview()
            })
        }
    }

    func animateSineWaveForCorrectAnswer() {
        let amplitude = waveView.kDefaultAmplitude * 2
        let speed = waveView.kDefaultSpeed / 2
        let color = UIColor.lightBlueColor()
        waveView.transformSineWaveWithTimeCheckpoints([CFTimeInterval(1), CFTimeInterval(1.5), CFTimeInterval(2.5)], minBarHeightCheckpoints: nil, amplitudeCheckpoints: [amplitude, amplitude, waveView.kDefaultAmplitude], frequencyCheckpoints: nil, speedCheckpoints: [speed, speed, waveView.kDefaultSpeed], colorCheckpoints: [color, color, waveView.kDefaultColor])
    }
}
