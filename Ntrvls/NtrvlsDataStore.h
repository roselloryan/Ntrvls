
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NtrvlWorkout.h"

@interface NtrvlsDataStore : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *workoutsArray;

+ (instancetype)sharedNtrvlsDataStore;

- (void)saveContext;

- (void)fetchWorkouts;

- (void)createTabataWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock;

- (NtrvlWorkout *)copyNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout;

- (void)saveNewWorkoutWithTitle:(NSString *)workoutTitle;

- (void)deleteWorkoutWithTitle:(NSString *)title;

- (BOOL)alreadySavedWorkoutWithTitle:(NSString *)title;

- (void)addNewNtrvlToWorkout:(NtrvlWorkout *)ntrvlWorkout;

- (void)deleteNtrvl:(Ntrvl *)ntrvl fromNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout;

- (void)workoutDescriptionStringForNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout withCompletionBlock:(void(^)(BOOL complete, NSString *workoutDescriptionString))completionBlock;

- (void)saveWorkoutType:(NSString *)workouType forNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout;


@end
