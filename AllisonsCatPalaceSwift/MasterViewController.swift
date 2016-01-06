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
    let ref = Firebase(url: "https://catpalace.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerForPreviewingWithDelegate(self, sourceView: self.view)

        // Load all the datas
        ref.observeEventType(.Value, withBlock: { snapshot in
            
            var kittens = [Kitten]()
            for item in snapshot.children {
                let kitten = Kitten(snapshot: item as! FDataSnapshot)
                kittens.append(kitten)
            }
            self.kittens = kittens

            self.tableView.reloadData()
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.registerForPreviewingWithDelegate(self, sourceView: self.view)
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    func insertNewObject(sender: AnyObject) {
        // TODO - open editVC with no data. Or maybe a default kitten image
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let kitten = kittens[indexPath.row]
                let detailVC = (segue.destinationViewController as! DetailViewController)
                
                    detailVC.kittenImage = kittenImages[indexPath.row]
                    detailVC.kitten = kitten
                
                    detailVC.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    detailVC.navigationItem.leftItemsSupplementBackButton = true
            }
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
        
        let kitten = kittens[indexPath.row]
        
        let kittenImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        if let cachedImage = kittenImages[indexPath.row] {
            kittenImageView.image = cachedImage
        } else {
            downloadImagesForImageView(kittenImageView, link: kitten.pictureUrl, contentMode: .ScaleAspectFit) {
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
        guard
            let url = NSURL(string: link)
            else {return}
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
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func deleteKittenWithWarning(kitten: Kitten) {
        let alertController = UIAlertController(title: "DANGER", message: "This action is permanent. The kitten will cease to exist. Are you certain you want to proceed?", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Yes. Delete the Kitten", style: .Destructive) {
            UIAlertAction in
            kitten.ref?.removeValue()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            UIAlertAction in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
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
        print(" something ")
        guard let indexPath = tableView?.indexPathForRowAtPoint(location) else { return nil }
        guard let cell = tableView?.cellForRowAtIndexPath(indexPath) else { return nil }

        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController else { return nil }
        print("guards done")
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
        }
        
        detailVC.deleteKittenCompletion = deleteKittenWithWarning
        
        return detailVC
    }
}
