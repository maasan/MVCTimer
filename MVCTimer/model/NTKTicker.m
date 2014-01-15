#import "NTKTicker.h"

@interface NTKTicker () {
  struct {
    unsigned int tickerNotifyTick : 1;
  } _delegateFlags;
}

@property (nonatomic, readwrite, strong) NSTimer *innerTimer;

@end

@implementation NTKTicker

//--------------------------------------------------------------//
#pragma mark -- プロパティ --
//--------------------------------------------------------------//

- (void)setDelegate:(id)delegate
{
  _delegate = delegate;
  _delegateFlags.tickerNotifyTick = [delegate respondsToSelector:@selector(tickerNotifyTick:)];
}

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

- (id)initWithTickInterval:(NSTimeInterval)tickInterval
{
  self = [super init];
  if (self) {
    // 初期化共通処理を呼び出す
    [self p_initConcrete];

    // インスタンス変数を初期化する
    _tickInterval = tickInterval;
  }
  return self;
}

- (id)init
{
  // 指定イニシャライザーの利用を促すために例外を投げる
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"Must use initWithInterval: instead."
                               userInfo:nil];
}

//--------------------------------------------------------------//
#pragma mark -- パブリックメンバーメソッド --
//--------------------------------------------------------------//

- (void)start
{
	// もし既にタイマーが存在する場合
	if (_innerTimer) {
    // タイマーを停止して解放する
    [_innerTimer invalidate];
    self.innerTimer = nil;
	}
  
	// タイマーを生成する
	NSTimer *timer = [NSTimer timerWithTimeInterval:_tickInterval
                                           target:self
                                         selector:@selector(p_timerFireMethod:)
                                         userInfo:nil
                                          repeats:YES];
  
	// タイマーを開始する
//	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	
	// タイマーを保存する
	self.innerTimer = timer;
	
	// ステータスを変更する
	_tickerStatus = NTKTickerStatusStart;
}

- (void)pause
{
	// タイマーを停止して解放する
	[_innerTimer invalidate];
	self.innerTimer = nil;
  
	// ステータスを変更する
	_tickerStatus = NTKTickerStatusPause;
}

- (void)reset
{
	// タイマーを停止して解放する
	[_innerTimer invalidate];
	self.innerTimer = nil;
  
	// ステータスを変更する
	_tickerStatus = NTKTickerStatusReset;
}

//--------------------------------------------------------------//
#pragma mark -- プライベートメンバーメソッド --
//--------------------------------------------------------------//

- (void)p_initConcrete
{
  // 識別子を作成する
  CFUUIDRef uuid = CFUUIDCreate(NULL);
  _identifier = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
  CFRelease(uuid);
  
  // インスタンス変数を初期化する
  _tickerStatus = NTKTickerStatusReset;
}

- (void)p_timerFireMethod:(NSTimer *)timer
{
  // デリゲートに通知する
	if (_delegateFlags.tickerNotifyTick) {
		[_delegate tickerNotifyTick:self];
	}
}

@end
