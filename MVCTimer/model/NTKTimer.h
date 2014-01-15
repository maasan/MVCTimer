typedef NS_ENUM(NSUInteger, NTKTimerStatus) {
	NTKTimerStatusReset, // 0
	NTKTimerStatusStart,
	NTKTimerStatusPause,
};

typedef NS_OPTIONS(NSUInteger, NTKTimerMode) {
  NTKTimerModeCountUp = 1 << 0,
  NTKTimerModeCountDown = 1 << 1,
};

@protocol NTKTimerDelegate;

@interface NTKTimer : NSObject

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, readwrite, weak) id<NTKTimerDelegate> delegate;
@property (nonatomic, readonly, assign) NTKTimerStatus timerStatus;    // 動作状態
@property (nonatomic, readonly, assign) NTKTimerMode timerMode;        // 動作モード
@property (nonatomic, readonly, assign) NSTimeInterval currentTime;    // 現在時間
@property (nonatomic, readonly, assign) NSTimeInterval finishTime;     // 終了時間
@property (nonatomic, readonly, assign) NSTimeInterval updateInterval; // 更新通知間隔

- (id)initWithMode:(NTKTimerMode)timerMode finishTime:(NSTimeInterval)finishTime updateInterval:(NSTimeInterval)updateInterval;

- (void)start;
- (void)pause;
- (void)reset;

@end

@protocol NTKTimerDelegate

- (void)timerDidStart:(NTKTimer *)sender;
- (void)timerDidUpdate:(NTKTimer *)sender;
- (void)timerDidFinish:(NTKTimer *)sender;
- (void)timerDidPause:(NTKTimer *)sender;
- (void)timerDidReset:(NTKTimer *)sender;

@end
