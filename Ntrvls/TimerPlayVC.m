
#import "TimerPlayVC.h"
#import "BreakAwayView.h"
#import "UIColor+UIColorExtension.h"
#import "NtrvlsAPIClient.h"
#import "NtrvlsDataStore.h"

@import AVFoundation;

@interface TimerPlayVC ()

@property (weak, nonatomic) IBOutlet UILabel *workoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextIntervalDescriptionLabel;


@property (weak, nonatomic) IBOutlet UILabel *totalTimeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentIntervalDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *currentIntervalView;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *shareOnStravaButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) NSTimer *labelTimer;

@property (assign, nonatomic) NSUInteger totalTimeElapsed;
@property (assign, nonatomic) NSUInteger timeLeftInInterval;
@property (assign, nonatomic) NSInteger intervalNumber;

@property (assign, nonatomic) BOOL playerIsPaused;

@property (assign, nonatomic) CGRect pauseButtonOriginalFrame;
@property (assign, nonatomic) CGRect stopButtonOriginalFrame;

@property (assign, nonatomic) SystemSoundID threeTwoOneSoundID;
@property (assign, nonatomic) SystemSoundID completedNtrvlSoundID;

@end



@implementation TimerPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.workoutLabel.text = self.workoutTitle;
    
//    self.startButton.layer.borderWidth = 1.0;
//    self.startButton.layer.borderColor = [UIColor ntrvlsGreen].CGColor;
//    self.startButton.layer.cornerRadius = 5.0f;
//    self.startButton.layer.masksToBounds = YES;
//    
//    self.pauseButton.layer.borderWidth = 1.0;
//    self.pauseButton.layer.borderColor = [UIColor ntrvlsYellow].CGColor;
//    self.pauseButton.layer.cornerRadius = 5.0f;
//    self.pauseButton.layer.masksToBounds = YES;
//    
//    self.stopButton.layer.borderWidth = 1.0;
//    self.stopButton.layer.borderColor = [UIColor ntrvlsRed].CGColor;
//    self.stopButton.layer.cornerRadius = 5.0f;
//    self.stopButton.layer.masksToBounds = YES;
    
    self.startButton.backgroundColor = [UIColor ntrvlsGreen];
    self.pauseButton.backgroundColor = [UIColor ntrvlsYellow];
    self.stopButton.backgroundColor = [UIColor ntrvlsRed];
    
    self.pauseButton.enabled = NO;
    self.pauseButton.hidden = YES;
    self.stopButton.enabled = NO;
    self.stopButton.hidden = YES;
    self.shareOnStravaButton.enabled = NO;
    self.shareOnStravaButton.hidden = YES;
    
    self.shareOnStravaButton.layer.cornerRadius = 5.0f;
    self.shareOnStravaButton.layer.masksToBounds = YES;
    self.shareOnStravaButton.alpha = 0.0;
    
    
    self.pauseButtonOriginalFrame = self.pauseButton.frame;
    self.stopButtonOriginalFrame = self.stopButton.frame;
    
    
    [self.navigationController setNavigationBarHidden:YES];
    
    NSLog(@"IN PLAY----- self.selectedWorkout.workoutType: %@", self.selectedWorkout.workoutType);
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureSystemSounds];

    
}

#pragma mark - Buttons and button methods


- (IBAction)backButtonTapped:(UIButton *)sender {
    [self navigateBackToTimerPrepVC];
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
        self.nextIntervalDescriptionLabel.text = [NSString stringWithFormat:@"Next: %@", self.selectedWorkout.interval[self.intervalNumber + 1].intervalDescription];
    }
    
    [self hideBackButton];
    
    
}

- (IBAction)pauseButtonTapped:(UIButton *)sender {
    
    if (!self.playerIsPaused) {
        
        self.playerIsPaused = YES;
        
        [self.labelTimer invalidate];
        
        [self.pauseButton setTitle:@"-Go-" forState:UIControlStateNormal];
//        [self flashButton: self.pauseButton];
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

    
    [self showQuitAlert];
    
    self.intervalNumber = 0;
    [self.labelTimer invalidate];
}

- (IBAction)shareOnStravaButtonTapped:(UIButton *)sender {
    
    NSLog(@"STRAVA button tapped");
    [NtrvlsAPIClient loginIntoStravaWithSuccessBlock:^(BOOL success) {
        
        if (success){
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessDenied) name: @"deniedAccess" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessAllowed) name: @"allowedAccess" object:nil];
        }
        else {
            NSLog(@"NO CONNECTION :(   :(    :(    :(");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //TODO: BUild this alert
//                [self presentNoInternetAlert];
            });
        }
    }];
}


- (void)animateButtonsForFinishedWorkout {
    
    [UIButton animateKeyframesWithDuration: 1.0 delay: 1.0 options: 0 animations:^{
        
        [UIButton addKeyframeWithRelativeStartTime: 0.0 relativeDuration: 0.25 animations:^{
            self.pauseButton.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width * 3/5 - self.pauseButton.frame.size.width, -60);
            self.stopButton.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width * 3/5 + self.stopButton.frame.size.width, -60);
        }];
        [UIButton addKeyframeWithRelativeStartTime: 0.25 relativeDuration: 0.25 animations:^{
            self.pauseButton.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width * 3/5 - self.pauseButton.frame.size.width, 0);
            self.stopButton.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width * 3/5 + self.stopButton.frame.size.width, 0);
        }];
        [UIButton addKeyframeWithRelativeStartTime: 0.5 relativeDuration: 0.25 animations:^{
            self.pauseButton.transform = CGAffineTransformMakeTranslation(0, 0);
            self.stopButton.transform = CGAffineTransformMakeTranslation(0, 0);
            self.pauseButton.alpha = 0.0;
            self.stopButton.alpha = 0.0;
            self.shareOnStravaButton.alpha = 0.20;
        }];
        [UIButton addKeyframeWithRelativeStartTime: 0.75 relativeDuration: 0.25 animations:^{
            self.shareOnStravaButton.alpha = 1.0;
            self.shareOnStravaButton.hidden = NO;
            self.shareOnStravaButton.enabled = YES;
            self.shareOnStravaButton.transform = CGAffineTransformMakeTranslation(0, - self.view.frame.size.height / 4);
            NSLog(@"self.view.frame.size.height = %f", self.view.frame.size.height);
        }];
        
    } completion:^(BOOL finished) {
        [self flashButton: self.shareOnStravaButton];
    }];
}


- (void)hideBackButton {
    self.backButton.hidden = YES;
    self.backButton.enabled = NO;
}


- (void)displayDoneBackButton {
    self.backButton.enabled = YES;
    self.backButton.hidden = NO;
}


- (void)animatePauseAndStopButtons {
    
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
    if (button == self.shareOnStravaButton) {
        flashView.backgroundColor = [[UIColor ntrvlsGrey] colorWithAlphaComponent:0.2];
    }
    else {
        flashView.backgroundColor = [[UIColor ntrvlsGreen] colorWithAlphaComponent:0.2];
    }
    flashView.layer.cornerRadius = 5.0f;
    flashView.layer.masksToBounds = YES;
    [self.view addSubview: flashView];
    [self.view bringSubviewToFront: button];
    
    [UIButton animateWithDuration: 1.0 delay: 0.0 options: UIViewAnimationOptionRepeat animations:^{
        flashView.alpha = 0;
    } completion:^(BOOL finished) {
        // anything
    }];
}



# pragma mark - timer methods

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
    
    [self playSoundsFor321Done];
    
    self.timeIntervalLabel.text = [self timeStringFromSecondsCount: self.timeLeftInInterval];
    self.totalTimeElapsedLabel.text = [self timeStringFromSecondsCount: self.totalTimeElapsed];
    
    if (self.intervalNumber == self.selectedWorkout.interval.count && self.timeLeftInInterval == 0){
        self.timeIntervalLabel.text = @"Finished!";
    }
    
 
}

// TODO: Add completed workout logic and alert to post to Strava athlete feed
-(void)intervalCompleted {
    
    [self takeScreenShotAndInitializeBreakAwayView];
    
    // proceed to next interval
    self.intervalNumber += 1;
    
    // Check for zero time and skip intervals without duration
    if (self.intervalNumber != self.selectedWorkout.interval.count) {
        while (self.selectedWorkout.interval[self.intervalNumber].intervalDuration == 0) {
            self.intervalNumber ++;
        }
    }
    // last interval
    if (self.intervalNumber == self.selectedWorkout.interval.count) {
        
        [self.labelTimer invalidate];
    
        // update label text. Timer still executes remaining code setting timeLabel text to "Finished!"
        self.currentIntervalDescriptionLabel.text = @"";
        self.nextIntervalDescriptionLabel.text = @"";
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsOrange];
        
        [self displayDoneBackButton];
        [self animateButtonsForFinishedWorkout];
        
        // TODO: reset start/stop/pause buttons or make them a post to strava button?
        // TODO: check if completing last interval and if yes prompt post to Strava if not proceed
    }
    // 2nd to last interval
    else if (self.intervalNumber == self.selectedWorkout.interval.count -1){
        
        Ntrvl *currentInterval = self.selectedWorkout.interval[self.intervalNumber];
        self.timeLeftInInterval = currentInterval.intervalDuration;
        
        self.timeIntervalLabel.text = [self timeStringFromSecondsCount: self.timeLeftInInterval];
        self.currentIntervalDescriptionLabel.text = currentInterval.intervalDescription;
        self.nextIntervalDescriptionLabel.text = @"Next: FINSHED";
        
        [self updateIntervalScreenColorforNtrvl:currentInterval];
    }
    // all other intervals
    else {
        
        Ntrvl *currentInterval = self.selectedWorkout.interval[self.intervalNumber];
        self.timeLeftInInterval = currentInterval.intervalDuration;
        
        self.timeIntervalLabel.text = [self timeStringFromSecondsCount: self.timeLeftInInterval];
        self.currentIntervalDescriptionLabel.text = currentInterval.intervalDescription;
        self.nextIntervalDescriptionLabel.text = [NSString stringWithFormat:@"Next: %@",((Ntrvl *)self.selectedWorkout.interval[self.intervalNumber + 1]).intervalDescription];
        
        [self updateIntervalScreenColorforNtrvl: currentInterval];
    }
}


- (void)takeScreenShotAndInitializeBreakAwayView {
    
    // stole this. Learn it!!!
//    UIGraphicsBeginImageContext(self.view.frame.size);
    UIGraphicsBeginImageContext(self.currentIntervalView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.currentIntervalView.layer renderInContext: context];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    BreakAwayView *viewToFlash = [[BreakAwayView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) andImage:screenShot];

    BreakAwayView *viewToFlash = [[BreakAwayView alloc]initWithFrame: self.currentIntervalView.frame andImage:screenShot];
    
    [self.view addSubview:viewToFlash];
}

- (void)updateIntervalScreenColorforNtrvl:(Ntrvl *)ntrvl {
        
    if ([ntrvl.screenColor isEqualToString:@"red"]) {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsRed];
    }
    else if ([ntrvl.screenColor isEqualToString:@"blue"]) {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsBlue];
    }
    else if ([ntrvl.screenColor isEqualToString:@"green"]) {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsGreen];
    }
    else if ([ntrvl.screenColor isEqualToString:@"grey"]) {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsGrey];
    }
    else if ([ntrvl.screenColor isEqualToString:@"orange"]) {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsOrange];
    }
    else {
        self.currentIntervalView.backgroundColor = [UIColor ntrvlsYellow];
    }
}


- (NSString *)timeStringFromSecondsCount:(NSUInteger)secondsCount {
   
    NSUInteger hours = 0;
    NSUInteger minutes = 0;
    NSUInteger seconds = 0;
    
    if (secondsCount > 3600) {
        hours = secondsCount / 3600;
        secondsCount = secondsCount - (hours * 3600);
    }
    
    if (secondsCount > 60) {
        minutes = secondsCount / 60;
        seconds = secondsCount % 60;
    }
    else {
        seconds = secondsCount;
    }
    
    NSString *hoursString =  [NSString stringWithFormat: @"%lu", hours];
    NSString *minutesString =  [NSString stringWithFormat: @"%lu", minutes];
    NSString *secondsString = @"";
    
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat: @"0%lu", seconds];
    }
    else {
        secondsString = [NSString stringWithFormat: @"%lu", seconds];
    }
    
    NSString *timeString = [[NSString alloc]init];
    if (hours == 0) {
        // set minutes without 0 buffer
        minutesString = [NSString stringWithFormat: @"%lu", minutes];
        timeString = [NSString stringWithFormat: @"%@:%@", minutesString, secondsString];
    }
    else {
        if (minutes < 10) {
            minutesString = [NSString stringWithFormat: @"0%lu", minutes];
        }
        else {
            minutesString = [NSString stringWithFormat: @"%lu", minutes];
        }
        
        timeString = [NSString stringWithFormat: @"%@:%@:%@", hoursString, minutesString, secondsString];
    }
    
    return timeString;
}

#pragma mark - Strava Access Methods

- (void)stravaAccessAllowed {
    
    NSLog(@"Strava Access allowed");
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allowedAccess" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"deniedAccess" object: nil];
    
    [[NtrvlsDataStore sharedNtrvlsDataStore] workoutDescriptionStringForNtrvlWorkout: self.selectedWorkout withCompletionBlock:^(BOOL complete, NSString *workoutDescriptionString) {
        
        if (complete) {
            NSString *startDate = [self stringForCurrentTimeAndDateIOS8601Format];
            
            // TODO: Title and save wokout if posting to strava
            NSString *titleString = [NSString stringWithFormat:@"Ntrvls Workout - %@", self.workoutTitle];
            NSString *escapedTitleString = [titleString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
            
            [NtrvlsAPIClient postNtrvlWorkoutToStravaWithname: escapedTitleString type: self.selectedWorkout.workoutType startDateLocal: startDate elapsedTime: self.selectedWorkout.totalTime description: workoutDescriptionString withCompletionBlock:^(BOOL success) {
                
                if (success){
                    
                    // delay one second then present success alert?
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    
                        [self presentSuccessfulStravaUploadAlert];
                    });
                    
                    NSLog(@"Posted Ntrvls Workout!!!");
                }
                else {
                    NSLog(@"Posting failed :(");
                }
            }];
        }
    }];
}

- (void)stravaAccessDenied {
    
    NSLog(@"!!!!!!!!Strava Access Denied!!!!!!!!");
//    [self presentNoInternetAlert];
    
    //    UIAlertController *noInternetAlertController = [UIAlertController alertControllerWithTitle: @"Strava couldn't login" message: @"Maybe try again?" preferredStyle: UIAlertControllerStyleAlert];
    //    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //
    //        // TODO: Make sure this saves workout
    //    }];
    //    [noInternetAlertController addAction:okAction];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"deniedAccess" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allowedAccess" object: nil];
}



#pragma mark - String methods

- (NSString *)stringForCurrentTimeAndDateIOS8601Format {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSDate *now = [NSDate date];
    NSString *timeDateISO8601String = [dateFormatter stringFromDate:now];
    return timeDateISO8601String;
}


#pragma mark - Alerts

- (void)showQuitAlert {
    
    UIAlertController *quitAlertController = [UIAlertController alertControllerWithTitle: @"Are you sure you want to quit?!" message: @"" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *finishedAction = [UIAlertAction actionWithTitle: @"Finished" style: UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        // TODO: Do we want to post the partial workout???
        [self displayDoneBackButton];
        [self animateButtonsForFinishedWorkout];
        
    }];
    UIAlertAction *dontQuitAction = [UIAlertAction actionWithTitle: @"I Don't Quit!" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self pauseButtonTapped: self.pauseButton];
    }];
    
    [quitAlertController addAction: finishedAction];
    [quitAlertController addAction: dontQuitAction];
    [self presentViewController: quitAlertController animated: YES completion:^{
        //anything else?
        // maybe pause here?
    }];
}

- (void)presentSuccessfulStravaUploadAlert {
    
    UIAlertController *successfulStravaPostAlertController = [UIAlertController alertControllerWithTitle:@"Success!" message: @"Workout posted to Strava" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
        
//        [self navigateBackToTimerPrepVC];
    }];
    [successfulStravaPostAlertController addAction: okAction];
    
    [self presentViewController: successfulStravaPostAlertController animated: YES completion:^{
        // delay one second then dismiss success alert
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            
//            [self dismissViewControllerAnimated: YES completion: nil];
//        });
    }];
}

# pragma mark - Sounds 

- (void)configureSystemSounds {
    // respects the mute switch
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error:nil];

    NSURL *threeTwoOnePathURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/short_double_low.caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)threeTwoOnePathURL, &_threeTwoOneSoundID);
    
    NSURL *completedNtrvlPathURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/long_low_short_high.caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)completedNtrvlPathURL, &_completedNtrvlSoundID);
}


- (void)playSoundsFor321Done {
    
    if (self.timeLeftInInterval == 3 || self.timeLeftInInterval == 2 || self.timeLeftInInterval == 1) {
        AudioServicesPlaySystemSound(self.threeTwoOneSoundID);
    }
    else if (self.timeLeftInInterval == 0) {
        AudioServicesPlaySystemSound(self.completedNtrvlSoundID);
    }
    else if (self.timeLeftInInterval == self.selectedWorkout.interval[self.intervalNumber].intervalDuration) {
        AudioServicesPlaySystemSound(self.completedNtrvlSoundID );
    }
}


#pragma mark - Navigation

- (void)navigateBackToTimerPrepVC {
    
    self.intervalNumber = 0;
    [self.labelTimer invalidate];
    
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
