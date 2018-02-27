//
//  RefreshActionView.m
//  RefreshArrayProxy
//
//  Created by YLCHUN on 2017/12/6.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import "RefreshActionView.h"

inline MJRefreshHeader *refreshHeader(void(^action)(void)) {
    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        if (action) {
            action();
        }
    }];
    return header;
}


inline MJRefreshFooter *refreshFooter(void(^action)(void)) {
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (action) {
            action();
        }
    }];
    return footer;
}

