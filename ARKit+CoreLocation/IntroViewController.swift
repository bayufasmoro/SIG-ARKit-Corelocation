//
//  IntroViewController.swift
//  ARKit+CoreLocation
//
//  Created by MF839 on 20/06/19.
//  Copyright © 2019 Project Dent. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = 3
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//        self.navigationController?.navigationBar.shadowImage = nil
//        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    // MARK: - CollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "introCell", for: indexPath)
        
        let textLabel = cell.viewWithTag(1) as! UILabel
        let nextButton = cell.viewWithTag(2) as! UIButton
        
        if (indexPath.item == 0) {
            textLabel.text = "Sekarang Anda dapat melihat rute map melalui kamera Anda sendiri menggunakan AR."
            nextButton.isHidden = true
        } else if (indexPath.item == 1) {
            textLabel.text = "Cukup pilih menu rute lalu masukkan alamat yang Anda tuju."
            nextButton.isHidden = true
        } else {
            textLabel.text = "Berhati-hatilah agar tidak menabrak yang ada di sekeliling Anda."
            nextButton.isHidden = false
        }
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        return CGSize(width: screenSize.width, height: 200)
    }
    
    // MARK: - Actions
    
    @objc func nextButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showMain", sender: self)
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = collectionView.contentOffset.x/scrollView.frame.size.width
        pageControl.currentPage = Int(page)
    }

}
