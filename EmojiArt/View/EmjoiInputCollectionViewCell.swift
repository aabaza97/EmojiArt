//
//  EmjoiInputCollectionViewCell.swift
//  EmojiArt
//
//  Created by Ahmed Abaza on 27/12/2021.
//

import UIKit

class EmjoiInputCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var inputField: UITextField! {
        didSet {
            self.inputField.delegate = self
        }
    }
}


//MARK: -Textfield Delegate
extension EmjoiInputCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.inputField.resignFirstResponder()
        return true
    }
}
