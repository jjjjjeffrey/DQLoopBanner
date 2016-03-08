//
//  LoopBannerView.swift
//  Pods
//
//  Created by Jeffrey on 15/11/4.
//
//

import UIKit

public class LoopBannerView: UIView {
    
    public var pageIndex: Int {
        didSet {
            self.scrollView.contentOffset.x = self.bannerWidth * CGFloat(self.pageIndex+1)
        }
    }
    
    private var bannerWidth: CGFloat {
        get {
            return CGRectGetWidth(self.frame)
        }
    }
    
    private var bannerHeight: CGFloat {
        get {
            return CGRectGetHeight(self.frame)
        }
    }
    
    lazy private var tapGestureRecognizer: UITapGestureRecognizer = {
       let tap = UITapGestureRecognizer(target: self, action: Selector("tappedBanner:"))
        return tap
    }()
    
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
            reloadData()
        }
    }
    
    required override public init(frame: CGRect) {
        self.pageIndex = 0
        super.init(frame: frame)
        self.initSubViews()

    }

    required public init?(coder aDecoder: NSCoder) {
        self.pageIndex = 0
        super.init(coder: aDecoder)
        self.initSubViews()
    }
    
    private func initSubViews() {
        self.addGestureRecognizer(self.tapGestureRecognizer)
        self.addSubview(scrollView)
    }
    
    override public func layoutSubviews() {
        self.scrollView.frame = CGRectMake(0, 0, self.bannerWidth, self.bannerHeight);
        for (index, view) in self.scrollView.subviews.enumerate() {
            view.frame = CGRectMake(CGFloat(index)*self.bannerWidth, 0, self.bannerWidth, self.bannerHeight)
        }
        self.scrollView.contentSize = CGSizeMake(CGFloat(self.scrollView.subviews.count)*self.bannerWidth, self.bannerHeight)
        self.scrollView.contentOffset.x = self.bannerWidth * CGFloat(self.pageIndex+1)
        self.sendSubviewToBack(self.scrollView)
    }
    
    public func reloadData() {
        guard let numberOfBanners = dataSource?.numberOfBannersInLoopBannerView(self) else { return }
        self.scrollView.subviews.forEach { $0.removeFromSuperview() }
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
        setNeedsLayout()
    }
}

extension LoopBannerView: UIScrollViewDelegate {
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
            self.pageIndex = index-1
            self.dataSource?.loopBannerView?(self, didScrollToIndex: index-1)
        }
    }
}

extension LoopBannerView {
    func tappedBanner(tapGestureRecognizer: UITapGestureRecognizer) {
        self.dataSource?.loopBannerView?(self, didTappedBannerForIndex: self.pageIndex)
    }
}

@objc public protocol LoopBannerViewDataSource: NSObjectProtocol {
    func numberOfBannersInLoopBannerView(loopBannerView: LoopBannerView) -> Int
    func loopBannerView(loopBannerView: LoopBannerView, bannerForIndex index: Int) -> UIView
    optional func loopBannerView(loopBannerView: LoopBannerView, didScrollToIndex index: Int)
    optional func loopBannerView(loopBannerView: LoopBannerView, didTappedBannerForIndex index: Int)
}



