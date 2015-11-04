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
        self.pageControl.numberOfPages = 5;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ViewController: LoopBannerViewDataSource {
    func numberOfBannersInLoopBannerView(loopBannerView: LoopBannerView) -> Int {
        return 5
    }
    
    func loopBannerView(loopBannerView: LoopBannerView, bannerForIndex index: Int) -> UIView {
        let colors = [UIColor.grayColor(), UIColor.lightGrayColor(), UIColor.redColor(), UIColor.blueColor(), UIColor.purpleColor()]
        
        return {
            let view = UIView()
            view.backgroundColor = colors[index]
            return view
            }()
    }
    
    func loopBannerView(loopBannerView: LoopBannerView, didScrollToIndex index: Int) {
        self.pageControl.currentPage = index
    }
}


