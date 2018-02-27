//
//  RefreshArrayProxy.m
//  RefreshArrayProxy
//
//  Created by YLCHUN on 2017/12/6.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "RefreshArrayProxy.h"
#import <UIKit/UIKit.h>
#import "RefreshActionView.h"

@interface RefreshArrayProxy()
@property (nonatomic, strong) RefreshView *refreshView;
@property (nonatomic, weak) id<RefreshArrayProxyDelegate> delegate;

@property(nonatomic, assign) RefreshSet refSet;
@property(nonatomic, assign) NSUInteger page;

/**
 数组0元素时候请求Page始终是StartPage，默认false
 */
//@property (nonatomic, assign) BOOL pageIsStartPageWhenEmpty;
@property (nonatomic, copy) BOOL(^hidenFooterAtFirstPageWhen1PageSize)(RefreshArrayProxy *proxy);
@property (nonatomic, readonly) NSMutableArray *mySelf;

@end

inline RefreshSet RefreshSetMake(BOOL header, BOOL footer, NSUInteger startPage, NSUInteger pageSize) {
    RefreshSet refreshSet;
    refreshSet.header = header;
    refreshSet.footer = footer;
    refreshSet.pageSize = pageSize;
    refreshSet.startPage = startPage;
    return refreshSet;
}


@implementation RefreshArrayProxy
{
    NSMutableArray *_array;
}

+ (id)proxyWithRefreshView:(RefreshView*)view delegate:(id<RefreshArrayProxyDelegate>)delegate {
    RefreshArrayProxy *proxy = [self alloc];
    proxy.delegate = delegate;
    proxy.refreshView = view;
    return proxy;
}

+(id)alloc {
    RefreshArrayProxy *proxy = [super alloc];
    proxy->_array = [NSMutableArray array];
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [_array methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:_array];
}

-(NSMutableArray *)mySelf {
    return (NSMutableArray*)self;
}


- (void)ref_addRefreshHeader {
    __weak typeof(self) weakSelf = self;
    MJRefreshHeader *header = refreshHeader(^{
        weakSelf.page = weakSelf.refSet.startPage;
        weakSelf.refreshView.mj_footer.hidden=YES;
        [weakSelf loadNextPageData];
    });
    self.refreshView.mj_header = header;
}

- (void)ref_addRefreshFooter {
    __weak typeof(self) weakSelf = self;
    // 添加传统的上拉刷新
    MJRefreshFooter *footer = refreshFooter(^{
        [weakSelf loadNextPageData];
    });
    self.refreshView.mj_footer = footer;
}

-(void)loadNextPageData {
    if (/*self.pageIsStartPageWhenEmpty &&*/ self.mySelf.count == 0) {
        self.page = self.refSet.startPage;
    }
    __weak typeof(self)wself = self;
    NSAssert(self.delegate, @"delegate unfind");
    NSUInteger page = self.page;
    
    [self.delegate loadDataInRefreshView:self.refreshView page:page firstPage:page == self.refSet.startPage res:^(NSArray *arr, BOOL isOK) {

        BOOL isFristPage = page == wself.refSet.startPage;
        
        if (isOK) {
            if (isFristPage) {
                [wself.mySelf removeAllObjects];
            }
            if (arr.count>0) {
                [wself.mySelf addObjectsFromArray:arr];
            }
            if ([wself.refreshView respondsToSelector:@selector(reloadData)]) {
                [wself.refreshView performSelector:@selector(reloadData)];
            }
            if (isFristPage) {//加载第一页
                if ([wself.delegate respondsToSelector:@selector(emptyDataArrayInRefreshView:isEmpty:)]) {
                    [wself.delegate emptyDataArrayInRefreshView:wself.refreshView isEmpty:arr.count == 0];
                }
                [wself.refreshView.mj_header endRefreshing];
                if (wself.refSet.pageSize>1 && wself.mySelf.count >= wself.refSet.pageSize) {//有多页
                    wself.page = page + 1;
                    wself.refreshView.mj_footer.hidden = NO;
                }else {//只有一页
                    if (wself.hidenFooterAtFirstPageWhen1PageSize && wself.refSet.pageSize == 1) {
                        wself.refreshView.mj_footer.hidden = wself.hidenFooterAtFirstPageWhen1PageSize(wself);
                    }
                }
            }else {
                if (arr.count >= wself.refSet.pageSize) {
                    [wself.refreshView.mj_footer endRefreshing];
                    wself.page = page + 1;
                }else{
                    [wself.refreshView.mj_footer endRefreshingWithNoMoreData];
                }
                wself.refreshView.mj_footer.hidden = NO;
            }
        }else {
            if (isFristPage) {
                [wself.refreshView.mj_header endRefreshing];
            }else {
                [wself.refreshView.mj_footer endRefreshing];
            }
        }
        if ([wself.delegate respondsToSelector:@selector(didLoadDataInRefreshView:page:firstPage:)]) {
            [wself.delegate didLoadDataInRefreshView:wself.refreshView page:page firstPage:page == wself.refSet.startPage];
        }
    }];
}


-(void)reloadDataWithAnimate:(BOOL)animate {
    if (self.refSet.header && animate) {
            [self.refreshView.mj_header beginRefreshing];
    }else{
        self.page = self.refSet.startPage;
        [self loadNextPageData];
    }
}


-(void)setRefreshView:(RefreshView *)refreshView {
    _refreshView = refreshView;
    if (self.refSet.header){
        [self ref_addRefreshHeader];
    }
    if (self.refSet.footer){
        [self ref_addRefreshFooter];
        self.refreshView.mj_footer.hidden = YES;
    }
}

-(void)setDelegate:(id<RefreshArrayProxyDelegate>)delegate {
    _delegate = delegate;
    self.refSet = [self.delegate refreshSetWithRefreshView:self.refreshView];
}

-(void)setRefSet:(RefreshSet)refSet {
    if (!refSet.footer) {//没有下拉加载更多时候pageSize设为0
        refSet.pageSize = 0;
    }else if (refSet.pageSize < 1) {
        refSet.footer = NO;
    }
    _refSet = refSet;
}

@end



