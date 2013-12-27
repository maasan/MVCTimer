#import <UIKit/UIKit.h>

@interface MVCTimerViewController : UIViewController

@property (nonatomic, readwrite, weak) IBOutlet UILabel *currentTimeLabel;

- (IBAction)startButtonPressed:(id)sender;
- (IBAction)pauseButtonPressed:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;

@end
