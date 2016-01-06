//
//  DetailViewController.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 1/4/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var kitten: Kitten?
    var kittenImage: UIImage?
    var editKittenCompletion: (() -> Void)?
    
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
        }
    }
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        let editAction = UIPreviewAction(title: "Edit", style: .Default) { (action: UIPreviewAction, vc: UIViewController) -> Void in
            let detailVC = vc as! DetailViewController
            detailVC.editKittenCompletion?()
        }
        
        let deleteAction = UIPreviewAction(title: "Delete", style: .Destructive) { (action: UIPreviewAction, vc: UIViewController) -> Void in
            
        }
        return [editAction, deleteAction]
    }
}

