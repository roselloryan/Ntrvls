
#import "TimerPlayVC.h"
#import "BreakAwayView.h"
#import "UIColor+UIColorExtension.h"

@interface TimerPlayVC ()

@property (weak, nonatomic) IBOutlet UILabel *workoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentIntervalDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *currentIntervalView;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property (strong, nonatomic) NSTimer *labelTimer;

@property (assign, nonatomic) NSUInteger totalTimeElapsed;
@property (assign, nonatomic) NSUInteger timeLeftInInterval;
@property (assign, nonatomic) NSInteger intervalNumber;

@property (assign, nonatomic) BOOL playerIsPaused;

@property (assign, nonatomic) CGRect pauseButtonOriginalFrame;
@property (assign, nonatomic) CGRect stopButtonOriginalFrame;


@end



@implementation TimerPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.workoutLabel.text = self.workoutTitle;
    
    self.startButton.layer.borderWidth = 1.0;
    self.startButton.layer.borderColor = [UIColor ntrvlsGreen].CGColor;
    self.startButton.layer.cornerRadius = 5.0f;
    self.startButton.layer.masksToBounds = YES;
    
    self.pauseButton.layer.borderWidth = 1.0;
    self.pauseButton.layer.borderColor = [UIColor ntrvlsYellow].CGColor;
    self.pauseButton.layer.cornerRadius = 5.0f;
    self.pauseButton.layer.masksToBounds = YES;
    
    self.stopButton.layer.borderWidth = 1.0;
    self.stopButton.layer.borderColor = [UIColor ntrvlsRed].CGColor;
    self.stopButton.layer.cornerRadius = 5.0f;
    self.stopButton.layer.masksToBounds = YES;
    
    self.pauseButton.enabled = NO;
    self.pauseButton.hidden = YES;
    self.stopButton.enabled = NO;
    self.stopButton.hidden = YES;
    
    self.pauseButtonOriginalFrame = self.pauseButton.frame;
    self.stopButtonOriginalFrame = self.stopButton.frame;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *backButton =[[UIBarButtonItem alloc]initWithTitle:@"<edit" style:UIBarButtonItemStyleDone target:self action:@selector(navigateBackToTimerPrepVC)];
    [backButton setTitleTextAttributes: @{NSFontAttributeName : [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin]} forState: UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backButton;

    //    [self.navigationController setNavigationBarHidden:YES];
}


- (IBAction)startButtonTapped:(UIButton *)sender {
    
    [self animatePauseAndStopButtons];
    
    self.currentIntervalView.backgroundColor = [UIColor ntrvlsYellow];
    
    if (!self.playerIsPaused) {
        
        NSTimer *labelTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector:@selector(labelTimerFired:) userInfo:nil repeats:YES];
        self.labelTimer = labelTimer;
    
        Ntrvl *currentInterval = self.selectedWorkout.interval[self.intervalNumber];
        self.timeLeftInInterval = currentInterval.intervalDuration;
        
        // update labels
        self.timeIntervalLabel.text = [self timeStringFromSecondsCount: currentInterval.intervalDuration];
        self.currentIntervalDescriptionLabel.text = [NSString stringWithFormat:@"%@", currentInterval.intervalDescription];
        self.nextIntervalLabel.text = self.selectedWorkout.interval[self.intervalNumber].intervalDescription;
    }
}


- (IBAction)pauseButtonTapped:(UIButton *)sender {
    
    if (!self.playerIsPaused) {
        
        self.playerIsPaused = YES;
        
        [self.labelTimer invalidate];
        
        // if we save the count we don't have to do any fancy time keeping
        
        [self.pauseButton setTitle:@"-Go-" forState:UIControlStateNormal];
        [self flashButton: self.pauseButton];
    }
    
    // play again from being paused
    else {
        self.playerIsPaused = NO;
        
        NSTimer *labelTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector:@selector(labelTimerFired:) userInfo:nil repeats:YES];
        self.labelTimer = labelTimer;
    
        
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
        // removes flashing view
        for (UIView *subview in self.view.subviews) {
            if (subview.tag == 1) {
                [subview removeFromSuperview];
                break;
            }
        }
    }
}


- (IBAction)stopButtonTapped:(UIButton *)sender {
    
    
    self.intervalNumber = 0;
    
    [self.labelTimer invalidate];
}


-(void)labelTimerFired:(NSTimer *)timer {
    
    // don't increment total time during warm up
    if (self.intervalNumber != 0) {
        self.totalTimeElapsed ++;
    }
    
    if (self.timeLeftInInterval == 1) {
        self.timeLeftInInterval --;
        [self intervalCompleted];
    }
    else {
        self.timeLeftInInterval --;
    }

    self.timeIntervalLabel.text = [self timeStringFromSecondsCount: self.timeLeftInInterval];
    self.totalTimeElapsedLabel.text = [self timeStringFromSecondsCount: self.totalTimeElapsed];
}

// TODO: Add completed workout logic and alert to post to Strava athlete feed
-(void)intervalCompleted {
    
    // stole this. Learn it!!!
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext: context];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    BreakAwayView *viewToFlash = [[BreakAwayView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) andImage:screenShot];
    [self.view addSubview:viewToFlash];
    
    
    // proceed to next interval
    self.intervalNumber += 1;
    Ntrvl *currentInterval = self.selectedWorkout.interval[self.intervalNumber];
    self.timeLeftInInterval = currentInterval.intervalDuration;
    
    // update label text
    self.timeIntervalLabel.text = [self timeStringFromSecondsCount: self.timeLeftInInterval];
    self.currentIntervalDescriptionLabel.text = currentInterval.intervalDescription;
    
    if (self.intervalNumber == self.selectedWorkout.interval.count - 1) {
        self.nextIntervalLabel.text = @"FINSHED";
    }
    else {
        self.nextIntervalLabel.text = [NSString stringWithFormat:@"%@",((Ntrvl *)self.selectedWorkout.interval[self.intervalNumber + 1]).intervalDescription];
    }
    
    // update interval screen color using colors from UIColorExtension
    if ([currentInterval.screenColor isEqualToString:@"red"]) {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsRed];
    }
    else if ([currentInterval.screenColor isEqualToString:@"blue"]) {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsBlue];
    }
    else if ([currentInterval.screenColor isEqualToString:@"green"]) {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsGreen];
    }
    else if ([currentInterval.screenColor isEqualToString:@"grey"]) {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsGrey];
    }
    else {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsYellow];
    }
}


-(void)animatePauseAndStopButtons {
    
        self.stopButton.alpha = 0.25;
        self.pauseButton.alpha = 0.25;
        self.pauseButton.enabled = YES;
        self.pauseButton.hidden = NO;
        self.stopButton.enabled = YES;
        self.stopButton.hidden = NO;
    
    [UIButton animateKeyframesWithDuration: 0.5 delay: 0.0 options: 0 animations:^{
        
        [UIButton addKeyframeWithRelativeStartTime: 0.0 relativeDuration: 0.40 animations:^{
            
            self.startButton.alpha = 0.0;
            self.startButton.enabled = NO;
            
            self.stopButton.alpha = 1.0;
            self.pauseButton.alpha = 1.0;
            self.pauseButton.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width * 3/5 - self.pauseButton.frame.size.width, 0);
            self.stopButton.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width * 3/5 + self.stopButton.frame.size.width, 0);
        }];
        
        [UIButton addKeyframeWithRelativeStartTime: 0.40 relativeDuration: 0.40 animations:^{

            self.pauseButton.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width * 3/5 - self.pauseButton.frame.size.width, -60);
            self.stopButton.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width * 3/5 + self.stopButton.frame.size.width, -60);
        }];
        
        [UIButton addKeyframeWithRelativeStartTime: 0.8 relativeDuration: 0.20 animations:^{
            
            self.pauseButton.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width / 4, -60);
            self.stopButton.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width / 4, -60);
        }];
    } completion:^(BOOL finished) {
        // anything else?
    }];
}

-(void)flashButton:(UIButton *)button {
    
    UIView *flashView = [[UIView alloc]initWithFrame: button.frame];
    flashView.tag = 1;
    flashView.backgroundColor = [[UIColor ntrvlsGreen] colorWithAlphaComponent:0.2];
    flashView.layer.cornerRadius = 5.0f;
    flashView.layer.masksToBounds = YES;
    [self.view addSubview: flashView];
    [self.view bringSubviewToFront: self.pauseButton];
    
    
    [UIButton animateWithDuration: 1.0 delay: 0.0 options: UIViewAnimationOptionRepeat animations:^{
        flashView.alpha = 0;
    } completion:^(BOOL finished) {
        // anything
    }];
}

- (NSString *)timeStringFromSecondsCount:(NSUInteger)secondsCount {
   
    NSUInteger minutes = 0;
    NSUInteger seconds = 0;
    
    if (secondsCount > 60) {
        minutes = secondsCount / 60;
        seconds = secondsCount % 60;
    }
    else {
        seconds = secondsCount;
    }
    
    NSString *minutesString =  [NSString stringWithFormat: @"%lu", minutes];
    NSString *secondsString = @"";
    
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat: @"0%lu", seconds];
    }
    else {
        secondsString = [NSString stringWithFormat: @"%lu", seconds];
    }
    
    NSString *timeString = [NSString stringWithFormat: @"%@:%@", minutesString, secondsString];
    
     return timeString;
}



#pragma mark - Navigation

- (void)navigateBackToTimerPrepVC {
    [self.navigationController popViewControllerAnimated: YES];
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
