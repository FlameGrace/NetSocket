//
//  ViewController.m
//  NetSocket
//
//  Created by Flame Grace on 2017/1/21.
//  Copyright © 2017年 hello. All rights reserved.
//

#import "BlockViewController.h"
#import "LMBlockSocket.h"

#define TestPort 8005


@interface BlockViewController ()<LMSocketDelegate>

@property (strong, nonatomic) UIButton *connectButton;

@property (strong, nonatomic) UIButton *clientSendButton;

@property (strong, nonatomic) UIButton *serverSendButton;

@property (strong, nonatomic) UIButton *closeButton;

@property (strong, nonatomic) LMBlockSocket *server;

@property (strong, nonatomic) LMBlockSocket *client1;

@property (strong, nonatomic) LMBlockSocket *client2;

@property (strong, nonatomic)  NSMutableArray *clients;

@property (assign, nonatomic) NSInteger nowClient;

@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self connectButton];
    [self serverSendButton];
    [self clientSendButton];
    [self closeButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)socketDidConnect:(LMBlockSocket *)socket
{
    NSLog(@"%@连接上",socket.name);
}

- (void)socketDidDisconnect:(LMBlockSocket *)socket
{
    NSLog(@"%@失去链接",socket.name);
}

- (void)socket:(LMBlockSocket *)socket recieveData:(NSData *)data
{
    
    NSString *st = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@接收到数据：%@",socket.name,st);
    
}

- (void)socketDidSendData:(LMBlockSocket *)socket
{
    NSLog(@"%@发送数据",socket.name);
}

- (void)socket:(LMBlockSocket *)socket didAcceptNewSocket:(LMBlockSocket *)newSocket
{
    self.nowClient ++;
    newSocket.name = [NSString stringWithFormat:@"新连接%ld",(long)self.nowClient];
    newSocket.delegate = self;
    [newSocket receiveData];
    [self.clients addObject:newSocket];
    
    NSLog(@"%@接收到新连接%@",socket.name,newSocket.name);
}

- (void)btnClickStart
{
    if(!self.server)
    {
        self.server = [[LMBlockSocket alloc]init];
        self.server.delegate = self;
        self.server.name = @"服务器";
    }
    
    
    NSError *error = nil;
    if(![self.server acceptOnPort:TestPort error:&error])
    {
#pragma 如果上次调用没有关闭链接，有可能会报错地址已被占用
        NSLog(@"服务器启动失败:%@",error);
    }
    
    
    if(!self.client1)
    {
        self.client1 = [[LMBlockSocket alloc]init];
        self.client1.delegate = self;
        self.client1.name = @"客户端1";
    }
    
    if(![self.client1 connectHost:@"127.0.0.1" port:TestPort])
    {
        NSLog(@"客户端1链接失败");
    }
    else
    {
        [self.client1 receiveData];
    }
    
    if(!self.client2)
    {
        self.client2 = [[LMBlockSocket alloc]init];
        self.client2.delegate = self;
        self.client2.name = @"客户端2";
    }
    
    
    if(![self.client2 connectHost:@"127.0.0.1" port:TestPort])
    {
        NSLog(@"客户端2链接失败");
    }
    else
    {
        [self.client2 receiveData];
    }

}

- (void)btnClickServerSend
{
    NSTimeInterval date = [[NSDate date]timeIntervalSince1970];
    for (LMBlockSocket *socket in self.clients) {
        
        NSData *data = [[NSString stringWithFormat:@"服务器通过%@发送数据了：%f",socket.name,date] dataUsingEncoding:NSUTF8StringEncoding];
        [socket sendData:data];
    }
}

- (void)btnClickClientSend
{
    NSTimeInterval date = [[NSDate date]timeIntervalSince1970];
    NSData *data = [[NSString stringWithFormat:@"%@发送数据了：%f",self.client1.name,date] dataUsingEncoding:NSUTF8StringEncoding];
    [self.client1 sendData:data];
    
    NSData *data2 = [[NSString stringWithFormat:@"%@发送数据了：%f",self.client2.name,date] dataUsingEncoding:NSUTF8StringEncoding];
    [self.client2 sendData:data2];
}

- (void)btnClickClose
{
    [self.client1 close];
    [self.client2 close];
    [self.server close];
    self.clients = nil;
    self.client1 = nil;
    self.client2 = nil;
    self.server = nil;
}


- (NSMutableArray *)clients
{
    if(!_clients)
    {
        _clients = [[NSMutableArray alloc]init];
    }
    return _clients;
}

- (UIButton *)connectButton
{
    if(!_connectButton)
    {
        _connectButton = [[UIButton alloc]init];
        _connectButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_connectButton];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_connectButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_connectButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-160.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_connectButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:150.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_connectButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0]];
        [_connectButton setTitle:@"开启链接" forState:UIControlStateNormal];
        [_connectButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_connectButton addTarget:self action:@selector(btnClickStart) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _connectButton;
}

- (UIButton *)clientSendButton
{
    if(!_clientSendButton)
    {
        _clientSendButton = [[UIButton alloc]init];
        _clientSendButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_clientSendButton];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_clientSendButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_clientSendButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_clientSendButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:150.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_clientSendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0]];
        [_clientSendButton setTitle:@"客户端发送数据" forState:UIControlStateNormal];
        [_clientSendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_clientSendButton addTarget:self action:@selector(btnClickClientSend) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _clientSendButton;
}


- (UIButton *)closeButton
{
    if(!_closeButton)
    {
        _closeButton = [[UIButton alloc]init];
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_closeButton];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_closeButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_closeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:80.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:150.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0]];
        [_closeButton setTitle:@"关闭链接" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(btnClickClose) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _clientSendButton;
}

- (UIButton *)serverSendButton
{
    if(!_serverSendButton)
    {
        _serverSendButton = [[UIButton alloc]init];
        _serverSendButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_serverSendButton];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_serverSendButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_serverSendButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-80.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_serverSendButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:150.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_serverSendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0]];
        [_serverSendButton setTitle:@"服务器发送数据" forState:UIControlStateNormal];
        [_serverSendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_serverSendButton addTarget:self action:@selector(btnClickServerSend) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _clientSendButton;
}


@end
