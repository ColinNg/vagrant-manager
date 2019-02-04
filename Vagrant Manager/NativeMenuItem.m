//
//  NativeMenuItem.m
//  Vagrant Manager
//
//  Copyright (c) 2014 Lanayo. All rights reserved.
//

#import "NativeMenuItem.h"
#import "BookmarkManager.h"
#import "CustomCommandManager.h"

@implementation NativeMenuItem {
    NSMenu *_submenu;
    
    NSMenuItem *_instanceUpMenuItem;
    NSMenuItem *_instanceUpProvisionMenuItem;
    NSMenuItem *_sshMenuItem;
    NSMenuItem *_rdpMenuItem;
    NSMenuItem *_instanceReloadMenuItem;
    NSMenuItem *_instanceSuspendMenuItem;
    NSMenuItem *_instanceHaltMenuItem;
    NSMenuItem *_instanceDestroyMenuItemPlaceholder;
    NSMenuItem *_instanceDestroyMenuItem;
    NSMenuItem *_instanceProvisionMenuItem;
    NSMenuItem *_instanceCustomCommandMenuItem;
    
    NSMenuItem *_editVagrantfileMenuItem;
    NSMenuItem *_openInFinderMenuItem;
    NSMenuItem *_openInTerminalMenuItem;
    NSMenuItem *_addBookmarkMenuItem;
    NSMenuItem *_removeBookmarkMenuItem;
    NSMenuItem *_chooseProviderMenuItem;
    
    NSMenuItem *_machineSeparator;
    NSMenuItem *_actionSeparator;
    
    NSMutableArray *_machineMenuItems;
}

- (id)init {
    self = [super init];
    if(self) {
        _machineMenuItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return [menuItem isEnabled];
}

- (void)refresh {
    
    if(self.instance) {
        
        NSArray *customCommands = [[CustomCommandManager sharedManager] getCustomCommands];
        
        if ([self.instance getRunningMachineCount] == 0) {
            // only show custom commands that run on the host since no machines are up
            NSMutableArray *hostCustomCommands = [NSMutableArray new];
            for (CustomCommand *customCommand in customCommands) {
                if (customCommand.runOnHost) {
                    [hostCustomCommands addObject:customCommand];
                }
            }
            
            customCommands = hostCustomCommands;
        }
        
        if(!_submenu) {
            _submenu = [[NSMenu alloc] init];
            [_submenu setAutoenablesItems:NO];
            _submenu.delegate = self;
        }
        
        if(!self.menuItem.hasSubmenu) {
            self.menuItem.submenu = _submenu;
        }
        
        if(!_instanceUpMenuItem) {
            _instanceUpMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"Up All" : @"Up" action:@selector(upAllMachines:) keyEquivalent:@""];
            _instanceUpMenuItem.target = self;
            _instanceUpMenuItem.image = [NSImage imageNamed:@"up"];
            [_instanceUpMenuItem.image setTemplate:YES];
            [_submenu addItem:_instanceUpMenuItem];
        } else {
            _instanceUpMenuItem.title = self.instance.machines.count > 1 ? @"Up All" : @"Up";
        }
        
        if(!_instanceUpProvisionMenuItem) {
            _instanceUpProvisionMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"Up All (with provision)" : @"Up (with provision)" action:@selector(upProvisionAllMachines:) keyEquivalent:@""];
            _instanceUpProvisionMenuItem.target = self;
            _instanceUpProvisionMenuItem.image = [NSImage imageNamed:@"up"];
            [_instanceUpProvisionMenuItem.image setTemplate:YES];
            [_submenu addItem:_instanceUpProvisionMenuItem];
        } else {
            _instanceUpProvisionMenuItem.title = self.instance.machines.count > 1 ? @"Up All (with provision)" : @"Up (with provision)";
        }
        
        if(!_sshMenuItem) {
            _sshMenuItem = [[NSMenuItem alloc] initWithTitle:@"SSH" action:@selector(sshInstance:) keyEquivalent:@""];
            _sshMenuItem.target = self;
            _sshMenuItem.image = [NSImage imageNamed:@"ssh"];
            [_sshMenuItem.image setTemplate:YES];
            [_submenu addItem:_sshMenuItem];
        }

        if(!_rdpMenuItem) {
            _rdpMenuItem = [[NSMenuItem alloc] initWithTitle:@"RDP" action:@selector(rdpInstance:) keyEquivalent:@""];
            _rdpMenuItem.target = self;
            _rdpMenuItem.image = [NSImage imageNamed:@"rdp"];
            [_rdpMenuItem.image setTemplate:YES];
            [_submenu addItem:_rdpMenuItem];
        }

        if(!_instanceReloadMenuItem) {
            _instanceReloadMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"Reload All" : @"Reload" action:@selector(reloadAllMachines:) keyEquivalent:@""];
            _instanceReloadMenuItem.target = self;
            _instanceReloadMenuItem.image = [NSImage imageNamed:@"reload"];
            [_instanceReloadMenuItem.image setTemplate:YES];
            [_submenu addItem:_instanceReloadMenuItem];
        } else {
            _instanceReloadMenuItem.title = self.instance.machines.count > 1 ? @"Reload All" : @"Reload";
        }
        
        if(!_instanceSuspendMenuItem) {
            _instanceSuspendMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"Suspend All" : @"Suspend" action:@selector(suspendAllMachines:) keyEquivalent:@""];
            _instanceSuspendMenuItem.target = self;
            _instanceSuspendMenuItem.image = [NSImage imageNamed:@"suspend"];
            [_instanceSuspendMenuItem.image setTemplate:YES];
            [_submenu addItem:_instanceSuspendMenuItem];
        } else {
            _instanceSuspendMenuItem.title = self.instance.machines.count > 1 ? @"Suspend All" : @"Suspend";
        }
        
        if(!_instanceHaltMenuItem) {
            _instanceHaltMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"Halt All" : @"Halt" action:@selector(haltAllMachines:) keyEquivalent:@""];
            _instanceHaltMenuItem.target = self;
            _instanceHaltMenuItem.image = [NSImage imageNamed:@"halt"];
            [_instanceHaltMenuItem.image setTemplate:YES];
            [_submenu addItem:_instanceHaltMenuItem];
        } else {
            _instanceHaltMenuItem.title = self.instance.machines.count > 1 ? @"Halt All" : @"Halt";
        }
        
        BOOL optionKeyDestroy = [[NSUserDefaults standardUserDefaults] boolForKey:@"optionKeyDestroy"];
        
        if(!_instanceDestroyMenuItemPlaceholder) {
            _instanceDestroyMenuItemPlaceholder = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"Destroy All" : @"Destroy" action:nil keyEquivalent:@""];
            _instanceDestroyMenuItemPlaceholder.image = [NSImage imageNamed:@"destroy"];
            [_instanceDestroyMenuItemPlaceholder.image setTemplate:YES];
            _instanceDestroyMenuItemPlaceholder.enabled = NO;
            [_submenu addItem:_instanceDestroyMenuItemPlaceholder];
        } else {
            _instanceDestroyMenuItemPlaceholder.title = self.instance.machines.count > 1 ? @"Destroy All" : @"Destroy";
        }

        if(!optionKeyDestroy) {
            _instanceDestroyMenuItemPlaceholder.hidden = YES;
        }
        
        if(!_instanceDestroyMenuItem) {
            _instanceDestroyMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"Destroy All" : @"Destroy" action:@selector(destroyAllMachines:) keyEquivalent:@""];
            _instanceDestroyMenuItem.target = self;
            _instanceDestroyMenuItem.image = [NSImage imageNamed:@"destroy"];
            [_instanceDestroyMenuItem.image setTemplate:YES];
            [_submenu addItem:_instanceDestroyMenuItem];
        } else {
            _instanceDestroyMenuItem.title = self.instance.machines.count > 1 ? @"Destroy All" : @"Destroy";
        }
        
        if(optionKeyDestroy) {
            _instanceDestroyMenuItem.alternate = YES;
            _instanceDestroyMenuItem.keyEquivalentModifierMask = NSAlternateKeyMask;
        } else {
            _instanceDestroyMenuItem.alternate = NO;
        }
        
        if(!_instanceProvisionMenuItem) {
            _instanceProvisionMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"Provision All" : @"Provision" action:@selector(provisionAllMachines:) keyEquivalent:@""];
            _instanceProvisionMenuItem.target = self;
            _instanceProvisionMenuItem.image = [NSImage imageNamed:@"provision"];
            [_instanceProvisionMenuItem.image setTemplate:YES];
            [_submenu addItem:_instanceProvisionMenuItem];
        } else {
            _instanceProvisionMenuItem.title = self.instance.machines.count > 1 ? @"Provision All" : @"Provision";
        }
        
        if(!_instanceCustomCommandMenuItem) {
            _instanceCustomCommandMenuItem = [[NSMenuItem alloc] initWithTitle:self.instance.machines.count > 1 ? @"Custom Command All" : @"Custom Command" action:nil keyEquivalent:@""];
            _instanceCustomCommandMenuItem.target = self;
            
            [_submenu addItem:_instanceCustomCommandMenuItem];
            _instanceCustomCommandMenuItem.submenu = [[NSMenu alloc] init];
            [_instanceCustomCommandMenuItem.submenu setAutoenablesItems:NO];
        } else {
            _instanceCustomCommandMenuItem.title = self.instance.machines.count > 1 ? @"Custom Command All" : @"Custom Command";
        }

        [_instanceCustomCommandMenuItem.submenu removeAllItems];
        if(customCommands.count > 0) {
            _instanceCustomCommandMenuItem.hidden = NO;
            
            for(CustomCommand *customCommand in customCommands) {
                NSMenuItem *customCommandMenuItem = [[NSMenuItem alloc] initWithTitle:customCommand.displayName action:@selector(customCommandAllMachines:) keyEquivalent:@""];
                customCommandMenuItem.target = self;
                customCommandMenuItem.representedObject = customCommand;
                
                [_instanceCustomCommandMenuItem.submenu addItem:customCommandMenuItem];
            }
        } else {
            _instanceCustomCommandMenuItem.hidden = YES;
        }
        
        
        if (!_actionSeparator) {
            _actionSeparator = [NSMenuItem separatorItem];
           [_submenu addItem:[NSMenuItem separatorItem]];
        }
        
        if (!_editVagrantfileMenuItem) {
            _editVagrantfileMenuItem = [[NSMenuItem alloc] initWithTitle:@"Edit Vagrantfile" action:@selector(editVagrantfileMenuItemClicked:) keyEquivalent:@""];
            _editVagrantfileMenuItem.target = self;
            [_submenu addItem:_editVagrantfileMenuItem];
        }

        if (!_openInFinderMenuItem) {
            _openInFinderMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open in Finder" action:@selector(finderMenuItemClicked:) keyEquivalent:@""];
            _openInFinderMenuItem.target = self;
            [_submenu addItem:_openInFinderMenuItem];
        }
        
        if (!_openInTerminalMenuItem) {
            _openInTerminalMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open in Terminal" action:@selector(terminalMenuItemClicked:) keyEquivalent:@""];
            _openInTerminalMenuItem.target = self;
            [_submenu addItem:_openInTerminalMenuItem];
        }
        
        if (!_chooseProviderMenuItem) {
            _chooseProviderMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Provider: %@", self.instance.providerIdentifier ?: @"Unknown"] action:nil keyEquivalent:@""];
            [_submenu addItem:_chooseProviderMenuItem];
        }
        
        NSMenu *submenu = [[NSMenu alloc] init];
        [submenu setAutoenablesItems:NO];
        NSArray *providerIdentifiers = [[VagrantManager sharedManager] getProviderIdentifiers];
        for(NSString *providerIdentifier in providerIdentifiers) {
            NSMenuItem *submenuItem = [[NSMenuItem alloc] initWithTitle:providerIdentifier action:@selector(updateProviderIdentifier:) keyEquivalent:@""];
            submenuItem.representedObject = providerIdentifier;
            submenuItem.target = self;
            [submenu addItem:submenuItem];
        }
        
        [_chooseProviderMenuItem setSubmenu:submenu];
        _chooseProviderMenuItem.title = [NSString stringWithFormat:@"Provider: %@", self.instance.providerIdentifier ?: @"Unknown"];
        
        if (!_removeBookmarkMenuItem) {
            _removeBookmarkMenuItem = [[NSMenuItem alloc] initWithTitle:@"Remove from bookmarks" action:@selector(removeBookmarkMenuItemClicked:) keyEquivalent:@""];
            _removeBookmarkMenuItem.target = self;
            [_submenu addItem:_removeBookmarkMenuItem];
        }
        
        if (!_addBookmarkMenuItem) {
            _addBookmarkMenuItem = [[NSMenuItem alloc] initWithTitle:@"Add to bookmarks" action:@selector(addBookmarkMenuItemClicked:) keyEquivalent:@""];
            _addBookmarkMenuItem.target = self;
            [_submenu addItem:_addBookmarkMenuItem];
        }
        
        Bookmark *bookmark = [[BookmarkManager sharedManager] getBookmarkWithPath:self.instance.path];
        
        if([self.instance hasVagrantfile]) {
            int runningCount = [self.instance getRunningMachineCount];
            int suspendedCount = [self.instance getMachineCountWithState:SavedState];
            if(runningCount == 0 && suspendedCount == 0) {
                self.menuItem.image = [NSImage imageNamed:bookmark ? @"bm_status_icon_off" : @"status_icon_off"];
            } else if(runningCount == self.instance.machines.count) {
                self.menuItem.image = [NSImage imageNamed:bookmark ? @"bm_status_icon_on" : @"status_icon_on"];
            } else {
                self.menuItem.image = [NSImage imageNamed:bookmark ? @"bm_status_icon_suspended" : @"status_icon_suspended"];
            }
            
            if([self.instance getRunningMachineCount] < self.instance.machines.count) {
                [_instanceUpMenuItem setHidden:NO];
                [_instanceUpProvisionMenuItem setHidden:NO];
                [_sshMenuItem setHidden:YES];
                [_rdpMenuItem setHidden:YES];
                [_instanceReloadMenuItem setHidden:YES];
                [_instanceSuspendMenuItem setHidden:YES];
                [_instanceHaltMenuItem setHidden:YES];
                [_instanceProvisionMenuItem setHidden:YES];
            }
            
            if([self.instance getRunningMachineCount] > 0) {
                [_instanceUpMenuItem setHidden:YES];
                [_instanceUpProvisionMenuItem setHidden:YES];
                [_sshMenuItem setHidden:NO];
                [_rdpMenuItem setHidden:NO];
                [_instanceReloadMenuItem setHidden:NO];
                [_instanceSuspendMenuItem setHidden:NO];
                [_instanceHaltMenuItem setHidden:NO];
                [_instanceProvisionMenuItem setHidden:NO];
            }
            
            if (self.instance.machines.count > 1) {
                [_sshMenuItem setHidden:YES];
                [_rdpMenuItem setHidden:YES];
            }
            
            if([[BookmarkManager sharedManager] getBookmarkWithPath:self.instance.path]) {
                [_removeBookmarkMenuItem setHidden:NO];
                [_addBookmarkMenuItem setHidden:YES];
            } else {
                [_addBookmarkMenuItem setHidden:NO];
                [_removeBookmarkMenuItem setHidden:YES];
            }
            
        } else {
            self.menuItem.image = [NSImage imageNamed:@"status_icon_problem"];
            self.menuItem.submenu = nil;
        }
        
        NSString *title;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"usePathAsInstanceDisplayName"]) {
            title = self.instance.path;
        } else {
            title = self.instance.displayName;                
        }
        
        if(self.instance.machines.count > 0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"includeMachineNamesInMenu"]) {
            NSMutableArray *machineNames = [[NSMutableArray alloc] init];
            for(VagrantMachine *machine in self.instance.machines) {
                [machineNames addObject:machine.name];
            }
            title = [title stringByAppendingString:[NSString stringWithFormat:@" (%@)", [machineNames componentsJoinedByString:@", "]]];
        }
        
        self.menuItem.title = title;
        
        if(!_machineSeparator) {
            _machineSeparator = [NSMenuItem separatorItem];
            [_submenu addItem:_machineSeparator];
        }
        
        //destroy machine menu items
        for(NSMenuItem *machineItem in _machineMenuItems) {
            [_submenu removeItem:machineItem];
        }
        
        [_machineMenuItems removeAllObjects];
        
        //build machine submenus
        if(self.instance.machines.count > 1) {
            [_machineSeparator setHidden:NO];
            
            for(VagrantMachine *machine in self.instance.machines) {
                NSMenuItem *machineItem = [[NSMenuItem alloc] initWithTitle:machine.name action:nil keyEquivalent:@""];
                NSMenu *machineSubmenu = [[NSMenu alloc] init];
                [machineSubmenu setAutoenablesItems:NO];
                machineSubmenu.delegate = self;
                
                NSMenuItem *machineUpMenuItem = [[NSMenuItem alloc] initWithTitle:@"Up" action:@selector(upMachine:) keyEquivalent:@""];
                machineUpMenuItem.target = self;
                machineUpMenuItem.representedObject = machine;
                machineUpMenuItem.image = [NSImage imageNamed:@"up"];
                [machineUpMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineUpMenuItem];
                
                NSMenuItem *machineUpProvisionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Up (with provision)" action:@selector(upProvisionMachine:) keyEquivalent:@""];
                machineUpProvisionMenuItem.target = self;
                machineUpProvisionMenuItem.representedObject = machine;
                machineUpProvisionMenuItem.image = [NSImage imageNamed:@"up"];
                [machineUpProvisionMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineUpProvisionMenuItem];

                NSMenuItem *machineSSHMenuItem = [[NSMenuItem alloc] initWithTitle:@"SSH" action:@selector(sshMachine:) keyEquivalent:@""];
                machineSSHMenuItem.target = self;
                machineSSHMenuItem.representedObject = machine;
                machineSSHMenuItem.image = [NSImage imageNamed:@"ssh"];
                [machineSSHMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineSSHMenuItem];

                NSMenuItem *machineRDPMenuItem = [[NSMenuItem alloc] initWithTitle:@"RDP" action:@selector(rdpMachine:) keyEquivalent:@""];
                machineRDPMenuItem.target = self;
                machineRDPMenuItem.representedObject = machine;
                machineRDPMenuItem.image = [NSImage imageNamed:@"rdp"];
                [machineRDPMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineRDPMenuItem];

                NSMenuItem *machineReloadMenuItem = [[NSMenuItem alloc] initWithTitle:@"Reload" action:@selector(reloadMachine:) keyEquivalent:@""];
                machineReloadMenuItem.target = self;
                machineReloadMenuItem.representedObject = machine;
                machineReloadMenuItem.image = [NSImage imageNamed:@"reload"];
                [machineReloadMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineReloadMenuItem];

                NSMenuItem *machineSuspendMenuItem = [[NSMenuItem alloc] initWithTitle:@"Suspend" action:@selector(suspendMachine:) keyEquivalent:@""];
                machineSuspendMenuItem.target = self;
                machineSuspendMenuItem.representedObject = machine;
                machineSuspendMenuItem.image = [NSImage imageNamed:@"suspend"];
                [machineSuspendMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineSuspendMenuItem];

                NSMenuItem *machineHaltMenuItem = [[NSMenuItem alloc] initWithTitle:@"Halt" action:@selector(haltMachine:) keyEquivalent:@""];
                machineHaltMenuItem.target = self;
                machineHaltMenuItem.representedObject = machine;
                machineHaltMenuItem.image = [NSImage imageNamed:@"halt"];
                [machineHaltMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineHaltMenuItem];
                
                NSMenuItem *machineDestroyMenuItem = [[NSMenuItem alloc] initWithTitle:@"Destroy" action:@selector(destroyMachine:) keyEquivalent:@""];
                machineDestroyMenuItem.target = self;
                machineDestroyMenuItem.representedObject = machine;
                machineDestroyMenuItem.image = [NSImage imageNamed:@"destroy"];
                [machineDestroyMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineDestroyMenuItem];
                
                NSMenuItem *machineProvisionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Provision" action:@selector(provisionMachine:) keyEquivalent:@""];
                machineProvisionMenuItem.target = self;
                machineProvisionMenuItem.representedObject = machine;
                machineProvisionMenuItem.image = [NSImage imageNamed:@"provision"];
                [machineProvisionMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineProvisionMenuItem];
                
                NSMenuItem *machineCustomCommandMenuItem = [[NSMenuItem alloc] initWithTitle:@"Custom Command" action:nil keyEquivalent:@""];
                //machineCustomCommandMenuItem.image = [NSImage imageNamed:@"provision"];
                [machineCustomCommandMenuItem.image setTemplate:YES];
                [machineSubmenu addItem:machineCustomCommandMenuItem];
                machineCustomCommandMenuItem.submenu = [[NSMenu alloc] init];
                [machineCustomCommandMenuItem.submenu setAutoenablesItems:NO];
                
                [machineCustomCommandMenuItem.submenu removeAllItems];
                if(customCommands.count > 0) {
                    machineCustomCommandMenuItem.hidden = NO;
                    
                    for(CustomCommand *customCommand in customCommands) {
                        NSMenuItem *customCommandMenuItem = [[NSMenuItem alloc] initWithTitle:customCommand.displayName action:@selector(customCommandMachine:) keyEquivalent:@""];
                        customCommandMenuItem.target = self;
                        customCommandMenuItem.representedObject = @{@"machine": machine, @"command": customCommand};
                        
                        [machineCustomCommandMenuItem.submenu addItem:customCommandMenuItem];
                    }
                } else {
                    machineCustomCommandMenuItem.hidden = YES;
                }

                machineItem.submenu = machineSubmenu;
                
                [_machineMenuItems addObject:machineItem];
                [_submenu insertItem:machineItem atIndex:[self.menuItem.submenu indexOfItem:_machineSeparator] + _machineMenuItems.count];
                
                machineItem.image = machine.state == RunningState ? [NSImage imageNamed:@"status_icon_on"] : machine.state == SavedState ? [NSImage imageNamed:@"status_icon_suspended"] : [NSImage imageNamed:@"status_icon_off"];
                
                if(machine.state == RunningState) {
                    [machineUpMenuItem setHidden:YES];
                    [machineUpProvisionMenuItem setHidden:YES];
                    [machineSSHMenuItem setHidden:NO];
                    [machineRDPMenuItem setHidden:NO];
                    [machineReloadMenuItem setHidden:NO];
                    [machineSuspendMenuItem setHidden:NO];
                    [machineHaltMenuItem setHidden:NO];
                    [machineProvisionMenuItem setHidden:NO];
                } else {
                    [machineUpMenuItem setHidden:NO];
                    [machineUpProvisionMenuItem setHidden:NO];
                    [machineSSHMenuItem setHidden:YES];
                    [machineRDPMenuItem setHidden:YES];
                    [machineReloadMenuItem setHidden:YES];
                    [machineSuspendMenuItem setHidden:YES];
                    [machineHaltMenuItem setHidden:YES];
                    [machineProvisionMenuItem setHidden:YES];
                }
            }
        } else {
            [_machineSeparator setHidden:YES];
        }
        
    } else {
        self.menuItem.submenu = nil;
    }
}

- (void)upAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemUpAllMachines:self withProvision:NO];
}

- (void)upProvisionAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemUpAllMachines:self withProvision:YES];
}

- (void)sshInstance:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemSSHInstance:self];
}

- (void)rdpInstance:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemRDPInstance:self];
}

- (void)reloadAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemReloadAllMachines:self];
}

- (void)suspendAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemSuspendAllMachines:self];
}

- (void)haltAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemHaltAllMachines:self];
}

- (void)destroyAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemDestroyAllMachines:self];
}

- (void)provisionAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemProvisionAllMachines:self];
}

- (void)customCommandAllMachines:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemCustomCommandAllMachines:self withCommand:sender.representedObject];
}

- (void)finderMenuItemClicked:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemOpenFinder:self];
}

- (void)editVagrantfileMenuItemClicked:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemEditVagrantfile:self];
}

- (void)terminalMenuItemClicked:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemOpenTerminal:self];
}

- (void)updateProviderIdentifier:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemUpdateProviderIdentifier:self withProviderIdentifier:sender.representedObject];
}

- (void)removeBookmarkMenuItemClicked:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemRemoveBookmark:self];
}

- (void)addBookmarkMenuItemClicked:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemAddBookmark:self];
}

- (void)upMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemUpMachine:sender.representedObject withProvision:NO];
}

- (void)upProvisionMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemUpMachine:sender.representedObject withProvision:YES];
}

- (void)sshMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemSSHMachine:sender.representedObject];
}

- (void)rdpMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemRDPMachine:sender.representedObject];
}

- (void)reloadMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemReloadMachine:sender.representedObject];
}

- (void)suspendMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemSuspendMachine:sender.representedObject];
}

- (void)haltMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemHaltMachine:sender.representedObject];
}

- (void)destroyMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemDestroyMachine:sender.representedObject];
}

- (void)provisionMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemProvisionMachine:sender.representedObject];
}

- (void)customCommandMachine:(NSMenuItem*)sender {
    [self.delegate nativeMenuItemCustomCommandMachine:[sender.representedObject objectForKey:@"machine"] withCommand:[sender.representedObject objectForKey:@"command"]];
}

- (void)menuWillOpen:(NSMenu *)menu {
    BOOL optionKeyDestroy = [[NSUserDefaults standardUserDefaults] boolForKey:@"optionKeyDestroy"];

    if(optionKeyDestroy) {
        _instanceDestroyMenuItemPlaceholder.hidden = NO;
        _instanceDestroyMenuItem.alternate = YES;
        _instanceDestroyMenuItem.keyEquivalentModifierMask = NSAlternateKeyMask;
    } else {
        _instanceDestroyMenuItem.alternate = NO;
        _instanceDestroyMenuItemPlaceholder.hidden = YES;
    }
}

@end
