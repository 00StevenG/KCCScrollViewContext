# KCCScrollViewContext

KCCScrollViewContext provides additional UIScrollView state and expands upon UIScrollViewDelegate. It’s simple to add and works with existing messaging from UIScrollViewDelegate and its extended protocols. It features:

* accessors like isScrolling, isAnimating, and current scrolling direction (UIRectEdge) 
* accessors to contentOffset values during scrolling events (scrollingBeganOffset , expectedScrollingEndOffset, scrollingEndedOffset) 
* additional delegate callbacks with content offsets for ‘will scroll’ (calculated)  and ‘did scroll’ (actual),  
* additional delegate callbacks for ‘will scroll’ and ‘did scroll’ events with content edge detection (UIRectEdge) and scrollview bounce events. 
* completion block handlers for UIScrollView’s built in animated methods (setContentOffset:animated: / scrollRectToVisible:animated:) 
* additional zooming callbacks when the user initiates zooming at and past the minimum or maximum zoom scale. 
* UIScrollViewDelegate and it’s extended protocols (UITableViewDelegate and so on) methods are forwarded to the original delegate (such as UITableViewController). 

How to use:

```
- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollContext = [[KCCScrollViewContext alloc]initWithScrollView:self.tableView andDelegate:self];
}
```

Respond to events:

```
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // handle row selection as usual
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // handle UIScrollView messages as usual
}

- (void)scrollViewWillScroll:(KCCScrollViewContext *)context toOffset:(CGPoint)offset { 
  // do something
}

- (void)scrollViewDidBounce:(KCCScrollViewContext *)context fromEdge:(UIRectEdge)edge {
  // do something
}
```

Brief explanation at : http://00steveng.github.io/KCCScrollViewContext

