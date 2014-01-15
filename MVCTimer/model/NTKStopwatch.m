#import "NTKStopwatch.h"
#import "NTKTicker.h"

@interface NTKStopwatch () <NTKTickerDelegate>
{
  struct {
    unsigned int stopwatchDidStart : 1;
    unsigned int stopwatchDidUpdate : 1;
    unsigned int stopwatchDidPause : 1;
    unsigned int stopwatchDidReset : 1;
  } _delegateFlags;
}

@property (nonatomic, readwrite, strong) NTKTicker *ticker;

@end

@implementation NTKStopwatch

//--------------------------------------------------------------//
#pragma mark -- プロパティ --
//--------------------------------------------------------------//

- (void)setDelegate:(id)delegate
{
  _delegate = delegate;
  _delegateFlags.stopwatchDidStart = [delegate respondsToSelector:@selector(stopwatchDidStart:)];
  _delegateFlags.stopwatchDidUpdate = [delegate respondsToSelector:@selector(stopwatchDidUpdate:)];
  _delegateFlags.stopwatchDidPause = [delegate respondsToSelector:@selector(stopwatchDidPause:)];
  _delegateFlags.stopwatchDidReset = [delegate respondsToSelector:@selector(stopwatchDidReset:)];
}

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

- (id)initWithUpdateInterval:(NSTimeInterval)updateInterval
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
    _updateInterval = updateInterval;
    _stopwatchStatus = NTKStopwatchStatusReset;
  }
  return self;
}

- (id)init
{
  // 例外を投げる
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"Must use initWithUpdateInterval: instead."
                               userInfo:nil];
}

//--------------------------------------------------------------//
#pragma mark -- パブリックメンバーメソッド --
//--------------------------------------------------------------//

- (void)start
{
  // 開始状態の場合
  if (_stopwatchStatus == NTKStopwatchStatusStart) {
    // 何もしない
    return;
  }
  
  NSDate *d_startDate = [NSDate date];
  [[NSUserDefaults standardUserDefaults] setObject:d_startDate forKey:@"DebugTimeStart"];
  LOG_DEBUG(@"%3.3f %@", self.currentTime, d_startDate);
  
  // 動作状態を変更する
  _stopwatchStatus = NTKStopwatchStatusStart;
  
	// Tickerを開始する
	[_ticker start];
	
	// デリゲートに通知する
	if (_delegateFlags.stopwatchDidStart) {
		[_delegate stopwatchDidStart:self];
	}
}

- (void)pause
{
  // 開始状態以外の場合
  if (_stopwatchStatus != NTKStopwatchStatusStart) {
    // 何もしない
    return;
  }
  
	// Tickerを一時停止する
	[_ticker pause];
	
  // 動作状態を変更する
  _stopwatchStatus = NTKStopwatchStatusPause;
  
  NSDate *d_pauseDate = [NSDate date];
  NSDate *d_startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"DebugTimeStart"];
  LOG_DEBUG(@"%3.3f %3.3f", self.currentTime, [d_pauseDate timeIntervalSinceDate:d_startDate]);
  
	// デリゲートに通知する
	if (_delegateFlags.stopwatchDidPause) {
		[_delegate stopwatchDidPause:self];
	}
}

- (void)reset
{
  // リセット状態の場合
  if (_stopwatchStatus == NTKStopwatchStatusReset) {
    // 何もしない
    return;
  }
  
  // 動作状態を変更する
  _stopwatchStatus = NTKStopwatchStatusReset;
  
	// Tickerを停止する
	[_ticker reset];
  
  // 現在時間をクリアする
  _currentTime = 0;
  
  LOG_DEBUG(@"%3.3f", _currentTime);
  
	// デリゲートに通知する
	if (_delegateFlags.stopwatchDidReset) {
		[_delegate stopwatchDidReset:self];
	}
}

//--------------------------------------------------------------//
#pragma mark -- TickerDelegate --
//--------------------------------------------------------------//

- (void)tickerNotifyTick:(NTKTicker *)sender
{
  // 現在時間を更新する
  _currentTime = [self p_roundToMilisec:_currentTime + _ticker.tickInterval];
  
  // デリゲートに通知する
	if (_delegateFlags.stopwatchDidUpdate) {
		[_delegate stopwatchDidUpdate:self];
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
