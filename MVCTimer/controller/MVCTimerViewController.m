#import "MVCTimerViewController.h"
#import "NTKTimer.h"
#import "NTKStopwatch.h"

@interface MVCTimerViewController ()
<NTKTimerDelegate, NTKStopwatchDelegate>

@property (nonatomic, readwrite, strong) NTKTimer *timer;
@property (nonatomic, readwrite, strong) NTKStopwatch *stopwatch;

@end

@implementation MVCTimerViewController

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
  self = [super initWithNibName:nibName bundle:nibBundle];
  if (self) {
    // 初期化共通処理を呼び出す
    [self p_initConcrete];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    // 初期化共通処理を呼び出す
    [self p_initConcrete];
  }
  return self;
}

//--------------------------------------------------------------//
#pragma mark -- ビュー --
//--------------------------------------------------------------//

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

//--------------------------------------------------------------//
#pragma mark -- アクション --
//--------------------------------------------------------------//

- (IBAction)startButtonPressed:(id)sender
{
  [_timer start];
//  [_stopwatch start];
}

- (IBAction)pauseButtonPressed:(id)sender
{
  [_timer pause];
//  [_stopwatch pause];
}

- (IBAction)resetButtonPressed:(id)sender
{
  [_timer reset];
//  [_stopwatch reset];
}

//--------------------------------------------------------------//
#pragma mark -- NTKTimerDelegate --
//--------------------------------------------------------------//

- (void)timerDidStart:(NTKTimer *)sender
{
  _currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.currentTime];
}

- (void)timerDidUpdate:(NTKTimer *)sender
{
  _currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.currentTime];
}

- (void)timerDidFinish:(NTKTimer *)sender
{
  _currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.currentTime];
}

- (void)timerDidPause:(NTKTimer *)sender
{
  _currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.currentTime];
}

- (void)timerDidReset:(NTKTimer *)sender
{
  _currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.currentTime];
}

//--------------------------------------------------------------//
#pragma mark -- NTKStopwatchDelegate --
//--------------------------------------------------------------//

- (void)stopwatchDidStart:(NTKStopwatch *)sender
{
  _currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.currentTime];
}

- (void)stopwatchDidUpdate:(NTKStopwatch *)sender
{
  _currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.currentTime];
}

- (void)stopwatchDidPause:(NTKStopwatch *)sender
{
  _currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.currentTime];
}

- (void)stopwatchDidReset:(NTKStopwatch *)sender
{
  _currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", sender.currentTime];
}

//--------------------------------------------------------------//
#pragma mark -- プライベートメンバーメソッド --
//--------------------------------------------------------------//

- (void)p_initConcrete
{
  // Timerを生成する
  _timer = [[NTKTimer alloc] initWithMode:NTKTimerModeCountUp finishTime:20.0 updateInterval:0.01];
  _timer.delegate = self;
  
  // Stopwatchを生成する
  _stopwatch = [[NTKStopwatch alloc] initWithUpdateInterval:0.1];
  _stopwatch.delegate = self;
}

@end
