//
//  YYIMChatViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYIMChatViewController.h"
#import "XHDisplayTextViewController.h"
#import "XHDisplayMediaViewController.h"
#import "XHDisplayLocationViewController.h"
#import "XHAudioPlayerHelper.h"

#import "YYContactsViewController.h"
#import "YYGroupInfoViewController.h"

#import "YYMsgUtils.h"
#import "YYMediaSDKEngine.h"
#import "YYMsgManager.h"
#import "YYConversationModel.h"
#import "MediaPlusSDK+IM.h"


//将数字转为Unicode
#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0| (x & 0x3F000)>> 4)| (x & 0xFC0)<< 10)| (x & 0x1C0000)<< 18)| (x & 0x3F)<< 24);


NSString *const kIMChatGroupInfoSugueID             = @"yy_im_chat_group_info_segue_id";



@interface YYIMChatViewController ()<XHAudioPlayerHelperDelegate>

@property (nonatomic, strong) NSArray *emotionManagers;

@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarBtnItem;

/// 最旧的一条信息时间
@property (nonatomic, strong) NSDate *oldestDate;

@property (nonatomic, assign) NSInteger fetchOffset;

@property (nonatomic, assign) BOOL hasLocalMsg;

@end

@implementation YYIMChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:_targetName];
    [self.navigationItem.leftBarButtonItem setTitle:@"返回"];
    [[YYMsgManager sharedInstance]addMessageListener:self];
    _fetchOffset = 0;
    _hasLocalMsg = YES;
    if (_targetType == YYChatTargetTypeGroup) {
        // 群组
        [self.rightBarBtnItem setTitle:@"管理"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearAllLocalMessage) name:kGroupInfoClearAllMessageNF object:nil];
    } else {
        [self.rightBarBtnItem setTitle:@"清除"];
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.messageSender = _targetName;
    [self loadShareView];
    [self loadEmojiView];
    [self loadChatMsgData:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([[XHAudioPlayerHelper shareInstance] isPlaying]) {
        [[XHAudioPlayerHelper shareInstance] stopAudio];
    }
    [self updateMsgToReaded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)rightBarBtnAction:(UIBarButtonItem *)sender {
    if (_targetType == YYChatTargetTypeGroup) {
        // 群组进入群组信息页面
        [self performSegueWithIdentifier:kIMChatGroupInfoSugueID sender:nil];
    } else {
        // 清除聊天记录
        [self clearAllLocalMessage];
    }
}

- (void)clearAllLocalMessage {
    WEAKSELF
    __block NSError *err;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YYMsgManager sharedInstance] clearAllMessages:weakSelf.targetid error:&err];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (err) {
                DLog(@"====%s===error:%@", __FUNCTION__, err);
            }
            weakSelf.hasLocalMsg = YES;
            [weakSelf.messages removeAllObjects];
            [weakSelf.messageTableView reloadData];
        });
    });
}

- (void)updateMsgToReaded {
    // 更新设置所有的未读消息为已读
    [[YYMsgManager sharedInstance] updateAllMsgToReaded:_targetid];
}

- (void)loadChatMsgData:(BOOL)isAppend {
    WEAKSELF
    __block NSArray *messages;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError  *err;
        messages = [[YYMsgManager sharedInstance] getAllMsgsConvID:_targetid offset:_fetchOffset error:&err];
        if (!isAppend) {
            weakSelf.fetchOffset += messages.count;
        }
        if (messages.count == 0 || messages.count < 20) {
            weakSelf.hasLocalMsg = NO;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!messages || ![messages isKindOfClass:[NSArray class]]) {
                return ;
            }
            if (!isAppend) {
                self.messages = [[NSMutableArray alloc]initWithArray:messages];
                [self.messageTableView reloadData];
                [self scrollToBottomAnimated:NO];
                
                [self updateMsgToReaded];
            } else {
                [self insertOldMessages:[NSArray arrayWithArray:messages]];
                self.loadingMoreMessage = NO;
                
            }
        });
    });
}

- (void)loadShareView {
    // 添加第三方接入数据
    NSMutableArray *shareMenuItems = [NSMutableArray array];
    NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video", @"sharemore_location"];
    NSArray *plugTitle = @[@"照片", @"拍摄", @"位置"];
    for (NSString *plugIcon in plugIcons) {
        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
        [shareMenuItems addObject:shareMenuItem];
    }
    self.shareMenuItems = shareMenuItems;
    [self.shareMenuView reloadData];
}

//获取默认表情数组
- (NSArray*)defaultEmoticons {
    NSMutableArray *array= [NSMutableArray new];
    for(int i = 0x1F600 ; i <= 0x1F64B; i++) {
        if(i < 0x1F641 || i > 0x1F644) {
            int sym = EMOJI_CODE_TO_SYMBOL(i);
            NSString *emoT= [[NSString alloc]initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
            [array addObject:emoT];
        }
    }
    return array;
}

- (void)loadEmojiView {
    NSMutableArray *emotionManagers = [NSMutableArray array];
    XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
    emotionManager.emotionName = [NSString stringWithFormat:@"😀"];
    emotionManager.emotionType = XHBubbleEmotionTypeEmoji;
    NSMutableArray *emotions = [NSMutableArray array];
    NSArray *emojiArr = [self defaultEmoticons];
    for (NSInteger j = 0; j < emojiArr.count; j++) {
        XHEmotion *emotion = [[XHEmotion alloc] init];
        emotion.emotionType = emotionManager.emotionType;
        emotion.emotionPath = [NSString stringWithFormat:@"%@", emojiArr[j]];
        [emotions addObject:emotion];
    }
    emotionManager.emotions = emotions;
    
    [emotionManagers addObject:emotionManager];
    
    self.emotionManagers = emotionManagers;
    [self.emotionManagerView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kIMChatGroupInfoSugueID]) {
        // 群组信息
        YYGroupInfoViewController *groupInfoVC = (YYGroupInfoViewController *)segue.destinationViewController;
        groupInfoVC.groupID = _targetid;
    }
}

- (void)setAttributeActionString:(NSString *)text {
    if ([text isEmptyString]) {
        return;
    }
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber | NSTextCheckingTypeDate error:nil];
    
    NSMutableArray *actionArr = [NSMutableArray array];
    [detector enumerateMatchesInString:text
                                 options:0
                                   range:NSMakeRange(0, [text length])
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                  
                                  [actionArr addObject:result];
                                  
                                  if (flags == NSMatchingHitEnd) {
                                      UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                                      [actionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                          NSTextCheckingResult *tmp = (NSTextCheckingResult *)obj;
                                          if ([tmp resultType] == NSTextCheckingTypeLink) {
                                              UIAlertAction *action = [UIAlertAction actionWithTitle:[tmp URL].absoluteString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  [[UIApplication sharedApplication]openURL:[tmp URL]];
                                              }];
                                              [alertVC addAction:action];
                                          } else if ([tmp resultType] == NSTextCheckingTypePhoneNumber) {
                                              UIAlertAction *action = [UIAlertAction actionWithTitle:[tmp phoneNumber] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [tmp phoneNumber]]]];
                                              }];
                                              [alertVC addAction:action];
                                          }
                                          
                                      }];
                                      
                                      UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                      }];
                                      [alertVC addAction:action];
                                      
                                      [self presentViewController:alertVC animated:YES completion:nil];
                                  }
                              }];
}

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers {
    return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
    return [self.emotionManagers objectAtIndex:column];
}

- (NSArray *)emotionManagersAtManager {
    return self.emotionManagers;
}

#pragma mark - XHMessageTableViewCell delegate

- (UIViewController *)presentPhotoVC:(id <XHMessageModel>)message {
    XHDisplayMediaViewController *messageDisplayPhotoVC = [[XHDisplayMediaViewController alloc] init];
    messageDisplayPhotoVC.message = message;
    messageDisplayPhotoVC.view.backgroundColor = [UIColor whiteColor];
    return messageDisplayPhotoVC;
}

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
    UIViewController *disPlayViewController;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeText:
            [self setAttributeActionString:message.text];
            break;
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypePhoto: {
            
            if (message.isLoaded) {
                disPlayViewController = [self presentPhotoVC:message];
                
            } else {
                // 下载
                [self getFileWithFileIndexPath:indexPath];
            }
            
        }
            break;
        case XHBubbleMessageMediaTypeVoice: {
            DLog(@"message : %@", message.voicePath);
            
            // Mark the voice as read and hide the red dot.
            if (!message.isRead) {
                message.isRead = YES;
                [[YYMsgManager sharedInstance] updateMsgToReaded:message.messageID];
            }
            messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = YES;
            
            [[XHAudioPlayerHelper shareInstance] setDelegate:(id<NSFileManagerDelegate>)self];
            if (_currentSelectedCell) {
                [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
            }
            if (_currentSelectedCell == messageTableViewCell) {
                [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
                [[XHAudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            } else {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
                [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
            }
            
            
            break;
        }
        case XHBubbleMessageMediaTypeEmotion:
            DLog(@"facePath : %@", message.emotionPath);
            break;
        case XHBubbleMessageMediaTypeLocalPosition: {
            DLog(@"facePath : %@", message.localPositionPhoto);
            XHDisplayLocationViewController *displayLocationViewController = [[XHDisplayLocationViewController alloc] init];
            displayLocationViewController.message = message;
            disPlayViewController = displayLocationViewController;
            break;
        }
        default:
            break;
    }
    if (disPlayViewController) {
        [self.navigationController pushViewController:disPlayViewController animated:YES];
    }
}

- (void)didDoubleSelectedOnTextMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"text : %@", message.text);
//    XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
//    displayTextViewController.message = message;
//    [self.navigationController pushViewController:displayTextViewController animated:YES];
}

- (void)didSelectedAvatarOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
//    XHContact *contact = [[XHContact alloc] init];
//    contact.contactName = [message sender];
//    contact.contactIntroduction = @"自定义描述，这个需要和业务逻辑挂钩";
//    [self.navigationController pushViewController:contactDetailTableViewController animated:YES];
}

- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType {
    
}

#pragma mark - XHAudioPlayerHelper Delegate

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (!_currentSelectedCell) {
        return;
    }
    [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - XHShareMenuView Delegate

- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index {
    [super didSelecteShareMenuItem:shareMenuItem atIndex:index];
    
}

#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldLoadMoreMessagesScrollToTop {
    return YES;
}

- (void)loadMoreMessagesScrollTotop {
    if (!self.loadingMoreMessage) {
        self.loadingMoreMessage = YES;
        if (_hasLocalMsg) {
            [self loadChatMsgData:YES];
        } else {
            WEAKSELF
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                YYChatHistoryType histType = YYChatHistoryTypeSingle;
                if (YYChatTargetTypeGroup == weakSelf.targetType) {
                    histType = YYChatHistoryTypeGroup;
                }
                XHMessage *model = [weakSelf.messages firstObject];
                if (model) {
                    weakSelf.oldestDate = model.timestamp;
                } else {
                    weakSelf.oldestDate = [NSDate date];
                }
                [[YYMsgManager sharedInstance] getChatHistory:weakSelf.targetid timestamp:weakSelf.oldestDate.timeIntervalSince1970 type:histType completion:^(NSArray *result, NSError *err) {
                    NSArray *response = [NSArray arrayWithArray:result];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf insertOldMessages:response];
                        weakSelf.loadingMoreMessage = NO;
                    });
                }];
                
            });
        }
        
    }
}

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *textMessage = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
    [self sendMsg:textMessage];
}

- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:date];
    
    [self sendMsg:photoMessage];
}

- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
    NSString *spanID = [[YYMediaSDKEngine sharedInstance].mediaPlusSDK getVoiceSpanId:_targetid];
    // wav to arm
    [YYMsgUtils corverFromWavAmrPath:voicePath spanID:spanID];
    XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:nil voiceDuration:voiceDuration sender:sender timestamp:date];
    voiceMessage.audioSpanID = spanID;
    [self sendMsg:voiceMessage];
}

- (void)didSendEmotion:(NSString *)emotionPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    // TODO emoji not emotion.
    XHMessage *textMessage = [[XHMessage alloc] initWithText:emotionPath sender:sender timestamp:date];
    [self sendMsg:textMessage];
}

- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *geoLocationsMessage = [[XHMessage alloc] initWithLocalPositionPhoto:geoLocationsPhoto geolocations:geolocations location:location sender:sender timestamp:date];
    geoLocationsMessage.avatar = [UIImage imageNamed:@"iconImg"];
    geoLocationsMessage.messageMediaType = XHBubbleMessageMediaTypeLocalPosition;
//
//    [self sendMsg:geoLocationsMessage];
}

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return YES;
    }
    if (self.messages.count > 0 && indexPath.row < self.messages.count) {
        // 距离上一条大于等于5分钟的都显示
        XHMessage *pre = self.messages[indexPath.row - 1];
        XHMessage *curr = self.messages[indexPath.row];
        int time = (int)(curr.timestamp.timeIntervalSince1970 - pre.timestamp.timeIntervalSince1970) / (60);
        return time >= 5;
    }
    return NO;
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

- (void)sendMsg:(XHMessage *)msg {
    if (msg) {
        [self addMessage:msg];
        msg.messageID = [NSString stringWithFormat:@"%llu", [[YYMsgUtils sharedInstance] getMsgID]];
        msg.avatar = [UIImage imageNamed:@"iconImg"];
        msg.sender = [YYMediaSDKEngine sharedInstance].userModel.userNickName;
        msg.senderID = [YYMediaSDKEngine sharedInstance].userModel.userID;
        NSError *error = nil;
        [[YYMsgManager sharedInstance]sendMessage:msg
                                     conversation:_targetid
                                         convName:_targetName progress:^(NSUInteger receivedSize, long long expectedSize) {
                                             [self showHUDProgress:receivedSize / expectedSize status:@"loading..."];
                                             if (receivedSize == expectedSize) {
                                                 [self dismissHUD];
                                             }
                                             msg.isLoaded = YES;
                                         }
                                 conversationType:_targetType];
        if (!error) {
            [self finishSendMessageWithBubbleMessageType:msg.messageMediaType];
        }
        if (msg.messageMediaType == XHBubbleMessageMediaTypePhoto) {
            [self showHUDProgress:0.0 status:@"loading..."];
        }
    }
}

- (void)getFileWithFileIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.messages.count) {
        return;
    }
    XHMessage *msg = self.messages[indexPath.row];
    WEAKSELF
    [self showHUDProgress:0.0 status:@"loading..."];
    [[YYMsgManager sharedInstance] getFileWithMessage:msg completion:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        
        DLog(@"==get file=%@===err: %@", jsonRet, err);
        if (err) {
            [self showHUDErrorWithStatus:err.localizedDescription];
            return ;
        }
        
        NSString *fileid = [jsonRet[@"fid"] description];
        if (![fileid isEmptyString]) {
            NSString *originPath = [[[YYMediaSDKEngine sharedInstance] getImgCachePath]stringByAppendingPathComponent:fileid];
            UIImage *origImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:originPath]];
            msg.photo = origImg;
            msg.isLoaded = YES;
            UIViewController *vc = [self presentPhotoVC:msg];
            if (vc) {
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
            [weakSelf.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        NSError *errTmp;
        [[YYMsgManager sharedInstance] updateMessageLoadedMsgID:msg.messageID error:&errTmp];
        if (errTmp) {
            DLog(@"===update message error :%@", errTmp);
        }
        
        [weakSelf showHUDSuccessWithStatus:nil];
    } progress:^(NSUInteger receivedSize, long long expectedSize) {
        [weakSelf showHUDProgress:receivedSize / expectedSize status:@"loading..."];
    }];
}

#pragma mark - MsgManager

/**
 *  消息增加
 *
 *  @param msgs         消息列表
 *  @param conversation 会话
 */
- (void)msgsAdded:(NSArray*)msgs conversation:(YYConversationModel*)conversation {
    if (msgs.count == 0 || ![conversation.conversationID isEqualToString:_targetid]) {
        DLog(@"+++++++++++%s+++++++", __FUNCTION__);
        return;
    }
    for (XHMessage *model in msgs) {
        [self addMessage:model];
        [self finishSendMessageWithBubbleMessageType:model.messageMediaType];
    }
}

- (void)msgsUpdated:(NSArray*)msgs conversation:(YYConversationModel*)conversation {
    
}

- (void)msgsDeleted:(NSArray*)msgIds conversation:(YYConversationModel*)conversation {
    
}

- (void)msgsInsert:(NSArray *)msgs conversation:(YYConversationModel*)conversation {
    if (msgs.count == 0 || ![conversation.conversationID isEqualToString:_targetid]) {
        return;
    } else {
        DLog(@"insert messsage count :%ld", msgs.count);
    }
    
}


@end
