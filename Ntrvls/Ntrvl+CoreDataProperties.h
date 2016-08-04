//
//  Ntrvl+CoreDataProperties.h
//  Ntrvls
//
//  Created by RYAN ROSELLO on 7/12/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Ntrvl.h"
#import "NtrvlWorkout.h"

NS_ASSUME_NONNULL_BEGIN

@interface Ntrvl (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *screenColor;
@property (nonatomic) int64_t intervalDuration;
@property (nullable, nonatomic, retain) NSString *intervalDescription;
@property (nonatomic) int64_t positionNumberInWorkout;
@property (nullable, nonatomic, retain) NtrvlWorkout *workout;

@end

NS_ASSUME_NONNULL_END
