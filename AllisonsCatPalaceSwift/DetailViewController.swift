//
//  DetailViewController.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 1/4/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {
    
    @IBOutlet weak var cutenessLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var kitten: Kitten?
    var kittenImage: UIImage?
    var editKittenCompletion: (() -> UIViewController)?
    var deleteKittenCompletion: ((Kitten) -> Void)?
    var ref: Firebaseable = Firebase(url: "https://catpalace.firebaseio.com/")
    var previewActions: [UIPreviewAction]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let kitten = self.kitten {
            imageView.image = kittenImage
            nameLabel.text = kitten.name
            detailDescriptionLabel.text = kitten.greeting
            if let age = kitten.age, cuteness = kitten.cutenessLevel {
                ageLabel.text = "Age: \(age)"
                cutenessLabel.text = "CutenessLevel: \(cuteness)"
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        loadKittenData() {
            self.configureView()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditVC" {
            let editVC = segue.destinationViewController as! EditTableViewController
            editVC.kitten = kitten
            editVC.kittenImage = kittenImage
        }
    }
    
    func loadKittenData(completionHandler: (()->())?) {
        ref.observeSingleEventOfType(.ChildChanged, withBlock: { snapshot in
            do {
                self.kitten = try Kitten(snapshot: snapshot as SnapShotable)
            } catch let error {
                print(error)
            }
        })
        completionHandler?()
    }
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        let editAction = UIPreviewAction(title: "Edit", style: .Default) { (action: UIPreviewAction, vc: UIViewController) -> Void in
            let detailVC = vc as! DetailViewController
            detailVC.editKittenCompletion?()
        }
        
        let deleteAction = UIPreviewAction(title: "Delete", style: .Destructive) { (action: UIPreviewAction, vc: UIViewController) -> Void in
            let detailVC = vc as! DetailViewController
            detailVC.deleteKittenCompletion?(self.kitten!)
        }
        self.previewActions = [editAction, deleteAction] // hacky test stuff
        return [editAction, deleteAction]
    }
}