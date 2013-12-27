#import "NTKTimer.h"
#import "NTKTicker.h"

@interface NTKTimer ()

@property (nonatomic, readwrite, strong) NTKTicker *ticker;
@property (nonatomic, readwrite, assign) NSTimeInterval elapsedTime; // 経過時間

@end

@implementation NTKTimer

- (NSTimeInterval)currentTime
{
  switch (_timerMode) {
    case NTKTimerModeCountUp:
      return _elapsedTime;
      break;
      
    case NTKTimerModeCountDown:
      return _finishTime - _elapsedTime;
      break;
      
    default:
      break;
  }

  // 例外を投げる
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Invalid _timerMode[%d]", _timerMode]
                               userInfo:nil];
}

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

- (id)initWithMode:(NTKTimerMode)timerMode finishTime:(NSTimeInterval)finishTime updateInterval:(NSTimeInterval)updateInterval
{
  self = [super init];
  if (self) {
    // 識別子を作成する
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    _identifier = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    // Tickerを初期化する
    _ticker = [[NTKTicker alloc] initWithTickInterval:updateInterval];
    _ticker.delegate = self;
    
    // インスタンス変数を初期化する
    _timerMode = timerMode;
    _finishTime = finishTime;
    _updateInterval = updateInterval;
    _timerStatus = NTKTimerStatusReset;
  }
  return self;
}

- (id)init
{
  // 指定イニシャライザーの利用を促すために例外を投げる
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"Must use initWithMode:finishInterval:updateInterval: instead."
                               userInfo:nil];
}

//--------------------------------------------------------------//
#pragma mark -- パブリックメンバーメソッド --
//--------------------------------------------------------------//

- (void)start
{
  // 開始状態の場合、または経過時間がタイマー終了時間を超えている場合
  if (_timerStatus == NTKTimerStatusStart || _finishTime <= _elapsedTime) {
    // 何もしない
    return;
  }

  NSDate *d_startDate = [NSDate date];
  [[NSUserDefaults standardUserDefaults] setObject:d_startDate forKey:@"DebugTimeStart"];
  LOG_DEBUG(@"%3.3f %@", self.currentTime, d_startDate);

  // 動作状態を変更する
  _timerStatus = NTKTimerStatusStart;
  
	// Tickerを開始する
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    [_ticker start];
//  });
	
	// デリゲートに通知する
	if ([_delegate respondsToSelector:@selector(timerDidStart:)]) {
		[_delegate timerDidStart:self];
	}
}

- (void)pause
{
  // 開始状態以外の場合
  if (_timerStatus != NTKTimerStatusStart) {
    // 何もしない
    return;
  }
  
	// Tickerを一時停止する
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    [_ticker pause];
//  });
	
  // 動作状態を変更する
  _timerStatus = NTKTimerStatusPause;
  
  NSDate *d_pauseDate = [NSDate date];
  NSDate *d_startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"DebugTimeStart"];
  LOG_DEBUG(@"%3.3f %3.3f", self.currentTime, [d_pauseDate timeIntervalSinceDate:d_startDate]);

	// デリゲートに通知する
	if ([_delegate respondsToSelector:@selector(timerDidPause:)]) {
		[_delegate timerDidPause:self];
	}
}

- (void)reset
{
  // リセット状態の場合
  if (_timerStatus == NTKTimerStatusReset) {
    // 何もしない
    return;
  }
  
  // 動作状態を変更する
  _timerStatus = NTKTimerStatusReset;

	// Tickerを停止する
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    [_ticker reset];
//  });

  // 経過時間を初期化する
  _elapsedTime = 0;
  
  LOG_DEBUG(@"%3.3f", self.currentTime);
  
	// デリゲートに通知する
	if ([_delegate respondsToSelector:@selector(timerDidReset:)]) {
		[_delegate timerDidReset:self];
	}
}

//--------------------------------------------------------------//
#pragma mark -- TickerDelegate --
//--------------------------------------------------------------//

- (void)tickerNotifyTick:(NTKTicker *)sender
{
  // 経過時間を更新する
  _elapsedTime = [self p_roundToMilisec:_elapsedTime + _ticker.tickInterval];
  
	// 経過時間が設定時間を超えている場合
	if (_finishTime <= _elapsedTime) {
    // Tickerを一時停止する
    [_ticker pause];
    
    // 動作状態を変更する
    _timerStatus = NTKTimerStatusPause;
    
    NSDate *d_pauseDate = [NSDate date];
    NSDate *d_startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"DebugTimeStart"];
    LOG_DEBUG(@"%3.3f %3.3f", self.currentTime, [d_pauseDate timeIntervalSinceDate:d_startDate]);

		// デリゲートに通知する
//    dispatch_async(dispatch_get_main_queue(), ^(void){
      if ([_delegate respondsToSelector:@selector(timerDidFinish:)]) {
        [_delegate timerDidFinish:self];
      }
//    });
	}
	// それ以外の場合
	else {
		// デリゲートに通知する
//    dispatch_async(dispatch_get_main_queue(), ^(void){
      if ([_delegate respondsToSelector:@selector(timerDidUpdate:)]) {
        [_delegate timerDidUpdate:self];
      }
//    });
	}
}

//--------------------------------------------------------------//
#pragma mark -- プライベートメンバーメソッド --
//--------------------------------------------------------------//

- (NSTimeInterval)p_roundToMilisec:(NSTimeInterval)inputInterval
{
  NSString *convertStr = [NSString stringWithFormat:@"%.3f", inputInterval];
  return (NSTimeInterval)[convertStr doubleValue];
}

@end
