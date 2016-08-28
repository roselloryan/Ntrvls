
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
        // makes shorter row heights for 4s
        self.tableView.rowHeight = self.tableView.frame.size.height / 9;
    }
    else {
        self.tableView.rowHeight = self.tableView.frame.size.height / 8;
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.toolbar.tintColor = [UIColor whiteColor];
    
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
    
    // TODO: decide when to write saved workouts
    if (self.sharedNtrvlsDataStore.workoutsArray.count == 0) {
        [self.sharedNtrvlsDataStore createTabataWorkoutWithCompletionBlock:^(BOOL complete) {
            if (complete) {
                
                [self.sharedNtrvlsDataStore fetchWorkouts];

//                NSLog(@"ShareDataStore.workoutsArray: %@", self.sharedNtrvlsDataStore.workoutsArray);
                
                [self.tableView reloadData];
            }
        }];
    }
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
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
    
    // Configure the cell...
    NtrvlWorkout *cellWorkout = self.sharedNtrvlsDataStore.workoutsArray[indexPath.row];
    
    cell.textLabel.text = cellWorkout.workoutTitle;
    cell.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = [self timeStringFromSecondsCount: cellWorkout.totalTime];
    
    UIView *selectedView = [UIView new];
    selectedView.backgroundColor = [[UIColor ntrvlsRed] colorWithAlphaComponent:0.5];
    cell.selectedBackgroundView = selectedView;
    
    return cell;
}


// TODO: allow editing of user created workouts!

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

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



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"timerPrepSegue"]) {
        TimerPrepVC *destinationVC = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        
        destinationVC.selectedWorkout = self.sharedNtrvlsDataStore.workoutsArray[selectedIndexPath.row];
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
