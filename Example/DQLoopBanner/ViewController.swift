//
//  ViewController.swift
//  DQLoopBanner
//
//  Created by zengdaqian on 11/04/2015.
//  Copyright (c) 2015 zengdaqian. All rights reserved.
//

import UIKit
import DQLoopBanner

class ViewController: UIViewController {
    @IBOutlet var bannerView: LoopBannerView!
    @IBOutlet var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bannerView.dataSource = self
        self.bannerView.pageIndex = 3
        self.pageControl.numberOfPages = 5;
        self.pageControl.currentPage = self.bannerView.pageIndex
        self.bannerView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ViewController: LoopBannerViewDataSource {
    func numberOfBannersInLoopBannerView(_ loopBannerView: LoopBannerView) -> Int {
        return 5
    }
    
    func loopBannerView(_ loopBannerView: LoopBannerView, bannerForIndex index: Int) -> UIView {
        let colors = [UIColor.gray, UIColor.lightGray, UIColor.red, UIColor.blue, UIColor.purple]
        
        return {
            let view = UIView()
            view.backgroundColor = colors[index]
            return view
            }()
    }
    
    func loopBannerView(_ loopBannerView: LoopBannerView, didScrollToIndex index: Int) {
        self.pageControl.currentPage = index
    }
    
    func loopBannerView(_ loopBannerView: LoopBannerView, didTappedBannerForIndex index: Int) {
        print("点击第\(index+1)页")
    }
    
}


