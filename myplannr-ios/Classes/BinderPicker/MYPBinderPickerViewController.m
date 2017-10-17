//
//  MYPBinderPickerViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 15/11/2016.
//
//

#import "MYPBinderPickerViewController.h"
#import "MYPBinderCollectionViewCell.h"
#import "MYPBinder.h"
#import "MYPUser.h"

static CGFloat const kCellHeight = 55.0f;
static CGFloat const kColorImageSize = 25.0f;

@implementation MYPBinderPickerViewController

static NSString * const kBinderCellIdentifier = @"BinderCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.binders.count > 0, @"Illegal state: binders.count == 0");
    NSAssert(self.documentData, @"Illegal state: documentData == nil");
    NSAssert(self.fileName.length > 0, @"Illegal state: fileName is empty");
    NSAssert(self.mimeType.length > 0, @"Illegal state: mimeType is empty");
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.tableView.backgroundColor = [UIColor myp_colorWithHexInt:0xF1F1F1];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.binders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBinderCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kBinderCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showTabPickerController" sender:cell];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTabPickerController"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        MYPBinder *binder = self.binders[path.row];
        UIViewController *destinationVC = segue.destinationViewController;
        [destinationVC setValue:binder forKey:@"binder"];
        [destinationVC setValue:self.documentData forKey:@"documentData"];
        [destinationVC setValue:self.fileName forKey:@"fileName"];
        [destinationVC setValue:self.mimeType forKey:@"mimeType"];
    }
}

#pragma mark - Action handlers

- (IBAction)handleCancelBarButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MYPBinder *binder = self.binders[indexPath.row];
    cell.textLabel.text = binder.name;
    cell.detailTextLabel.text = [[NSDateFormatter myp_clientDateFormatter] stringFromDate:binder.eventDate];
    
    UIImage *image = [UIImage myp_imageWithColor:binder.color andSize:CGSizeMake(kColorImageSize, kColorImageSize)];
    cell.imageView.image = [image myp_circleImage];
}

@end
