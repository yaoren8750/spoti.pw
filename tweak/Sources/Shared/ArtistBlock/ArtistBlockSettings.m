// The Blocked artists page: the switch, whether a featured credit counts, blocking someone off the
// track playing now, and the list, swiped to unblock. The hook reads all of it per track, so a change
// needs no restart.
#import "Core/SGCore.h"
#import "Settings/SGPage.h"
#import "Settings/SGPageStyle.h"
#import "ArtistBlock.h"

typedef NS_ENUM(NSInteger, SGArtistSection) {
    SGArtistSectionSwitch,
    SGArtistSectionMode,
    SGArtistSectionAdd,
    SGArtistSectionList,
    SGArtistSectionCount,
};

@interface SGArtistBlockPage : SGPage
@end

@implementation SGArtistBlockPage {
    NSArray<NSDictionary *> *_blocked;
}

- (instancetype)init {
    if (!(self = [super initWithStyle:UITableViewStyleInsetGrouped])) return nil;
    self.title = @"已屏蔽的艺人";
    _blocked = SGBlockedArtists();
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    SGInsetForBars(self.tableView);
}

- (void)reload {
    _blocked = SGBlockedArtists();
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return SGArtistSectionCount;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if (section == SGArtistSectionMode) return 2;
    if (section == SGArtistSectionList) return MAX((NSInteger)_blocked.count, 1);
    return 1;
}

- (UIView *)tableView:(UITableView *)table viewForHeaderInSection:(NSInteger)section {
    if (section == SGArtistSectionMode) return SGSectionHeader(table, @"当艺人为以下类型时跳过");
    if (section == SGArtistSectionList) return SGSectionHeader(table, @"已屏蔽");
    return nil;
}

- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section {
    return section == SGArtistSectionMode || section == SGArtistSectionList ? SGSectionHeaderHeight : SGSectionGap;
}

- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = SGDequeueCell(table, @"artist");
    switch (path.section) {
        case SGArtistSectionSwitch: {
            SGFillCell(cell, @"跳过已屏蔽艺人", nil, nil, nil);
            UISwitch *toggle = [UISwitch new];
            toggle.onTintColor = SGGreen();
            toggle.on = SGFlag(SGKeyArtistBlock, NO);
            [toggle addTarget:self action:@selector(toggled:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = toggle;
            break;
        }
        case SGArtistSectionMode: {
            BOOL featured = path.row == 1;
            SGFillCell(cell, featured ? @"主要或合作艺人" : @"主要艺人",
                       featured ? @"歌曲中的任何署名艺人" : @"歌曲中的首位艺人", nil, nil);
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            if (featured == SGFlag(SGKeyArtistBlockFeatured, NO)) {
                UIImageView *tick = SGSymbolView(@"checkmark", 13, UIImageSymbolWeightSemibold, 16);
                tick.tintColor = SGGreen();
                cell.accessoryView = tick;
            }
            break;
        }
        case SGArtistSectionAdd:
            SGFillCell(cell, @"从当前播放歌曲中屏蔽…", nil, nil, @"person.crop.circle.badge.xmark");
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            break;
        default:
            if (!_blocked.count) {
                SGFillCell(cell, @"暂无", nil, SGGrey(), nil);
                break;
            }
            NSDictionary *artist = _blocked[(NSUInteger)path.row];
            SGFillCell(cell, artist[SGArtistName], artist[SGArtistURI], nil, nil);
            break;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)table canEditRowAtIndexPath:(NSIndexPath *)path {
    return path.section == SGArtistSectionList && _blocked.count > 0;
}

- (NSString *)tableView:(UITableView *)table titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)path {
    return @"取消屏蔽";
}

- (void)tableView:(UITableView *)table commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)path {
    if (style != UITableViewCellEditingStyleDelete) return;
    SGUnblockArtist(_blocked[(NSUInteger)path.row][SGArtistURI]);
    [self reload];
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    [table deselectRowAtIndexPath:path animated:YES];
    if (path.section == SGArtistSectionMode) {
        SGSetEnabled(SGKeyArtistBlockFeatured, path.row == 1);
        [self reload];
    } else if (path.section == SGArtistSectionAdd) {
        [self pickFromPlaying:[table cellForRowAtIndexPath:path]];
    }
}

- (void)pickFromPlaying:(UIView *)source {
    NSArray<NSDictionary *> *artists = SGPlayingArtists();
    if (!artists.count) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前没有播放内容"
                                                                      message:@"请先播放该艺人的歌曲，然后返回此处。"
                                                               preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"屏蔽"
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    [artists enumerateObjectsUsingBlock:^(NSDictionary *artist, NSUInteger index, BOOL *stop) {
        BOOL blocked = SGArtistBlocked(artist[SGArtistURI]);
        NSString *title = index == 0 ? artist[SGArtistName] : [NSString stringWithFormat:@"%@ (合作艺人)", artist[SGArtistName]];
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
            SGBlockArtist(artist);
            [self reload];
        }];
        action.enabled = !blocked;
        [sheet addAction:action];
    }];
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.sourceView = source;
    sheet.popoverPresentationController.sourceRect = source.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)toggled:(UISwitch *)toggle {
    SGSetEnabled(SGKeyArtistBlock, toggle.on);
}

@end

UIViewController *SGArtistBlockSettingsPage(void) {
    return [SGArtistBlockPage new];
}
