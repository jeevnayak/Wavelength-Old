//
//  NewGameCell.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/26/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class NewGameCell : UICollectionViewCell {

    func highlight() {
        contentView.backgroundColor = UIColor.lightGrayColor()
    }

    func unhighlight() {
        contentView.backgroundColor = UIColor.whiteColor()
    }
}
