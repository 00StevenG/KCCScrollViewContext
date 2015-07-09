//
//  ViewController.m
//  ScrollViewContext
//
//
//  Created by Steven Grace on 6/15/15.
//  Copyright (c) 2015 Steven Grace. All rights reserved.
//


#import "DemoTableViewController.h"
#import "KCCScrollViewContext.h"
#import "DemoTableCell.h"
#import "DemoTableHeaderView.h"


#define kUVCellActiveHeight 160.f
#define kUVCellDefaultHeight 160.f
#define kUVCellDragInterval 160.f
#define kDragVelocityDampener .85


@interface DemoTableViewController () <KCCScrollViewContextDelegate>

@property (nonatomic, readwrite, strong)KCCScrollViewContext *context;

@end

@implementation DemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[KCCScrollViewContext alloc]initWithScrollView:self.tableView andDelegate:self];
}

#pragma mark - Datasource

+ (UIImage *)imageForIndexPath:(NSIndexPath *)indexPath {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%li.jpg",indexPath.row%10]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    DemoTableHeaderView *header = [[[UINib nibWithNibName:NSStringFromClass([DemoTableHeaderView class]) bundle:nil]instantiateWithOwner:self options:nil]objectAtIndex:0];
    header.sectionLabel.text = [NSString stringWithFormat:@"%li",(long)section];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DemoTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DemoTableCell class]) forIndexPath:indexPath];
    cell.rowLabel.text = [NSString stringWithFormat:@"%li",(long)indexPath.row];
    cell.rowImageView.image = [[self class]imageForIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGPoint offset = [tableView cellForRowAtIndexPath:indexPath].frame.origin;
    offset.y = offset.y - ([self.topLayoutGuide length]+CGRectGetHeight([tableView rectForHeaderInSection:indexPath.section]));
    
    __weak typeof(self) weakSelf = self;
    
    [self.context setContentOffset:offset animated:YES complete:^{
        NSLog(@"Animation complete :%@",NSStringFromCGPoint(weakSelf.context.scrollView.contentOffset));
    }];
}

#pragma mark - KCCScrollViewContextDelegate

- (void)scrollViewWillScroll:(KCCScrollViewContext *)context toContentEdge:(UIRectEdge)edge {
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));
}

- (void)scrollViewDidScroll:(KCCScrollViewContext *)context toContentEdge:(UIRectEdge)edge {
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));
}

- (void)scrollViewWillBounce:(KCCScrollViewContext*)context toEdge:(UIRectEdge)edge{
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));
}

- (void)scrollViewDidBounce:(KCCScrollViewContext*)context fromEdge:(UIRectEdge)edge{
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));
}

- (void)scrollViewWillScroll:(KCCScrollViewContext *)context toOffset:(CGPoint)offset {
    NSLog(@"%s :%@",__PRETTY_FUNCTION__,NSStringFromCGPoint(offset));
}

- (void)scrollViewDidScroll:(KCCScrollViewContext *)context toOffset:(CGPoint)offset {
    NSLog(@"%s :%@",__PRETTY_FUNCTION__,NSStringFromCGPoint(offset));
}

@end
