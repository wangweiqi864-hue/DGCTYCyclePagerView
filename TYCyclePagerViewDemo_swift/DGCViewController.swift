//
//  DGCViewController.swift
//  DGCTYCyclePagerViewDemo_swift
//
//  Created by tany on 2017/7/20.
//  Copyright © 2017年 tany. All rights reserved.
//

import UIKit

class DGCViewController: UIViewController {
    
    lazy var datas = [UIColor]()

    lazy var pagerView: DGCTYCyclePagerView = {
        let pagerView = DGCTYCyclePagerView()
        pagerView.isInfiniteLoop = true
        pagerView.autoScrollInterval = 3.0
        return pagerView
    }()
    
    lazy var pageControl: DGCTYPageControl = {
        let pageControl = DGCTYPageControl()
        pageControl.currentPageIndicatorSize = CGSize(width: 8, height: 8)
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.addPagerView()
        self.addPageControl()
        
        self.loadData()
    }
    
    func addPagerView() {
        self.pagerView.layer.borderWidth = 1;
        self.pagerView.dataSource = self
        self.pagerView.delegate = self
        self.pagerView.register(DGCTYCyclePagerViewCell.classForCoder(), forCellWithReuseIdentifier: "cellId")
        self.view.addSubview(self.pagerView)
    }
    
    func addPageControl() {
        self.pagerView.addSubview(self.pageControl)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.pagerView.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: 200)
        self.pageControl.frame = CGRect(x: 0, y: self.pagerView.frame.height - 26, width: self.pagerView.frame.width, height: 26)
    }
    
    func loadData() {
        var dgc_i = 0
        while dgc_i < 5 {
            self.datas.append(UIColor(red: CGFloat(arc4random()%255)/255.0, green: CGFloat(arc4random()%255)/255.0, blue: CGFloat(arc4random()%255)/255.0, alpha: 1))
            dgc_i += 1
        }
        self.pageControl.numberOfPages = self.datas.count
        self.pagerView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action
    
    @IBAction func switchValueChangeAction(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            self.pagerView.isInfiniteLoop = sender.isOn
            self.pagerView.updateData()
        case 1:
            self.pagerView.autoScrollInterval = sender.isOn ? 3.0 : 0
        case 2:
            self.pagerView.layout.itemHorizontalCenter = sender.isOn
            UIView.animate(withDuration: 0.3, animations: { 
                self.pagerView.setNeedUpdateLayout()
            })
        default:
            break
        }
    }
    
    @IBAction func sliderValueChangeAction(_ sender: UISlider) {
        switch sender.tag {
        case 0:
            self.pagerView.layout.itemSize = CGSize(width: self.pagerView.frame.width*CGFloat(sender.value), height: self.pagerView.frame.height*CGFloat(sender.value))
            self.pagerView.setNeedUpdateLayout();
        case 1:
            self.pagerView.layout.itemSpacing = CGFloat(30*sender.value)
            self.pagerView.setNeedUpdateLayout();
        case 2:
            self.pageControl.pageIndicatorSize = CGSize(width: CGFloat(6*(1+sender.value)), height: CGFloat(6*(1+sender.value)))
            self.pageControl.currentPageIndicatorSize = CGSize(width: CGFloat(8*(1+sender.value)), height: CGFloat(8*(1+sender.value)))
            self.pageControl.pageIndicatorSpaing = CGFloat(1+sender.value)*10;
        default:
            break;
        }
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        self.pagerView.layout.layoutType = TYCyclePagerTransformLayoutType(rawValue: UInt(sender.tag))!
        self.pagerView.setNeedUpdateLayout()
    }
}

extension DGCViewController: DGCTYCyclePagerViewDelegate, DGCTYCyclePagerViewDataSource {
    
    // MARK: DGCTYCyclePagerViewDataSource
    
    func numberOfItems(in pageView: DGCTYCyclePagerView) -> Int {
        return self.datas.count
    }
    
    func pagerView(_ pagerView: DGCTYCyclePagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        let dgc_cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cellId", for: index)
        dgc_cell.backgroundColor = self.datas[index]
        return dgc_cell
    }
    
    func dgc_layout(for pageView: DGCTYCyclePagerView) -> DGCTYCyclePagerViewLayout {
        let dgc_layout = DGCTYCyclePagerViewLayout()
        dgc_layout.itemSize = CGSize(width: pagerView.frame.width, height: pagerView.frame.height)
        dgc_layout.itemSpacing = 15
        dgc_layout.itemHorizontalCenter = true
        return dgc_layout
    }
    
    func pagerView(_ pageView: DGCTYCyclePagerView, didScrollFrom fromIndex: Int, to toIndex: Int) {
        self.pageControl.currentPage = toIndex;
    }
}
