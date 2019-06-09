#include "NCRootListController.h"

@implementation NCRootListController
- (instancetype)init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.navigationController.navigationController.navigationBar.translucent = YES;
}

- (void)respring:(id)sender {
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/sbreload"]) {
        //sbreload
        pid_t pid;
        const char* args[] = {"sbreload", NULL};
        posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
    } else {
        //common respring
        pid_t pid;
        const char* args[] = {"killall", "backboardd", NULL};
        posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
    }
}

- (void)resetPrefs:(id)sender {
    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.notchcontrol"];
    [prefs removeAllObjects];

    [self respring:sender];
}
@end
