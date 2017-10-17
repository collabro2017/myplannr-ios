//
//  MYPTableView.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 27/12/2016.
//
//

#import "MYPTableView.h"

@implementation MYPTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setupTableView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupTableView];
    }
    return self;
}

#pragma mark - Private methods

- (void)setupTableView {
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

@end
