typedef NS_ENUM(NSUInteger, NTKStopwatchStatus) {
	NTKStopwatchStatusReset, // 0
	NTKStopwatchStatusStart,
	NTKStopwatchStatusPause,
};

@protocol NTKStopwatchDelegate;

@interface NTKStopwatch : NSObject

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, readwrite, weak) id<NTKStopwatchDelegate> delegate;
@property (nonatomic, readonly, assign) NTKStopwatchStatus stopwatchStatus; // 動作状態
@property (nonatomic, readonly, assign) NSTimeInterval updateInterval;      // 更新通知間隔
@property (nonatomic, readonly, assign) NSTimeInterval currentTime;         // 現在時間

- (id)initWithUpdateInterval:(NSTimeInterval)updateInterval;

- (void)start;
- (void)pause;
- (void)reset;

@end

@protocol NTKStopwatchDelegate

- (void)stopwatchDidStart:(NTKStopwatch *)sender;
- (void)stopwatchDidUpdate:(NTKStopwatch *)sender;
- (void)stopwatchDidPause:(NTKStopwatch *)sender;
- (void)stopwatchDidReset:(NTKStopwatch *)sender;

@end
