
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NtrvlWorkout.h"
#import "NtrvlsConstants.h"

@interface NtrvlsDataStore : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *workoutsArray;

+ (instancetype)sharedNtrvlsDataStore;

- (void)saveContext;

- (void)fetchWorkouts;

- (void)createTabataWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock;

- (void)createNewWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock;

- (void)createOverUndersWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock;

- (void)createDemoWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock;

- (void)createMixedRPMAndPowerWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock;

- (void)createPowerOverUndersWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock;

- (void)createPlanksWorkoutWithCompletionBlock:(void (^)(BOOL complete))completionBlock;

- (NtrvlWorkout *)copyNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout;

- (void)saveCopyAsNewWorkoutWithTitle:(NSString *)workoutTitle;

- (void)deleteWorkoutWithTitle:(NSString *)title;

- (void)overwriteWorkoutWithTitle:(NSString *)title;

- (BOOL)alreadySavedWorkoutWithTitle:(NSString *)title;

- (void)addNewNtrvlToWorkout:(NtrvlWorkout *)ntrvlWorkout;

- (void)deleteNtrvl:(Ntrvl *)ntrvl fromNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout;

- (void)workoutDescriptionStringForNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout withCompletionBlock:(void(^)(BOOL complete, NSString *workoutDescriptionString))completionBlock;

- (void)saveWorkoutType:(NSString *)workouType forNtrvlWorkout:(NtrvlWorkout *)ntrvlWorkout;

- (NSInteger)totalTimeForWorkout:(NtrvlWorkout *)ntrvlWorkout;

@end
