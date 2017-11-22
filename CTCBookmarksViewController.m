//
//  CTCBookmarksViewController.m
//
//  Created by Byron Ruth on 1/26/10.
//  Copyright The Children's Hospital of Philadelphia 2010. All rights reserved.
//

#import "CTCBookmarksViewController.h"
#import "CTCGradeController.h"


@implementation CTCBookmarksViewController

@synthesize bookmarkManager, dao;


- (void)viewDidLoad {
    [super viewDidLoad];
	@try {
		self.bookmarkManager = [CTCBookmarkManager sharedInstance];
	}
	@catch (NSException * e) {
       //***NEW
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                            message:@"Bookmarks file appears to be corrupt. This error will be corrected, but bookmarks will be lost" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok"
                                                          style: UIAlertActionStyleCancel
                                                        handler: ^(UIAlertAction *action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        //**end NEW
        /* Deprecated
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" 
														message: @"Bookmarks file appears to be corrupt. This error will be corrected, but bookmarks will be lost"
													   delegate: nil 
											  cancelButtonTitle: @"OK" 
											  otherButtonTitles: nil];
        [alert show];
         */
		
		[alert release];
		[CTCBookmarkManager cleanBookmarks];
		self.bookmarkManager = [CTCBookmarkManager sharedInstance];
		
	}
	@finally {
		self.title = @"Bookmarks";
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	//bookmarks get added in other parts of the app; this refreshes the table
 	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	//Disable bookmark editing when the user leaves the screen
	[self setEditing:NO animated:YES]; 
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// specify the identifier to use with the tableView
	static NSString *cellIdentifier = @"BookmarkCell";
    
    // if cell is not available, initialize a new one
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		// apply styling
		cell.textLabel.font =  [cell.textLabel.font fontWithSize: 16];
		[cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        [cell.textLabel setMinimumScaleFactor:10]; //new
        //deprecated [cell.textLabel setMinimumFontSize:10];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping; //new
		//deprecated cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation | UILineBreakModeWordWrap;
		cell.textLabel.numberOfLines = 0;
    }
    
	// lookup in the bookmarks which cell this is refering and get the label
	cell.textLabel.text = [bookmarkManager.bookmarks objectAtIndex:indexPath.row];
	
    return cell;
}


#pragma mark UITableViewDelegate methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *event = [self.bookmarkManager.bookmarks objectAtIndex:indexPath.row];
	
	CTCGradeController *gradeController = [[CTCGradeController alloc] initWithNibName:@"CTCGradeView" bundle:nil];
	gradeController.event = event;
	
	[self.navigationController pushViewController:gradeController animated:YES];
	[gradeController release];
}


#pragma mark UITableViewDataSource methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.bookmarkManager.bookmarks count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		@try {
			[self.bookmarkManager deleteBookmarkAtIndex:indexPath.row];
		}
		@catch (NSException * e) {
            //***NEW
            UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Error"
                                                                         message:@"Problem deleting bookmark" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok"
                                                                    style: UIAlertActionStyleCancel
                                                                  handler: ^(UIAlertAction *action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            //***END NEW
			
            /*Deprecated
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
															message: @"Problem deleting bookmark"
														   delegate: nil 
												  cancelButtonTitle: @"OK" 
												  otherButtonTitles: nil];
			[alert show];
             */
			[alert release];
		}
		// Tell the table view that it should reflect the change
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
	
}

#pragma mark row movement
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	@try {
		[self.bookmarkManager moveBookmarkFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
	}
	@catch (NSException * e) {
        //***NEW
        UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Error"
                                                                      message:@"Problem updating bookmarks" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok"
                                                                style: UIAlertActionStyleCancel
                                                              handler: ^(UIAlertAction *action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        // ***END NEW
        
        /*Deprecated
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" 
														message: @"Problem updating bookmarks"
													   delegate: nil 
											  cancelButtonTitle: @"OK" 
											  otherButtonTitles: nil];
		[alert show];
         */
		[alert release];
	}
	
}

- (void)dealloc {
	[dao release];
    [super dealloc];
}

@end
