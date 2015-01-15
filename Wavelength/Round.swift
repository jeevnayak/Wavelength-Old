//
//  Round.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class Round: PFObject, PFSubclassing {

    enum GuessState {
        case Empty
        case Pending
        case Incorrect
        case Correct
        case WavelengthPending
        case WavelengthIncorrect
        case WavelengthCorrect
    }

    enum GuessResult {
        case Empty
        case Incorrect
        case Correct
        case WavelengthIncorrect
        case WavelengthCorrect
    }

    @NSManaged var game: Game
    @NSManaged var index: Int
    @NSManaged var word: String
    @NSManaged var clues: NSArray
    @NSManaged var guesses: NSArray
    @NSManaged var replayed: NSNumber

    override class func load() {
        self.registerSubclass()
    }

    class func parseClassName() -> String! {
        return "Round"
    }

    class func newRoundInGame(game: Game, index: Int, block: (newRound: Round, error: NSError?) -> Void) {
        let round = Round()
        round.game = game
        round.index = index
        round.word = Round.generateWordForGame(game)
        round.clues = []
        round.guesses = []
        round.replayed = NSNumber(bool: false)
        // TODO(rajeev): modifying the round and game together should be atomic
        round.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            if error == nil {
                var newWords = [] as [String]
                for w in game.words {
                    newWords.append(w as String)
                }
                newWords.append(round.word)
                game.words = newWords
                game.saveInBackgroundWithBlock({ (succeeded, error2) -> Void in
                    block(newRound: round, error: error2)
                })
            } else {
                block(newRound: round, error: error)
            }
        }
    }

    func replaceWordForGame(game: Game, block: (error: NSError?) -> Void) {
        word = Round.generateWordForGame(game)
        saveInBackgroundWithBlock { (succeeded, error) -> Void in
            block(error: error)
        }
    }

    func wereCluesGiven() -> Bool {
        return clues.count > 0
    }

    func normalize(word: String) -> String {
        return word.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
    }

    func guessStates() -> [GuessState] {
        var states = [] as [GuessState]
        var correctGuessFound = false
        var emptyGuessFound = false
        for (i, clue) in enumerate(clues) {
            if guesses.count < i + 1 {
                if !emptyGuessFound {
                    if !correctGuessFound {
                        states.append(GuessState.Pending)
                    } else {
                        states.append(GuessState.WavelengthPending)
                    }
                    emptyGuessFound = true
                } else {
                    states.append(GuessState.Empty)
                }
                continue
            }

            let guess = guesses[i] as String
            if !correctGuessFound {
                if normalize(guess) == normalize(word) {
                    states.append(GuessState.Correct)
                    correctGuessFound = true
                } else {
                    states.append(GuessState.Incorrect)
                }
            } else {
                if normalize(guess) == normalize(clue as String) {
                    states.append(GuessState.WavelengthCorrect)
                } else {
                    states.append(GuessState.WavelengthIncorrect)
                }
            }
        }

        return states
    }

    func submitGuess(guess: String) -> GuessResult {
        let normalizedGuess = normalize(guess)
        if normalizedGuess.isEmpty {
            return GuessResult.Empty
        }

        let index = guesses.count
        var result: GuessResult
        switch guessStates()[index] {
        case .Pending:
            if normalize(guess) == normalize(word) {
                result = GuessResult.Correct
            } else {
                result = GuessResult.Incorrect
            }
        case .WavelengthPending:
            if normalize(guess) == normalize(clues[index] as String) {
                result = GuessResult.WavelengthCorrect
            } else {
                result = GuessResult.WavelengthIncorrect
            }
        default:
            assertionFailure("invalid state for submitted guess \(index): \(guessStates()[index])")
        }

        var newGuesses = [] as [String]
        for g in guesses {
            newGuesses.append(g as String)
        }
        newGuesses.append(guess)
        guesses = newGuesses
        saveInBackgroundWithTarget(nil, selector: nil)

        return result
    }

    func wasWon() -> Bool {
        for guess in guesses {
            if normalize(guess as String) == normalize(word) {
                return true
            }
        }

        return false
    }

    class func generateWordForGame(game: Game) -> String {
        let words = [
            "GRASS",
            "POLYGAMY",
            "SORE",
            "BUN",
            "CREEK",
            "POSTCARD",
            "CLEAR",
            "BEDBUG",
            "MASTER",
            "SITCOM",
            "BLANKET",
            "BLIND",
            "ROGUE",
            "NEEDLE",
            "CROP",
            "DUST",
            "FOREST",
            "ACCOUNTANT",
            "GODFATHER",
            "ASTEROID",
            "FEAT",
            "FORECAST",
            "TAILGATE",
            "LIFEBOAT",
            "AFTERNOON",
            "PINK",
            "TUNA",
            "NIECE",
            "DICTIONARY",
            "SAFARI",
            "DUMPSTER",
            "BINOCULARS",
            "KICK",
            "STAND",
            "EEL",
            "BLEACHERS",
            "CLEATS",
            "DOT",
            "TORPEDO",
            "BAR",
            "BINGO",
            "CORKSCREW",
            "GLASSES",
            "CRUISE",
            "GOLDILOCKS",
            "CAMOUFLAGE",
            "SALMON",
            "GUITAR",
            "AIR",
            "SCROLL",
            "EURO",
            "VOWEL",
            "QUESTION",
            "DUNK",
            "BAZAAR",
            "FORT",
            "ORPHAN",
            "DOOR",
            "BALCONY",
            "NOCTURNAL",
            "OXYMORON",
            "GREASE",
            "HIJACK",
            "DARE",
            "THYME",
            "ARSON",
            "GOGGLES",
            "SMOOTHIE",
            "RECLINER",
            "SWORD",
            "SKY",
            "WRITER",
            "GENIUS",
            "SPLIT",
            "NUDE",
            "TUMBLER",
            "PUSH",
            "PIN",
            "SAUCER",
            "THIRSTY",
            "BLACKSMITH",
            "VASE",
            "JUGGLE",
            "BELLY",
            "REEBOK",
            "CANDY",
            "CORN",
            "HEAT",
            "WAVE",
            "MSG",
            "HOMESICK",
            "VOLUME",
            "LATE",
            "BARRACKS",
            "POT",
            "RODEO",
            "CORNER",
            "VINEGAR",
            "RELISH",
            "SKYLIGHT",
            "MEAT",
            "POMEGRANATE",
            "BRAIN",
            "FREEZE",
            "SCRUNCHIE",
            "TILL",
            "WORKAHOLIC",
            "ZOOM",
            "HOLE",
            "TRIGGER",
            "MUSICAL",
            "CHAIR",
            "POSH",
            "CHEEK",
            "CUBICLE",
            "DELIVERY",
            "HANDKERCHIEF",
            "BLACK FRIDAY",
            "DETOUR",
            "LINGERIE",
            "PATCH",
            "WHOPPER",
            "LIMB",
            "INFINITY",
            "BLOODY MARY",
            "SAND",
            "SHUFFLEBOARD",
            "BIRCH",
            "ANCHOR",
            "PERSON",
            "CAT",
            "TUPPERWARE",
            "QUICHE",
            "RANCH",
            "TAPAS",
            "ABEL",
            "PECK",
            "CURRENT",
            "WAITRESS",
            "RAMP",
            "STUTTER",
            "STICKER",
            "SHOCK",
            "JESTER",
            "HEAL",
            "ANIMAL CRACKERS",
            "CARICATURE",
            "CROW",
            "POPPY",
            "LOAFER",
            "WINDEX",
            "NEAT",
            "PERJURY",
            "BIG DIPPER",
            "CATNIP",
            "MEGAPHONE",
            "CHICKEN DANCE",
            "ALIEN",
            "SPRAY TAN",
            "YANKEE",
            "MAGNIFYING GLASS",
            "SEAWEED",
            "UNICORN",
            "JUMPSUIT",
            "MIDWAY",
            "SOY",
            "JOUST",
            "TYPE",
            "MANE",
            "YEW",
            "SHAWL",
            "KISS",
            "JANITOR",
            "HOOK",
            "WAGON",
            "YOGURT",
            "ARCHITECT",
            "HAIRSPRAY",
            "CHICK FLICK",
            "BOOKMARK",
            "MOJITO",
            "SIDEKICK",
            "RESERVATION",
            "HYMN",
            "VILLA",
            "GNU",
            "CARBON DIOXIDE",
            "LAUNDRY",
            "GOTHAM",
            "RECRUIT",
            "COCOON",
            "VOW",
            "GHOST TOWN",
            "HOOKY",
            "MAGNET",
            "CAVE",
            "CHAIN",
            "RIPE",
            "VINTAGE",
            "MOZART",
            "PI",
            "INDEX FINGER",
            "TWEAK",
            "LUCKY CHARMS",
            "FLUNK",
            "SCARLET",
            "MENORAH",
            "HICCUP",
            "JUMPER CABLES",
            "APOSTROPHE",
            "CREST",
            "HAMLET",
            "CONTACT LENS",
            "FLASK",
            "CAMP",
            "WASABI",
            "CONVERSATION",
            "HEART",
            "BROWN BAG",
            "FIESTA",
            "SPEED BUMP",
            "REINS",
            "TROUT",
            "WALK",
            "ALBUM",
            "ADDRESS",
            "SNOWBLOWER",
            "FORMULA",
            "FIRE ESCAPE",
            "FLEECE",
            "RIBBON",
            "PEA",
            "SHORTSTOP",
            "VROOM",
            "RECALL",
            "BLOCKBUSTER",
            "ALPHABET",
            "JACKKNIFE",
            "HOUSTON",
            "JIMMY FALLON",
            "PEDOMETER",
            "JACKET",
            "WAX",
            "CRAB",
            "VELCRO",
            "PUPPY",
            "DIZZY",
            "KAYAK",
            "GODIVA",
            "SCARY MOVIE",
            "USA TODAY",
            "GLITCH",
            "GROUPIE",
            "CENTRAL PARK",
            "LADDER",
            "REALTOR",
            "SHOULDER",
            "CAP",
            "BACTERIA",
            "BLACKOUT",
            "CINCO DE MAYO",
            "MONSTER TRUCK",
            "WATERMELON",
            "RABBI",
            "ROCK",
            "HOTLINE",
            "TRAIL MIX",
            "SCRUBS",
            //            "COMPASS",
            //            "PLUM",
            //            "SEESAW",
            //            "COFFEE",
            //            "SKY",
            //            "SADDLE",
            //            "VIOLIN",
            //            "CIGAR",
            //            "SHADOW",
            //            "CACTUS",
            //            "HELICOPTER",
            //            "JEANS",
            //            "BASEBALL",
            //            "SMOKE",
            //            "MIME",
            //            "SNEAKERS",
            //            "SQUEAK",
            //            "SUBMARINE",
            //            "ANDROID",
            //            "HOODIE",
            //            "KEYBOARD",
            //            "ZIPPER",
            //            "CANADA",
            //            "LONDON",
            //            "HARRY POTTER",
            //            "GYM",
            //            "MICROWAVE",
            //            "REFRIGERATOR",
            //            "BEAN",
            //            "DOLLHOUSE",
            //            "PAWN",
            //            "ORIGAMI",
            //            "TOMATO",
            //            "SHARK",
            //            "POLE",
            //            "FROG",
            //            "WISDOM",
            //            "RAINCOAT",
            //            "SAUNA",
            //            "HERCULES",
            //            "PSYCHIC",
            //            "CHRISTMAS",
            //            "WINE",
            //            "TRUMP",
            //            "RECESS",
            //            "LEGO",
            //            "CRAYON",
            //            "TUXEDO",
            //            "VALENTINE",
            //            "SUBWAY",
            //            "CHAMPION",
            //            "BOLT",
            //            "TEXTBOOK",
            //            "CHEMISTRY",
            //            "DORITOS",
            //            "PILL",
            //            "LADY GAGA",
            //            "SWIFT",
            //            "UFO",
            //            "RAPUNZEL",
            //            "PENGUIN",
            //            "SNOOPY",
            //            "LAUGH",
            //            "COUNT",
            //            "POTATO",
            //            "CAVIAR",
            //            "MYTH",
            //            "COCKROACH",
            //            "TICKLE",
            //            "WHISKERS",
            //            "ROBIN",
            //            "LAS VEGAS",
            //            "MOUTHWASH",
            //            "PENTAGON",
            //            "OVEN",
            //            "MAYFLOWER",
            //            "CUDDLE",
            //            "FLY",
            //            "ONION",
            //            "GOLDFISH",
            //            "UMBRELLA",
            //            "POODLE",
            //            "BOTOX",
            //            "SESAME",
            //            "BUZZ",
            //            "BAGEL",
            //            "NUN",
            //            "RADIO",
            //            "BABY",
            //            "VALENTINE",
            //            "KINDLE",
            //            "MICHAEL JORDAN",
            //            "TICKET",
            //            "TREADMILL",
            //            "TOP",
            //            "GOOGLE",
            //            "SAFEWAY",
        ]

        var word = ""
        var newWord = false
        while !newWord {
            word = words[Int(arc4random_uniform(UInt32(words.count)))]
            newWord = !game.words.containsObject(word)
        }
        return word
    }
}
