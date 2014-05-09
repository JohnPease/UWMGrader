//
//  GradeTableViewController.m
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "GradeTableViewController.h"
#import "GradeItemViewController.h"
#import "GradeSection.h"
#import "Grade.h"
#import "Course.h"
#import "Parser.h"

@interface GradeTableViewController ()
@property(nonatomic)UIRefreshControl* refreshControl;
@property(nonatomic)Parser* parser;
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
	
	self.parser = [[Parser alloc] init];
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshTableData) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshTableData {
//	[self.d2lWebView stringByEvaluatingJavaScriptFromString:self.course.url];
	self.gradeSections = [self.parser getGradeSectionsFrom:[NSString stringWithContentsOfURL:[NSURL URLWithString:self.course.url] encoding:NSASCIIStringEncoding error:nil]];
	[self.refreshControl endRefreshing];
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.gradeSections.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	GradeSection* gradeSection = [self.gradeSections objectAtIndex:section];
	NSMutableString* header = [NSMutableString stringWithFormat:@"%@", gradeSection.name];
	if (gradeSection.weightAchieved != nil) [header appendFormat:@" (%@)", gradeSection.weightAchieved];
	return header;
}

/* if i want to customize the table section headers... not sure yet */
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
//    /* Create custom view to display section header... */
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, tableView.frame.size.width, 30)];
//    [label setFont:[UIFont boldSystemFontOfSize:24]];
//	GradeSection* gradeSection = [self.gradeSections objectAtIndex:section];
//	NSString *string = gradeSection.name;
//    /* Section header is in 0th index... */
//    [label setText:string];
//    [view addSubview:label];
////    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
//	[view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
//    return view;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GradeSection* gradeSection = [self.gradeSections objectAtIndex:section];
    return gradeSection.grades.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"GradeCell"];
	
    GradeSection* gradeSection = [self.gradeSections objectAtIndex:indexPath.section];
    Grade* grade = [gradeSection.grades objectAtIndex:indexPath.row];
	
    [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", grade.name];
	
	if (grade.weightAchieved != nil) cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, (%@)", grade.score, grade.weightAchieved];
	else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", grade.score];
	
    cell.detailTextLabel.textColor = [UIColor grayColor];
	if (grade.feedback != nil) cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    else cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"GradeDetailSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GradeItemViewController *dest = segue.destinationViewController;
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    GradeSection* gradeSection = [self.gradeSections objectAtIndex:indexPath.section];
    Grade* grade = [gradeSection.grades objectAtIndex:indexPath.row];
	
    dest.navigationItem.title = grade.name;
	dest.grade = grade;
	dest.gradeStatisticsWebView = self.d2lWebView;
}

@end
