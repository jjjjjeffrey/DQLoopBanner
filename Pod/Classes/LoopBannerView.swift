//
//  LoopBannerView.swift
//  Pods
//
//  Created by Jeffrey on 15/11/4.
//
//

import UIKit

public class LoopBannerView: UIView, UIScrollViewDelegate {
    
    lazy private var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.pagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        return view
    }()

    weak public var dataSource: LoopBannerViewDataSource? {
        didSet {
            guard let numberOfBanners = dataSource?.numberOfBannersInLoopBannerView(self) else { return }
            for index in 0..<numberOfBanners+2 {
                switch index {
                case 0:
                    let bannerView = dataSource!.loopBannerView(self, bannerForIndex: numberOfBanners-1)
                    self.scrollView.addSubview(bannerView)
                case numberOfBanners+2-1:
                    let bannerView = dataSource!.loopBannerView(self, bannerForIndex: 0)
                    self.scrollView.addSubview(bannerView)
                default:
                    let bannerView = dataSource!.loopBannerView(self, bannerForIndex: index-1)
                    self.scrollView.addSubview(bannerView)
                }
            }
        }
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.initSubViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initSubViews()
    }
    
    private func initSubViews() {
        self.addSubview(scrollView)
    }
    
    override public func layoutSubviews() {
        let width = CGRectGetWidth(self.frame)
        let height = CGRectGetHeight(self.frame)
        
        self.scrollView.frame = CGRectMake(0, 0, width, height);
        for (index, view) in self.scrollView.subviews.enumerate() {
            view.frame = CGRectMake(CGFloat(index)*width, 0, width, height)
        }
        self.scrollView.contentSize = CGSizeMake(CGFloat(self.scrollView.subviews.count)*width, height)
        self.scrollView.contentOffset.x = width
        self.sendSubviewToBack(self.scrollView)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let width = CGRectGetWidth(self.frame)
        if scrollView.contentOffset.x == 0 {
            scrollView.contentOffset.x = CGFloat(scrollView.subviews.count-2)*width
        }
        if scrollView.contentOffset.x == CGFloat(scrollView.subviews.count-1)*width {
            scrollView.contentOffset.x = width
        }
        switch scrollView.contentOffset.x {
        case 0:
            self.dataSource?.loopBannerView?(self, didScrollToIndex: self.scrollView.subviews.count-2-1)
        case CGFloat(scrollView.subviews.count-1)*width:
            self.dataSource?.loopBannerView?(self, didScrollToIndex: 0)
        default:
            let index = Int(scrollView.contentOffset.x/width)
            self.dataSource?.loopBannerView?(self, didScrollToIndex: index-1)
        }
    }

}

@objc public protocol LoopBannerViewDataSource: NSObjectProtocol {
    func numberOfBannersInLoopBannerView(loopBannerView: LoopBannerView) -> Int
    func loopBannerView(loopBannerView: LoopBannerView, bannerForIndex index: Int) -> UIView
    optional func loopBannerView(loopBannerView: LoopBannerView, didScrollToIndex index: Int)
}
