//
//  PYCountDownProtocol.h
//  FBSnapshotTestCase
//
//  Created by 衣二三 on 2019/11/5.
//

#import <Foundation/Foundation.h>
@class PYCountDownHandler;


/**
 * CountDownHandler 有两种代理
 > 1. 利用`registerCountDownEventWithDataSources` 储存modelArray
  其中modelArray中的model必须继承CountDownHandlerDataSource代理
  在储存modelArray数组时，会向model中添加一个CGFlaot属性（countDownHandler_startCountDown），用来记录此时 CountDownHandler 计时器已经计时时间（currentTime）。
  countDownHandler_startCountDown： 在计算剩余倒计时时间时，会用到。 剩余时间 = model的总倒计时时间-(CountDownHandler.currentTime - countDownHandler_startCountDown);
 
 > 2. 利用`CountDownHandlerViewDelegate`刷新UI
 
 */


/**
 倒计时工具
 @warning  需要自行保证CountDownHandler生命周期
 @warning  如果需求为 tableView的cell中有倒计时:
 
 1. 必须 在数据源数组的set方法中 调用`registerCountDownEventWithDataSources`方法，进行model的批量注册，无需判断是否重复注册，方法内部进行了排除
 
 2. 在model需要实现`CountDownHandlerDataSource`相关代理方法,进行倒计时计算

 3. 在tableView中持有`CountDownHandler`，并且需要在`tableView`的`DataSource`方法`cellFroRowAtIndexPath`中,调用 `registerCountDownEventWithDelegate`，把cell，作为delegate，在代理方法中修改UI
 */


@protocol CountDownHandlerDataSource;


/** 针对于视图的delegate方法 */
@protocol CountDownHandlerViewDelegate<NSObject>
/**
 在每次倒计时事件触发后调用与调用`registerCountDownEventWithDelegate`后都会触发代理方法`- (void) countDownHandler: (CountDownHandler *)handler andDataSource: (id <CountDownHandlerDataSource>)dataSource;`
 */
- (void) countDownHandler: (PYCountDownHandler *)handler andDataSource: (id <CountDownHandlerDataSource>)dataSource;

/**
 获取视图所对应的Model
 @return model
 */
- (id <CountDownHandlerDataSource>) getViewDelegateMapDataSource;
@end


/** 针对于model的delegate方法 */
@protocol CountDownHandlerDataSource<NSObject>

/**
 当需要这条数据显示的时候，会进行调用

 @param handler handler
 @param until 当前已经倒计时了多少时间【剩余时间 = 倒计时总时间 - until】
 */
- (void) countDownHandler: (PYCountDownHandler *)handler andDataSourceCurrenUntil: (CGFloat)until;
@end


NS_ASSUME_NONNULL_BEGIN

@interface PYCountDownProtocol : NSObject

@end

NS_ASSUME_NONNULL_END
