
#import "TimerPrepVC.h"
#import "TimerPlayVC.h"
#import "NtrvlsDataStore.h"
#import "UIColor+UIColorExtension.h"
#import "NtrvlsAPIClient.h"
#import "JNKeychainWrapper.h"
#import "CustomNtrvlView.h"
#import "IntervalLabel.h"
#import "Reachability.h"


@interface TimerPrepVC () <UIGestureRecognizerDelegate, UITextFieldDelegate, DeleteButtonProtocol, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *workoutTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stravaButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *activityTypeButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (weak, nonatomic) IBOutlet UIView *contentView;


@property (weak, nonatomic) UITextView *descriptionTextView;
@property (weak, nonatomic) UITextField *minutesTextField;
@property (weak, nonatomic) UITextField *secondsTextField;
@property (strong, nonatomic) NSString *screenColorOfDeselectedNtrvlView;

@property (weak, nonatomic) UITextField *alertTextField;
@property (strong, nonatomic) NSString *alertControllerName;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (assign, nonatomic) BOOL workoutWasEdited;
@property (assign, nonatomic) BOOL workoutWasSaved;

@property (assign, nonatomic) CGFloat screenHeight;
@property (assign, nonatomic) CGFloat screenWidth;

@property (strong, nonatomic) UIView *fadeOutView;

@property (assign, nonatomic) CGRect customViewFrame;
@property (assign, nonatomic) CGFloat bufferWidth;

@end


@implementation TimerPrepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNtrvlCustomCellDimensionConstant];
    
    if ([self.selectedWorkout.workoutTitle isEqualToString:@"+ New Workout"]) {
        self.workoutTitleLabel.text = @"New Workout";
    }
    else {
        self.workoutTitleLabel.text = self.selectedWorkout.workoutTitle;
    }
    [self.navigationController setNavigationBarHidden:YES];
    self.workoutWasEdited = NO;
    
    // make a copy of loaded workout in dataStore then set selectedWorout to copy
    self.selectedWorkout = [[NtrvlsDataStore sharedNtrvlsDataStore] copyNtrvlWorkout: self.selectedWorkout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // remove fadeOutView if returning from PlayerVC
    if (self.fadeOutView) {
        [self.fadeOutView removeFromSuperview];
        self.startButton.titleLabel.alpha = 1.0;
    }
    //iPad customView configurations
    if (self.deviceIsIpad) {
        self.bufferWidth = 8;
        NSUInteger labelWidth = self.screenWidth / 5;
        NSUInteger labelHeight = self.screenHeight / 5;
        NSUInteger xCoordonate = self.contentView.frame.size.width - (labelWidth + labelWidth/2 + self.bufferWidth);
        NSUInteger yCoordinate = 0.7 * labelHeight;
        self.customViewFrame = CGRectMake(xCoordonate, yCoordinate, labelWidth, labelHeight);
    }
    else {
        self.bufferWidth = 4;
        NSUInteger labelWidth = self.screenWidth / 4;
        NSUInteger labelHeight = self.screenHeight / 5;
        NSUInteger xCoordonate = self.contentView.frame.size.width - (labelWidth + labelWidth/2 + self.bufferWidth);
        NSUInteger yCoordinate = 0.7 * labelHeight;
        self.customViewFrame = CGRectMake(xCoordonate, yCoordinate, labelWidth, labelHeight);
    }
    
    // add gestureRecognizer to close selected cells when screen tapped
    UITapGestureRecognizer *backgroundTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget: self action: @selector(deselectOtherSelectedCustomNtrvlViews)];
    [self.view addGestureRecognizer: backgroundTapGestureRecognizer];
    
    if (self.selectedWorkout.workoutType) {
        [self.activityTypeButton setTitle: self.selectedWorkout.workoutType forState: UIControlStateNormal];
    }
    
    if (self.contentView.subviews.count < 1) {
        [self addIntervalLabelCellsToContentView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

        // keychain tests
//    NSLog(@"Running generic Keychain test+++++++++++++++++++++++++++++++++++++++++++++++++");
//    [self testKeychain:@"genericTestValue" forKey:@"genericTestKey" andAccessGroup:nil];
//    [self testKeychain:@"1234567" forKey:@"access_token" andAccessGroup:nil];
}

#pragma mark - Text Field Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.alertTextField && [self.alertControllerName isEqualToString:@"stravaTextInputAlertController"]) {
        
        [self postToStravaWithTitle: textField.text];
        self.alertControllerName = nil;
        [self dismissViewControllerAnimated: NO completion: nil];
    }
    
    else if (textField == self.alertTextField) {
        if (![[NtrvlsDataStore sharedNtrvlsDataStore] alreadySavedWorkoutWithTitle: self.alertTextField.text]) {
            
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveCopyAsNewWorkoutWithTitle: self.alertTextField.text];
            [self dismissViewControllerAnimated: NO completion: nil];
            [self.navigationController popViewControllerAnimated: YES];
        }
        else {
            [self dismissViewControllerAnimated: NO completion: nil];
            [self presentTitleAlreadySavedAlert];
        }
    }
    return YES;
}


#pragma mark - Buttons

- (IBAction)menuButtonTapped:(UIButton *)sender {
    
    [self showAskSaveAlert];
}

- (IBAction)activityTypeButtonTapped:(UIButton *)sender {
    [self presentWorkoutTypeAlertControllerfromButton: sender];
}

- (IBAction)saveButtonTapped:(UIButton *)sender {
    
    if (self.workoutWasEdited) {
        if (!self.selectedWorkout.workoutType) {
            [self presentWorkoutTypeAlertControllerfromButton: sender];
        }
        else {
            if ([self.workoutTitleLabel.text isEqualToString: @"New Workout"]){
                [self presentTextInputAlert];
            }
            else {
                [self presentSaveOrUpdateAlert];
            }
        }
    }
    else {
        [self presentNoChangesToSave];
    }
}

- (IBAction)shareOnStravaButtonTapped:(UIButton *)sender {
    
    [self deselectOtherSelectedCustomNtrvlViews];
    
    if (!self.selectedWorkout.workoutType) {
        [self presentWorkoutTypeAlertControllerfromButton: sender];
    }
    else {
        [self presentNameWorkoutToPostToStravaAlert];
    }
}

- (IBAction)startButtonTapped:(UIButton *)sender {
    [self deselectOtherSelectedCustomNtrvlViews];
    
    if (self.selectedWorkout.workoutType) {
        [self fadeScreenAndSegueToPlayVCWhenComplete];
    }
    else {
        [self presentWorkoutTypeAlertControllerfromButton: sender];
    }
}

- (IBAction)addIntervalButtonTapped:(UIButton *)sender {
    [self deselectOtherSelectedCustomNtrvlViews];
    [self addNewCustomNtrvlViewToContentView];
    [[NtrvlsDataStore sharedNtrvlsDataStore] addNewNtrvlToWorkout:self.selectedWorkout];
}

- (void)deleteButtonTapped:(UIButton *)sender {
    
    CustomNtrvlView *deletedView = ((CustomNtrvlView *) sender.superview);
    
    [self deselectNtrvlView: deletedView];
    [self deleteNrtvlView: deletedView];
    self.workoutWasEdited = YES;
}

- (void)customNtrvlViewTappedFromGestureRecognizer:(UITapGestureRecognizer *)gestureRecongnizer {

    if (gestureRecongnizer.state == UIGestureRecognizerStateEnded) {
        
        if ([gestureRecongnizer.view isKindOfClass: [CustomNtrvlView class]]) {
    
            CustomNtrvlView *selectedNtrvlView = (CustomNtrvlView *)gestureRecongnizer.view;
            
            if (selectedNtrvlView.isSelected == NO) {
                    
                [self deselectOtherSelectedCustomNtrvlViews];
                [self.contentView bringSubviewToFront: gestureRecongnizer.view];
                [self selectNtrvlView: selectedNtrvlView];
            }
            else {
                [self deselectNtrvlView: selectedNtrvlView];
                [self copyInfoToNtrvlModelFromCustomNtrvlView:selectedNtrvlView];
            }
        }
    }
}

- (void)disableMenuActivtyAndSaveButtons {
    self.menuButton.enabled = NO;
    self.saveButton.enabled = NO;
    self.activityTypeButton.enabled = NO;
}

- (void)enableMenuActivtyAndSaveButtons {
    self.menuButton.enabled = YES;
    self.saveButton.enabled = YES;
    self.activityTypeButton.enabled = YES;
}

#pragma mark - Strava Methods

- (void)postToStravaWithTitle:(NSString *)workoutTitle {
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = self.view.center;
    [activityView startAnimating];
    activityView.hidesWhenStopped = YES;
    self.activityIndicatorView = activityView;
    [self.view addSubview: self.activityIndicatorView];
    
    if ([NtrvlsAPIClient testForInternet]) {
    
        [[NtrvlsDataStore sharedNtrvlsDataStore] workoutDescriptionStringForNtrvlWorkout: self.selectedWorkout withCompletionBlock:^(BOOL complete, NSString *workoutDescriptionString) {
        
            if (complete) {
                NSString *startDate = [self stringForCurrentTimeAndDateIOS8601Format];
            
                NSString *titleString = [NSString stringWithFormat:@"Ntrvls Workout - %@", workoutTitle];
                NSString *escapedTitleString = [titleString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
            
                [NtrvlsAPIClient postNtrvlWorkoutToStravaWithname: escapedTitleString type: self.selectedWorkout.workoutType startDateLocal: startDate elapsedTime: self.selectedWorkout.totalTime description: workoutDescriptionString withCompletionBlock:^(BOOL success) {
                
                    if (success){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"Posted Ntrvls Workout!!!");
                            [self.activityIndicatorView stopAnimating];
                            [self.activityIndicatorView removeFromSuperview];
                            self.activityIndicatorView = nil;
                            [self presentSuccessfulStravaUploadAlert];
                        });
                    }
                    else {
                        NSLog(@"Posting failed :( Try loging in now....................");
                        [self loginToStrava];
                    }
                }];
            }
        }];
    }
    else {
        [self dismissViewControllerAnimated: NO completion: nil];
        [self presentNoInternetAlert];
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)loginToStrava {
    [NtrvlsAPIClient loginIntoStravaWithSuccessBlock:^(BOOL success) {
        if (success){
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessDenied) name: @"deniedAccess" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stravaAccessAllowed) name: @"allowedAccess" object:nil];
        }
        else {
            NSLog(@"NO CONNECTION :(   :(    :(    :(");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentNoInternetAlert];
            });
        }
    }];
}

- (void)stravaAccessAllowed {
    
    NSLog(@"Strava Access allowed");
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allowedAccess" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"deniedAccess" object: nil];
    
    [[NtrvlsDataStore sharedNtrvlsDataStore] workoutDescriptionStringForNtrvlWorkout: self.selectedWorkout withCompletionBlock:^(BOOL complete, NSString *workoutDescriptionString) {
    
        if (complete) {
            NSString *startDate = [self stringForCurrentTimeAndDateIOS8601Format];
            
            NSString *titleString = [NSString stringWithFormat:@"Ntrvls Workout - %@", self.workoutTitleLabel.text];
            NSString *escapedTitleString = [titleString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
            
            [NtrvlsAPIClient postNtrvlWorkoutToStravaWithname: escapedTitleString type: self.selectedWorkout.workoutType startDateLocal: startDate elapsedTime: self.selectedWorkout.totalTime description: workoutDescriptionString withCompletionBlock:^(BOOL success) {
        
                if (success){
                    NSLog(@"Posted Ntrvls Workout!!!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicatorView stopAnimating];
                        [self.activityIndicatorView removeFromSuperview];
                        self.activityIndicatorView = nil;
                        [self presentSuccessfulStravaUploadAlert];
                     });
                }
                else {
                    NSLog(@"Posting failed :(");
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
    NSLog(@"!!!!!!!!Strava Access Denied!!!!!!!!");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
        [self presentFailedToPostToStravaAlert];
    });
    
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"deniedAccess" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allowedAccess" object: nil];
}

# pragma mark - CustomNtrvlViews Methods

- (void)addNewCustomNtrvlViewToContentView {

    NSUInteger xCoordonate = self.contentView.frame.size.width - (self.customViewFrame.size.width + self.customViewFrame.size.width/2 + self.bufferWidth);
    
    CustomNtrvlView *newIntervalView = [[CustomNtrvlView alloc]initWithFrame: CGRectMake(xCoordonate, self.customViewFrame.origin.y, self.customViewFrame.size.width, self.customViewFrame.size.height)intervalDescription:@"" andDuration: 0 isIPad: self.deviceIsIpad];
    newIntervalView.positionInWorkout = self.selectedWorkout.interval.count - 1;
    newIntervalView.backgroundColor = [UIColor ntrvlsRed];
    newIntervalView.screenColor = @"red";
    newIntervalView.delegate = self;
    
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width + newIntervalView.frame.size.width, self.contentView.frame.size.height);
    
    self.contentViewWidth.constant = self.contentViewWidth.constant + newIntervalView.frame.size.width + self.bufferWidth;
    
    // move cooldown cell and add button to right & increment position in workout number
    for (CustomNtrvlView *customView in self.contentView.subviews) {
        
        if (customView.tag == 1) {
            customView.frame = CGRectMake(customView.frame.origin.x + self.customViewFrame.size.width + self.bufferWidth, customView.frame.origin.y, customView.frame.size.width, customView.frame.size.height);
            customView.positionInWorkout ++;
        }
    }
    [self.contentView addSubview: newIntervalView];
    [self addGestureRecognizerToView: newIntervalView];
    [self selectNtrvlView: newIntervalView];
    
    [self panScrollViewToShowNewCellsIfNecessary ];
}

- (void)deleteNrtvlView:(CustomNtrvlView *)deletedNtrvlView {

    for (CustomNtrvlView *ntrvlView in self.contentView.subviews) {
        
        if (ntrvlView.positionInWorkout > deletedNtrvlView.positionInWorkout || ntrvlView.tag == 1) {
            
            [UIView animateWithDuration: 0.3 animations:^{
                ntrvlView.frame = CGRectMake(ntrvlView.frame.origin.x - (self.customViewFrame.size.width + self.bufferWidth), ntrvlView.frame.origin.y, ntrvlView.frame.size.width, ntrvlView.frame.size.height);
                
                self.workoutTitleLabel.alpha = 1;
                self.menuButton.alpha = 1;
                self.activityTypeButton.alpha = 1;
                self.saveButton.alpha = 1;
            }];
            ntrvlView.positionInWorkout --;
        }
    }
    [deletedNtrvlView removeFromSuperview];
    
    // contract contentView width
    self.contentViewWidth.constant =  self.contentViewWidth.constant - self.customViewFrame.size.width - self.bufferWidth;
    
    [[NtrvlsDataStore sharedNtrvlsDataStore] deleteNtrvl: self.selectedWorkout.interval[deletedNtrvlView.positionInWorkout] fromNtrvlWorkout: self.selectedWorkout];
    
    [self.selectedWorkout updateTotalTime];
}

- (void)addIntervalLabelCellsToContentView {
    
    self.contentViewWidth.constant = self.customViewFrame.size.width * self.selectedWorkout.interval.count + (self.bufferWidth * self.selectedWorkout.interval.count)+ (self.customViewFrame.size.width /2);
    
    for (NSInteger i = 0; i < self.selectedWorkout.interval.count; i ++) {
        
        Ntrvl *interval = self.selectedWorkout.interval[i];
        
        NSUInteger xCoordinte = i * self.customViewFrame.size.width + i * self.bufferWidth;
        NSUInteger yCoordinte = 0.7 * self.customViewFrame.size.height;
        
        CustomNtrvlView *intervalView = [[CustomNtrvlView alloc]initWithFrame:CGRectMake(xCoordinte, yCoordinte, self.customViewFrame.size.width, self.customViewFrame.size.height) intervalDescription: interval.intervalDescription andDuration: interval.intervalDuration isIPad: self.deviceIsIpad];
        intervalView.delegate = self;
        intervalView.secondsTextField.delegate = self;
        intervalView.minutesTextField.delegate = self;
        intervalView.positionInWorkout = interval.positionNumberInWorkout;
        intervalView.screenColor = interval.screenColor;
        
        if (i == 0) {
            intervalView.descriptionTextView.textColor = [UIColor lightGrayColor];
            intervalView.intervalDurationLabel.textColor = [UIColor lightGrayColor];
            [self applyScreenColorToCustomNtrvlView:intervalView fromNtrvl:interval];
        }
        else if (i == self.selectedWorkout.interval.count - 1) {
            
            // build customview for add button cell 1/2 width
            CustomNtrvlView *addCellView = [[CustomNtrvlView alloc]initWithFrame:CGRectMake(xCoordinte, yCoordinte, self.customViewFrame.size.width/2, self.customViewFrame.size.height) intervalDescription: @"" andDuration: 0 isIPad: self.deviceIsIpad];
            addCellView.intervalDurationLabel.hidden = YES;
            addCellView.tag = 1;
            
            //build button view
            UIButton *addCellButton = [[UIButton alloc]initWithFrame: CGRectMake(0, 2 * self.bufferWidth, self.customViewFrame.size.width/2, self.customViewFrame.size.height - 4 * self.bufferWidth)];
            addCellButton.titleLabel.font = [UIFont systemFontOfSize:50 weight:UIFontWeightThin];
            [addCellButton setTitle:@"+" forState:UIControlStateNormal];
            addCellButton.backgroundColor = [UIColor ntrvlsGrey];
            addCellButton.showsTouchWhenHighlighted = YES;
            [addCellButton addTarget: self action:@selector(addIntervalButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [addCellView addSubview: addCellButton];
            
            // move cool down interval over
            intervalView.frame = CGRectMake(intervalView.frame.origin.x + self.customViewFrame.size.width/2 + self.bufferWidth, intervalView.frame.origin.y, intervalView.frame.size.width, intervalView.frame.size.height);
            intervalView.tag = 1;
            intervalView.descriptionTextView.textColor = [UIColor lightTextColor];
            intervalView.intervalDurationLabel.textColor = [UIColor lightTextColor];
            
            [self applyScreenColorToCustomNtrvlView:intervalView fromNtrvl:interval];
            [self.contentView addSubview: addCellView];
        }
        
        else {
            [self addGestureRecognizerToView:intervalView];
    
            [self applyScreenColorToCustomNtrvlView:intervalView fromNtrvl:interval];
        }
        [self.contentView addSubview:intervalView];
    }
}

- (void)panScrollViewToShowNewCellsIfNecessary {
    if (self.deviceIsIpad) {
        if (self.contentView.subviews.count > 6) {
            [self.scrollView setContentOffset:CGPointMake(self.contentView.frame.size.width - self.view.frame.size.width, 0) animated:YES];
        }
    }
    else {
        if (self.contentView.subviews.count > 4) {
            [self.scrollView setContentOffset:CGPointMake(self.contentView.frame.size.width - self.view.frame.size.width, 0) animated:YES];
        }
    }
}

#pragma mark - Cell Methods

- (void)selectNtrvlView:(CustomNtrvlView *)selectedView {
    
    [self disableMenuActivtyAndSaveButtons];
    
    selectedView.isSelected = YES;
    
    self.descriptionTextView = selectedView.descriptionTextView;
    self.minutesTextField = selectedView.minutesTextField;
    self.secondsTextField = selectedView.secondsTextField;
    
    selectedView.descriptionTextView.userInteractionEnabled = YES;
    selectedView.descriptionTextView.editable = YES;
    
    selectedView.intervalDurationLabel.hidden = YES;
    selectedView.minutesTextField.hidden = NO;
    selectedView.secondsTextField.hidden = NO;
    selectedView.colonLabel.hidden = NO;
    selectedView.deleteButton.hidden = NO;
    selectedView.deleteButton.enabled = YES;
    selectedView.selectColorButton.hidden = NO;
    
    selectedView.minutesTextField.userInteractionEnabled = YES;
    selectedView.secondsTextField.userInteractionEnabled = YES;
    
    selectedView.descriptionTextView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    selectedView.minutesTextField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    selectedView.secondsTextField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    
    [selectedView.descriptionTextView becomeFirstResponder];
    [selectedView bringSubviewToFront: selectedView.deleteButton];
    
    CGFloat CGATransformScale = 0;
    if (self.screenHeight == 480) {
        CGATransformScale = 2.0;
    }
    else {
        CGATransformScale = 2.5;
    }
    
    [UIView animateWithDuration: 0.3 animations:^{
        
        selectedView.transform = CGAffineTransformMakeScale(CGATransformScale, CGATransformScale );
        
        self.workoutTitleLabel.alpha = 0;
        self.menuButton.alpha = 0;
        self.activityTypeButton.alpha = 0;
        self.saveButton.alpha = 0;
        
    } completion:^(BOOL finished) {
        // anything else?
    }];
}


- (void)deselectNtrvlView:(CustomNtrvlView *)deselectedView {
    
    [self enableMenuActivtyAndSaveButtons];

    deselectedView.isSelected = NO;

    self.screenColorOfDeselectedNtrvlView = deselectedView.screenColor;
    
    [deselectedView hideSelectColorsViewAndButtons];
    
    deselectedView.intervalDurationLabel.text = [deselectedView timeStringFromSecondsCount: [self.minutesTextField.text integerValue] * 60 + [self.secondsTextField.text integerValue]];
    
    deselectedView.descriptionTextView.userInteractionEnabled = NO;
    deselectedView.minutesTextField.userInteractionEnabled = NO;
    deselectedView.secondsTextField.userInteractionEnabled = NO;

    deselectedView.intervalDurationLabel.hidden = NO;
    deselectedView.minutesTextField.hidden = YES;
    deselectedView.secondsTextField.hidden = YES;
    deselectedView.colonLabel.hidden = YES;
    deselectedView.deleteButton.hidden = YES;
    deselectedView.selectColorButton.hidden = YES;

    deselectedView.descriptionTextView.backgroundColor = [UIColor clearColor];
    deselectedView.minutesTextField.backgroundColor = [UIColor clearColor];
    deselectedView.secondsTextField.backgroundColor = [UIColor clearColor];

    [deselectedView.descriptionTextView resignFirstResponder];
    [deselectedView.minutesTextField resignFirstResponder];
    [deselectedView.secondsTextField resignFirstResponder];

    [UITextField animateWithDuration: 0.5 animations:^{
        
        deselectedView.transform = CGAffineTransformMakeScale(1, 1);
        self.workoutTitleLabel.alpha = 1;
        self.menuButton.alpha = 1;
        self.activityTypeButton.alpha = 1;
        self.saveButton.alpha = 1;
    
    } completion: nil];
    
    [self copyInfoToNtrvlModelFromCustomNtrvlView: deselectedView];
    //NSLog(@"copied info from view to model?");
    //NSLog(@"selfselectedWorkout.totalTime = %lld", self.selectedWorkout.totalTime);
}

- (void)addGestureRecognizerToView:(UIView *)view {
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget: self action:@selector(customNtrvlViewTappedFromGestureRecognizer:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.view.userInteractionEnabled = YES;
    
    [view addGestureRecognizer: tapGestureRecognizer];
}


- (void)deselectOtherSelectedCustomNtrvlViews {

    for (UIView *subview in self.contentView.subviews) {
        if ([subview isKindOfClass: [CustomNtrvlView class]]) {
            if (((CustomNtrvlView *)subview).isSelected) {
                
                self.screenColorOfDeselectedNtrvlView = ((CustomNtrvlView *)subview).screenColor;
                [self copyInfoToNtrvlModelFromCustomNtrvlView:((CustomNtrvlView *)subview)];
                ((CustomNtrvlView *)subview).isSelected = NO;
                [self deselectNtrvlView: ((CustomNtrvlView *)subview)];
            }
        }
    }
}


- (void)copyInfoToNtrvlModelFromCustomNtrvlView:(CustomNtrvlView *)customNtrvlView {
    
    if (![self.selectedWorkout.interval[customNtrvlView.positionInWorkout].intervalDescription isEqualToString:self.descriptionTextView.text]) {
        
        self.workoutWasEdited = YES;
        self.selectedWorkout.interval[customNtrvlView.positionInWorkout].intervalDescription = self.descriptionTextView.text;
    }
    
    if (self.selectedWorkout.interval[customNtrvlView.positionInWorkout].intervalDuration != [self.minutesTextField.text integerValue] * 60 + [self.secondsTextField.text integerValue]) {

        self.workoutWasEdited = YES;
        self.selectedWorkout.interval[customNtrvlView.positionInWorkout].intervalDuration = [self.minutesTextField.text integerValue] * 60 + [self.secondsTextField.text integerValue];
        
        [self.selectedWorkout updateTotalTime];
    }
    if (![self.selectedWorkout.interval[customNtrvlView.positionInWorkout].screenColor isEqualToString: self.screenColorOfDeselectedNtrvlView]) {
        
//        NSLog(@"self.selectedWorkout.interval[customNtrvlView.positionInWorkout].screenColor: %@\nself.selectedWorkout.interval[customNtrvlView.positionInWorkout].positionNumberInWorkout: %lld", self.selectedWorkout.interval[customNtrvlView.positionInWorkout].screenColor, self.selectedWorkout.interval[customNtrvlView.positionInWorkout].positionNumberInWorkout);
        
        self.workoutWasEdited = YES;
        self.selectedWorkout.interval[customNtrvlView.positionInWorkout].screenColor = self.screenColorOfDeselectedNtrvlView;
    }
    // log out interval descriptions because debugger will not po properties
//    for (Ntrvl *interval in self.selectedWorkout.interval) {
//        NSLog(@"postion in workout: %lld\ndescription: %@\nduration: %lld", interval.positionNumberInWorkout, interval.intervalDescription, interval.intervalDuration);
//    }
}

- (void)applyScreenColorToCustomNtrvlView:(CustomNtrvlView *)intervalView fromNtrvl:(Ntrvl *)interval {
    if ([interval.screenColor isEqualToString: @"yellow"]) {
        intervalView.backgroundColor = [UIColor ntrvlsYellow];
    }
    else if ([interval.screenColor isEqualToString:@"blue"]) {
        intervalView.backgroundColor = [UIColor ntrvlsBlue];
    }
    else if ([interval.screenColor isEqualToString:@"green"]) {
        intervalView.backgroundColor = [UIColor ntrvlsGreen];
    }
    else if ([interval.screenColor isEqualToString:@"grey"]) {
        intervalView.backgroundColor = [UIColor ntrvlsDarkGrey];
    }
    else if ([interval.screenColor isEqualToString:@"orange"]) {
        intervalView.backgroundColor = [UIColor ntrvlsOrange];
    }
    else {
        intervalView.backgroundColor = [UIColor ntrvlsRed];
    }
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


#pragma mark - Keychain test method

- (void)testKeychain:(NSString *)value forKey:(NSString *)key andAccessGroup:(NSString *)group {
    
    NSString *forGroupLog = (group ? [NSString stringWithFormat:@" for access group '%@'", group] : @"");
    
    if ([JNKeychainWrapper saveValue:value forKey:key forAccessGroup:group]) {
        NSLog(@"Correctly saved value '%@' for key '%@'%@", value, key, forGroupLog);
    }
    else {
        NSLog(@"Failed to save!%@", forGroupLog);
    }
    NSLog(@"Value for key '%@' is: '%@'%@", key, [JNKeychainWrapper loadValueForKey:key forAccessGroup:group], forGroupLog);
    
    if ([JNKeychainWrapper deleteValueForKey:key forAccessGroup:group]) {
        NSLog(@"Deleted value for key '%@'. Value is: '%@'%@", key, [JNKeychainWrapper loadValueForKey:key forAccessGroup:group], forGroupLog);
    }
    else {
        NSLog(@"Failed to delete!%@", forGroupLog);
    }
}


#pragma mark - Alert Controllers

- (void)showAskSaveAlert {
    
    [self deselectOtherSelectedCustomNtrvlViews];
    
    if (self.workoutWasEdited && !self.workoutWasSaved) {
        UIAlertController *saveAlertController = [UIAlertController alertControllerWithTitle: @"Do you want to save your changes?" message: nil preferredStyle: UIAlertControllerStyleAlert];
       
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle: @"Yes" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([self.workoutTitleLabel.text isEqualToString:@"New Workout"]) {
                [self presentTextInputAlert];
            }
            else {
                [self presentSaveOrUpdateAlert];
            }
        }];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle: @"No" style: UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[NtrvlsDataStore sharedNtrvlsDataStore] deleteWorkoutWithTitle: kWorkoutCopyName];
            self.selectedWorkout = nil;
            [self.navigationController popViewControllerAnimated: YES];
        }];
        
        [saveAlertController addAction: noAction];
        [saveAlertController addAction: yesAction];
        [self presentViewController: saveAlertController animated: YES completion: nil];
    }
    else {
        [[NtrvlsDataStore sharedNtrvlsDataStore] deleteWorkoutWithTitle: kWorkoutCopyName];
        [self.scrollView setContentOffset: CGPointMake(0, 0) animated: NO];
        [self.navigationController popViewControllerAnimated: YES];
    }
}

- (void)presentSaveOrUpdateAlert{
    
    UIAlertController *saveOrUpdateAlertController = [UIAlertController alertControllerWithTitle: @"Update this workout, or save as new workout?" message: nil preferredStyle: UIAlertControllerStyleAlert];

    UIAlertAction *newWorkoutAction = [UIAlertAction actionWithTitle:@"New Workout" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentTextInputAlert];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // anything else?
    }];
    
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"Update" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[NtrvlsDataStore sharedNtrvlsDataStore] overwriteWorkoutWithTitle: self.workoutTitleLabel.text];
            [self.navigationController popViewControllerAnimated: YES];
    }];
    
    [saveOrUpdateAlertController addAction: updateAction];
    [saveOrUpdateAlertController addAction: newWorkoutAction];
    [saveOrUpdateAlertController addAction: cancelAction];
    [self presentViewController: saveOrUpdateAlertController animated: YES completion: nil];
}

- (void)presentTextInputAlert {
    
    UIAlertController *textInputAlertController = [UIAlertController alertControllerWithTitle: @"Title your workout" message: @"" preferredStyle: UIAlertControllerStyleAlert];
    
    [textInputAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"workout title";
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.alertTextField = textField;
        self.alertControllerName = @"textInputAlertController";
    }];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![[NtrvlsDataStore sharedNtrvlsDataStore] alreadySavedWorkoutWithTitle: self.alertTextField.text]) {
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveCopyAsNewWorkoutWithTitle: self.alertTextField.text];
            [self dismissViewControllerAnimated: NO completion: nil];
            [self.navigationController popViewControllerAnimated: YES];
        }
        else {
            [self presentTitleAlreadySavedAlert];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // default behavior?
    }];
    
    [textInputAlertController addAction: cancelAction];
    [textInputAlertController addAction: saveAction];
    
    [self presentViewController: textInputAlertController animated: YES completion:^{
        // anything else?
    }];
}

- (void)presentTitleAlreadySavedAlert {
    
    UIAlertController *titleAlreadySaveAlertController = [UIAlertController alertControllerWithTitle: @"Title already saved" message: @"Choose a different title" preferredStyle: UIAlertControllerStyleAlert];
    [titleAlreadySaveAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"workout title";
        self.alertTextField = textField;
        self.alertControllerName = @"titleAlreadySaveAlertController";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![[NtrvlsDataStore sharedNtrvlsDataStore] alreadySavedWorkoutWithTitle: self.alertTextField.text]) {
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveCopyAsNewWorkoutWithTitle: self.alertTextField.text];
            [self dismissViewControllerAnimated: NO completion: nil];
            [self.navigationController popViewControllerAnimated: YES];
        }
        else {
            [self presentTitleAlreadySavedAlert];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // default behavior?
    }];
    
    [titleAlreadySaveAlertController addAction: cancelAction];
    [titleAlreadySaveAlertController addAction: okAction];
    [self presentViewController: titleAlreadySaveAlertController animated: YES completion: nil];
}

- (void)presentNameWorkoutToPostToStravaAlert {
    
    UIAlertController *stravaTextInputAlertController = [UIAlertController alertControllerWithTitle: @"Title your workout to post on Strava" message:@"" preferredStyle: UIAlertControllerStyleAlert];
    
    [stravaTextInputAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"workout title";
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.alertTextField = textField;
        self.alertControllerName = @"stravaTextInputAlertController";
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.alertTextField.text.length > 0) {
            [self postToStravaWithTitle: self.alertTextField.text];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDefault handler: nil];
    
    [stravaTextInputAlertController addAction: cancelAction];
    [stravaTextInputAlertController addAction: okAction];
    [self presentViewController: stravaTextInputAlertController animated: YES completion: nil];
}


- (void)presentWorkoutTypeAlertControllerfromButton:(UIButton *)button{
    
    UIAlertController *workoutTypeAlertController = [UIAlertController alertControllerWithTitle:@"Choose activity" message: nil preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *runAction = [UIAlertAction actionWithTitle:@"Run" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![self.selectedWorkout.workoutType isEqualToString:@"Run"]){
            self.workoutWasEdited = YES;
            [self.activityTypeButton setTitle: @"Run" forState: UIControlStateNormal];
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Run" forNtrvlWorkout: self.selectedWorkout];
            self.selectedWorkout.workoutType = @"Run";
        }
        if (button == self.startButton) {
            [self performSegueWithIdentifier:@"TimerPlaySegue" sender:self];
        }
        else if (button == self.saveButton) {
            [self presentTextInputAlert];
        }
        else if (button == self.stravaButton) {
            [self presentNameWorkoutToPostToStravaAlert];
        }
    }];
    UIAlertAction *rideAction = [UIAlertAction actionWithTitle:@"Ride" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![self.selectedWorkout.workoutType isEqualToString:@"Ride"]){
            self.workoutWasEdited = YES;
            [self.activityTypeButton setTitle: @"Ride" forState: UIControlStateNormal];
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Ride" forNtrvlWorkout: self.selectedWorkout];
            self.selectedWorkout.workoutType = @"Ride";
        }
        if (button == self.startButton) {
            [self performSegueWithIdentifier:@"TimerPlaySegue" sender:self];
        }
        else if (button == self.saveButton) {
            [self presentTextInputAlert];
        }
        else if (button == self.stravaButton) {
            [self presentNameWorkoutToPostToStravaAlert];
        }
    }];
    UIAlertAction *rowAction = [UIAlertAction actionWithTitle:@"Row" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![self.selectedWorkout.workoutType isEqualToString:@"Row"]){
            self.workoutWasEdited = YES;
            [self.activityTypeButton setTitle: @"Row" forState: UIControlStateNormal];
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Row" forNtrvlWorkout: self.selectedWorkout];
            self.selectedWorkout.workoutType = @"Row";
        }
        if (button == self.startButton) {
            [self performSegueWithIdentifier:@"TimerPlaySegue" sender:self];
        }
        else if (button == self.saveButton) {
            [self presentTextInputAlert];
        }
        else if (button == self.stravaButton) {
            [self presentNameWorkoutToPostToStravaAlert];
        }
    }];
    UIAlertAction *walkAction = [UIAlertAction actionWithTitle:@"Walk" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        if (![self.selectedWorkout.workoutType isEqualToString:@"Walk"]){
            self.workoutWasEdited = YES;
            [self.activityTypeButton setTitle: @"Walk" forState: UIControlStateNormal];
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Walk" forNtrvlWorkout: self.selectedWorkout];
            self.selectedWorkout.workoutType = @"Walk";
        }
        if (button == self.startButton) {
            [self performSegueWithIdentifier:@"TimerPlaySegue" sender:self];
        }
        else if (button == self.saveButton) {
            [self presentTextInputAlert];
        }
        else if (button == self.stravaButton) {
            [self presentNameWorkoutToPostToStravaAlert];
        }
    }];
    UIAlertAction *swimAction = [UIAlertAction actionWithTitle:@"Swim" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![self.selectedWorkout.workoutType isEqualToString:@"Swim"]){
            self.workoutWasEdited = YES;
            [self.activityTypeButton setTitle: @"Swim" forState: UIControlStateNormal];
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Swim" forNtrvlWorkout: self.selectedWorkout];
            self.selectedWorkout.workoutType = @"Swim";
        }
        if (button == self.startButton) {
            [self performSegueWithIdentifier:@"TimerPlaySegue" sender:self];
        }
        else if (button == self.saveButton) {
            [self presentTextInputAlert];
        }
        else if (button == self.stravaButton) {
            [self presentNameWorkoutToPostToStravaAlert];
        }
    }];
    UIAlertAction *workoutAction = [UIAlertAction actionWithTitle:@"Workout" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![self.selectedWorkout.workoutType isEqualToString:@"Workout"]){
            self.workoutWasEdited = YES;
            [self.activityTypeButton setTitle: @"Workout" forState: UIControlStateNormal];
            [[NtrvlsDataStore sharedNtrvlsDataStore] saveWorkoutType:@"Workout" forNtrvlWorkout: self.selectedWorkout];
            self.selectedWorkout.workoutType = @"Workout";
        }
        if (button == self.startButton) {
            [self performSegueWithIdentifier:@"TimerPlaySegue" sender:self];
        }
        else if (button == self.saveButton) {
            [self presentTextInputAlert];
        }
        else if (button == self.stravaButton) {
            [self presentNameWorkoutToPostToStravaAlert];
        }
    }];
    [workoutTypeAlertController addAction: runAction];
    [workoutTypeAlertController addAction: rideAction];
    [workoutTypeAlertController addAction: rowAction];
    [workoutTypeAlertController addAction: walkAction];
    [workoutTypeAlertController addAction: swimAction];
    [workoutTypeAlertController addAction: workoutAction];
    
    workoutTypeAlertController.popoverPresentationController.sourceRect = button.bounds;
    workoutTypeAlertController.popoverPresentationController.sourceView = button;
    
    [self presentViewController: workoutTypeAlertController animated: YES completion:nil];
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

- (void)presentSuccessfulStravaUploadAlert {

    UIAlertController *successfulStravaPostAlertController = [UIAlertController alertControllerWithTitle:@"Success!" message: @"Workout posted to Strava" preferredStyle: UIAlertControllerStyleAlert];
    
    [self presentViewController: successfulStravaPostAlertController animated: YES completion:^{
        // delay one second then dismiss success alert
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [self dismissViewControllerAnimated: YES completion: nil];
        });
    }];
}

- (void)presentNoChangesToSave {
    UIAlertController *noChangesToSaveAlertController = [UIAlertController alertControllerWithTitle: @"No changes to save" message: @"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // anything else?
    }];
    
    [noChangesToSaveAlertController addAction: okAction];
    [self presentViewController: noChangesToSaveAlertController animated: NO completion:nil];
}

- (void)presentFailedToPostToStravaAlert {
    UIAlertController *failedToPostAlert = [UIAlertController alertControllerWithTitle: @"Strava access denied" message: @"Save workout and try again later" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // anything else?
    }];
    
    [failedToPostAlert addAction: okAction];
    [self presentViewController: failedToPostAlert animated: NO completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"TimerPlaySegue"]) {
        
        TimerPlayVC *destinationVC = segue.destinationViewController;
        destinationVC.selectedWorkout = self.selectedWorkout;
        destinationVC.deviceIsIpad = self.deviceIsIpad;
        
        // since editing a copy of workout, pass forward current title
        destinationVC.workoutTitle = self.workoutTitleLabel.text;
    }
}

- (void)fadeScreenAndSegueToPlayVCWhenComplete {
    UIView *blackView = [[UIView alloc]initWithFrame:self.view.frame];
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = 0.0;
    self.fadeOutView = blackView;
    [self.view addSubview: self.fadeOutView];
    [self.view bringSubviewToFront:self.startButton];
    
    [UIView animateWithDuration: 0.5 animations:^{
        self.fadeOutView.alpha = 1.0;
        self.startButton.titleLabel.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"TimerPlaySegue" sender:self];
    }];
    
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
//    NSLog(@"self.selectedWorkout.workoutType: %@",  self.selectedWorkout.workoutType);
    
    if (sender == self.startButton && !self.selectedWorkout.workoutType) {
        [self presentWorkoutTypeAlertControllerfromButton: sender];
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark - dimension method
- (void)setNtrvlCustomCellDimensionConstant {
    if (self.view.frame.size.height > self.view.frame.size.width) {
        self.screenHeight = self.view.frame.size.height;
        self.screenWidth = self.view.frame.size.width;
    }
    else {
        self.screenHeight = self.view.frame.size.width;
        self.screenWidth = self.view.frame.size.height;
    }
}

#pragma mark - update total time method

- (void)updateTotalTimeForSelectedWorkout {
    // skip 10 second pepare interval
    NSInteger timeSum = 0;
    for (NSUInteger i = 1; i < self.contentView.subviews.count; i++) {
        timeSum += self.selectedWorkout.interval[i].intervalDuration;
        //NSLog(@"cell number %lu with duration = %lld", i, self.selectedWorkout.interval[i].intervalDuration);
    }
    self.selectedWorkout.totalTime = timeSum;
}

@end
