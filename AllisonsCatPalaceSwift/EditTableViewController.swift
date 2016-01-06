//
//  EditTableViewController.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 1/6/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import UIKit
import Firebase

class EditTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var greetingField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    
    var kitten: Kitten?
    var kittenImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        greetingField.delegate = self
        nameField.delegate = self
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let kitten = self.kitten {
            imageView.image = kittenImage
            nameField.text = kitten.name
            greetingField.text = kitten.greeting
        }
    }
    
    @IBAction func applyChanges(sender: AnyObject) {
        kitten?.ref?.updateChildValues([
            "name": self.nameField.text!,
            "greeting": self.greetingField.text!
            ], withCompletionBlock: { (error, firebase) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.nameField {
            self.greetingField.text = "Hello, my name is \(textField.text!)"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.nameField {
            self.greetingField.becomeFirstResponder()
        }
        if textField == self.greetingField {
            self.greetingField.resignFirstResponder()
        }
        
        return true
    }
}
