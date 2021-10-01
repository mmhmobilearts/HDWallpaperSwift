
//
//  WallpaperHomeVC.swift
//  WallpaperHD
//
//  Created by WallpaperHD on 20/12/19.
//  Copyright © 2019 WallpaperHD. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import PinterestLayout

class WallpaperHomeVC: UIViewController
{
    @IBOutlet weak private var collectionView: UICollectionView!
    
    var addressURL = ""
    var array = [[String: Any]]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    func getPhotos()
    {
        let components = URLComponents(string: self.addressURL)
        let request = URLRequest(url: (components?.url)!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            self.array = try! JSONSerialization.jsonObject(with: data) as! [[String : Any]]
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        task.resume()
    }
    
    func setupCollectionView()
    {
        let layout = PinterestLayout()
        layout.delegate = self
        layout.cellPadding = 5
        layout.numberOfColumns = 2
        self.collectionView.collectionViewLayout = layout
        let nib = UINib(nibName: "WallpaperCollectionViewCell", bundle:nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "wallpaper-cell")
        
        self.getPhotos()
    }
    
    func requestPhotoLibraryAuthorization(completion: @escaping (_ success: Bool) -> Void) {
        DispatchQueue.main.async {
            if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .denied || status == .restricted {
                        self.presentAuthorizationAlert()
                    } else if status == .authorized { completion(true) }
                })
            } else if PHPhotoLibrary.authorizationStatus() == .denied || PHPhotoLibrary.authorizationStatus() == .restricted {
                self.presentAuthorizationAlert()
            } else if PHPhotoLibrary.authorizationStatus() == .authorized { completion(true) }
        }
    }
    
    private func presentAuthorizationAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Access required", message: "To save wallpapers into your photo library, this app needs photo library access. Select 'Settings' to allow Photos access.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension WallpaperHomeVC: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : WallpaperCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaper-cell", for: indexPath) as! WallpaperCollectionViewCell

        let item = self.array[indexPath.row]
        
        cell.favbutton.tag = Int(item["ID"] as! String) ?? 0
        cell.savbutton.tag = indexPath.row
        cell.savbutton.addTarget(self, action: #selector(self.onSave), for: .touchUpInside)
        if let array = UserDefaults.standard.value(forKey: "array") as? [Int]
        {
            if array.contains(cell.favbutton.tag)
            {
                cell.favbutton.tintColor = UIColor.orange
            }
            else
            {
                cell.favbutton.tintColor = UIColor.lightGray
            }
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dirPath = paths.first as NSString?
        {
            let folderPath = dirPath.appendingPathComponent("images") as NSString?
            if !FileManager.default.fileExists(atPath: folderPath! as String)
            {
                try! FileManager.default.createDirectory(atPath: folderPath! as String, withIntermediateDirectories: true, attributes: nil)
            }
            let thumbnail = item["title"] as! String
            let filePath = folderPath!.appendingPathComponent(thumbnail)
            if (FileManager.default.fileExists(atPath: filePath))
            {
                cell.imageView.image = UIImage(contentsOfFile: filePath)
            }
            else
            {
                DispatchQueue.global().async {
                    let url:NSURL = NSURL(string: thumbnail)!
                    if let data:NSData = try? Data(contentsOf: url as URL) as NSData {
                        FileManager.default.createFile(atPath: filePath as String, contents: data as Data, attributes: nil)
                        if let image = UIImage(data: data as Data) {
                            DispatchQueue.main.async {
                                cell.imageView.image = image
                            }
                        }
                    }
                }
            }
        }
                
        return cell
    }
    
    @objc func onSave(sender:UIButton)
    {
        let item = self.array[sender.tag] 
        requestPhotoLibraryAuthorization { (success) in
            if success { self.saveCurrentLiveWallpaper(item: item) }
        }
    }
    
    /// Save current live wallpaper to the gallery
    private func saveCurrentLiveWallpaper(item: [String: Any])
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dirPath = paths.first as NSString?
        {
            let folderPath = dirPath.appendingPathComponent("thumbnail") as NSString?
            if !FileManager.default.fileExists(atPath: folderPath! as String)
            {
                try! FileManager.default.createDirectory(atPath: folderPath! as String, withIntermediateDirectories: true, attributes: nil)
            }
            let thumbnail = item["title"] as! String
            let filePath = folderPath!.appendingPathComponent(thumbnail)
            if (FileManager.default.fileExists(atPath: filePath))
            {
                UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: filePath)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let alert = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Saved successfully", message: "This wallpaper has been saved into your photo library.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
}

extension WallpaperHomeVC: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let item = self.array[indexPath.row]
        let bundle = Bundle(for: type(of:self))
        let storyBoard = UIStoryboard(name: "Main", bundle: bundle)
        let objVC = storyBoard.instantiateViewController(withIdentifier: "GalleryVC") as! WallpaperGalleryVC
        objVC.currentWallpaper = item
        self.present(objVC, animated: true, completion: nil)
    }
}

extension WallpaperHomeVC: PinterestLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView,
                        heightForImageAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat
    {
        let item = self.array[indexPath.row] 

        let height = CGFloat(item["height"] as! Int)

        return height
    }
    
    func collectionView(collectionView: UICollectionView,
                        heightForAnnotationAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat
    {
        return 0
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
