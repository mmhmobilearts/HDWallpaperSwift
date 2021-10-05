//
//  WallpaperFavoriteVC.swift
//  WallpaperHD
//
//  Created by WallpaperHD on 22/04/2021.
//

import UIKit
import Photos
import PhotosUI

class WallpaperFavoriteVC: UIViewController
{
    @IBOutlet weak private var collectionView: UICollectionView!

    var addressURL = ""
    var array = [[String: Any]]()
    var favorites = [[String: Any]]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    func getPhotos()
    {
        let components = URLComponents(string: self.addressURL)
        let request = URLRequest(url: (components?.url)!)
        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            guard let data = data else { return }
            self.array = try! JSONSerialization.jsonObject(with: data) as! [[String : Any]]
            if let array = UserDefaults.standard.value(forKey: "array") as? [Int]
            {
                for item in self.array
                {
                    if array.contains(Int(item["ID"] as! String) ?? 0)
                    {
                        self.favorites.append(item)
                    }
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        task.resume()
    }
    
    func setupCollectionView()
    {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let width = (self.view.frame.size.width - 3*10)/2
        layout.itemSize = CGSize(width: width, height: width*2)
        self.collectionView.collectionViewLayout = layout
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: "WallpaperCollectionViewCell", bundle:bundle)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "wallpaper-cell")
        
        self.getPhotos()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let cell = sender as? UICollectionViewCell,
           let indexPath = self.collectionView.indexPath(for: cell)
        {
            let gallery = segue.destination as! WallpaperGalleryVC
            gallery.currentWallpaper = self.favorites[indexPath.row]
        }
    }
    
    @IBAction func onDismiss(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onSave(sender:UIButton)
    {
        let item = self.favorites[sender.tag]
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
            let title = item["title"] as! String
            let filePath = folderPath!.appendingPathComponent(title)
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

extension WallpaperFavoriteVC : UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let item = self.favorites[indexPath.row]
        let bundle = Bundle(for: type(of:self))
        let storyBoard = UIStoryboard(name: "Main", bundle: bundle)
        let objVC = storyBoard.instantiateViewController(withIdentifier: "Gallery") as! WallpaperGalleryVC
        objVC.currentWallpaper = item
        self.present(objVC, animated: true, completion: nil)
    }
}

extension WallpaperFavoriteVC : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : WallpaperCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaper-cell", for: indexPath) as! WallpaperCollectionViewCell

        let item = self.favorites[indexPath.row]
        
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
            let folderPath = dirPath.appendingPathComponent("thumbnail") as NSString?
            if !FileManager.default.fileExists(atPath: folderPath! as String)
            {
                try! FileManager.default.createDirectory(atPath: folderPath! as String, withIntermediateDirectories: true, attributes: nil)
            }
            let title = item["title"] as! String
            let filePath = folderPath!.appendingPathComponent(title)
            if (FileManager.default.fileExists(atPath: filePath))
            {
                cell.imageView.image = UIImage(contentsOfFile: filePath)
            }
            else
            {
                DispatchQueue.global().async {
                    let thumbnail = item["thumbnail"] as! String
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
}
