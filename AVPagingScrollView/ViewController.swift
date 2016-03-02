//
//  ViewController.swift
//  AVPagingScrollView
//
//  Created by Arpit Vishwakarma on 01/03/16.
//  Copyright © 2016 Arpit Vishwakarma. All rights reserved.
//  https://github.com/arpitVishwakarma/AVPagingScrollView.git


import UIKit
import Foundation

let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height

class ViewController: UIViewController, AVPagingScrollViewDelegate, UIScrollViewDelegate {

    
    var pagingScrollView: AVPagingScrollView!
    var pageControl:UIPageControl!
    var vwObj:UIView!

    var _numPages:NSInteger = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _numPages = 5
    }

    override func viewDidAppear(animated: Bool) {
        
        self.pageControl = UIPageControl(frame: CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40))
        self.vwObj = UIView(frame: CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64))
        self.pagingScrollView = AVPagingScrollView(frame: vwObj.bounds)

        self.pageControl.backgroundColor = UIColor.clearColor()
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pagingScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.vwObj.translatesAutoresizingMaskIntoConstraints = false
        
        self.vwObj.addSubview(self.pagingScrollView)
        self.view.addSubview(self.vwObj)
        self.view.addSubview(self.pageControl)

        self.createConstraints()
        
        self.pagingScrollView.previewInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.pagingScrollView.pagingDelegate = self
        self.pagingScrollView.delegate = self
        
        self.pagingScrollView.reloadPages();
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = _numPages;
        self.vwObj.backgroundColor = UIColor.clearColor()
             
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*!
    Get the device rotation to update constraints
    */
    func rotated(){
     
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {            
            print("landscape")
            self.removeAllConstraints()
            self.createConstraints()
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            print("Portrait")
            self.removeAllConstraints()
            self.createConstraints()
        }
    }
    
    /*!
    Remove all added constraints
    */
    func removeAllConstraints() -> Void {
        
        self.view.removeConstraints(self.vwObj.constraints)
        self.view.removeConstraints(self.pageControl.constraints)
        self.view.removeConstraints(self.pagingScrollView.constraints)
    }
    
    /*!
    Add new constraints for the view
    */
    func createConstraints() -> Void
    {
        //Views to add constraints to
        let views = Dictionary(dictionaryLiteral: ("vwObj",vwObj),("pagingScrollView",pagingScrollView),("pageControl",pageControl))
        
        //Horizontal constraints
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[vwObj]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(horizontalConstraints)
        
        //Vertical constraints
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[vwObj]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(verticalConstraints)
        
        
        //Horizontal constraints
        let horizontalConstraints1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|[pagingScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(horizontalConstraints1)
        
        //Vertical constraints
        let verticalConstraints1 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[pagingScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(verticalConstraints1)
        
        //Horizontal constraints
        let horizontalConstraints2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[pageControl]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(horizontalConstraints2)
        
        //Vertical constraints
        let verticalConstraints2 = NSLayoutConstraint.constraintsWithVisualFormat("V:[pageControl(==30)]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(verticalConstraints2)
        
    }
    
    /*!
    * Asks the delegate to return the number of pages.
    */
    func numberOfPagesInPagingScrollView(sender : AVPagingScrollView) -> NSInteger{
        return _numPages;
    }
    
    /*!
    * Asks the delegate for a page to insert. The delegate should ask for a
    * reusable view using dequeueReusablePageView.
    */
    
    func pagingScrollView(pagingScrollView : AVPagingScrollView ,pageForIndex index:NSInteger) -> UIView{
        
        var pageView = pagingScrollView.dequeueReusablePage() as? AVPageView
        if (pageView == nil){
            pageView = AVPageView()
        }
        pageView?.setPageIndex(index)
        return pageView!;
    }
    
    @IBAction func turnPage(){
        self.pagingScrollView.selectPageAtIndex(self.pageControl.currentPage, animated: true)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.pagingScrollView.beforeRotation()
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.pagingScrollView.afterRotation()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.pageControl.currentPage < _numPages{
            self.pageControl.currentPage = self.pagingScrollView.indexOfSelectedPage()
            self.pagingScrollView.scrollViewDidScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if (self.pagingScrollView.indexOfSelectedPage() == _numPages - 1)
        {
            self.pagingScrollView.reloadPages()
            self.pageControl.numberOfPages = _numPages;
        }
    }
}

