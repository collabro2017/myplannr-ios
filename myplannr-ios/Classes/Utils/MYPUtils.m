//
//  MYPUtils.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 17/09/16.
//
//

#import "MYPUtils.h"

@implementation MYPUtils

+ (void)shakeView:(UIView *) view {
    const int reset = 5;
    const int maxShakes = 6;
    
    // pass these as variables instead of statics or class variables if shaking two controls simultaneously
    static int shakes = 0;
    static int translate = reset;
    
    [UIView animateWithDuration:0.09 - (shakes * .01) // reduce duration every shake from .09 to .04
                          delay:0.01f // edge wait delay
                        options:(enum UIViewAnimationOptions) UIViewAnimationCurveEaseInOut
                     animations:^{view.transform = CGAffineTransformMakeTranslation(translate, 0);}
                     completion:^(BOOL finished){
                         if(shakes < maxShakes){
                             shakes++;
                             
                             // throttle down movement
                             if (translate > 0)
                             translate--;
                             
                             //change direction
                             translate *= -1;
                             [self shakeView:view];
                         } else {
                             view.transform = CGAffineTransformIdentity;
                             shakes = 0; //ready for next time
                             translate = reset; //ready for next time
                             return;
                         }
                     }];
}

@end
