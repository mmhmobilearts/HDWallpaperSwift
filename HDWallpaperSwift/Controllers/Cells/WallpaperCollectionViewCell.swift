//
//  VideoCollectionViewCell.swift
//  WallpaperHD
//
//  Created by WallpaperHD on 22/04/2021.
//

import Foundation
import UIKit

class WallpaperCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifer = "wallpaper-cell"
    
    @IBOutlet var imageView: UIImageView!
    {
        didSet {
            imageView.layer.borderWidth = 1.5
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet var favbutton: UIButton!
    @IBOutlet var savbutton: UIButton!

    @IBAction func addToFavorite(_ sender: UIButton)
    {
        if var array = UserDefaults.standard.value(forKey: "array") as? [Int]
        {
            if array.contains(sender.tag)
            {
                if let index = array.firstIndex(of: sender.tag)
                {
                    array.remove(at: index)
                    UserDefaults.standard.set(array, forKey: "array")
                }
            }
            else
            {
                array.append(sender.tag)
                UserDefaults.standard.set(array, forKey: "array")
            }
        }
        else
        {
            let array = [sender.tag]
            UserDefaults.standard.set(array, forKey: "array")
        }
        let collectionView = self.superview as! UICollectionView
        collectionView.reloadData()
    }
}
