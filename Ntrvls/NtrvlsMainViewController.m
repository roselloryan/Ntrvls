//
//  NtrvlsMainViewController.m
//  Ntrvls


#import "NtrvlsMainViewController.h"
#import "TimerPrepVC.h"
#import "UIColor+UIColorExtension.h"
#import "NtrvlsDataStore.h"
//#import "NtrvlWorkout.h"
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
    
    [self createTabataWorkout];
    
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
    
    [self.sharedNtrvlsDataStore fetchWorkouts];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self.tableView reloadData];
}


#pragma mark - create preset workouts 

- (void)createTabataWorkout {
    
    NtrvlWorkout *tabata = [NSEntityDescription insertNewObjectForEntityForName:@"NtrvlWorkout" inManagedObjectContext: self.sharedNtrvlsDataStore.managedObjectContext];
    tabata.workoutTitle = @"TABATA";
    tabata.creationDate = [NSDate timeIntervalSinceReferenceDate];
    
    for (NSUInteger i = 0; i < 10; i++) {

        if (i == 0) {
            
            Ntrvl *getReadyInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: self.sharedNtrvlsDataStore.managedObjectContext];
            getReadyInterval.intervalDuration = 60;
            getReadyInterval.screenColor = @"yellow";
            getReadyInterval.intervalDescription = @"Get ready to start";
            getReadyInterval.workout = tabata;
            getReadyInterval.positionNumberInWorkout = 0;
            getReadyInterval.positionNumberInWorkout = i;
        }
        else if (i == 5) {
            
            Ntrvl *longBreakInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: self.sharedNtrvlsDataStore.managedObjectContext];
            longBreakInterval.intervalDuration = 120;
            longBreakInterval.screenColor = @"grey";
            longBreakInterval.intervalDescription = @"2 minute recovery";
            longBreakInterval.workout = tabata;
            longBreakInterval.positionNumberInWorkout = i;
        }
        
        else if (i % 2 != 0) {
            Ntrvl *firstInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: self.sharedNtrvlsDataStore.managedObjectContext];
            firstInterval.intervalDuration = 90;
            firstInterval.screenColor = @"red";
            firstInterval.intervalDescription = @"Full Speed!";
            firstInterval.workout = tabata;
            firstInterval.positionNumberInWorkout = i;
        }
        else {
            Ntrvl *secondInterval = [NSEntityDescription insertNewObjectForEntityForName:@"Ntrvl" inManagedObjectContext: self.sharedNtrvlsDataStore.managedObjectContext];
            secondInterval.intervalDuration = 10;
            secondInterval.screenColor = @"blue";
            secondInterval.intervalDescription = @"Complete rest";
            secondInterval.workout = tabata;
            secondInterval.positionNumberInWorkout = i;
        }
    }
    
    NSLog(@"TABATA: %@", tabata.interval);
    
    [self.sharedNtrvlsDataStore saveContext];
    
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
    cell.textLabel.text = ((NtrvlWorkout *)self.sharedNtrvlsDataStore.workoutsArray[indexPath.row]).workoutTitle;
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *selectedView = [UIView new];
    selectedView.backgroundColor = [[UIColor ntrvlsRed] colorWithAlphaComponent:0.5];
    cell.selectedBackgroundView = selectedView;
    
    return cell;
}


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


@end
