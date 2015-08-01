//
//  KCCScrollViewContext.h
//  KCCScrollViewContext
//
//  Created by Steven Grace on 6/15/15.
//  Copyright (c) 2015 Steven Grace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol KCCScrollViewContextDelegate;



@interface KCCScrollViewContext : NSObject <UIScrollViewDelegate,UITableViewDelegate, UICollectionViewDelegate>


- (instancetype)initWithScrollView:(UIScrollView *)scrollView andDelegate:(id<KCCScrollViewContextDelegate>)delegate;

@property (nonatomic, readonly, weak) UIScrollView *scrollView;
@property (nonatomic, readonly, weak) id<KCCScrollViewContextDelegate> scrollDelegate;

// Max contentOffset calculated from the ContentSize and ScrollView Frame
@property (nonatomic, readonly, assign) CGPoint maxOffset;
// YES when scrolling because of user interaction or animation
@property (nonatomic, readonly, assign) BOOL isScrolling;
// YES when using the UIScrollView animation methods
@property (nonatomic, readonly, assign) BOOL isAnimating;

// last recorded location of the UIScrollView panGesture
@property (nonatomic, readonly ,assign) CGPoint lastKnownTrackingPoint;


/* Calculated Scrolling Points */

// set when the user begins dragging
@property (nonatomic, readonly, assign) CGPoint scrollingBeganOffset;
// (NAN,NAN) when not scrolling or dragging. Updated once the user has stopped dragging
// and UIScrollgView has been given a chance to caluculate a final offset
@property (nonatomic, readonly, assign) CGPoint expectedScrollingEndOffset;
// ContentOffset when the scrolling last stopped
@property (nonatomic, readonly, assign) CGPoint scrollingEndedOffset;


/* Scrolling Direction */

// Valid when UIScrollView isScrolling otherwise UIRectEdgeNone
@property (nonatomic, readonly, assign) UIRectEdge scrollingToHorizontalEdge;
@property (nonatomic, readonly, assign) UIRectEdge scrollingToVerticalEdge;


/* ZOOM */

// set at UIScrollView's callback  @selector(scrollViewWillBeginZooming:withView:)
@property (nonatomic, readonly, assign) CGFloat zoomingBeganScale;

/* Animation */

// Completion block is copied and released once animation completes
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated complete:(void (^)(void))complete;
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated complete:(void (^)(void))complete;


// Margin for a given point and edge in the UIScrollView space including contentInset
- (CGFloat)contentMarginForOffset:(CGPoint)point fromEdge:(UIRectEdge)edge;

@end


@protocol KCCScrollViewContextDelegate <UITableViewDelegate,UICollectionViewDelegate,UITextViewDelegate>

@optional

/* Scroll Intent */

// called after a UIScrollView has calculated a final content offset
- (void)scrollViewWillScroll:(KCCScrollViewContext *)context toOffset:(CGPoint)offset;
// called once UIScrollView has stopped
- (void)scrollViewDidScroll:(KCCScrollViewContext *)context toOffset:(CGPoint)offset;

/* Content Edge */

// called at End Dragging and end of scrolling based on calculated offsets
- (void)scrollViewWillScroll:(KCCScrollViewContext *)context toContentEdge:(UIRectEdge)edge;
- (void)scrollViewDidScroll:(KCCScrollViewContext *)context toContentEdge:(UIRectEdge)edge;

/* Bounce */

// called before UIScrollView deceleration begins and UIScrollView will 'bounce' in respose to the calculated offset
- (void)scrollViewWillBounce:(KCCScrollViewContext *)context toEdge:(UIRectEdge)edge;
// called after UIScrollView stopped scrolling and after a 'bounce'
- (void)scrollViewDidBounce:(KCCScrollViewContext *)context fromEdge:(UIRectEdge)edge;


/* Zoom */

// called when the zoom interaction begins at the MIN or MAX zoom scale and continues to less than or greated than that scale.
- (void)scrollViewDidZoomPastMinimumScale:(KCCScrollViewContext *)context;
- (void)scrollViewDidZoomPastMaximumScale:(KCCScrollViewContext *)context;

@end


// Description Support
NSString* KCC_NSStringFromUIRectEdge(UIRectEdge edge);
