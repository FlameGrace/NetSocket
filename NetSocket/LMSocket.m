//
//  LMSocket.m
//  NetSocket
//
//  Created by FlameGrace on 2017/1/20.
//  Copyright © 2017年 hello. All rights reserved.
//

#import "LMSocket.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <sys/errno.h>

static NSString *NetSocketErrorDomain = @"com.NetSocket.socket";

@interface LMSocket()

@property (assign, nonatomic) int socket_;

/**
 链接是否被关闭
 */
@property (assign, nonatomic) BOOL isClosed;

@property (readwrite, strong, nonatomic) NSString *connectHost;

@property (readwrite, assign, nonatomic) uint32_t connectPort;

@property (readwrite, assign, nonatomic) uint32_t bindPort;

@property (readwrite, assign, nonatomic) BOOL isBind;

@property (readwrite, assign, nonatomic) BOOL isConnected;

@property (strong, nonatomic) dispatch_queue_t delegateQueue;

@end

@implementation LMSocket

- (instancetype)init
{
    if(self  = [super init])
    {
        self.socket_ = socket(AF_INET,SOCK_STREAM,0);
        
    }
    
    return self;
}

- (instancetype)initWithDelete:(id <LMSocketDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    if(self = [super init])
    {
        self.socket_ = socket(AF_INET,SOCK_STREAM,0);
        self.delegate = delegate;
        _delegateQueue = delegateQueue;
    }
    
    return self;
}

- (instancetype)initWithSocket:(int)socket
{
    if(self  = [super init])
    {
        self.socket_ = socket;
    }
    
    return self;
}



- (BOOL)connectHost:(NSString *)host port:(uint32_t)port
{
    
    if(!host.length)
    {
        return NO;
    }
    if(self.isConnected)
    {
        return NO;
    }
    
    struct sockaddr_in connect_addr={0};
    connect_addr.sin_len =
    connect_addr.sin_family = AF_INET;
    connect_addr.sin_port = htons(port);
    connect_addr.sin_addr.s_addr = inet_addr([host UTF8String]);
    
    int s = connect(self.socket_, (struct sockaddr *)&connect_addr, sizeof(connect_addr));
    if( s < 0)
    {
        if(errno != EINPROGRESS)
        {
            return NO;
        }
    }
    
    self.isConnected = YES;
    self.connectHost = host;
    self.connectPort = port;
    self.isClosed = NO;
    
    [self didConnect];
    
    return YES;
    
}

- (BOOL)acceptOnPort:(uint32_t)port error:(NSError *__autoreleasing *)error
{
    
    if(self.isBind)
    {
        if(port == self.bindPort)
        {
            return YES;
        }
        *error = [NSError errorWithDomain:NetSocketErrorDomain code:1 userInfo:@{@"description":@"已经在监听中"}];
        return NO;
    }
    
    struct sockaddr_in socket_addr;
    
    memset(&socket_addr, 0, sizeof(socket_addr));
    socket_addr.sin_family = AF_INET;
    socket_addr.sin_port = htons(port);
    socket_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    if(bind(self.socket_,(struct sockaddr *)&socket_addr, sizeof(socket_addr)) == -1)
    {
        *error = [NSError errorWithDomain:NetSocketErrorDomain code:errno userInfo:@{@"description":@"Address already in use."}];
        return NO;
    }
    
    if(listen(self.socket_, 20) == -1)
    {
        *error = [NSError errorWithDomain:NetSocketErrorDomain code:errno userInfo:@{@"description":@"Address already in use."}];
        return NO;
    }
    
    self.isBind = YES;
    self.bindPort = port;
    self.isClosed = NO;
    
    dispatch_async(self.delegateQueue, ^{
        while (1)
        {
            if(self.isClosed)
            {
                break;
            }
            struct sockaddr_in client_add;
            socklen_t len = sizeof(client_add);
            int client_sock = accept(self.socket_, (struct sockaddr *)&client_add, &len);
            if(client_sock < 0)
            {
                NSLog(@"接收客户端失败:%d",errno);
                continue;
            }
            LMSocket *socket = [[LMSocket alloc]initWithSocket:client_sock];
            socket.isConnected = YES;
            char *host = inet_ntoa(client_add.sin_addr);
            socket.connectHost = [NSString stringWithUTF8String:host];
            socket.connectPort = client_add.sin_port;
            [self didAcceptNewSocket:socket];
        }
    });

    
    return YES;
    
}

- (void)receiveData
{
    
    dispatch_async(self.delegateQueue, ^{
        
        char buffer[1024];
        while (1)
        {
            if(self.isClosed)
            {
                break;
            }
            if(!self.isConnected)
            {
                break;
            }
            
            memset(buffer, 0, sizeof(buffer));
            ssize_t len = recv(self.socket_, buffer, sizeof(buffer), 0);
            if(len <= 0)
            {
                //系统信号导致没有收到消息
                if(errno == EINTR)
                {
                   continue;
                }
                //链接断开
                self.isConnected = NO;
                [self didDisConnect];
                break;
            }
            
            NSData *data = [NSData dataWithBytes:buffer length:len];
            
            [self didRecieveData:data];
            
        }
    });
}

- (void)sendData:(NSData *)data
{
    if(!self.isConnected)
    {
        return;
    }
    ssize_t len = send(self.socket_, data.bytes, data.length, 0);
    if(len <data.length)
    {
        return;
    }
    
    [self didSendData];
}


- (void)close
{
    if(!self.isClosed)
    {
        self.isClosed = YES;
        close(self.socket_);
        self.isBind = NO;
        self.isConnected = NO;
        self.connectHost = nil;
        self.connectPort = 0;
    }
    
}


- (void)dealloc
{
    self.delegate = nil;
    [self close];
    self.delegateQueue = nil;
}


- (void)didRecieveData:(NSData *)data
{
    if([self.delegate respondsToSelector:@selector(socket:recieveData:)])
    {
        [self.delegate socket:self recieveData:data];
    }
}

- (void)didConnect
{
    if([self.delegate respondsToSelector:@selector(socketDidConnect:)])
    {
        [self.delegate socketDidConnect:self];
    }
}

- (void)didDisConnect
{
    if([self.delegate respondsToSelector:@selector(socketDidDisconnect:)])
    {
        [self.delegate socketDidDisconnect:self];
    }
}

- (void)didSendData
{
    if([self.delegate respondsToSelector:@selector(socketDidSendData:)])
    {
        [self.delegate socketDidSendData:self];
    }
}

- (void)didAcceptNewSocket:(id<LMSocketProtocol>)newSocket
{
    if([self.delegate respondsToSelector:@selector(socket:didAcceptNewSocket:)])
    {
        [self.delegate socket:self didAcceptNewSocket:newSocket];
    }
}


- (dispatch_queue_t)delegateQueue
{
    if(!_delegateQueue)
    {
        NSTimeInterval date = [[NSDate date]timeIntervalSince1970];
        NSString *st = [NSString stringWithFormat:@"self.socket_delegate_queue%f",date];
        _delegateQueue = dispatch_queue_create([st UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    
    return _delegateQueue;
}



@end
