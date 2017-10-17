//
//  MYPColorPickerViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 30/05/2017.
//
//

#import "MYPColorPickerViewController.h"
#import "HRColorMapView.h"

@implementation MYPColorPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.color) {
        self.color = [UIColor yellowColor];
    }
    
    self.colorPickerView.color = self.color;
    self.colorPickerView.colorMapView.saturationUpperLimit = @0.9;
    
    [self.colorPickerView addTarget:self
                             action:@selector(colorDidChange:)
                   forControlEvents:UIControlEventValueChanged];
}

- (void)colorDidChange:(HRColorPickerView *)colorPickerView {
    self.color = colorPickerView.color;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.colorPickerView.color = color;
}

#pragma mark - Action handlers

- (IBAction)handleDoneBarButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:
     ^{
         SEL selector = @selector(colorPickerViewController:didPickColor:);
         if ([self.delegate respondsToSelector:selector]) {
             [self.delegate colorPickerViewController:self didPickColor:self.color];
         }
     }];
}

- (IBAction)handleCancelBarButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
