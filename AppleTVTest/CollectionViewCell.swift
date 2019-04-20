//
//  CollectionViewCell.swift
//  AppleTVTest
//
//  Created by Rolf Locher on 12/17/18.
//  Copyright © 2018 Rolf Locher. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var label0: UILabel!
    
    @IBOutlet var label1: UILabel!
    
    @IBOutlet var label2: UILabel!
    
    @IBOutlet var label3: UILabel!
    
    @IBOutlet weak var symbolImage: UIImageView!
    
//    override var canBecomeFocused: Bool {
//        return true
//    }
//
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.layer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
            }, completion: nil)

        } else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.layer.backgroundColor = UIColor.clear.cgColor
            }, completion: nil)
        }
    }
}
