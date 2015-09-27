//
//  PhotosCollectionViewController.swift
//  Peat
//
//  Created by Matthew Barth on 9/27/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3


private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UICollectionViewController {
  
  var imageArray: Array<UIImage>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func downloadPhoto() {
    
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let filePath = "\(paths)/SaveFile2.png"
    let filePathToWrite = NSURL(fileURLWithPath: filePath)
    
    let downloadRequest = AWSS3TransferManagerDownloadRequest()
    downloadRequest.bucket = "peat-assets"
    downloadRequest.key  = "MYFILE" //fileName on s3
    downloadRequest.downloadingFileURL = filePathToWrite
    
    let transferManager = AWSS3TransferManager.defaultS3TransferManager()
    transferManager.download(downloadRequest).continueWithBlock {
      (task: AWSTask!) -> AnyObject! in
      if task.error != nil {
        print("Error downloading")
        print(task.error.description)
        return "HI"
      }
      else {
        print(filePathToWrite)
        //        var err: NSError?
        if let imageData = NSData(contentsOfURL: filePathToWrite) {
          let currentImage = UIImage(data: imageData)
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.imageArray.append(currentImage)
          })
        }
        return "HI"
      }
    }
    
  }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
