//
//  LMSocketDelegate.h
//  NetSocket
//
//  Created by Flame Grace on 2017/1/21.
//  Copyright © 2017年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMSocketProtocol.h"


@protocol LMSocketDelegate <NSObject>

/**
 链接上
 */
- (void)socketDidConnect:(id<LMSocketProtocol>)socket;
/**
 失去链接
 */
- (void)socketDidDisconnect:(id<LMSocketProtocol>)socket;
/**
 接收到数据
 */
- (void)socket:(id<LMSocketProtocol>)socket recieveData:(NSData *)data;
/**
 发送数据成功
 */
- (void)socketDidSendData:(id<LMSocketProtocol>)socket;

/**
 接收到新的链接
 @param socket 服务器
 @param newSocket 新链接
 */
- (void)socket:(id<LMSocketProtocol>)socket didAcceptNewSocket:(id<LMSocketProtocol>)newSocket;

@end
