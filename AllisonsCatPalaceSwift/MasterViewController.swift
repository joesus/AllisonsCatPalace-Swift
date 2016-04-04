//
//  MasterViewController.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 1/4/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import UIKit
import Firebase

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var kittens = [Kitten]()
    var kittenImages = [Int: UIImage]()
    
    // not sure if need all this fiddle faddle
    var deleteKittenAlert: UIAlertController?
    var alertAction = UIAlertAction.self
    var actionString: String?
    
    var ref: Firebase = Firebase(url: "https://catpalace.firebaseio.com/")
    
    convenience init(ref: String) {
        self.init()
        self.ref = Firebase(url: ref)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForPreviewingWithDelegate(self, sourceView: self.view)

        // Load all the datas
        loadKittenData() {}
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    func loadKittenData(completionHandler: (()->())?) {
        ref.observeEventType(.Value, withBlock: { snapshot in
            var kittens = [Kitten]()
            for item in snapshot.children {
                do {
                    let kitten = try Kitten(snapshot: item as! FDataSnapshot)
                    kittens.append(kitten)
                } catch let error{
                    self.actionString = "\(error)"
                }
            }
            self.kittens = kittens

            self.tableView.reloadData()
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.registerForPreviewingWithDelegate(self, sourceView: self.view)
                completionHandler?()
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let row = (sender as? UITableViewCell)?.tag {
                let kitten = kittens[row]
                let detailVC = (segue.destinationViewController as! DetailViewController)
                
                detailVC.kittenImage = kittenImages[row]
                detailVC.kitten = kitten
                
                detailVC.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                detailVC.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "showEditVC" {
            let kitten = Kitten(name: "", about: "", greeting: "", age: 1, cutenessLevel: 5)
            let editVC = segue.destinationViewController as! EditTableViewController
            editVC.kitten = kitten
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kittens.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.tag = indexPath.row
        
        let kitten = kittens[indexPath.row]
        
        let kittenImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        if let cachedImage = kittenImages[indexPath.row] {
            kittenImageView.image = cachedImage
        } else {
            downloadImagesForImageView(kittenImageView, link: kitten.pictureUrl!, contentMode: .ScaleAspectFit) {
                self.kittenImages[indexPath.row] = kittenImageView.image
            }
        }
        
        // Hax to make images round on tableview
        kittenImageView.layer.cornerRadius = 20
        kittenImageView.layer.masksToBounds = true
        kittenImageView.layer.borderWidth = 0.35
        
        cell.indentationLevel = 50
        cell.indentationWidth = 1
        cell.contentView.addSubview(kittenImageView)
        
        cell.textLabel!.text = kitten.name
        cell.detailTextLabel!.text = kitten.about

        self.registerForPreviewingWithDelegate(self, sourceView: self.view)

        return cell
    }
    
    func downloadImagesForImageView(imageView: UIImageView, link:String, contentMode mode: UIViewContentMode, onCompletion: (() -> ())) {
        guard let url = NSURL(string: link) else { return }
        imageView.contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, error) -> Void in
            guard
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                imageView.image = image
                onCompletion()
            }
        }).resume()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteKittenWithWarning(self.kittens[indexPath.row])
            self.tableView.reloadData()
        } 
    }
    
    func deleteKittenWithWarning(kitten: Kitten) {
        let alertController = UIAlertController(title: "DANGER", message: "This action is permanent. The kitten will cease to exist. Are you certain you want to proceed?", preferredStyle: .Alert)
        
        let okAction = alertAction.init(title: "Yes. Delete the Kitten", style: .Destructive) {
            UIAlertAction in
            self.actionString = "Yes"
            kitten.ref?.removeValue()
        }
        
        let cancelAction = alertAction.init(title: "Cancel", style: .Cancel) {
            UIAlertAction in
            self.actionString = "Cancel"
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.deleteKittenAlert = alertController // for testing
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}

extension MasterViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView?.indexPathForRowAtPoint(location) else { return nil }
        guard let cell = tableView?.cellForRowAtIndexPath(indexPath) else { return nil }
        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController else { return nil }
        
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        previewingContext.sourceRect = cell.frame
        
        let kitten = kittens[indexPath.row]
        detailVC.kittenImage = kittenImages[indexPath.row]
        detailVC.kitten = kitten
        
        detailVC.editKittenCompletion = {
            let editVC = self.storyboard?.instantiateViewControllerWithIdentifier("EditTableViewController") as! EditTableViewController
            editVC.kitten = kitten
            editVC.kittenImage = self.kittenImages[indexPath.row]
            self.showViewController(editVC, sender: nil)
            return editVC // only for getting a reference for testing. Bad practice?
        }
        
        detailVC.deleteKittenCompletion = deleteKittenWithWarning
        
        return detailVC
    }
}
