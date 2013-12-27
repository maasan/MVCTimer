typedef NS_ENUM(NSUInteger, NTKTickerStatus) {
	NTKTickerStatusReset, // 0
	NTKTickerStatusStart,
	NTKTickerStatusPause,
};

@interface NTKTicker : NSObject

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, readwrite, weak) id delegate;
@property (nonatomic, readonly, assign) NTKTickerStatus tickerStatus;
@property (nonatomic, readonly, assign) NSTimeInterval tickInterval; // ティック周期

- (id)initWithTickInterval:(NSTimeInterval)tickInterval;

- (void)start;
- (void)pause;
- (void)reset;

@end

@interface NSObject (NTKTickerDelegate)

- (void)tickerNotifyTick:(NTKTicker *)sender;

@end
