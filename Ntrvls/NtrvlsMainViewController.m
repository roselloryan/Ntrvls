
#import "NtrvlsMainViewController.h"
#import "TimerPrepVC.h"
#import "UIColor+UIColorExtension.h"
#import "NtrvlsDataStore.h"
#import "NtrvlWorkout+CoreDataProperties.h"


CGFloat const iPhone4sHeight = 480.0f;
static CGFloat const topConstraintConstantFor4s = 0.0f;
static CGFloat const bottomConstraintConstantFor4s = -20.0f;


@interface NtrvlsMainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NtrvlsDataStore *sharedNtrvlsDataStore;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *presetWorkoutTitles;
@property (assign, nonatomic) BOOL deviceIsIpad;

@end



@implementation NtrvlsMainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.sharedNtrvlsDataStore = [NtrvlsDataStore sharedNtrvlsDataStore];
    
    
    // adjust constraints for tiny 4s screen
    if (self.view.frame.size.height == iPhone4sHeight) {
        self.tableViewTopConstraint.constant = topConstraintConstantFor4s;
        self.tableViewBottomConstraint.constant = bottomConstraintConstantFor4s;
    }
    self.tableView.estimatedRowHeight = 40.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.deviceIsIpad = [self thisDeviceAnIpad];
    NSLog(@"---------------------- self.deviceIsIpad = %d ----------------------", self.deviceIsIpad);
    if (self.deviceIsIpad) {
        self.tableView.rowHeight = 80.0;
    }
    
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.toolbar.tintColor = [UIColor whiteColor];

    
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath: selectedIndexPath animated:YES];
    }
    
    [self createPresetWorkouts];
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self.tableView reloadData];
    NSLog(@"self.view.frame = %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"self.tableView.frame = %@", NSStringFromCGRect(self.tableView.frame));
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.sharedNtrvlsDataStore.workoutsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workoutCell" forIndexPath:indexPath];
    
    NtrvlWorkout *cellWorkout = self.sharedNtrvlsDataStore.workoutsArray[indexPath.row];
    
    cell.textLabel.text = cellWorkout.workoutTitle;
    
    if ([cellWorkout.workoutTitle isEqualToString:@"TABATA"] || [cellWorkout.workoutTitle isEqualToString:@"New Workout"] || [cellWorkout.workoutTitle isEqualToString:@"Over/Unders"]) {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    else {
        cell.textLabel.textColor =  [UIColor ntrvlsBlue];
        cell.detailTextLabel.textColor = [UIColor ntrvlsBlue];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = [self timeStringFromSecondsCount: cellWorkout.totalTime];
    
    UIView *selectedView = [UIView new];
    selectedView.backgroundColor = [[UIColor ntrvlsGrey] colorWithAlphaComponent:0.3];
    cell.selectedBackgroundView = selectedView;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 
    NtrvlWorkout *cellWorkout = self.sharedNtrvlsDataStore.workoutsArray[indexPath.row];
    
    if ([cellWorkout.workoutTitle isEqualToString:@"TABATA"] || [cellWorkout.workoutTitle isEqualToString:@"New Workout"] || [cellWorkout.workoutTitle isEqualToString:@"Over/Unders"]) {
        return NO;
    }
    else {
        return YES;
    }
}

 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     
     if (editingStyle == UITableViewCellEditingStyleDelete) {
        
         NtrvlWorkout *workoutToDelete = self.sharedNtrvlsDataStore.workoutsArray[indexPath.row];
         [[NtrvlsDataStore sharedNtrvlsDataStore] deleteWorkoutWithTitle: workoutToDelete.workoutTitle];
         [tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationFade];
     }
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         // TODO: Add empty workout?
     }
     [self.tableView reloadData];
 }

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)createPresetWorkouts {
    if (self.sharedNtrvlsDataStore.workoutsArray.count == 0) {
        [self.sharedNtrvlsDataStore createTabataWorkoutWithCompletionBlock:^(BOOL complete) {
            if (complete) {
                [self.sharedNtrvlsDataStore fetchWorkouts];
                [self.tableView reloadData];
            }
        }];
        [self.sharedNtrvlsDataStore createNewWorkoutWithCompletionBlock:^(BOOL complete) {
            if (complete) {
                [self.sharedNtrvlsDataStore fetchWorkouts];
                [self.tableView reloadData];
            }
        }];
        [self.sharedNtrvlsDataStore createOverUndersWorkoutWithCompletionBlock:^(BOOL complete) {
            if (complete) {
                [self.sharedNtrvlsDataStore fetchWorkouts];
                [self.tableView reloadData];
            }
        }];
        [self.sharedNtrvlsDataStore createDemoWorkoutWithCompletionBlock:^(BOOL complete) {
            if (complete) {
                [self.sharedNtrvlsDataStore fetchWorkouts];
                [self.tableView reloadData];
            }
        }];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"timerPrepSegue"]) {
        TimerPrepVC *destinationVC = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        
        destinationVC.selectedWorkout = self.sharedNtrvlsDataStore.workoutsArray[selectedIndexPath.row];
        destinationVC.deviceIsIpad = self.deviceIsIpad;
    }
}

#pragma mark - iPad check

- (BOOL)thisDeviceAnIpad {
    if (self.view.frame.size.height > 736.0 || self.view.frame.size.width > 736.0) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - time string method

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


@end
