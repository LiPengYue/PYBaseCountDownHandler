//
//  PYCountDownViewController.m
//  PYCountDownHandler_Example
//
//  Created by 李鹏跃 on 2018/12/18.
//  Copyright © 2018年 LiPengYue. All rights reserved.
//

#import "PYCountDownViewController.h"
#import "PYCountDownTableViewCell.h"
#import "PYCountDownModel.h"
#import "PYCountDownHandler.h"


static NSString *const k_PYCountDownTableViewCellID = @"k_PYCountDownTableViewCellID";
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]

#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface PYCountDownViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UILabel * label;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray <PYCountDownModel *> *modelArray;
@property (nonatomic,strong) PYCountDownHandler *countDownHandler;
@end


@implementation PYCountDownViewController
#pragma mark - init
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self setup];
}

#pragma mark - functions

- (void) setup {
    self.countDownHandler = [[PYCountDownHandler alloc]init];
    self.countDownHandler.targetMaxCount = 100;
    
//    self.countDownHandler.isStopWithBackstage = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:@"K_countDownHandler_startCountDown_becomeActive_notification" object:nil];
    
    [self.countDownHandler start];
    [self setupView];
    
    [self loadData];
}

- (void) didBecomeActive {
    CGFloat currentTimeline = [PYCountDownHandler currentTimeDifferent];
    CGFloat totalTimeline = [PYCountDownHandler totalTimeDifferent];
    self.label.text = [NSString stringWithFormat:@"进入后台：%.2lfs，共%lfs",currentTimeline,totalTimeline];
}

// MARK: network
- (void) loadData {
    NSMutableArray * arrayM = @[].mutableCopy;
    for (int i = 0; i < 20; i ++) {
        PYCountDownModel *model = [PYCountDownModel new];
        model.countDownNum = 30;
        model.isShowCountDown = i%2;
        [arrayM addObject:model];
    }
    self.modelArray = arrayM.copy;
}

// MARK: handle views

- (void) setupView {
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:self.label];
    [self.view addSubview:self.button];
    [self.view addSubview:self.tableView];
    
    CGFloat maxW = self.view.frame.size.width;
    self.label.frame = CGRectMake(0,30,maxW-10,20);
    self.button.frame = CGRectMake(0, 0, maxW, 30);
    
    [self layoutTableView];
    
    [self.tableView registerClass:[PYCountDownTableViewCell class] forCellReuseIdentifier:k_PYCountDownTableViewCellID];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    [self setupFooterView];
    
    // tableView 偏移20/64适配
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void) layoutTableView {
    CGFloat maxTop = self.label.frame.size.height + self.label.frame.origin.y;
    self.tableView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:maxTop];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self.view addConstraints:@[top,left,bottom,right]];
}

- (void) setupFooterView {
    
    UIButton *footerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 0, 40)];
    footerButton.backgroundColor = UIColor.redColor;
    [footerButton setTitle:@"点击加载更多" forState:UIControlStateNormal];
    [footerButton setTitle:@"加载中" forState:UIControlStateSelected];
    self.tableView.tableFooterView = footerButton;
    [footerButton addTarget:self action:@selector(clickLoadData:) forControlEvents:UIControlEventTouchUpInside];
}
/// 加载数据
- (void) clickLoadData:(UIButton *)button {
   
    button.selected = true;
    button.userInteractionEnabled = false;
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), q, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableArray * arrayM = self.modelArray.mutableCopy;
            for (int i = 0; i < 20; i ++) {
                PYCountDownModel *model = [PYCountDownModel new];
                model.countDownNum = 340;
                model.isShowCountDown = i%2;
                [arrayM addObject:model];
            }
            self.modelArray = arrayM.copy;
            button.selected = false;
            button.userInteractionEnabled = true;
        });
    });
}

// MARK: properties get && set
- (void)setModelArray:(NSArray<PYCountDownModel *> *)modelArray {
    _modelArray = modelArray;
    [self.countDownHandler registerCountDownEventWithDataSources:modelArray];
    [self.tableView reloadData];
}

// MARK: - delegate && datesource

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    return _tableView;
}


- (UILabel *) label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        
        _label.backgroundColor = UIColor.whiteColor;
        _label.textAlignment = NSTextAlignmentLeft;
        _label.font = [UIFont systemFontOfSize:8];
        _label.textColor = UIColor.whiteColor;
        _label.textAlignment = NSTextAlignmentRight;
        _label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
    return _label;
}

- (UIButton *) button {
    if (!_button) {
        _button = [UIButton new];
        [_button setTitleColor:UIColor.grayColor forState:UIControlStateSelected];
        
        [_button setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        
        [_button setTitle:@"后台计时" forState:UIControlStateNormal];
        
        _button.backgroundColor = UIColor.clearColor;
        [_button addTarget:self action:@selector(click_button) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
- (void)click_button {
    self.button.selected = !self.button.selected;
    self.countDownHandler.isStopWithBackstage = self.button.selected;
}

//MARK: - delegate && datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PYCountDownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:k_PYCountDownTableViewCellID forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[PYCountDownTableViewCell class]]) {
        PYCountDownModel *model = self.modelArray[indexPath.row];
        /// 注意！！
        /// 调用registerCountDownEventWithDelegate方法时
        /// cell的倒计时model一定要是最新值！！
        /// 否则会导致倒计时数据错乱！！！
        cell.model = model;
        [self.countDownHandler registerCountDownEventWithDelegate:cell];
        
        
        /** 错误示范 （位置反了）
         
         [self.countDownHandler registerCountDownEventWithDelegate:cell];
         
         cell.model = model;
         */
    }
    return cell;
}

// MARK:life cycles
- (void)dealloc {
    [self.countDownHandler end];
    NSLog(@"✅销毁：%@",NSStringFromClass([self class]));
}
@end

