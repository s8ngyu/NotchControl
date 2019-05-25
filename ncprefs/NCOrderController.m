#import "NCOrderController.h"

@implementation NCOrderController

- (id)initForContentSize:(CGSize)size {
    self = [super init];

    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setEditing:YES animated:YES];
        [_tableView setAllowsSelection:YES];
        [_tableView setAllowsMultipleSelection:NO];
        
        if ([self respondsToSelector:@selector(setView:)])
            [self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];        
    }

    return self;
}

- (id)view {
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Modules";
}

- (void)dealloc { 
    [super dealloc];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    NSString *sectionName;
    switch (section) {
        case 0:
            sectionName = NSLocalizedString(@"Enabled", @"Enbaled");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Disabled", @"Disabled");
            break;
        // ...
        default:
            sectionName = @"";
            break;
    }    
    return sectionName;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

-(NSArray *)getEnabledModules {
    NSMutableArray *allData = [[NSMutableArray alloc] init];

    for (int row = 0; row < [_tableView numberOfRowsInSection:0]; row++) {
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];

        [allData addObject:cell.textLabel.text];
    }

    return allData;
}

-(NSArray *)getDisabledModules {
    NSMutableArray *allData = [[NSMutableArray alloc] init];

    for (int row = 0; row < [_tableView numberOfRowsInSection:1]; row++) {
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];

        [allData addObject:cell.textLabel.text];
    }

    return allData;
}

-(NSArray *)loadEnabledModules {
    NSMutableArray *allData = [[NSMutableArray alloc] init];
    HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.notchcontrol"];

    if ([file objectForKey:@"kEnabledModules"]) {
        allData = [file objectForKey:@"kEnabledModules"];
        
        return allData;
    }

    [allData addObject:@"Now Playing"];
    [allData addObject:@"Music Controller"];
    [allData addObject:@"Clock"];

    return allData;
}

-(NSArray *)loadDisabledModules {
    NSMutableArray *allData = [[NSMutableArray alloc] init];
    HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.notchcontrol"];

    if ([file objectForKey:@"kDisabledModules"]) {
        allData = [file objectForKey:@"kDisabledModules"];
        
        return allData;
    }
    return allData;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.loadEnabledModules.count;
    }

    if (section == 1) {
        return self.loadDisabledModules.count;
    }

    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ModuleCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ModuleCell"];
    }

    if (indexPath.section == 0) {
        NSString *module = [self.loadEnabledModules objectAtIndex:indexPath.row];

        cell.textLabel.text = module;
        cell.selected = NO;
    }
    
    if (indexPath.section == 1) {
        NSString *module = [self.loadDisabledModules objectAtIndex:indexPath.row];

        cell.textLabel.text = module;
        cell.selected = NO;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    //nothing
}

- (void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath {
    HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.notchcontrol"];

    [file setObject:self.getEnabledModules forKey:@"kEnabledModules"];
    [file setObject:self.getDisabledModules forKey:@"kDisabledModules"];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.peterdev.notchcontrol/settingschanged"), nil, nil, true);
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}
@end