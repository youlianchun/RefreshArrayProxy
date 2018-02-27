//
//  ViewController.m
//  RefreshArrayProxy
//
//  Created by YLCHUN on 2017/12/6.
//  Copyright © 2016年 YLCHUN. All rights reserved.
//

#import "ViewController.h"
#import "RefreshArrayProxy.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,RefreshArrayProxyDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) RefreshArray<NSNumber*>* dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview: self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.dataArray = [RefreshArrayProxy proxyWithRefreshView:self.tableView delegate:self];
    
    [self.dataArray reloadDataWithAnimate:YES];
    // Do any additional setup after loading the view, typically from a nib.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.dataArray[indexPath.row]];
    return cell;
}



-(RefreshSet)refreshSetWithRefreshView:(RefreshView *)view{
    return RefreshSetMake(YES, YES, 1, 10);
}

BOOL netIsOk() {
    static int i = 0;
    i++;
    return i%2 == 0;
}

-(void)loadDataInRefreshView:(RefreshView *)view page:(NSUInteger)page firstPage:(BOOL)firstPage res:(void (^)(NSArray *, BOOL))netRes {
    //模拟网络请求（一共10页，最后一页只有三条数据）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (netIsOk()) {
            NSArray *arr;
            if (page<10) {
                arr = @[@(page),@(page),@(page),@(page),@(page),@(page),@(page),@(page),@(page),@(page)];
            }else {
                arr = @[@(page),@(page),@(page)];
            }
            netRes(arr, YES);
        }else {//网络请求失败
            netRes(nil, NO);
        }
        
    });
}

@end

