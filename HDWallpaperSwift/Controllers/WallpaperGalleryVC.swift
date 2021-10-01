//
//  WallpaperGalleryVC.swift
//  WallpaperHD
//
//  Created by WallpaperHD on 30/3/21.
//  Copyright © 2021 WallpaperHD. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

// This is the gallery with all live wallpapers from the app
class WallpaperGalleryVC: UIViewController, UIScrollViewDelegate
{
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var label: UILabel!
    @IBOutlet weak private var saveButton: UIButton!
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var closeView: UIView!
    @IBOutlet weak private var loader: UIActivityIndicatorView!
    //private var livePhotoView = UIImageView()
    var currentWallpaper = [String : Any]()

    /// Initial logic when the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSaveButtonStyle()
        setupCloseButtonStyle()
        setupHDWallpaperScrollView()
    }

    /// Setup save button style
    private func setupSaveButtonStyle() {
        saveButton.layer.borderWidth = 1.5
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.cornerRadius = saveButton.frame.height/2
    }
    
    /// Setup close button style
    private func setupCloseButtonStyle() {
        closeView.layer.borderWidth = 1.5
        closeView.layer.borderColor = UIColor.white.cgColor
        closeView.layer.cornerRadius = closeView.frame.height/2
    }
    
    /// Setul live wallpapers into a scroll view
    private func setupHDWallpaperScrollView()
    {
        self.label.text = currentWallpaper["title"] as? String
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dirPath = paths.first as NSString?
        {
            let folderPath = dirPath.appendingPathComponent("images") as NSString?
            if !FileManager.default.fileExists(atPath: folderPath! as String)
            {
                try! FileManager.default.createDirectory(atPath: folderPath! as String, withIntermediateDirectories: true, attributes: nil)
            }
            let thumbnail = currentWallpaper["title"] as? String
            let filePath = folderPath!.appendingPathComponent(thumbnail!)
            if (FileManager.default.fileExists(atPath: filePath))
            {
                self.loader.isHidden = true
                imageView.image = UIImage(contentsOfFile: filePath)
            }
            else
            {
                DispatchQueue.global().async
                {
                    let url:NSURL = NSURL(string: thumbnail!)!
                    if let data:NSData = try? Data(contentsOf: url as URL) as NSData {
                        FileManager.default.createFile(atPath: filePath as String, contents: data as Data, attributes: nil)
                        if let image = UIImage(data: data as Data) {
                            DispatchQueue.main.async {
                                self.loader.isHidden = true
                                self.imageView.image = image
                            }
                        }
                    }
                }
            }
        }
        
        //let count = scrollView.subviews.count
        //scrollView.contentSize = CGSize(width: view.frame.width*CGFloat(count), height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        //livePhotoView = UIImageView(frame: view.frame)
        //scrollView.addSubview(livePhotoView)
        //loadLivePhoto()
    }
    
    /// Load live photos
    /*private func loadLivePhoto()
    {
        /*guard let photoURL = Bundle.main.url(forResource: "\(currentWallpaper)", withExtension: "JPG"),
            let liveURL = Bundle.main.url(forResource: "\(currentWallpaper)", withExtension: "MOV")
        else { return }
        manager.loadLivePhoto(photoURL: photoURL, videoURL: liveURL) { (livePhoto) in
            DispatchQueue.main.async {
                LoadingView.removeLoadingView()
                if let photo = livePhoto {
                    self.livePhotoView.frame = CGRect(x: self.scrollView.contentOffset.x, y: 0, width: self.livePhotoView.frame.width, height: self.livePhotoView.frame.height)
                    //self.livePhotoView.livePhoto = photo
                    //self.livePhotoView.startPlayback(with: .full)
                }
            }
        }*/
        self.livePhotoView.frame = CGRect(x: self.scrollView.contentOffset.x, y: 0, width: self.livePhotoView.frame.width, height: self.livePhotoView.frame.height)
        //self.livePhotoView.image = currentWallpaper
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dirPath = paths.first as NSString?
        {
            let folderPath = dirPath.appendingPathComponent("images") as NSString?
            if !FileManager.default.fileExists(atPath: folderPath! as String)
            {
                try! FileManager.default.createDirectory(atPath: folderPath! as String, withIntermediateDirectories: true, attributes: nil)
            }
            let title = currentWallpaper["title"] as? String
            let thumbnail = currentWallpaper["name"] as? String
            let filePath = folderPath!.appendingPathComponent(title!)
            if (FileManager.default.fileExists(atPath: filePath))
            {
                self.loader.isHidden = true
                self.livePhotoView.image = UIImage(contentsOfFile: filePath)
            }
            else
            {
                DispatchQueue.global().async {
                    let storage = Storage.storage()
                    let pathReference = storage.reference(withPath: "image/\(thumbnail ?? "")")
                    pathReference.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if data != nil
                        {
                            FileManager.default.createFile(atPath: filePath as String, contents: data! as Data, attributes: nil)
                            if let image = UIImage(data: data! as Data) {
                                DispatchQueue.main.async {
                                    self.loader.isHidden = true
                                    self.livePhotoView.image = image
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }*/
    
    /// Save current live wallpaper to the gallery
    private func saveCurrentLiveWallpaper()
    {
        /*guard let photoURL = Bundle.main.url(forResource: "\(currentWallpaperIndex)", withExtension: "JPG"),
            let liveURL = Bundle.main.url(forResource: "\(currentWallpaperIndex)", withExtension: "MOV") else { return }
        manager.saveLivePhoto(photoURL: photoURL, videoURL: liveURL) { (success) in
            DispatchQueue.main.async {
                LoadingView.removeLoadingView()
                if success
                {
                    self.presentLivePhotoSavedAlert()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                    {
                        self.showAd()
                    }
                }
                else { self.presentGenericErrorAlert() }
            }
        }*/
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dirPath = paths.first as NSString?
        {
            let folderPath = dirPath.appendingPathComponent("images") as NSString?
            if !FileManager.default.fileExists(atPath: folderPath! as String)
            {
                try! FileManager.default.createDirectory(atPath: folderPath! as String, withIntermediateDirectories: true, attributes: nil)
            }
            let thumbnail = currentWallpaper["title"] as! String
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
    
    /// When scroll view ends animation
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /*currentWallpaperIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        loadLivePhoto()
        var shouldShowPButton = false
        if((AppDelegate.sharedInstance().mobflow) != nil)
        {
            shouldShowPButton = AppDelegate.sharedInstance().mobflow!.shouldShowPButton()
        }
        if currentWallpaperIndex % adsDisplayInterval == 0 && !shouldShowPButton
        {
            AdsHelper.shared.showAd(self, placementId: "rewardedVideo")
        }*/
    }
    
    /// Invoke save action
    @IBAction private func onSaveAction(_ sender: UIButton)
    {
        requestPhotoLibraryAuthorization { (success) in
            if success { self.saveCurrentLiveWallpaper() }
        }
    }
    
    /// Hide/Show save button
    @IBAction private func onShowSaveAction(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.saveButton.alpha = self.saveButton.alpha == 0 ? 1 : 0
            self.closeButton.alpha = self.saveButton.alpha
        }
    }
    
    /// Close gallery and go back to main screen
    @IBAction private func onDismissAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Save current live wallpaper to the gallery
    private func saveCurrentLiveWallpaper(item: [String: Any])
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dirPath = paths.first as NSString?
        {
            let folderPath = dirPath.appendingPathComponent("images") as NSString?
            if !FileManager.default.fileExists(atPath: folderPath! as String)
            {
                try! FileManager.default.createDirectory(atPath: folderPath! as String, withIntermediateDirectories: true, attributes: nil)
            }
            let title = item["title"] as? String
            let filePath = folderPath!.appendingPathComponent(title!)
            if (FileManager.default.fileExists(atPath: filePath))
            {
                UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: filePath)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
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
