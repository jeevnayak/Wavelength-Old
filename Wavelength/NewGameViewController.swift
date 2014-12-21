//
//  NewGameViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class NewGameViewController: FBFriendPickerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        allowsMultipleSelection = false
        title = "New Game"

        loadData()
    }
}
