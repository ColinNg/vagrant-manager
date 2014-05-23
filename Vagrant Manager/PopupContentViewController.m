//
//  PopupContentViewController.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "PopupContentViewController.h"
#import "InstanceMenuItem.h"
#import "MachineMenuItem.h"
#import "InstanceRowView.h"
#import "MenuItemObject.h"

@interface PopupContentViewController ()

@end

@implementation PopupContentViewController {
    BOOL _isRefreshing;
    NSMutableArray *_vagrantInstances;
    NSMutableArray *_menuItems;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _vagrantInstances = [[NSMutableArray alloc] init];
        _menuItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self.moreUpIndicator setHidden:YES];
    [self.moreDownIndicator setHidden:YES];
    [self setIsRefreshing:_isRefreshing];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView.enclosingScrollView setScrollerStyle:NSScrollerStyleOverlay];
    [self.tableView.enclosingScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    [self.tableView.enclosingScrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
    
    [self.tableView.enclosingScrollView.contentView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:self.tableView.enclosingScrollView.contentView];
}

- (void)scrollBoundsDidChange:(id)sender {
    [self updateScrollIndicators];
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        [(InstanceRowView*)rowView checkHover];
    }];
}


#pragma mark - TableView delegates

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _menuItems.count;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[InstanceRowView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [[notification object] selectedRow];
    if(row == -1) {
        return;
    }
    
    [self.tableView deselectRow:row];
    
    MenuItemObject *menuItem = [_menuItems objectAtIndex:row];
    
    if([menuItem.target isKindOfClass:[VagrantInstance class]]) {
        VagrantInstance *instance = menuItem.target;
        
        if(menuItem.isExpanded) {
            long nextRow = row + 1;
            [self.tableView beginUpdates];
            while(nextRow < _menuItems.count && [((MenuItemObject*)[_menuItems objectAtIndex:nextRow]).target isKindOfClass:[VagrantMachine class]]) {
                [_menuItems removeObjectAtIndex:nextRow];
                [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:nextRow] withAnimation:NSTableViewAnimationSlideUp|NSTableViewAnimationEffectFade];
            }
            [self.tableView endUpdates];
            [self performSelector:@selector(resizeTableView) withObject:nil afterDelay:.25f];
        } else {
            int i = 1;
            [self.tableView beginUpdates];
            for(VagrantMachine *machine in instance.machines) {
                [_menuItems insertObject:[[MenuItemObject alloc] initWithTarget:machine] atIndex:row+i];
                [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:row+i] withAnimation:NSTableViewAnimationSlideDown|NSTableViewAnimationEffectFade];
                ++i;
            }
            [self.tableView endUpdates];
            [self resizeTableView];
        }
        
        menuItem.isExpanded = !menuItem.isExpanded;
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    MenuItemObject *itemObj = [_menuItems objectAtIndex:row];
    
    if([itemObj.target isKindOfClass:[VagrantInstance class]]) {
        InstanceMenuItem *item = [tableView makeViewWithIdentifier:@"InstanceMenuItem" owner:self];
        
        VagrantInstance *instance = itemObj.target;
        item.nameTextField.stringValue = instance.displayName;
        
        [self updateScrollIndicators];
        [self resizeTableView];
        
        return item;
    } else if([itemObj.target isKindOfClass:[VagrantMachine class]]) {
        MachineMenuItem *item = [tableView makeViewWithIdentifier:@"MachineMenuItem" owner:self];
        
        VagrantMachine *machine = itemObj.target;
        item.nameTextField.stringValue = machine.name;
        
        [self updateScrollIndicators];
        [self resizeTableView];
        
        return item;
    }
    
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    MenuItemObject *itemObj = [_menuItems objectAtIndex:row];

    if([itemObj.target isKindOfClass:[VagrantInstance class]]) {
        return 20;
    } else {
        return 42;
    }
}

- (float)getTableHeight {
    float height = 0;
    for(MenuItemObject *menuItem in _menuItems) {
        if([menuItem.target isKindOfClass:[VagrantInstance class]]) {
            height += 20;
        } else {
            height += 42;
        }
    }
    
    return height;
}

- (void)updateScrollIndicators {
    [self.moreUpIndicator setHidden:![self hasMoreUp]];
    [self.moreDownIndicator setHidden:![self hasMoreDown]];
}

- (BOOL)hasMoreUp {
    NSRect scrollRect = self.tableView.enclosingScrollView.contentView.documentVisibleRect;
    return scrollRect.origin.y > 0;
}

- (BOOL)hasMoreDown {
    NSRect scrollRect = self.tableView.enclosingScrollView.contentView.documentVisibleRect;
    NSRect frame = ((NSView*)self.tableView.enclosingScrollView.documentView).frame;
    return scrollRect.origin.y + scrollRect.size.height < frame.size.height;
}

- (void)resizeTableView {
    float width = 200;
    for(MenuItemObject *menuItem in _menuItems) {
        NSString *name = [menuItem.target isKindOfClass:[VagrantInstance class]] ? ((VagrantInstance*)menuItem.target).displayName : ((VagrantMachine*)menuItem.target).name;
        NSLog(@"%@", name);
        float padLeft = [menuItem.target isKindOfClass:[VagrantInstance class]] ? 18 : 28;
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:name attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:11]}];
        CGRect rect = [string boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX} options:0];
        float itemWidth = ceil(padLeft + rect.size.width + 18);
        
        if(itemWidth > width) {
            width = itemWidth;
        }
    }
    
    float maxHeight = [[NSScreen mainScreen] frame].size.height - [NSStatusBar systemStatusBar].thickness - 60;
    float tableHeight = MAX(29 + [self getTableHeight], 100);
    
    float height = MIN(maxHeight, tableHeight);

    if([self.statusItemPopup getPopover].isShown) {
        CGRect frame = self.view.frame;
        frame.size.width = width;
        frame.size.height = height;
        [[self.statusItemPopup getPopover] setContentSize:frame.size];
    }
    
    [self updateScrollIndicators];
}

#pragma mark - Control

- (void)setIsRefreshing:(BOOL)isRefreshing {
    _isRefreshing = isRefreshing;
    
    [self.refreshButton setEnabled:!isRefreshing];
    [self.refreshButton setHidden:isRefreshing];
    if(isRefreshing) {
        [self.refreshingIndicator startAnimation:self];
    } else {
        [self.refreshingIndicator stopAnimation:self];
    }
}

#pragma mark - Menu management

- (void)addInstance:(VagrantInstance*)instance {
    [_vagrantInstances addObject:instance];
    [_menuItems addObject:[[MenuItemObject alloc] initWithTarget:instance]];

    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:_menuItems.count - 1] withAnimation:NSTableViewAnimationSlideDown|NSTableViewAnimationEffectFade];
    [self.tableView endUpdates];
    [self resizeTableView];

    /*
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:_vagrantInstances.count - 1] withAnimation:NSTableViewAnimationEffectFade];
    [self.tableView endUpdates];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self resizeTableView];
    }];
     */
//    [self performSelector:@selector(resizeTableView) withObject:nil afterDelay:.2f];
    //[self.tableView reloadData];
}

#pragma mark - Button handlers

- (IBAction)quitButtonClicked:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)preferencesButtonClicked:(id)sender {
    preferencesWindow = [[PreferencesWindow alloc] initWithWindowNibName:@"PreferencesWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [preferencesWindow showWindow:self];
    [self.statusItemPopup hidePopover];
}

- (IBAction)aboutButtonClicked:(id)sender {
    aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
    [NSApp activateIgnoringOtherApps:YES];
    [aboutWindow showWindow:self];
    [self.statusItemPopup hidePopover];    
}

- (IBAction)refreshButtonClicked:(id)sender {
    [[Util getApp] refreshVagrantMachines];
}

@end
