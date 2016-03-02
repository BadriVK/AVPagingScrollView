//
//  AVPagingScrollView.swift
//  AVPagingScrollView
//
//  Created by Arpit Vishwakarma on 01/03/16.
//  Copyright © 2016 Arpit Vishwakarma. All rights reserved.
//  https://github.com/arpitVishwakarma/AVPagingScrollView.git

import UIKit

class AVPageView: UILabel {

    /*!
    Set page index
    - parameter newIndex: newIndex object
    */
    
    func setPageIndex(newIndex: NSInteger){
        print(newIndex)
        self.text = NSString(format: "%u", newIndex)as String
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.opaque = true;
        self.backgroundColor = self.getRandomColor()        
        self.textColor = UIColor.whiteColor();
        self.textAlignment = NSTextAlignment.Center;
        self.font = UIFont.boldSystemFontOfSize(36);
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    /*!
      Get random color 
    
    - returns: get generated color
    */
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }

}
