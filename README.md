# PYBaseCountDownHandler

[![CI Status](https://img.shields.io/travis/LiPengYue/PYBaseCountDownHandler.svg?style=flat)](https://travis-ci.org/LiPengYue/PYBaseCountDownHandler)
[![Version](https://img.shields.io/cocoapods/v/PYBaseCountDownHandler.svg?style=flat)](https://cocoapods.org/pods/PYBaseCountDownHandler)
[![License](https://img.shields.io/cocoapods/l/PYBaseCountDownHandler.svg?style=flat)](https://cocoapods.org/pods/PYBaseCountDownHandler)
[![Platform](https://img.shields.io/cocoapods/p/PYBaseCountDownHandler.svg?style=flat)](https://cocoapods.org/pods/PYBaseCountDownHandler)

**关于代码与导入：**
`pod 'PYBaseCountDownHandler'`
[demo](https://github.com/LiPengYue/PYBaseCountDownHandler.git)

## 思考 && 思路
1. 列表中有n个cell需要倒计时，并且列表需要支持上拉加载、下拉刷新。
>  在刷新数据源时持有所有的model，并且计算每个model的倒计时时差。
`(倒计时总计时间) - (新model加入时的已经倒计时时间) = (model倒计时)`
2. 对`cell`的更新
>1.  `countDownHandler`需要弱持有屏幕上的`cell`,并且在`cell`更新数据源后，根据`cell`获取到`model`。
>2. 把（`model`加入时已经倒计时时间）传递给`model`，让`model`来计算倒计时。
3. 切入后台后，定时器需要继续执行（或停止）。
>1.  进入后台前会调用
`- (void)applicationDidEnterBackground:(UIApplication *)application`
> 2. 回到前台后会调用
`- (void)applicationWillEnterForeground:(UIApplication *)application`
> 3. 在这两个地方计算时间差，然后累计到`countDownHandler`的已倒计时时间


## 实践：
2. 根据cell，获取
**分别设置声明两种代理，一个用于数据源代理方法，一个对于倒计时刷新View中Text的代理方法**
1. CountDownHandlerDataSource
>- 利用`registerCountDownEventWithDataSources` 储存modelArray  
>- 其中`modelArray`中的`model`必须继承`CountDownHandlerDataSource`代理
  在储存`modelArray`数组时，会向`model`中添加一个`CGFlaot`属性（`countDownHandler_startCountDown`），用来记录此时 `CountDownHandler` 计时器已经计时时间（`currentTime`）。
 > - `countDownHandler_startCountDown`： 在计算剩余倒计时时间时，会用到。 剩余时间 = `model的总倒计时时间-(CountDownHandler.currentTime - countDownHandler_startCountDown);`
```
/** 针对于model的delegate方法 */
@protocol CountDownHandlerDataSource<NSObject>
/**
 当需要这条数据显示的时候，会进行调用
 @param handler handler
 @param until 当前已经倒计时了多少时间【剩余时间 = 倒计时总时间 - until】
 */
- (void) countDownHandler: (CountDownHandler *)handler andDataSourceCurrenUntil: (CGFloat)until;
@end
```

 2. CountDownHandlerViewDelegate
>- 利用`CountDownHandlerViewDelegate`刷新UI
>- 在调用`- (void) countDownHandler: (CountDownHandler *)handler andDataSource: (id <CountDownHandlerDataSource>)dataSource;`方法前，会先调用`- (id <CountDownHandlerDataSource>) getViewDelegateMapDataSource;`方法，获取到相应的model，并调用model的代理方法`- (void) countDownHandler: (CountDownHandler *)handler andDataSourceCurrenUntil: (CGFloat)until;`来保证`model`的数据刷新
```
/** 针对于视图的delegate方法 */
@protocol CountDownHandlerViewDelegate<NSObject>
/**
在每次倒计时事件触发后调用与调用`registerCountDownEventWithDelegate`后都会触发该代理方法
 */
- (void) countDownHandler: (CountDownHandler *)handler andDataSource: (id <CountDownHandlerDataSource>)dataSource;

/**
 获取视图所对应的Model
 @return model
 */
- (id <CountDownHandlerDataSource>) getViewDelegateMapDataSource;
@end
```

## 列表实践
1.  需要自行保证`CountDownHandler`生命周期
2.   如果需求为` tableView`的`cell`中有倒计时:

 3. 必须 在数据源数组的set方法中 调用`registerCountDownEventWithDataSources`方法，进行model的批量注册，无需判断是否重复注册，方法内部进行了排除
 
 4. 在model需要实现`CountDownHandlerDataSource`相关代理方法,进行倒计时计算

 5. 在tableView中持有`CountDownHandler`，并且需要在`tableView`的`DataSource`方法`cellFroRowAtIndexPath`中,调用 `registerCountDownEventWithDelegate`，把cell，作为delegate，在代理方法中修改UI




# 具体实现

## .h
```

@interface PYCountDownHandler : NSObject

/**
 倒计时 时间 间隔 （秒单位） 默认为1
 */
@property (nonatomic, assign) CGFloat timeInterval;

/**
  现在已经进行时间 (负数 秒单位) 默认为0 
 */
@property (nonatomic, assign) CGFloat currentTime;

/**
 最多同时存在多少个需要倒计时的model
 @warning 最好是两个屏幕所能盛放的cell的数量）， 默认为100
 */
@property (nonatomic, assign) NSInteger targetMaxCount;

/**
 开始倒计时 创建 dispatch_source_t
 */
- (void) start;

/**
 结束倒计时 把timer赋值为nil 不会删除所需要倒计时的model
 */
- (void) end;

/**
 注册倒计时事件
 @bug 注册事件前，需要确保 delegate 中有正确的数据源，否则会数据错乱
 */
- (void) registerCountDownEventWithDelegate: (id <CountDownHandlerViewDelegate>)delegate;

/**
 批量添加delegate，

 @param dataSources dataSource数组 如果数中有元素已经添加，那么将不再添加
 @bug 在有上拉加载的需求中，如果依然 依据当前self.currentTime计算时间的话,会出现差错，因为新返回的数据，需要从0开始倒计时，而不是直接减去currentTime
 
    所以在添加到注册列表的过程中，在dataSource中记录了此时的currentTime（记做delegateCurrentTime），
 
    在进行倒计时时候，会利用currentTime - delegateCurrentTime, 得到需要真正的倒计时间
 
 @bug 需要在网络请求下来后，立即把modelArray注册到dataSources中，以保倒计时准确
 */
- (void)registerCountDownEventWithDataSources: (NSArray<id <CountDownHandlerDataSource>>*)dataSources;

/**
 注册单个的DataSource

 @param dataSource dataSource
 */
- (void) registerCountDownEventWithDataSource: (id<CountDownHandlerDataSource>)dataSource;
/**
 不再相应倒计时
 @param delegate 注销修改视图的delegate
 */
- (void) removeDelegate: (id)delegate;


/** 移除相应的 dataSource */
- (void) removeDataSource: (id<CountDownHandlerDataSource>)dataSource;

/**
 获取delegates
 */
- (NSArray *) getCurrentDelegates;
/**
 获取所有的dataSource
 */
- (NSArray *) getCurrentDataSource;
/**
 清除所需要倒计时的View delegate
 */
- (void) removeAllDelegate;

/**
 清除所需要倒计时的dataSource
 */
- (void) removeAllDataSource;

/**
* 停止后台计时
*/
- (void)stopBackstageTimeing;

/**
 * 开始后台计时
 */
- (void)startBackgroundTiming;

/**
 进入后台返回前台的回调 如果自定义实现这个方法，则 isStopWithBackstage 失效
*/
- (void) applicationWillEnterForegroundWithCurrentDate:(void(^)(CGFloat currentTimeDifferent, PYCountDownHandler *countDownHandler))currentTimeDifferentBlock;


/// 进入后台 又回到前台的时间差
+ (CGFloat) currentTimeDifferent;

/// 所有 进入后台 又回到前台的（currentTimeDifferent）时间差
+ (CGFloat) totalTimeDifferent;

+ (void) applicationDidEnterBackgroundWithCurrentDate: (NSDate *)date;

+ (void) applicationWillEnterForegroundWithCurrentDate: (NSDate *)date;
@end
```

## .m
```
#import "PYCountDownHandler.h"
#import <objc/runtime.h>

CGFloat STATIC_CURRENT_TIME_DIFFERENCE = 0.0f;
CGFloat STATIC_CURRENT_TIME_TOTAL_DIFFERENCE = 0.0f;
NSDate *STATIC_APPLICATION_DID_ENTER_BACKGROUND = nil;
NSDate *STATIC_APPLICATION_DID_BECOME_ACTIVE = nil;

static NSString *const K_countDownHandler_startCountDown = @"K_countDownHandler_startCountDown";
static NSString *const K_countDownHandler_startCountDown_becomeActive_notification = @"K_countDownHandler_startCountDown_becomeActive_notification";

@interface PYCountDownHandler()
@property (nonatomic,strong) NSMutableArray <id<CountDownHandlerViewDelegate>>*delegates;
@property (nonatomic,strong) NSMutableArray <id<CountDownHandlerDataSource>>*dataSources;
@property (nonatomic,strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic,strong) void(^currentTimeDifferentBlock)(CGFloat currentTimeDifferent, PYCountDownHandler *countDownHandler);
/**
进入后台后，是否停止倒计时 默认为false
实现`applicationWillEnterForegroundWithCurrentDate`方法后 该属性失效
*/
@property (nonatomic,assign) BOOL isStopWithBackstage;
@end

@implementation PYCountDownHandler

+ (void)applicationWillEnterForegroundWithCurrentDate:(NSDate *)date {
    STATIC_APPLICATION_DID_BECOME_ACTIVE = date;
    STATIC_CURRENT_TIME_DIFFERENCE = -1;
    [[NSNotificationCenter defaultCenter] postNotificationName:K_countDownHandler_startCountDown_becomeActive_notification object:nil];
}

+ (void) applicationDidEnterBackgroundWithCurrentDate: (NSDate *)date {
    STATIC_APPLICATION_DID_ENTER_BACKGROUND = date;
    STATIC_CURRENT_TIME_DIFFERENCE = -1;
}

+ (CGFloat) totalTimeDifferent {
    return STATIC_CURRENT_TIME_TOTAL_DIFFERENCE;
}

+ (CGFloat)currentTimeDifferent {
    return STATIC_CURRENT_TIME_DIFFERENCE;
}

- (instancetype) init {
    if (self = [super init]) {
        self.timeInterval = 1;
        self.currentTime = 0;
        self.targetMaxCount = 100;
    }
    return self;
}

- (void) start {
    if (!self.timer) {
        [self createTimer];
    }
}

- (void) end {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}

- (void) registerCountDownEventWithDataSources:(NSArray<id<CountDownHandlerDataSource>> *)dataSources {
    __weak typeof (self)weakSelf = self;
    [dataSources enumerateObjectsUsingBlock:^(id<CountDownHandlerDataSource>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf registerCountDownEventWithDataSource:obj];
    }];
}

- (void) registerCountDownEventWithDataSource:(id<CountDownHandlerDataSource>)dataSource {
    
    if (!dataSource) {
        return;
    }
    __weak typeof(dataSource) weakDataSource = dataSource;
    __weak typeof(self) weakSelf = self;
    if ([self getDataSourceStartCountDownTime:weakDataSource] < 0) {
        [self setDataSourceStartCountDownTime:weakDataSource];
    }
    if([weakDataSource respondsToSelector:@selector(countDownHandler:andDataSourceCurrenUntil:)]) {
        CGFloat currentUntil = weakSelf.currentTime - [weakSelf getDataSourceStartCountDownTime:weakDataSource];
        [weakDataSource countDownHandler:weakSelf andDataSourceCurrenUntil:currentUntil];
    }
    if ([self.dataSources containsObject:dataSource]) {
        return;
    }
  
    [self lock:^{
        [weakSelf.dataSources addObject:dataSource];
    }];
}

- (void)registerCountDownEventWithDelegates:(NSArray<id<CountDownHandlerViewDelegate>> *)delegates {
    __weak typeof(self)weakSelf = self;
    [delegates enumerateObjectsUsingBlock:^(id<CountDownHandlerViewDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf registerCountDownEventWithDelegate:obj];
    }];
}

- (void) registerCountDownEventWithDelegate: (id <CountDownHandlerViewDelegate>)delegate{
    if (!delegate) {
        NSLog(@".\
              \n   🌶：【%@】注册代理失败，代理为nil\
              \n   🌶： 如果出现倒计时复用问题:\
              \n     必须要在`registerCountDownEventWithDelegate`之前，保证delegate数据源存在\
              \n   也就是确保`getViewDelegateMapDataSource`可以获取到正确的值\
              \n.",NSStringFromClass([self class]));
        return;
    }
    __weak typeof(delegate) weakDelegate = delegate;
    __weak typeof(self) weakSelf = self;
    if([weakDelegate respondsToSelector:@selector(countDownHandler:andDataSource:)]) {
        id <CountDownHandlerDataSource> dataSource;
        if([weakDelegate respondsToSelector:@selector(getViewDelegateMapDataSource)]) {
            [weakSelf registerCountDownEventWithDataSource:dataSource];
            
            dataSource = [weakDelegate getViewDelegateMapDataSource];
            
            if (!dataSource) {
                [weakSelf logError_NotDataSource];
            }
            if ([dataSource respondsToSelector:@selector(countDownHandler:andDataSourceCurrenUntil:)]) {
                CGFloat currentUntil = weakSelf.currentTime - [weakSelf getDataSourceStartCountDownTime:dataSource];
                [dataSource countDownHandler:weakSelf andDataSourceCurrenUntil:currentUntil];
            }
        }
        [weakDelegate countDownHandler:weakSelf andDataSource:dataSource];
    }
    if ([self.delegates containsObject:delegate]) {
        return;
    }
    
    if (self.delegates.count > self.targetMaxCount) {
        [self removeDelegate:self.delegates.firstObject];
    }
    
    [self lock:^{
        [weakSelf.delegates addObject:weakDelegate];
    }];
}

- (void) removeDelegate: (id)delegate {
    if (!delegate) {
        NSLog(@"\n🌶：【%@】注册代理失败，代理为nil\n",NSStringFromClass([self class]));
        return;
    }
    __weak typeof(self)weakSelf = self;
    [self lock:^{
        [weakSelf.delegates removeObject: delegate];
    }];
}
- (void)removeDataSource:(id<CountDownHandlerDataSource>)dataSource {
    if (!dataSource) {
        NSLog(@"\n🌶：【%@】注册代理dataSource，dataSource为nil\n",NSStringFromClass([self class]));
        return;
    }
    __weak typeof(self)weakSelf = self;
    [self lock:^{
        [weakSelf.dataSources removeObject:dataSource];
    }];
}

- (void)timerAction {
    [self lock:^{
        self.currentTime += self.timeInterval;
        __weak typeof (self)weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegates enumerateObjectsUsingBlock:^(id<CountDownHandlerViewDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj respondsToSelector:@selector(countDownHandler:andDataSource:)]) {
                    id <CountDownHandlerDataSource>dataSource;
                    if ([obj respondsToSelector:@selector(getViewDelegateMapDataSource)]) {
                        dataSource = [obj getViewDelegateMapDataSource];
                    }
                    if ([dataSource respondsToSelector:@selector(countDownHandler:andDataSourceCurrenUntil:)]) {
                        CGFloat currentUntil = weakSelf.currentTime - [weakSelf getDataSourceStartCountDownTime:dataSource];
                        [dataSource countDownHandler:weakSelf andDataSourceCurrenUntil:currentUntil];
                    }
                    [obj countDownHandler:weakSelf andDataSource:dataSource];
                }
            }];
        });
    }];
}

- (void) lock: (void(^)(void))block {
//    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    if (block) {
        block();
    }
//    dispatch_semaphore_signal(self.semaphore);
}

- (void) createTimer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
      dispatch_time_t t = self.isStopWithBackstage ? DISPATCH_TIME_NOW : dispatch_walltime(NULL,0);
    
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    /*
    第一个参数:定时器对象
    第二个参数:DISPATCH_TIME_NOW 表示从现在开始计时相对时间 dispatch_walltime 绝对时间
    第三个参数:间隔时间 GCD里面的时间最小单位为 纳秒
    第四个参数:精准度(表示允许的误差,0表示绝对精准)
    */
    dispatch_source_set_timer(_timer,t,1.0*NSEC_PER_SEC, 0);
    
    self.timer = _timer;

    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        [weakSelf timerAction];
    });
    
    dispatch_resume(self.timer);
}

- (void)dealloc {
    NSLog(@"✅销毁：%@",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *) getCurrentDelegates {
    return self.delegates.copy;
}

- (NSArray *) getCurrentDataSource {
    return self.dataSources.copy;
}

- (void) removeAllDelegate {
    __weak typeof(self)weakSelf = self;
    [self.delegates enumerateObjectsUsingBlock:^(id<CountDownHandlerViewDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf removeDelegate:obj];
    }];
}

- (void)removeAllDataSource {
    __weak typeof(self)weakSelf = self;
    [self lock:^{
        [weakSelf.dataSources removeAllObjects];
    }];
}

// MARK: - get && set
- (NSMutableArray <id<CountDownHandlerViewDelegate>>*) delegates {
    if (!_delegates) {
        _delegates = [NSMutableArray new];
    }
    return _delegates;
}

- (NSMutableArray <id<CountDownHandlerDataSource>> *)dataSources {
    if (!_dataSources) {
        _dataSources = [NSMutableArray new];
    }
    return _dataSources;
}

- (dispatch_semaphore_t) semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return _semaphore;
}

- (void) setDataSourceStartCountDownTime: (id<CountDownHandlerDataSource>)dataSource {
    if (!dataSource) return;
    objc_setAssociatedObject(dataSource, &K_countDownHandler_startCountDown, @(self.currentTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat) getDataSourceStartCountDownTime: (id<CountDownHandlerDataSource>)dataSource {
    NSNumber *obj = objc_getAssociatedObject(dataSource, &K_countDownHandler_startCountDown);
    if (![obj isKindOfClass:[NSNumber class]]) {
        return -1;
    }
    return obj.integerValue;
}

- (void) logError_NotDataSource {
    
        NSLog(@".\
              \n   🌶：【%@】注册代理失败，代理为nil\
              \n   🌶： 如果出现倒计时复用问题，必须要在`registerCountDownEventWithDelegate`之前，保证delegate数据源存在\
              \n   也就是确保`getViewDelegateMapDataSource`可以获取到正确的值\
              \n.",NSStringFromClass([self class]));
}

- (void) applicationWillEnterForegroundWithCurrentDate:(void (^)(CGFloat, PYCountDownHandler *))currentTimeDifferentBlock {
    self.currentTimeDifferentBlock = currentTimeDifferentBlock;
}

- (void)setCurrentTimeDifferentBlock:(void (^)(CGFloat, PYCountDownHandler *))currentTimeDifferentBlock {
    if (currentTimeDifferentBlock) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:K_countDownHandler_startCountDown_becomeActive_notification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        NSLog(@"⚠️ currentTimeDifferentBlock 为nil 不再回调applicationDidBecomeActiveWithTimeDifferent");
    }
    _currentTimeDifferentBlock = currentTimeDifferentBlock;
}

- (void) didBecomeActive {
    
    [self setupTimeOffset];
    
    if (self.currentTimeDifferentBlock) {
        self.currentTimeDifferentBlock([PYCountDownHandler currentTimeDifferent],self);
    }
    if (self.isStopWithBackstage) {
        self.currentTime += [PYCountDownHandler currentTimeDifferent];
    }
}

- (void) setupTimeOffset {
    if (STATIC_CURRENT_TIME_DIFFERENCE <= 0 && STATIC_APPLICATION_DID_BECOME_ACTIVE && STATIC_APPLICATION_DID_ENTER_BACKGROUND) {
           STATIC_CURRENT_TIME_DIFFERENCE = STATIC_APPLICATION_DID_BECOME_ACTIVE.timeIntervalSince1970 - STATIC_APPLICATION_DID_ENTER_BACKGROUND.timeIntervalSince1970;
           STATIC_CURRENT_TIME_TOTAL_DIFFERENCE += STATIC_CURRENT_TIME_DIFFERENCE;
       }else{
           STATIC_CURRENT_TIME_DIFFERENCE = 0.0;
           STATIC_CURRENT_TIME_TOTAL_DIFFERENCE = 0.0;
       }
}

- (void)startBackgroundTiming {
    self.isStopWithBackstage = true;
}

- (void)stopBackstageTimeing {
    self.isStopWithBackstage = false;
}
@end
```


[说再多不如demo上手](https://github.com/LiPengYue/PYBaseCountDownHandler.git)
`pod 'PYBaseCountDownHandler'`
