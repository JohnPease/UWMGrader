//
//  ClassTableViewController.m
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "LogInViewController.h"
#import "ClassTableViewController.h"
#import "GradeTableViewController.h"
#import "Parser.h"
#import "Course.h"
#import "Grade.h"
#import "Reachability.h"

@interface ClassTableViewController ()
@property(nonatomic)int webViewLoads;
@property(nonatomic,strong)Parser* parser;
@property(nonatomic)MBProgressHUD* activityHud;
@property(nonatomic)UIRefreshControl* refreshControl;
@property(nonatomic)Reachability* reachability;
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
	
	self.d2lWebView.delegate	= self;
	self.webViewLoads			= 0;
	self.parser					= [[Parser alloc] init];
	self.refreshControl			= [[UIRefreshControl alloc] init];
	self.reachability			= [[Reachability alloc] init];
	
	[self.tableView addSubview:self.refreshControl];
	[self.refreshControl addTarget:self action:@selector(refreshTableData) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
	/* this is here mainly for when coming from grade viewer to this class */
	NSURL* url = [NSURL URLWithString:@"https://uwm.courses.wisconsin.edu/d2l/m/home"];
	NSURLRequest* request = [NSURLRequest requestWithURL:url];
	[self.d2lWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refreshTableData {
	if (![self.reachability networkConnection]) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Network Connection Error" message:@"You need a network connection to do this" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
		[self.refreshControl endRefreshing];
		return;
	}
	self.courses = [self.parser getCoursesFrom:[NSString stringWithContentsOfURL:self.d2lWebView.request.URL encoding:NSASCIIStringEncoding error:nil]];
	[self.refreshControl endRefreshing];
	[self.tableView reloadData];
}

- (IBAction)logoutButtonPressed {
    /* log out of d2l using javascript function from mobile site (Note: this only works on mobile site) */
    NSString* logoutJs = @"D2L.O(\"__g1\",15)();";
    [self.d2lWebView stringByEvaluatingJavaScriptFromString:logoutJs];
    /* load d2l login site */
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:D2LLoginUrl]];
    [self.d2lWebView loadRequest:request];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.courses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClassCell" forIndexPath:indexPath];
    
	Course* course		= [self.courses objectAtIndex:indexPath.row];
	cell.textLabel.text = course.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Course* course = [self.courses objectAtIndex:indexPath.row];
    if (course.gradeSections.count == 0) {
        [self startActivityHud];
        [self.d2lWebView stringByEvaluatingJavaScriptFromString:course.url];
    } else {
        [self performSegueWithIdentifier:@"GradesSegue" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if (![self.reachability networkConnection]) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Network Connection Error" message:@"You need a network connection to do this" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
		return;
	}
	if ([segue.identifier isEqualToString:@"logoutSegue"]) {
		[self.navigationController popViewControllerAnimated:YES];
	} else if ([segue.identifier isEqualToString:@"GradesSegue"]) {
		NSIndexPath* indexPath	= [self.tableView indexPathForSelectedRow];
		Course* course			= [self.courses objectAtIndex:indexPath.row];
        
		/* only get grades if they haven't been retrieved yet */
        if (course.gradeSections.count == 0) {
            [self startActivityHud];
            course.gradeSections = [self.parser getGradeSectionsFrom:[NSString stringWithContentsOfURL:self.d2lWebView.request.URL encoding:NSASCIIStringEncoding error:nil]];
        }
        
		GradeTableViewController* dest	= segue.destinationViewController;
		dest.d2lWebView					= self.d2lWebView;
		dest.navigationItem.title		= course.name;
		dest.course						= course;
        dest.gradeSections				= course.gradeSections;
		
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		[self.tableView cellForRowAtIndexPath:indexPath].selected = NO;
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
		[self performSegueWithIdentifier:@"GradesSegue" sender:self];
	} else if ([webView.request.URL.absoluteString isEqualToString:@"https://idp.uwm.edu/idp/logout.jsp"]) {
        [self.navigationController popViewControllerAnimated:YES];
        [self performSegueWithIdentifier:@"logoutSegue" sender:self];
    }
}

- (void)loadGradesPage {
	NSString* grades = [NSString stringWithFormat:@"https://uwm.courses.wisconsin.edu/d2l/lms/grades/my_grades/main.d2l?ou=%@", self.d2lWebView.request.URL.lastPathComponent];
	NSURL* gradesUrl = [NSURL URLWithString:grades];
	NSURLRequest* request = [NSURLRequest requestWithURL:gradesUrl];
	
	/* update the course.url to the actual url so that refreshing in grade table is possible */
	Course* course = [self.courses objectAtIndex:[self.tableView indexPathForSelectedRow].row];
	course.url = grades;
	
	[self.d2lWebView loadRequest:request];
}

- (void)startActivityHud {
	self.activityHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.activityHud = MBProgressHUDModeIndeterminate;
	self.activityHud.labelText = @"loading";
}

@end
