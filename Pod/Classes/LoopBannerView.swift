//
//  LoopBannerView.swift
//  Pods
//
//  Created by Jeffrey on 15/11/4.
//
//

import UIKit

open class LoopBannerView: UIView {
    
    open var pageIndex: Int {
        didSet {
            self.scrollView.contentOffset.x = self.bannerWidth * CGFloat(self.pageIndex+1)
        }
    }
    
    fileprivate var bannerWidth: CGFloat {
        get {
            return self.frame.width
        }
    }
    
    fileprivate var bannerHeight: CGFloat {
        get {
            return self.frame.height
        }
    }
    
    lazy fileprivate var tapGestureRecognizer: UITapGestureRecognizer = {
       let tap = UITapGestureRecognizer(target: self, action: #selector(LoopBannerView.tappedBanner(_:)))
        return tap
    }()
    
    lazy fileprivate var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        return view
    }()

    weak open var dataSource: LoopBannerViewDataSource? {
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
    
    fileprivate func initSubViews() {
        self.addGestureRecognizer(self.tapGestureRecognizer)
        self.addSubview(scrollView)
    }
    
    override open func layoutSubviews() {
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.bannerWidth, height: self.bannerHeight);
        for (index, view) in self.scrollView.subviews.enumerated() {
            view.frame = CGRect(x: CGFloat(index)*self.bannerWidth, y: 0, width: self.bannerWidth, height: self.bannerHeight)
        }
        self.scrollView.contentSize = CGSize(width: CGFloat(self.scrollView.subviews.count)*self.bannerWidth, height: self.bannerHeight)
        self.scrollView.contentOffset.x = self.bannerWidth * CGFloat(self.pageIndex+1)
        self.sendSubview(toBack: self.scrollView)
    }
    
    open func reloadData() {
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
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = self.frame.width
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
    func tappedBanner(_ tapGestureRecognizer: UITapGestureRecognizer) {
        self.dataSource?.loopBannerView?(self, didTappedBannerForIndex: self.pageIndex)
    }
}

@objc public protocol LoopBannerViewDataSource: NSObjectProtocol {
    func numberOfBannersInLoopBannerView(_ loopBannerView: LoopBannerView) -> Int
    func loopBannerView(_ loopBannerView: LoopBannerView, bannerForIndex index: Int) -> UIView
    @objc optional func loopBannerView(_ loopBannerView: LoopBannerView, didScrollToIndex index: Int)
    @objc optional func loopBannerView(_ loopBannerView: LoopBannerView, didTappedBannerForIndex index: Int)
}



