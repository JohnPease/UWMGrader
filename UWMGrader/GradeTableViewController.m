//
//  GradeTableViewController.m
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "GradeTableViewController.h"
#import "GradeSection.h"
#import "Grade.h"
#import "Course.h"
#import "Parser.h"

@interface GradeTableViewController ()
@end

@implementation GradeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	NSLog(@"entered grades");
}

- (void)viewWillDisappear:(BOOL)animated {
	NSArray* viewControllers = self.navigationController.viewControllers;
	if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
		//pushed another controller on
	} else if ([viewControllers indexOfObject:self] == NSNotFound) {
		//popped, going back to classes and loading mobile d2l homepage
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return self.gradeSections.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	GradeSection* gradeSection = [self.gradeSections objectAtIndex:section];
	return gradeSection.name;
}

- (NSInteger)getIndex:(NSInteger)index withSection:(NSInteger)section {
	for (int i = 0; i < section; ++i) {
		GradeSection* gradeSection = [self.gradeSections objectAtIndex:i];
		index += gradeSection.grades.count;
	}
	return index;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.gradeSections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GradeCell" forIndexPath:indexPath];
    
    // Configure the cell...
	/* NEED TO FIGURE THIS OUT */
	/*
	 notes: get section, get correct grade from that section
	 */
	
	return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
