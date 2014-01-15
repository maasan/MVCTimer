#import "NTKTimer.h"
#import "NTKTicker.h"

@interface NTKTimer () <NTKTickerDelegate>
{
  struct {
    unsigned int timerDidStart : 1;
    unsigned int timerDidUpdate : 1;
    unsigned int timerDidFinish : 1;
    unsigned int timerDidPause : 1;
    unsigned int timerDidReset : 1;
  } _delegateFlags;
}

@property (nonatomic, readwrite, strong) NTKTicker *ticker;
@property (nonatomic, readwrite, assign) NSTimeInterval elapsedTime; // 経過時間

@end

@implementation NTKTimer

//--------------------------------------------------------------//
#pragma mark -- プロパティ --
//--------------------------------------------------------------//

- (void)setDelegate:(id)delegate
{
  _delegate = delegate;
  _delegateFlags.timerDidStart = [delegate respondsToSelector:@selector(timerDidStart:)];
  _delegateFlags.timerDidUpdate = [delegate respondsToSelector:@selector(timerDidUpdate:)];
  _delegateFlags.timerDidFinish = [delegate respondsToSelector:@selector(timerDidFinish:)];
  _delegateFlags.timerDidPause = [delegate respondsToSelector:@selector(timerDidPause:)];
  _delegateFlags.timerDidReset = [delegate respondsToSelector:@selector(timerDidReset:)];
}

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
  [_ticker start];
	
	// デリゲートに通知する
	if (_delegateFlags.timerDidStart) {
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
  [_ticker pause];
	
  // 動作状態を変更する
  _timerStatus = NTKTimerStatusPause;
  
  NSDate *d_pauseDate = [NSDate date];
  NSDate *d_startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"DebugTimeStart"];
  LOG_DEBUG(@"%3.3f %3.3f", self.currentTime, [d_pauseDate timeIntervalSinceDate:d_startDate]);

	// デリゲートに通知する
	if (_delegateFlags.timerDidPause) {
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
  [_ticker reset];

  // 経過時間を初期化する
  _elapsedTime = 0;
  
  LOG_DEBUG(@"%3.3f", self.currentTime);
  
	// デリゲートに通知する
	if (_delegateFlags.timerDidReset) {
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
    if (_delegateFlags.timerDidFinish) {
        [_delegate timerDidFinish:self];
    }
	}
	// それ以外の場合
	else {
		// デリゲートに通知する
    if (_delegateFlags.timerDidUpdate) {
        [_delegate timerDidUpdate:self];
    }
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
