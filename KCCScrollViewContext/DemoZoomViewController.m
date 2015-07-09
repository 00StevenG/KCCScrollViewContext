//
//  DemoZoomViewController.m
//  ScrollViewContext
//
//
//  Created by Steven Grace on 6/15/15.
//  Copyright (c) 2015 Steven Grace. All rights reserved.
//


#import "DemoZoomViewController.h"
#import "KCCScrollViewContext.h"


@interface DemoZoomViewController () <KCCScrollViewContextDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, readwrite, strong) KCCScrollViewContext *context;


@end

@implementation DemoZoomViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[KCCScrollViewContext alloc]initWithScrollView:self.scrollView andDelegate:self];
}

#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"%s : ZoomBegan: %f Current: %f",__PRETTY_FUNCTION__,self.context.zoomingBeganScale,self.context.scrollView.zoomScale);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.imageView.alpha = 1;
}

#pragma mark - KCCScrollViewContextDelegate

- (void)scrollViewWillBounce:(KCCScrollViewContext *)context toEdge:(UIRectEdge)edge {
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));
}

- (void)scrollViewDidBounce:(KCCScrollViewContext *)context fromEdge:(UIRectEdge)edge {
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));
}

- (void)scrollViewDidZoomPastMinimumScale:(KCCScrollViewContext *)context {
    NSLog(@"%s ZoomBegan: %f Current: %f ",__PRETTY_FUNCTION__,self.context.zoomingBeganScale,context.scrollView.zoomScale);
    self.imageView.alpha = context.scrollView.zoomScale/4;
}

- (void)scrollViewDidZoomPastMaximumScale:(KCCScrollViewContext *)context {
    NSLog(@"%s ZoomBegan: %f Current: %f ",__PRETTY_FUNCTION__,self.context.zoomingBeganScale,context.scrollView.zoomScale);
}


@end
