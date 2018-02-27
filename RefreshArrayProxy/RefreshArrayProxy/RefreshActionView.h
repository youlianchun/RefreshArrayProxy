//
//  RefreshActionView.h
//  RefreshArrayProxy
//
//  Created by YLCHUN on 2017/12/6.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import "MJRefresh.h"
#import <MJRefresh/MJRefresh.h>

extern MJRefreshHeader *refreshHeader(void(^action)(void));
extern MJRefreshFooter *refreshFooter(void(^action)(void));
