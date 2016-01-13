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

    @IBOutlet weak var aboutField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var cutenessLevel: UISlider!
    @IBOutlet weak var applyButton: UIButton!
    
    var kitten: Kitten?
    var kittenImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        aboutField.delegate = self
        nameField.delegate = self
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let kitten = self.kitten {
            if let image = kittenImage {
                imageView.image = image
            }
            nameField.text = kitten.name
            aboutField.text = kitten.about
            ageField.text = String(kitten.age)
            cutenessLevel.value = Float(kitten.cutenessLevel)
        }
        addDoneButtonToNumberPad()
    }
    
    @IBAction func applyChanges(sender: AnyObject) {
        
        var kittenData: [NSObject: AnyObject] = [
            "name": self.nameField.text!,
            "greeting": "Hello, my name is \(self.nameField.text!)",
            "about": self.aboutField.text!,
            "cutenesslevel": Int(self.cutenessLevel.value),
            "age": Int(self.ageField.text!)!,
        ]
        
        if let ref = kitten?.ref {
            ref.updateChildValues(kittenData, withCompletionBlock: { (error, firebase) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        } else {
            kittenData["picture"] = kitten?.pictureUrl
            // sets the base ref. This should probably be global
            let ref = Firebase(url: "https://catpalace.firebaseio.com/")
            // maybe a better way to do this than autoID
            let newKittenRef = ref.childByAutoId()
            newKittenRef.setValue(kittenData)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelChanges(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    func addDoneButtonToNumberPad() {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self.ageField, action: "resignFirstResponder")
        let spaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.items = [spaceItem, barButtonItem]
        ageField.inputAccessoryView = toolbar
    }
    
    // MARK: TextField Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.nameField {
            self.aboutField.becomeFirstResponder()
        }
        if textField == self.aboutField {
            self.ageField.becomeFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.ageField {
            let text = NSString(string: textField.text!).stringByReplacingCharactersInRange(range, withString: string)
            if let _ = Int(text) {
                self.applyButton.enabled = true
            } else {
                self.applyButton.enabled = false
            }
        }
        return true
    }
}
