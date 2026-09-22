#import "Core/SGCore.h"
#import "Settings/SGPage.h"
#import "Settings/SGPageStyle.h"
#import "Navbar.h"

// What "Add a tab" offers: URIs Spotify's own router resolves to a page of its own, each with the
// name of the SPTEncoreIcon class method that draws its glyph.
static NSArray<NSDictionary *> *tabPresets(void) {
    return @[
        @{SGNavbarTitle: @"首页", SGNavbarURI: @"spotify:home", SGNavbarIcon: @"home"},
        @{SGNavbarTitle: @"搜索", SGNavbarURI: @"spotify:search", SGNavbarIcon: @"search"},
        @{SGNavbarTitle: @"你的音乐库", SGNavbarURI: @"spotify:collection", SGNavbarIcon: @"collection"},
        @{SGNavbarTitle: @"喜欢的歌曲", SGNavbarURI: @"spotify:collection:tracks", SGNavbarIcon: @"heart"},
        @{SGNavbarTitle: @"播放列表", SGNavbarURI: @"spotify:playlists", SGNavbarIcon: @"playlist"},
        @{SGNavbarTitle: @"专辑", SGNavbarURI: @"spotify:collection:albums", SGNavbarIcon: @"album"},
        @{SGNavbarTitle: @"艺人", SGNavbarURI: @"spotify:collection:artists", SGNavbarIcon: @"artist"},
        @{SGNavbarTitle: @"播客", SGNavbarURI: @"spotify:collection:podcasts", SGNavbarIcon: @"podcasts"},
        @{SGNavbarTitle: @"有声书", SGNavbarURI: @"spotify:collection:audiobooks", SGNavbarIcon: @"audiobook"},
        @{SGNavbarTitle: @"下载内容", SGNavbarURI: @"spotify:collection:downloads", SGNavbarIcon: @"downloaded"},
        @{SGNavbarTitle: @"你的节目", SGNavbarURI: @"spotify:collection:your-episodes", SGNavbarIcon: @"bookmark"},
        @{SGNavbarTitle: @"浏览", SGNavbarURI: @"spotify:browse", SGNavbarIcon: @"browse"},
        @{SGNavbarTitle: @"新发行", SGNavbarURI: @"spotify:new-releases", SGNavbarIcon: @"star"},
        @{SGNavbarTitle: @"为你打造", SGNavbarURI: @"spotify:made-for-you", SGNavbarIcon: @"user"},
        @{SGNavbarTitle: @"直播", SGNavbarURI: @"spotify:concerts", SGNavbarIcon: @"events"},
        @{SGNavbarTitle: @"播放列表", SGNavbarURI: @"spotify:now-playing:queue", SGNavbarIcon: @"queue"},
        @{SGNavbarTitle: @"创建", SGNavbarURI: @"spotify:create-menu", SGNavbarIcon: @"plus"},
    ];
}

// The list the Navbar page edits: the saved order first, then every tab of Spotify's it does not
// name, in Spotify's order. Entries for tabs Spotify no longer has drop out.
static NSMutableArray<NSMutableDictionary *> *navbarEntries(void) {
    NSArray<NSString *> *stock = SGNavbarStock();
    NSMutableArray<NSMutableDictionary *> *entries = [NSMutableArray array];
    NSMutableSet<NSString *> *seen = [NSMutableSet set];
    for (NSDictionary *entry in SGNavbarLayout()) {
        NSString *ident = entry[SGNavbarID];
        if (![ident isKindOfClass:NSString.class] || [seen containsObject:ident]) continue;
        if (!entry[SGNavbarURI] && ![stock containsObject:ident]) continue;
        [seen addObject:ident];
        [entries addObject:[entry mutableCopy]];
    }
    for (NSString *ident in stock) {
        if ([seen containsObject:ident]) continue;
        [entries addObject:[@{SGNavbarID: ident, SGNavbarTitle: ident} mutableCopy]];
    }
    return entries;
}

// A tab of the mod's own carries an identity of its own, so the same page can sit on the bar twice
// and renaming one does not shuffle the order.
static void appendTab(NSDictionary *tab) {
    NSMutableDictionary *entry = [tab mutableCopy];
    entry[SGNavbarID] = NSUUID.UUID.UUIDString;
    SGSetNavbarLayout([navbarEntries() arrayByAddingObject:entry]);
    SGRefreshTabBar();
}

@interface SGTabPickerPage : SGPage
@end

@implementation SGTabPickerPage {
    UIView *_footer;
}

- (instancetype)init {
    if (!(self = [super initWithStyle:UITableViewStyleInsetGrouped])) return nil;
    self.title = @"添加标签页";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _footer = SGNote(@"粘贴分享链接或 spotify: URI。图标: home, search, collection, heart, "
                   "playlist, album, artist, podcasts, audiobook, downloaded, bookmark, browse, star, "
                   "user, events, queue, plus, radio, gears, spotifyLogo.");
    self.tableView.tableFooterView = _footer;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    SGFitNote(self.tableView, _footer, 16, 24);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    SGInsetForBars(self.tableView);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? (NSInteger)tabPresets().count : 1;
}

- (UIView *)tableView:(UITableView *)table viewForHeaderInSection:(NSInteger)section {
    return SGSectionHeader(table, section == 0 ? @"Spotify 页面" : @"其他位置");
}

- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section {
    return SGSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = SGDequeueCell(table, @"pick");
    if (path.section == 0) {
        NSDictionary *tab = tabPresets()[(NSUInteger)path.row];
        SGFillCell(cell, tab[SGNavbarTitle], tab[SGNavbarURI], nil, nil);
    } else {
        SGFillCell(cell, @"任意链接…", nil, nil, @"link");
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    [table deselectRowAtIndexPath:path animated:YES];
    if (path.section == 0) {
        appendTab(tabPresets()[(NSUInteger)path.row]);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"任意链接" message:@"标签页打开的位置，以及对应图标。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) { field.placeholder = @"名称"; }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"spotify:playlist:…";
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"图标";
        field.text = @"star";
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *title = alert.textFields[0].text, *uri = alert.textFields[1].text, *icon = alert.textFields[2].text;
        if (!uri.length) return;
        appendTab(@{SGNavbarTitle: title.length ? title : uri, SGNavbarURI: uri, SGNavbarIcon: icon.length ? icon : @"star"});
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

typedef NS_ENUM(NSInteger, SGNavbarSection) {
    SGNavbarSectionSwitch,
    SGNavbarSectionTabs,
    SGNavbarSectionAdd,
    SGNavbarSectionReset,
    SGNavbarSectionCount,
};

// The tabs, in the order the bar shows them: drag to reorder, tap to show or hide, swipe a tab of
// your own away. Spotify's own tabs can only be hidden, never removed. Mod Settings and the welcome
// tour show the same editor.
@interface SGNavbarPage : SGPage
@end

@implementation SGNavbarPage {
    NSMutableArray<NSMutableDictionary *> *_entries;
    UIView *_intro;
}

- (instancetype)init {
    if (!(self = [super initWithStyle:UITableViewStyleInsetGrouped])) return nil;
    self.title = @"导航栏";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    _intro = SGNote(@"拖动调整顺序，点击显示或隐藏。");
    self.tableView.tableHeaderView = _intro;
    _entries = navbarEntries();
}

// The Add page writes straight to the layout, so the list is read again on the way back.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _entries = navbarEntries();
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    SGFitNote(self.tableView, _intro, 24, 0);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    SGInsetForBars(self.tableView);
}

- (void)save {
    SGSetNavbarLayout(_entries);
    SGRefreshTabBar();
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return SGNavbarSectionCount;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return section == SGNavbarSectionTabs ? (NSInteger)_entries.count : 1;
}

- (NSString *)headerFor:(NSInteger)section {
    return section == SGNavbarSectionTabs ? @"标签页" : nil;
}

- (UIView *)tableView:(UITableView *)table viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self headerFor:section];
    return title ? SGSectionHeader(table, title) : nil;
}

- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section {
    if ([self headerFor:section]) return SGSectionHeaderHeight;
    return [self tableView:table numberOfRowsInSection:section] ? SGSectionGap : CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = SGDequeueCell(table, @"navbar");
    switch (path.section) {
        case SGNavbarSectionSwitch: {
            SGFillCell(cell, @"自定义导航栏", nil, nil, nil);
            UISwitch *toggle = [UISwitch new];
            toggle.onTintColor = SGGreen();
            toggle.on = SGEnabled(SGKeyNavbar);
            [toggle addTarget:self action:@selector(toggled:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = toggle;
            break;
        }
        case SGNavbarSectionTabs: {
            NSDictionary *entry = _entries[(NSUInteger)path.row];
            BOOL hidden = [entry[SGNavbarHidden] boolValue];
            NSString *uri = entry[SGNavbarURI];
            SGFillCell(cell, entry[SGNavbarTitle], hidden ? @"已隐藏" : (uri ?: @"Spotify 原生标签页"),
                     hidden ? SGGrey() : nil, hidden ? @"eye.slash" : @"eye");
            break;
        }
        case SGNavbarSectionAdd:
            SGFillCell(cell, @"添加标签页…", nil, nil, @"plus");
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            break;
        default:
            SGFillCell(cell, @"恢复 Spotify 默认顺序", nil, nil, @"arrow.uturn.backward");
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            break;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)table canMoveRowAtIndexPath:(NSIndexPath *)path {
    return path.section == SGNavbarSectionTabs;
}

- (BOOL)tableView:(UITableView *)table canEditRowAtIndexPath:(NSIndexPath *)path {
    return path.section == SGNavbarSectionTabs;
}

// Spotify's own tabs stay on the list to be switched back on; only the mod's own can go.
- (UITableViewCellEditingStyle)tableView:(UITableView *)table editingStyleForRowAtIndexPath:(NSIndexPath *)path {
    if (path.section != SGNavbarSectionTabs) return UITableViewCellEditingStyleNone;
    return _entries[(NSUInteger)path.row][SGNavbarURI] ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)table targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)from toProposedIndexPath:(NSIndexPath *)to {
    return to.section == SGNavbarSectionTabs ? to : from;
}

- (void)tableView:(UITableView *)table moveRowAtIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to {
    NSMutableDictionary *entry = _entries[(NSUInteger)from.row];
    [_entries removeObjectAtIndex:(NSUInteger)from.row];
    [_entries insertObject:entry atIndex:(NSUInteger)to.row];
    [self save];
}

- (void)tableView:(UITableView *)table commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)path {
    if (style != UITableViewCellEditingStyleDelete) return;
    [_entries removeObjectAtIndex:(NSUInteger)path.row];
    [self save];
    [table deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    [table deselectRowAtIndexPath:path animated:YES];
    if (path.section == SGNavbarSectionTabs) {
        NSMutableDictionary *entry = _entries[(NSUInteger)path.row];
        entry[SGNavbarHidden] = [entry[SGNavbarHidden] boolValue] ? nil : @YES;
        [self save];
        [table reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    } else if (path.section == SGNavbarSectionAdd) {
        [self.navigationController pushViewController:[SGTabPickerPage new] animated:YES];
    } else if (path.section == SGNavbarSectionReset) {
        [self reset];
    }
}

- (void)toggled:(UISwitch *)toggle {
    SGSetEnabled(SGKeyNavbar, toggle.on);
    SGRefreshTabBar();
}

- (void)reset {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"恢复 Spotify 默认顺序"
                                                                  message:@"Spotify 的所有标签页将恢复到 Spotify 默认位置，你添加的标签页将被移除。"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"重置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        SGSetNavbarLayout(@[]);
        SGRefreshTabBar();
        self->_entries = navbarEntries();
        [self.tableView reloadData];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

UIViewController *SGNavbarSettingsPage(void) {
    return [SGNavbarPage new];
}

UIViewController *SGNavbarEditorPage(void) {
    return [SGNavbarPage new];
}
