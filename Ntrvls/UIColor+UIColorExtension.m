//
//  UIColor+UIColorExtension.m
//  Ntrvls


#import "UIColor+UIColorExtension.h"

@implementation UIColor (UIColorExtension)

+ (UIColor *) ntrvlsRed {
    return [UIColor colorWithRed: 207.0f/255.0f green: 0.0f/255.0f blue: 15.0f/255.0f alpha: 0.85f];
}
+ (UIColor *) ntrvlsGrey {
    return [UIColor colorWithRed: 71.0f/255.0f green: 77.0f/255.0f blue: 89.0f/255.0f alpha: 1.0f];
}

+ (UIColor *) ntrvlsYellow {
    return [UIColor colorWithRed: 232.0f/255.0f green: 166.0f/255.0f blue: 16.0f/255.0f alpha: 0.85f];
}

+ (UIColor *) ntrvlsGreen {
    return [UIColor colorWithRed: 31.0f/255.0f green: 193.0f/255.0f blue: 116.0f/255.0f alpha: 0.85f];
}

+ (UIColor *) ntrvlsBlue {
    return [[UIColor cyanColor] colorWithAlphaComponent: 0.85];
}

@end
