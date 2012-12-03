//
//  GradientView.h
//  iGrow
//
//  Created by Andrew Molloy on 5/15/09.
//  Copyright 2011 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientView : UIView

@property (strong, nonatomic) UIColor* topColor;
@property (strong, nonatomic) UIColor* bottomColor;
@property (nonatomic, assign) CGFloat sideways;

@end
