//
//  ClassTableViewController.m
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "ClassTableViewController.h"
#import "GradeTableViewController.h"
#import "Parser.h"
#import "Course.h"
#import "Grade.h"

@interface ClassTableViewController ()
@property(nonatomic)int webViewLoads;
@property(nonatomic,strong)Parser* parser;
@end

@implementation ClassTableViewController

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
	self.d2lWebView.delegate = self;
	self.webViewLoads = 0;
	self.parser = [[Parser alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
	/* this is here mainly for when coming from grade viewer to this class */
	NSURL* url = [NSURL URLWithString:@"https://uwm.courses.wisconsin.edu/d2l/m/home"];
	NSURLRequest* request = [NSURLRequest requestWithURL:url];
	[self.d2lWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonPressed {
    /* log out of d2l as well */
    NSHTTPCookie* cookie;
    NSHTTPCookieStorage* jar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [jar cookies]) {
        [jar deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
	[self performSegueWithIdentifier:@"logoutSegue" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.courses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClassCell" forIndexPath:indexPath];
    
    // Configure the cell...
	Course* course = [self.courses objectAtIndex:indexPath.row];
	cell.textLabel.text = course.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Course* course = [self.courses objectAtIndex:indexPath.row];
	[self.d2lWebView stringByEvaluatingJavaScriptFromString:course.url];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.identifier isEqualToString:@"logoutSegue"]) {
		[self.navigationController popViewControllerAnimated:YES];
	} else if ([segue.identifier isEqualToString:@"GradesSegue"]) {
		[self startActivityHud];
		NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
		Course* course = [self.courses objectAtIndex:indexPath.row];
		GradeTableViewController* dest = segue.destinationViewController;
		dest.d2lWebView = self.d2lWebView;
		dest.navigationItem.title = course.name;
		dest.course = course;
		dest.gradeSections = [self.parser getGradeSectionsFrom:[NSString stringWithContentsOfURL:self.d2lWebView.request.URL encoding:NSASCIIStringEncoding error:nil]];
		[self.activityHud hide:YES];
	}
}

#pragma mark - UIWebView
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	Course* course = [self.courses objectAtIndex:[self.tableView indexPathForSelectedRow].row];
	NSString* title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	if ([title isEqualToString:[NSString stringWithFormat:@"Home - %@", course.name]]) {
		[self loadGradesPage];
	} else if ([title isEqualToString:[NSString stringWithFormat:@"Grades - %@ - Milwaukee", course.name]]) {
		/* only perform segue once grades page has been loaded */
		NSLog(@"finished loading grades page");
		[self performSegueWithIdentifier:@"GradesSegue" sender:self];
	}
}

- (void)loadGradesPage {
	NSString* grades = [NSString stringWithFormat:@"https://uwm.courses.wisconsin.edu/d2l/lms/grades/my_grades/main.d2l?ou=%@", self.d2lWebView.request.URL.lastPathComponent];
	NSURL* gradesUrl = [NSURL URLWithString:grades];
	NSURLRequest* request = [NSURLRequest requestWithURL:gradesUrl];
	[self.d2lWebView loadRequest:request];
}

- (void)startActivityHud {
	self.activityHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.activityHud = MBProgressHUDModeIndeterminate;
	self.activityHud.labelText = @"loading";
}


@end
