//
//  TimerPlayVC.m
//  Ntrvls


#import "TimerPlayVC.h"
#import "BreakAwayView.h"

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

@property (strong, nonatomic) NSTimer *intervalTimer;
@property (strong, nonatomic) NSTimer *labelTimer;

@property (strong, nonatomic) NSDate *onStartTime;
@property (strong, nonatomic) NSDate *workoutStartTime;

@property (assign, nonatomic) NSTimeInterval totalTimeElapsed;
@property (assign, nonatomic) NSTimeInterval timeLeftInInterval;

@property (assign, nonatomic) NSInteger intervalNumber;

@property (assign, nonatomic) BOOL playerIsPaused;

@property (assign, nonatomic) CGRect pauseButtonOriginalFrame;
@property (assign, nonatomic) CGRect stopButtonOriginalFrame;


@end



@implementation TimerPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.workoutLabel.text = self.workoutTitle;
    
    // hard coded interval sequence
    self.intervalNumber = 0;
    Ntrvl *startNtrvl = [[Ntrvl alloc]initWithIntervalDescription:@"-Get Ready-" andDuration:5];
    Ntrvl *firstNtrvl = [[Ntrvl alloc]initWithIntervalDescription:@"work hard!" andDuration:10];
    Ntrvl *secondNtrvl = [[Ntrvl alloc]initWithIntervalDescription:@"Rest" andDuration:15];
    Ntrvl *thirdNtrvl = [[Ntrvl alloc]initWithIntervalDescription:@"NOW HARDER!" andDuration:10];
    Ntrvl *fourthNtrvl = [[Ntrvl alloc]initWithIntervalDescription:@"Rest" andDuration:15];
    
    self.workoutArray = @[startNtrvl, firstNtrvl, secondNtrvl, thirdNtrvl, fourthNtrvl];
    
    
    
    self.pauseButton.layer.borderWidth = 1.0;
    self.pauseButton.layer.borderColor = [[UIColor yellowColor] colorWithAlphaComponent: 0.7].CGColor;
    self.pauseButton.layer.cornerRadius = 5.0f;
    self.pauseButton.layer.masksToBounds = YES;
    
    self.stopButton.layer.borderWidth = 1.0;
    self.stopButton.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent: 0.7].CGColor;
    self.stopButton.layer.cornerRadius = 5.0f;
    self.stopButton.layer.masksToBounds = YES;
    
    self.pauseButton.enabled = NO;
    self.pauseButton.hidden = YES;
    self.stopButton.enabled = NO;
    self.stopButton.hidden = YES;
    
    self.pauseButtonOriginalFrame = self.pauseButton.frame;
    self.stopButtonOriginalFrame = self.stopButton.frame;


    
}


- (IBAction)startButtonTapped:(UIButton *)sender {
    
    [self animatePauseAndStopButtons];
    
     self.currentIntervalView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent: 0.5];
    
    if (!self.playerIsPaused) {
        
        self.workoutStartTime = [NSDate date];
        
        NSTimer *labelTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector:@selector(labelTimerFired:) userInfo:nil repeats:YES];
        self.labelTimer = labelTimer;
    
        
        // fire updates labels and advances intervals
        NSTimer *intervalTimer = [NSTimer scheduledTimerWithTimeInterval: ((Ntrvl *)self.workoutArray[self.intervalNumber]).duration target: self selector:@selector(intervalTimerFired:) userInfo:nil repeats:NO];
        self.intervalTimer = intervalTimer;
        
        self.onStartTime = [NSDate dateWithTimeInterval: ((Ntrvl *)self.workoutArray[self.intervalNumber]).duration + 1 sinceDate:[NSDate date]];
        
        // update labels
        self.totalTimeElapsedLabel.text = [self timeStringFromInterval:[[NSDate date] timeIntervalSinceDate: self.workoutStartTime]];
        self.timeIntervalLabel.text = [self timeStringFromInterval:((Ntrvl *)self.workoutArray[self.intervalNumber]).duration];
        self.currentIntervalDescriptionLabel.text = [NSString stringWithFormat: @"%@",((Ntrvl *)self.workoutArray[self.intervalNumber]).intervalDescription];
        self.nextIntervalLabel.text = [NSString stringWithFormat: @"Next: %@", ((Ntrvl *)self.workoutArray[self.intervalNumber + 1]).intervalDescription];
    }
    

}


- (IBAction)pauseButtonTapped:(UIButton *)sender {
    
    if (!self.playerIsPaused) {
        
        self.playerIsPaused = YES;
    
        NSTimeInterval totalTimeElapsed = [[NSDate date] timeIntervalSinceDate:self.workoutStartTime];
        
        NSTimeInterval timeLeft = -[[NSDate date] timeIntervalSinceDate:self.onStartTime];
    
        self.totalTimeElapsed = totalTimeElapsed;
        self.timeLeftInInterval = timeLeft;
    
        NSLog(@"totalTimeElapsed: %.0f", totalTimeElapsed);
        NSLog(@"timeLeftInInterval: %.0f", timeLeft);
    
        [self.intervalTimer invalidate];
        [self.labelTimer invalidate];
        
        [self.pauseButton setTitle:@"-Go-" forState:UIControlStateNormal];
        [self flashButton: self.pauseButton];
    }
    
    // play again from being paused
    else {
        self.playerIsPaused = NO;
        
        self.workoutStartTime = [NSDate dateWithTimeInterval: -self.totalTimeElapsed sinceDate:[NSDate date]];
        self.onStartTime = [NSDate dateWithTimeInterval:self.timeLeftInInterval sinceDate:[NSDate date]];
        
        NSTimer *labelTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector:@selector(labelTimerFired:) userInfo:nil repeats:YES];
        self.labelTimer = labelTimer;
        
        NSTimer *intervalTimer = [NSTimer scheduledTimerWithTimeInterval: self.timeLeftInInterval target: self selector:@selector(intervalTimerFired:) userInfo:nil repeats:NO];
        self.intervalTimer = intervalTimer;
        
        // update labels
        self.timeIntervalLabel.text = [self timeStringFromInterval: self.timeLeftInInterval];
        self.nextIntervalLabel.text = [NSString stringWithFormat: @"Next: %@", ((Ntrvl *)self.workoutArray[self.intervalNumber + 1]).intervalDescription];
        
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
    
    
    self.onStartTime = nil;
    self.workoutStartTime = nil;
    self.intervalNumber = 0;
    
    [self.intervalTimer invalidate];
    [self.labelTimer invalidate];
}


-(void)labelTimerFired:(NSTimer *)timer {
    
    NSTimeInterval timeLeft = -[[NSDate date] timeIntervalSinceDate: self.onStartTime];
    NSTimeInterval totalTime = [[NSDate date] timeIntervalSinceDate: self.workoutStartTime];

    NSString *timeleftString = [self timeStringFromInterval: timeLeft];
    NSString *totalTimeString =  [self timeStringFromInterval: totalTime];
    

    self.timeIntervalLabel.text = [NSString stringWithFormat: @"%@", timeleftString];
    self.totalTimeElapsedLabel.text = [NSString stringWithFormat: @"%@", totalTimeString];
}


-(void)intervalTimerFired:(NSTimer *)timer {
    
    // stole this. So Learn it!!!
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    BreakAwayView *viewToFlash = [[BreakAwayView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) andImage:screenShot];
    [self.view addSubview:viewToFlash];
    
    
    // proceed to next interval
    self.intervalNumber += 1;
    
    NSTimer *intervalTimer = [NSTimer scheduledTimerWithTimeInterval: ((Ntrvl *)self.workoutArray[self.intervalNumber]).duration  target: self selector:@selector(intervalTimerFired:) userInfo: nil repeats: NO];
    self.intervalTimer = intervalTimer;
    
    self.onStartTime = [NSDate dateWithTimeInterval: ((Ntrvl *)self.workoutArray[self.intervalNumber]).duration sinceDate:[NSDate date]];
    
    
    // update label text
    self.timeIntervalLabel.text = [self timeStringFromInterval: ((Ntrvl *)self.workoutArray[self.intervalNumber]).duration];
    self.currentIntervalDescriptionLabel.text = [NSString stringWithFormat:@"%@",((Ntrvl *)self.workoutArray[self.intervalNumber]).intervalDescription];
   self.nextIntervalLabel.text = [NSString stringWithFormat:@"Next: %@",((Ntrvl *)self.workoutArray[self.intervalNumber + 1]).intervalDescription];
    
    
    
    // background hard coded for demo
    if (self.intervalNumber == 0) {
        self.currentIntervalView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent: 0.4];
    }
    else if (self.intervalNumber % 2 == 0) {
        self.currentIntervalView.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent: 0.3];
    }
    else {
        self.currentIntervalView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent: 0.5];
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
        // key frames
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

- (NSString *)timeStringFromInterval:(NSTimeInterval)interval {
    
    NSDateComponentsFormatter *dateCompFormatter = [[NSDateComponentsFormatter alloc]init];
    dateCompFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dateCompFormatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
    NSString *timeString = [NSString stringWithFormat:@"%@", [dateCompFormatter stringFromTimeInterval:interval]];
    
     return timeString;
}

-(void)flashButton:(UIButton *)button {
    
    UIView *flashView = [[UIView alloc]initWithFrame: button.frame];
    flashView.tag = 1;
    
    flashView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
