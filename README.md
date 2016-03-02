## AVPagingScrollView in Swift


## Description
AVPagingScrollView is the subclass of ```UIScrollView``` that shows previews of the pages on the left and right. All views created and constraints handled programmatically.

##Requirements
>Swift 2.0 (Xcode 7+)

>iOS 8+

>ARC

##Usage

A ```UIScrollView``` subclass that shows previews of the pages on the left and right.

```
self.pagingScrollView.previewInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
self.pagingScrollView.pagingDelegate = self
self.pagingScrollView.delegate = self
        
self.pagingScrollView.reloadPages();
self.pageControl.currentPage = 0;
self.pageControl.numberOfPages = _numPages;
 ```

AVPagingScrollView Delegate

```
/*!
* Asks the delegate to return the number of pages.
*/

func numberOfPagesInPagingScrollView(sender : AVPagingScrollView) -> NSInteger

/*!
* Asks the delegate for a page to insert. The delegate should ask for a
* reusable view using dequeueReusablePageView.
*/
 
func pagingScrollView(pagingScrollView : AVPagingScrollView ,pageForIndex index:NSInteger) -> UIView
```
## Author
([@arpitVishwakarma](https://www.twitter.com/arpit_limodia))
