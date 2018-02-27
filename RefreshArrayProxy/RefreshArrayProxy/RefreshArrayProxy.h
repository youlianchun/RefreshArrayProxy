//
//  RefreshArrayProxy.h
//  RefreshArrayProxy
//
//  Created by YLCHUN on 2017/12/6.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark - RefreshSet (struct)

typedef struct RefreshSet {
    NSUInteger startPage;//起始页码
    NSUInteger pageSize;//分页大小，pageSize < 1 时候只有一页（footer为false时候会默认置0）
    BOOL header; //是否有下拉刷新
    BOOL footer; //是否有上拉加载 （pageSize < 1 时候会默认置false）
} RefreshSet;

extern RefreshSet RefreshSetMake(BOOL header, BOOL footer, NSUInteger startPage, NSUInteger pageSize);

#pragma mark - RefreshArrayProxy (Delegate)

@class UIScrollView;
typedef UIScrollView RefreshView;

@protocol RefreshArrayProxyDelegate <NSObject>

/**
 加载完成
 
 @param view 加载页
 @param page 加载结果
 @param firstPage 是否第一页
 @param netRes arr 网络请求数组 isOK 网络状态，false时候不执行其它操作
 */
-(void)loadDataInRefreshView:(RefreshView*)view page:(NSUInteger)page firstPage:(BOOL)firstPage res:(void(^)(NSArray* arr, BOOL isOK))netRes;

/**
 *  设置刷新项
 *
 *  @return return value description
 */
-(RefreshSet)refreshSetWithRefreshView:(RefreshView*)view;

@optional
/**
 加载完成
 
 @param view 加载页
 @param page 加载结果
 @param firstPage 是否第一页
 */
-(void)didLoadDataInRefreshView:(RefreshView*)view page:(NSUInteger)page firstPage:(BOOL)firstPage;

/**
 *  没有数据
 *
 *  @param isEmpty true时候没有数据
 */
-(void)emptyDataArrayInRefreshView:(RefreshView*)view isEmpty:(BOOL)isEmpty;

@end

#pragma mark - RefreshArrayProxy (Proxy)
@class RefreshArray;

@interface RefreshArrayProxy<ObjectType> : NSProxy
+ (RefreshArray*)proxyWithRefreshView:(RefreshView*)view delegate:(id<RefreshArrayProxyDelegate>)delegate;
@end


#pragma mark - RefreshArray (Interface)
@interface RefreshArray<ObjectType>: NSMutableArray<ObjectType>

-(void)setHidenFooterAtFirstPageWhen1PageSize:(BOOL (^)(RefreshArrayProxy *))hidenFooterAtFirstPageWhen1PageSize;

/**
 *  请求下一页数据，没有分页时候且第一页已经请求完成后不执行
 */
-(void)loadNextPageData;
/**
 *  下拉刷新,第一次请求数据时候若不需要动画时候使用 nextPage
 *
 *  @param animate true 时候有下拉效果
 */
-(void)reloadDataWithAnimate:(BOOL)animate;

@end;


