//
//  AVPagingScrollView.swift
//  AVPagingScrollView
//
//  Created by Arpit Vishwakarma on 01/03/16.
//  Copyright © 2016 Arpit Vishwakarma. All rights reserved.
//  https://github.com/arpitVishwakarma/AVPagingScrollView.git

import UIKit

@objc protocol AVPagingScrollViewDelegate: NSObjectProtocol {
    
    /*!
    * Asks the delegate to return the number of pages.
    */
    func numberOfPagesInPagingScrollView(sender : AVPagingScrollView) -> NSInteger
    
    /*!
    * Asks the delegate for a page to insert. The delegate should ask for a
    * reusable view using dequeueReusablePageView.
    */
    
    func pagingScrollView(pagingScrollView : AVPagingScrollView ,pageForIndex index:NSInteger) -> UIView
}


class AVPage: NSObject {
    
    var view: UIView!
    var index: NSInteger!
    
    override init() {
        super.init()
    }
}

/*!
* A paging scroll view that employs a reusable page mechanism like UITableView.
*
* AVPagingScrollView allows you to show partial previews of the pages to the
* left and right of the current page. The bounds of the scroll view always 
* correspond to a single page. To allow these previews, make the scroll view
* smaller to make room for the preview pages and set the previewInsets
* property.
*/

class AVPagingScrollView: UIScrollView {

    var _recycledPages: NSMutableSet = []
    var _visiblePages: NSMutableSet = []
    var _firstVisiblePageIndexBeforeRotation: NSInteger!  // for autorotation
    var _percentScrolledIntoFirstVisiblePage: CGFloat! 

    /*! The delegate for paging events. */
    @IBOutlet weak var pagingDelegate: AVPagingScrollViewDelegate?
    // var delegate:AVPagingScrollViewDelegate! = nil
    
    /*! The width of the preview pages. */
     var previewInsets: UIEdgeInsets!
    
    override init(frame: CGRect) {
       
        super.init(frame: frame)
        commonInit()
    }
    
    /*!
    Call initWithCoder
    - parameter aDecoder: aDecoder object
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    func commonInit(){
        
        _recycledPages = NSMutableSet()
        _visiblePages = NSMutableSet()
        
        self.pagingEnabled = true;
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.contentOffset = CGPointZero;
    }
    
    
    func pointInside(point: CGPoint, event:UIEvent) -> Bool{
        
        // This allows for touch handling outside of the scroll view's bounds.
        let parentLocation:CGPoint = self.convertPoint(point, toView: self.superview)
        
        var responseRect: CGRect = self.frame
        responseRect.origin.x -= previewInsets.left
        responseRect.origin.y -= previewInsets.top
        responseRect.size.width += (previewInsets.left + previewInsets.right)
        responseRect.size.height += (previewInsets.top + previewInsets.bottom)
        return CGRectContainsPoint(responseRect, parentLocation)
        
    }
    
    /*!
    * Makes the page at the requested index visible.
    */
    func selectPageAtIndex(index:NSInteger, animated:Bool){
       
        let newContentOffset:CGPoint = CGPointMake(self.bounds.size.width * CGFloat(index), 0)
        self.tilePagesAtPoint(newContentOffset)
        if (animated)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(3.0)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        }
        
        self.contentOffset = newContentOffset;
        if (animated){
            UIView.commitAnimations();
        }

    }
    
    /*!
    * Returns the index of the page that is currently visible.
    */
    func indexOfSelectedPage() -> NSInteger{
      
        let width:CGFloat = self.bounds.size.width;
        let currentPage:NSInteger = NSInteger((self.contentOffset.x + width/2.0) / width);
        return currentPage;
    }
    
    /*!
    * Returns the currently visible page.
    */
    func selectedPage() -> UIView?{
        
        let array:NSArray = _visiblePages.allObjects;
        for page:AVPage in array as! [AVPage] {
            if page.index == self.indexOfSelectedPage() {
                return page.view
            }else{
                return nil
            }
        }
        return nil

    }
    
    /*!
    * Returns a reusable UIView object.
    */
    func dequeueReusablePage() -> UIView?{
        
        let page = _recycledPages.anyObject() 
       
        if (page != nil) {
            let view:UIView = page!.view
            _recycledPages.removeObject(page!)
            return view;
        }else{
            return nil
        }
    }
    
    func frameForPageAtIndex(index:NSInteger) -> CGRect {
        var rect:CGRect = self.bounds;
        rect.origin.x = rect.size.width * CGFloat(index);
        return rect;
    }
    
    func tilePagesAtPoint(newOffset:CGPoint) {
        
        let pageWidth:CGFloat = self.bounds.size.width;
        let minX:CGFloat = newOffset.x - previewInsets.left;
        let  maxX:CGFloat = newOffset.x + pageWidth + previewInsets.right - 1.0;
    
        let min1 = NSInteger(minX / pageWidth)
        let max1 = NSInteger(maxX / pageWidth)

        let firstNeededPageIndex = max(min1, 0)
        let lastNeededPageIndex = min(max1, self.numberOfPages() - 1);
    
        let array:NSArray = _visiblePages.allObjects;
        for page:AVPage in array as! [AVPage] {
            
            if page.index < firstNeededPageIndex || page.index > lastNeededPageIndex{
                _recycledPages.addObject(page)
                page.view.removeFromSuperview()
            }
        }
        
        _visiblePages.minusSet(_recycledPages as Set<NSObject>)
        for var i = firstNeededPageIndex; i <= lastNeededPageIndex; ++i {
           
            if !self.isDisplayingPageForIndex(i){
                
                let pageView:UIView = pagingDelegate!.pagingScrollView(self, pageForIndex: i)
                pageView.frame = self.frameForPageAtIndex(i)
                pageView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
                self.addSubview(pageView)
                
                let page:AVPage = AVPage()
                page.index = i;
                page.view = pageView;
                _visiblePages.addObject(page)
            }
        }
    }

    
    func numberOfPages() -> NSInteger {
      
        return (pagingDelegate?.numberOfPagesInPagingScrollView(self))!
    }
    
    
    func isDisplayingPageForIndex(index:NSInteger) -> Bool {
    
        var boolFlag:Bool = false
        let array:NSArray = _visiblePages.allObjects;
        for page:AVPage in array as! [AVPage] {
            if (page.index == index){
                boolFlag = true;
                break
            }
        }
        return boolFlag
    }
     
    /*!
    * Reloads the pages. Call this method when the number of pages has changed.
    */
    func reloadPages(){
      
        self.contentSize = self.contentSizeForPagingScrollView()
        self.tilePagesAtPoint(self.contentOffset)
    }
    
    func contentSizeForPagingScrollView() -> CGSize {
        let rect:CGRect = self.bounds;
        return CGSizeMake(rect.size.width * CGFloat(self.numberOfPages()), rect.size.height)
    }
    
 
    /*!
    * Call this from your view controller's UIScrollViewDelegate.
    */
    func scrollViewDidScroll(){
        self.tilePagesAtPoint(self.contentOffset)
    }
    
    /*!
    * Call this from your view controller's willRotateToInterfaceOrientation if
    * you want to support autorotation.
    */
    func beforeRotation(){
        
        let offset:CGFloat = self.contentOffset.x
        let pageWidth:CGFloat = self.bounds.size.width
        
        if offset >= 0{
            _firstVisiblePageIndexBeforeRotation = NSInteger(floorf(Float(offset) / Float(pageWidth)));
        }else{
            _firstVisiblePageIndexBeforeRotation = 0;
           
        }
         _percentScrolledIntoFirstVisiblePage = offset / pageWidth - CGFloat(_firstVisiblePageIndexBeforeRotation)
    }
    
    /*!
    * Call this from your view controller's willAnimateRotationToInterfaceOrientation
    * if you want to support autorotation.
    */
    func afterRotation(){
       
        self.contentSize = self.contentSizeForPagingScrollView()
        
        let array:NSArray = _visiblePages.allObjects
        for page:AVPage in array as! [AVPage] {
            page.view.frame = self.frameForPageAtIndex(page.index)
        }
        
        let pageWidth:CGFloat = self.bounds.size.width
        let newOffset:CGFloat = (CGFloat(_firstVisiblePageIndexBeforeRotation) + _percentScrolledIntoFirstVisiblePage) * pageWidth
        self.contentOffset = CGPointMake(newOffset, 0);
       
    }
    
    /*!
    * Call this from your view controller's didReceiveMemoryWarning.
    */
    func didReceiveMemoryWarning(){
        _recycledPages.removeAllObjects();

    }
    
   
}
