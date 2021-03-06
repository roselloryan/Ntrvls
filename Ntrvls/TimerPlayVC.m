
#import "TimerPlayVC.h"
#import "BreakAwayView.h"
#import "UIColor+UIColorExtension.h"
#import "NtrvlsAPIClient.h"
#import "NtrvlsDataStore.h"
#import "CustomPlayerView.h"
#import "Reachability.h"

@import AVFoundation;

@interface TimerPlayVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalTimeElapsedLabel;

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

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIView *fadeInView;
@property (strong, nonatomic) CustomPlayerView *viewOne;
@property (strong, nonatomic) CustomPlayerView *viewTwo;
@property (strong, nonatomic) CustomPlayerView *viewThree;

@property (assign, nonatomic) CGFloat buffer;
@property (weak, nonatomic) UITextField *alertTextField;

@end



@implementation TimerPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    if (self.deviceIsIpad) {
        self.buffer = 48.0;
    }
    else {
        self.buffer = 28.0;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureSystemSounds];

    // draw view one and two
    self.viewOne = [self buildViewOffScreenForNtrvl: self.selectedWorkout.interval[0]];
    
    // Check for zero time and skip intervals without duration
    for (NSInteger i = 1; i < self.selectedWorkout.interval.count; i++) {
        if (self.selectedWorkout.interval[i].intervalDuration != 0) {
            self.viewTwo = [self buildViewOffScreenForNtrvl: self.selectedWorkout.interval[i]];
            break;
        }
    }
    
    self.viewOne.alpha = 0.0;
    self.viewTwo.alpha = 0.0;
    [self.view addSubview: self.viewOne];
    [self.view addSubview: self.viewTwo];
    
    UIView *fadeInView = [[UIView alloc]initWithFrame: self.view.frame];
    fadeInView.backgroundColor = [UIColor blackColor];
    self.fadeInView = fadeInView;
    [self.view addSubview: self.fadeInView];
    [self.view bringSubviewToFront: self.startButton];
    
    [self hideBackButton];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration: 0.5 delay: 0.25 options: 0 animations:^{
        self.fadeInView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.fadeInView removeFromSuperview];
    
        [self startButtonTapped: self.startButton];
        [self animatePauseAndStopButtons];
    }];
}

#pragma mark - Text Field method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.alertTextField && self.alertTextField.text.length > 0) {
        [self postToStravaWithTitle: self.alertTextField.text];
        [self dismissViewControllerAnimated: NO completion: nil];
    }
    return YES;
}

#pragma mark - Buttons and button methods


- (IBAction)backButtonTapped:(UIButton *)sender {
    [self navigateBackToTimerPrepVC];
}

- (IBAction)startButtonTapped:(UIButton *)sender {
    
    [self performSelector: @selector(animateViewToCurrentIntervalPosition:) withObject: self.viewOne afterDelay: 1.0];
    [self performSelector: @selector(animateViewToNextIntervalPosition:) withObject: self.viewTwo afterDelay: 1.0];
    [self performSelector: @selector(startLabelTimer) withObject: nil afterDelay: 1.5];
}

- (IBAction)pauseButtonTapped:(UIButton *)sender {
    
    if (!self.playerIsPaused) {
        self.playerIsPaused = YES;
        [self.labelTimer invalidate];
        
        [self.pauseButton setTitle:@"-Go-" forState:UIControlStateNormal];
        self.pauseButton.backgroundColor = [UIColor ntrvlsGreen];
    }
    
    // play again from being paused
    else {
        self.playerIsPaused = NO;
        
        NSTimer *labelTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector:@selector(labelTimerFired:) userInfo:nil repeats:YES];
        self.labelTimer = labelTimer;
    
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.pauseButton.backgroundColor = [UIColor ntrvlsYellow];
    }
}


- (IBAction)stopButtonTapped:(UIButton *)sender {
    
    [self showQuitAlert];
    [self.labelTimer invalidate];
}

- (IBAction)shareOnStravaButtonTapped:(UIButton *)sender {
    
    if ([NtrvlsAPIClient testForInternet]) {
        [self presentNameWorkoutToPostToStravaAlert];
    }
    else {
        [self presentNoInternetAlert];
    }
}


- (void)animateButtonsForFinishedWorkout {
    
    [UIButton animateKeyframesWithDuration: 1.0 delay: 0.5 options: 0 animations:^{
        
        [UIButton addKeyframeWithRelativeStartTime: 0.0 relativeDuration: 0.60 animations:^{
            self.pauseButton.transform = CGAffineTransformMakeTranslation(0, 0);
            self.stopButton.transform = CGAffineTransformMakeTranslation(0, 0);
            self.pauseButton.alpha = 0.0;
            self.stopButton.alpha = 0.0;
            self.shareOnStravaButton.alpha = 0.20;
        }];
        [UIButton addKeyframeWithRelativeStartTime: 0.6 relativeDuration: 0.4 animations:^{
            self.shareOnStravaButton.alpha = 1.0;
            self.shareOnStravaButton.hidden = NO;
            self.shareOnStravaButton.enabled = YES;
            self.shareOnStravaButton.transform = CGAffineTransformMakeTranslation(0, - self.view.frame.size.height / 8);
        }];
    } completion:^(BOOL finished) {
        //[self flashButton: self.shareOnStravaButton];
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
    self.pauseButton.hidden = NO;
    self.stopButton.hidden = NO;
    
    [UIButton animateKeyframesWithDuration: 1.0 delay: 0.0 options: 0 animations:^{
        
        [UIButton addKeyframeWithRelativeStartTime: 0.0 relativeDuration: 0.70 animations:^{
            self.startButton.alpha = 0.0;
            self.startButton.enabled = NO;
            
            self.stopButton.alpha = 1.0;
            self.pauseButton.alpha = 1.0;
            self.stopButton.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width * 4/5 + self.stopButton.frame.size.width, 0);
            self.pauseButton.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width * 4/5 - self.pauseButton.frame.size.width, 0);
        }];
        
        [UIButton addKeyframeWithRelativeStartTime: 0.75 relativeDuration: 0.30 animations:^{
            self.pauseButton.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width * 3/5 - self.pauseButton.frame.size.width, 0);
            self.stopButton.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width * 3/5 + self.stopButton.frame.size.width, 0);
        }];
    } completion:^(BOOL finished) {
        
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

- (void)startLabelTimer {
    NSTimer *labelTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector:@selector(labelTimerFired:) userInfo:nil repeats:YES];
    self.labelTimer = labelTimer;
    
    Ntrvl *currentInterval = self.selectedWorkout.interval[self.intervalNumber];
    self.timeLeftInInterval = currentInterval.intervalDuration;
    
    self.pauseButton.enabled = YES;
    self.stopButton.enabled = YES;
}

-(void)labelTimerFired:(NSTimer *)timer {
    
    // don't increment total time during warm up
    if (self.intervalNumber != 0) {
        self.totalTimeElapsed ++;
    }
    
    if (self.timeLeftInInterval == 1) {
        self.timeLeftInInterval --;
        self.viewOne.timeLabel.text = [self timeStringFromSecondsCount: self.timeLeftInInterval];
        [self intervalCompleted];
    }
    else {
        self.timeLeftInInterval --;
    }
    
    [self playSoundsFor321Done];
    
    self.viewOne.timeLabel.text = [self timeStringFromSecondsCount: self.timeLeftInInterval];
    self.totalTimeElapsedLabel.text = [self timeStringFromSecondsCount: self.totalTimeElapsed];
    
    if (self.intervalNumber == self.selectedWorkout.interval.count && self.timeLeftInInterval == 0){
        self.viewOne.timeLabel.text = @"Complete";
    }
    
 
}

-(void)intervalCompleted {
    
    // proceed to next interval
    self.intervalNumber += 1;
    
    // Check for zero time and skip intervals without duration
    if (self.intervalNumber < self.selectedWorkout.interval.count) {
        while (self.selectedWorkout.interval[self.intervalNumber].intervalDuration == 0) {
            self.intervalNumber ++;
        }
    }
    // last interval
    if (self.intervalNumber >= self.selectedWorkout.interval.count) {
        
        [self.labelTimer invalidate];
    
        // update label text. Timer still executes remaining code setting timeLabel text to "Finished!"
        self.viewOne.descriptionLabel.text = @"Workout";
        
        [self displayDoneBackButton];
        [self animateButtonsForFinishedWorkout];
    }
    
    // 2nd to last interval
    else if (self.intervalNumber == self.selectedWorkout.interval.count - 1){
        
        Ntrvl *currentInterval = self.selectedWorkout.interval[self.intervalNumber];
        self.timeLeftInInterval = currentInterval.intervalDuration;
        
        [self animateViewToFinishedIntervalPosition: self.viewOne];
        [self animateLastViewToCurrentIntervalPosition: self.viewTwo];
        self.viewOne = self.viewTwo;
    }
    
    // all other intervals
    else {
        Ntrvl *currentInterval = self.selectedWorkout.interval[self.intervalNumber];
        self.timeLeftInInterval = currentInterval.intervalDuration;

        [self animateViewToFinishedIntervalPosition: self.viewOne];
        [self animateViewToCurrentIntervalPosition: self.viewTwo];
        
        // Check for zero time and skip intervals without duration
        while (self.selectedWorkout.interval[self.intervalNumber + 1].intervalDuration == 0) {
            self.intervalNumber ++;
        }
        
        self.viewThree = [self buildViewOffScreenForNtrvl: self.selectedWorkout.interval[self.intervalNumber + 1]];
        [self.view addSubview:self.viewThree];
        [self animateViewToNextIntervalPosition: self.viewThree];
        self.viewOne = self.viewTwo;
        self.viewTwo = self.viewThree;
    }
}


//- (void)takeScreenShotAndInitializeBreakAwayView {
//    
//    // stole this. Learn it!!!
////    UIGraphicsBeginImageContext(self.view.frame.size);
//    UIGraphicsBeginImageContext(self.currentIntervalView.frame.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [self.currentIntervalView.layer renderInContext: context];
//    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
////    BreakAwayView *viewToFlash = [[BreakAwayView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) andImage:screenShot];
//
//    BreakAwayView *viewToFlash = [[BreakAwayView alloc]initWithFrame: self.currentIntervalView.frame andImage:screenShot];
//    
//    [self.view addSubview:viewToFlash];
//}

//- (void)updateIntervalScreenColorforNtrvl:(Ntrvl *)ntrvl {
//        
//    if ([ntrvl.screenColor isEqualToString:@"red"]) {
//        self.currentIntervalView.backgroundColor = [UIColor ntrvlsRed];
//    }
//    else if ([ntrvl.screenColor isEqualToString:@"blue"]) {
//        self.currentIntervalView.backgroundColor = [UIColor ntrvlsBlue];
//    }
//    else if ([ntrvl.screenColor isEqualToString:@"green"]) {
//        self.currentIntervalView.backgroundColor = [UIColor ntrvlsGreen];
//    }
//    else if ([ntrvl.screenColor isEqualToString:@"grey"]) {
//        self.currentIntervalView.backgroundColor = [UIColor ntrvlsGrey];
//    }
//    else if ([ntrvl.screenColor isEqualToString:@"orange"]) {
//        self.currentIntervalView.backgroundColor = [UIColor ntrvlsOrange];
//    }
//    else {
//        self.currentIntervalView.backgroundColor = [UIColor ntrvlsYellow];
//    }
//}


- (NSString *)timeStringFromSecondsCount:(NSUInteger)secondsCount {
   
    NSUInteger hours = 0;
    NSUInteger minutes = 0;
    NSUInteger seconds = 0;
    
    if (secondsCount > 3600) {
        hours = secondsCount / 3600;
        secondsCount = secondsCount - (hours * 3600);
    }
    
    if (secondsCount >= 60) {
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

- (void)postToStravaWithTitle:(NSString *)title {
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = self.view.center;
    [activityView startAnimating];
    activityView.hidesWhenStopped = YES;
    self.activityIndicatorView = activityView;
    [self.view addSubview: self.activityIndicatorView];
    
    [[NtrvlsDataStore sharedNtrvlsDataStore] workoutDescriptionStringForNtrvlWorkout: self.selectedWorkout withCompletionBlock:^(BOOL complete, NSString *workoutDescriptionString) {
        
        if (complete) {
            NSString *startDate = [self stringForCurrentTimeAndDateIOS8601Format];
            
            NSString *titleString = [NSString stringWithFormat:@"Ntrvls Workout - %@", title];
            NSString *escapedTitleString = [titleString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
            
            [NtrvlsAPIClient postNtrvlWorkoutToStravaWithname: escapedTitleString type: self.selectedWorkout.workoutType startDateLocal: startDate elapsedTime: self.selectedWorkout.totalTime description: workoutDescriptionString withCompletionBlock:^(BOOL success) {
                
                if (success){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //NSLog(@"Posted Ntrvls Workout!!!");
                        [self.activityIndicatorView stopAnimating];
                        [self.activityIndicatorView removeFromSuperview];
                        self.activityIndicatorView = nil;
                        [self presentSuccessfulStravaUploadAlert];
                    });
                }
                else {
                    //NSLog(@"Posting failed :( Try loging in now....................");
                    [self loginToStrava];
                }
            }];
        }
    }];
}

- (void)loginToStrava {
    [NtrvlsAPIClient loginIntoStravaWithSuccessBlock:^(BOOL success) {
        
        if (success){
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessDenied) name: @"deniedAccess" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessAllowed) name: @"allowedAccess" object:nil];
        }
    }];
}

- (void)stravaAccessAllowed {
    
    //NSLog(@"Strava Access allowed");
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allowedAccess" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"deniedAccess" object: nil];
    
    [[NtrvlsDataStore sharedNtrvlsDataStore] workoutDescriptionStringForNtrvlWorkout: self.selectedWorkout withCompletionBlock:^(BOOL complete, NSString *workoutDescriptionString) {
        
        if (complete) {
            NSString *startDate = [self stringForCurrentTimeAndDateIOS8601Format];
            
            NSString *titleString = [NSString stringWithFormat:@"Ntrvls Workout - %@", self.workoutTitle];
            NSString *escapedTitleString = [titleString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
            
            [NtrvlsAPIClient postNtrvlWorkoutToStravaWithname: escapedTitleString type: self.selectedWorkout.workoutType startDateLocal: startDate elapsedTime: self.selectedWorkout.totalTime description: workoutDescriptionString withCompletionBlock:^(BOOL success) {
                
                if (success){
                    // delay one second then present success alert?
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self presentSuccessfulStravaUploadAlert];
                    });
                    
                    //NSLog(@"Posted Ntrvls Workout!!!");
                }
                else {
                    //NSLog(@"Posting failed :(");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicatorView stopAnimating];
                        [self.activityIndicatorView removeFromSuperview];
                        self.activityIndicatorView = nil;
                        [self presentFailedToPostToStravaAlert];
                    });
                    
                }
            }];
        }
    }];
}

- (void)stravaAccessDenied {
    //NSLog(@"!!!!!!!!Strava Access Denied!!!!!!!!");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
        [self presentFailedToPostToStravaAlert];
    });
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"deniedAccess" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allowedAccess" object: nil];
}
# pragma mark - Play view methods

- (CustomPlayerView *)buildViewOffScreenForNtrvl:(Ntrvl *)ntrvl {
    
    CustomPlayerView *firstCell = [[CustomPlayerView alloc]initWithFrame: CGRectMake(self.view.frame.size.width, self.view.frame.size.height/5, self.view.frame.size.width * 3/4, self.view.frame.size.height/2)intervalDescription: ntrvl.intervalDescription duration: ntrvl.intervalDuration andBackgroundColor:ntrvl.screenColor isIpad:self.deviceIsIpad];

    return firstCell;
}

- (void)animateViewToCurrentIntervalPosition:(UIView *)view {
    [UIView animateWithDuration: 0.5 delay: 0.0 options: 0 animations:^{
        view.frame = CGRectMake(8, self.view.frame.size.height/5, self.view.frame.size.width * 3/4,self.view.frame.size.height/2);
        view.alpha = 1.0;
        view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion: nil];
}

- (void)animateViewToNextIntervalPosition:(UIView *)view {
    
    [UIView animateWithDuration: 0.25 delay: 0.25 options: 0 animations:^{
        view.frame = CGRectMake(self.view.frame.size.width * 3/4 + self.buffer , self.view.frame.size.height/5, self.view.frame.size.width * 3/4,self.view.frame.size.height/2);
        view.alpha = 1.0;
    } completion: nil];
}
- (void)animateViewToFinishedIntervalPosition:(UIView *)view {
    [UIView animateWithDuration: 0.5 delay: 0.0 options: 0 animations:^{
        view.frame = CGRectMake(-view.frame.size.width  , self.view.frame.size.height/5, self.view.frame.size.width * 3/4,self.view.frame.size.height/2);
        view.alpha = 0.0;
                view.transform = CGAffineTransformMakeScale(1, 1);
    } completion: nil];
}

- (void)animateLastViewToCurrentIntervalPosition:(CustomPlayerView *)view {
    
    [UIView animateWithDuration: 0.5 delay: 0.0 options: 0 animations:^{
        view.frame = CGRectMake(0, self.view.frame.size.height/5, self.view.frame.size.width, self.view.frame.size.height/2);
        view.alpha = 1.0;
//        view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion: nil];
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
- (void)presentNameWorkoutToPostToStravaAlert {
    
    UIAlertController *stravaTextInputAlertController = [UIAlertController alertControllerWithTitle: @"Title your workout to post on Strava" message:@"" preferredStyle: UIAlertControllerStyleAlert];
    
    [stravaTextInputAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"workout title";
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.alertTextField = textField;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.alertTextField.text.length > 0) {
            [self postToStravaWithTitle: stravaTextInputAlertController.textFields[0].text];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDefault handler: nil];
    
    [stravaTextInputAlertController addAction: cancelAction];
    [stravaTextInputAlertController addAction: okAction];
    [self presentViewController: stravaTextInputAlertController animated: YES completion: nil];
}

- (void)presentFailedToPostToStravaAlert {
    UIAlertController *failedToPostAlert = [UIAlertController alertControllerWithTitle: @"Strava access denied" message: @"Save workout and try again later" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // anything else?
    }];
    
    [failedToPostAlert addAction: okAction];
    [self presentViewController: failedToPostAlert animated: NO completion:nil];
}

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
    [self presentViewController: quitAlertController animated: YES completion: nil];
}

- (void)presentSuccessfulStravaUploadAlert {
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    
    UIAlertController *successfulStravaPostAlertController = [UIAlertController alertControllerWithTitle:@"Success!" message: @"Workout posted to Strava" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
        
        [self navigateBackToTimerPrepVC];
    }];
    [successfulStravaPostAlertController addAction: okAction];
    
    [self presentViewController: successfulStravaPostAlertController animated: YES completion: nil];
}

- (void)presentNoInternetAlert {
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    
    UIAlertController *noInternetAlertController = [UIAlertController alertControllerWithTitle: @"The internet can not be reached" message: @"Save workout and upload when connection is better" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *acceptDefeatAction = [UIAlertAction actionWithTitle:@"Accept your defeat" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // anything else?
    }];
    
    [noInternetAlertController addAction: acceptDefeatAction];
    [self presentViewController: noInternetAlertController animated: NO completion: nil];
}

# pragma mark - Sounds 

- (void)configureSystemSounds {
    
    // respects the mute switch
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error:nil];

    NSURL *threeTwoOnePathURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/short_double_low.caf"];
    if (threeTwoOnePathURL) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)threeTwoOnePathURL, &_threeTwoOneSoundID);
    }

    NSURL *completedNtrvlPathURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/long_low_short_high.caf"];
    if (completedNtrvlPathURL) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)completedNtrvlPathURL, &_completedNtrvlSoundID);
    }
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

@end
