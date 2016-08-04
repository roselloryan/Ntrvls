//
//  IntervalLabel.h
//  Ntrvls
//
//  Created by RYAN ROSELLO on 7/19/16.
//  Copyright © 2016 RYAN ROSELLO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntervalLabel : UILabel

@property (assign, nonatomic) BOOL isSelected;

- (instancetype)initWithFrame:(CGRect)frame intervalDescription:(NSString *)intervalDescription andDuration:(NSUInteger)duration;

@end
