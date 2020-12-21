## 概述

网易会议Android SDK提供了一套简单易用的接口，允许开发者通过调用NEMeeting SDK(以下简称SDK)提供的API，快速地集成音视频会议功能至现有Android应用中。

## 变更记录
[Android SDK CHANGELOG.md](CHANGELOG.md)

## 快速接入

#### 开发环境准备

| 名称 | 要求 |
| :------ | :------ |
| JDK版本  | >1.8.0 |
| 最小Android API 版本 | API 21, Android 5.0 |
| CPU架构支持 | ARM64、ARMV7 |
| IDE | Android Studio |
| 其他 | 依赖androidx，不支持support库 |

#### SDK快速接入

1. 新建Android工程

    a. 运行Android Sudio，顶部菜单依次选择“File -> New -> New Project...”新建工程，选择'Phone and Tablet' -> 'Empty Activity' 单击Next。
    ![new android project](images/new_project.png)
    
    b. 配置工程相关信息，请注意Minimum API Level为API 21。
    ![configure project](images/configure_project.png)
    
    c. 单击'Finish'完成工程创建。

2. 添加SDK编译依赖

    修改工程目录下的'app/build.gradle'文件，添加网易会议SDK的依赖。
    ```groovy
    dependencies {
      //声明SDK依赖，版本可根据实际需要修改
      implementation 'com.netease.yunxin:meetinglib:1.2.6'
    }
    ```
    之后通过顶部菜单'Build -> Make Project'构建工程，触发依赖下载，完成后即可在代码中引入SDK中的类和方法。

3. 权限处理

    网易会议SDK正常工作需要应用获取以下权限
    ```xml
    <!-- 网络相关 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />

    <!-- 读写外部存储 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <!-- 多媒体 -->
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    ```
    以上权限已经在SDK内部进行声明，开发者可以不用在```AndroidManifest.xml```文件中重新声明这些权限，但运行时的权限申请需要应用开发者自己编码实现，可在应用首页中统一申请，详情可参考[Android运行时权限申请示例](https://developer.android.google.cn/guide/topics/permissions/overview)。如果运行时对应权限缺失，SDK可能无法正常工作，如会议时无图像、对方听不到己方声音等。

4. SDK初始化

    在使用SDK其他功能之前首先需要完成SDK初始化，初始化操作需要保证在**Application**的**onCreate**方法中执行。代码示例如下：
    ```java
    public class MyApplication extends Application {
    
        private static final String TAG = "MyApplication";
    
        @Override
        public void onCreate() {
            super.onCreate();
            NEMeetingSDKConfig config = new NEMeetingSDKConfig();
            config.appKey = Constants.APPKEY;
            config.appName = context.getString(R.string.app_name);
            NEMeetingSDK.getInstance().initialize(this, config, new NECallback<Void>() {
                @Override
                public void onResult(int resultCode, String resultMsg, Void resultData) {
                    if (resultCode == NEMeetingError.ERROR_CODE_SUCCESS) {
                        //TODO when initialize success
                    } else {
                        //TODO when initialize fail
                    }
                }
            });
        }
    }
    ```

5. 调用相关接口完成特定功能，详情请参考API文档。

- 登录鉴权
    ```java
    NEMeetingSDK.getInstance().login(String account, String token, NECallback<Void> callback);
    ```
- 创建会议
    ```java
    NEMeetingService meetingService = NEMeetingSDK.getInstance().getMeetingService();
    meetingService.startMeeting(Context context, NEStartMeetingParams param, NEStartMeetingOptions opts, NECallback<Void> callback);
    ```
- 加入会议
    ```java
    NEMeetingService meetingService = NEMeetingSDK.getInstance().getMeetingService();
    meetingService.joinMeeting(Context context, NEJoinMeetingParams param, NEJoinMeetingOptions opts, NECallback<Void> callback);
    ```
- 添加/移除会议状态监听
    ```java
    NEMeetingService meetingService = NEMeetingSDK.getInstance().getMeetingService();
    meetingService.addMeetingStatusListener(NEMeetingStatusListener listener);    //添加监听
    meetingService.removeMeetingStatusListener(NEMeetingStatusListener listener); //移除监听
    ```
- 添加/移除登录状态监听
    ```java
    NEMeetingSDK.getInstance().addAuthListener(NEAuthListener authListener);    //添加监听
    NEMeetingSDK.getInstance().removeAuthListener(NEAuthListener authListener); //移除监听
    ```
- 注销登录
    ```java
    NEMeetingSDK.getInstance().logout(NECallback<Void> callback);
    ```

## 业务开发

### 初始化

#### 描述

在使用SDK其他接口之前，首先需要完成初始化操作。

#### 业务流程

1. 配置初始化相关参数

```java
NEMeetingSDKConfig config = new NEMeetingSDKConfig();
config.appKey = Constants.APPKEY; //应用AppKey
config.appName = context.getString(R.string.app_name); //应用AppName
//配置会议时显示前台服务
NEForegroundServiceConfig foregroundServiceConfig = new NEForegroundServiceConfig();
foregroundServiceConfig.contentTitle = context.getString(R.string.app_name);
config.foregroundServiceConfig = foregroundServiceConfig;
```

2. 调用接口并进行回调处理，该接口无额外回调结果数据

```java
NEMeetingSDK.getInstance().initialize(getApplication(), config, new NECallback<Void>() {
    @Override
    public void onResult(int resultCode, String resultMsg, Void result) {
        if (resultCode == NEMeetingError.ERROR_CODE_SUCCESS) {
            //初始化成功
        } else {
            //初始化失败
        }
    }
});
```

#### 注意事项

- 初始化操作需要保证在**Application**类的**onCreate**方法中执行
- 应用名称，该名称会显示在会议页面的顶部标题栏中，如果不设置，默认显示为<b>会议</b>
- 视频会议在会议过程中，如果退到后台，会被系统杀死，因此需要开启前台服务。当前在会议开始之前开启前台，在回去结束后关闭前台服务。详细配置参考**NEForegroundServiceConfig**

--------------------

### 登录鉴权

#### 描述

请求SDK进行登录鉴权，只有完成SDK登录鉴权才允许创建会议。

#### 业务流程

1. 获取登录用账号ID和Token。Token由网易会议应用服务器下发，但SDK不提供对应接口获取该信息，需要开发者自己实现。

```java
String accountId = "accountId";
String accountToken = "accountToken";
```

2. 登录并进行回调处理，该接口无额外回调结果数据

```java
NEMeetingSDK.getInstance().login(accountId, accountToken, new NECallback<Void>() {
    @Override
    public void onResult(int resultCode, String resultMsg, Void result) {
        if (resultCode == NEMeetingError.ERROR_CODE_SUCCESS) {
            //登录成功
        } else {
            //登录失败
        }
    }
});
```

#### 注意事项

- SDK不提供账号注册机制，第三方应用集成SDK时需要为第三方应用的用户帐号绑定网易会议系统中企业管理员开通的员工帐号，第三方应用的用户帐号和企业员工帐号是1:1映射的。

--------------------

### 创建会议

#### 描述

在已经完成SDK登录鉴权的状态下，创建并开始一个新的会议。

#### 业务流程

1. 配置创建会议用的相关参数

```java
NEStartMeetingParams params = new NEStartMeetingParams();   //会议参数
params.meetingId = "123456789";                             //会议号
params.displayName = "我的会议昵称";                          //会议昵称

NEStartMeetingOptions options = new NEStartMeetingOptions(); //会议选项
options.noVideo = true;                                      //入会时关闭视频，默认为true
options.noAudio = true;                                      //入会时关闭音频，默认为true
options.noInvite = false;                                    //入会隐藏"邀请"按钮，默认为false
options.noChat = false;                                      //入会隐藏"聊天"按钮，默认为false
options.noMinimize = true;                              //入会是否允许最小化会议页面，默认为true
options.injectedMoreMenuItems = addMeetingInfoItem();    //自定义【更多】按钮菜单。（参考自定义会中【更多】菜单内容#注意事项）

private List<NEMeetingMenuItem> addMeetingInfoItem() {
        List<NEMeetingMenuItem> injectedMoreMenuItems = new ArrayList<>();
        NEMeetingMenuItem meetingMenuItem = new NEMeetingMenuItem();
        meetingMenuItem.itemId = 101;
        meetingMenuItem.title = "获取房间信息";
        injectedMoreMenuItems.add(meetingMenuItem);
        return injectedMoreMenuItems;
}
```

2. 调用接口并进行回调处理。该接口无额外回调结果数据，可根据错误码判断是否成功

```java
NEMeetingSDK.getInstance().getMeetingService().startMeeting(getActivity(), params, options, new NECallback<Void>() {
    @Override
    public void onResult(int resultCode, String resultMsg, Void result) {
        if (resultCode == NEMeetingError.ERROR_CODE_SUCCESS) {
            //创建会议成功
        } else {
            //创建会议失败
        }
    }
});
```

3. 创建会议成功后，SDK会拉起会议界面并接管会议逻辑，开发者无需做其他处理。创会人会自动成为该会议的主持人，可进行相关的会议控制操作。其他参会者可通过该会议号加入到该会议中来。

#### 注意事项

- 创建会议时，会议号可以配置为个人会议号(登录后可通过**AccountService**获取)，或者置空(此时由服务器随机分配会议号)。
- 该接口仅支持**在登录鉴权成功后调用**，其他状态下调用不会成功
- 当进入会议前配置了允许最小化会议页面，在会中最小化会议页面，通过会议状态**NEMeetingStatus#MEETING_STATUS_INMEETING_MINIMIZED**回调进行通知。
- android 进入会议后，某些机型如果点击了Home按键，请使用最小化Icon的方式，回到会议界面。实例参考Sample
- 当会中修改密码，增加NEMeetingCode#MEETING_DISCONNECTING_AUTH_INFO_EXPIRED通知

--------------------

### 加入会议

#### 描述

在已登录或未登录的状态下，加入一个当前正在进行中的会议。

#### 业务流程

1. 配置加入会议用的相关参数

```java
NEJoinMeetingParams params = new NEJoinMeetingParams();     //会议参数
params.meetingId = "123456789";                             //会议号
params.displayName = "我的会议昵称";                          //会议昵称
params.password = "123456";                                 //会议密码

NEJoinMeetingOptions options = new NEJoinMeetingOptions();   //会议选项
options.noVideo = true;                                      //入会时关闭视频，默认为true
options.noAudio = true;                                      //入会时关闭音频，默认为true
options.noInvite = false;                                    //入会隐藏"邀请"按钮，默认为false
options.noChat = false;                                      //入会隐藏"聊天"按钮，默认为false
options.noMinimize = true;                              //入会是否允许最小化会议页面，默认为true
options.injectedMoreMenuItems = addMeetingInfoItem();    //自定义【更多】按钮菜单。（参考自定义会中【更多】菜单内容#注意事项）
 
private List<NEMeetingMenuItem> addMeetingInfoItem() {
        List<NEMeetingMenuItem> injectedMoreMenuItems = new ArrayList<>();
        NEMeetingMenuItem meetingMenuItem = new NEMeetingMenuItem();
        meetingMenuItem.itemId = 101;
        meetingMenuItem.title = "获取房间信息";
        injectedMoreMenuItems.add(meetingMenuItem);
        return injectedMoreMenuItems;
}
```

2. 调用接口并进行回调处理。该接口无额外回调结果数据，可根据错误码判断是否成功

```java
NEMeetingSDK.getInstance().getMeetingService().joinMeeting(getActivity(), params, options, new NECallback<Void>() {
    @Override
    public void onResult(int resultCode, String resultMsg, Void result) {
        if (resultCode == NEMeetingError.ERROR_CODE_SUCCESS) {
            //加入会议成功
        } else {
            //加入会议失败
        }
    }
});
```

3. 加入会议成功后，SDK会拉起会议界面并接管会议逻辑，开发者无需做其他处理。

#### 注意事项

- 会议号不能为空，需要配置为真实进行中的会议ID
- 该接口支持登录和未登录状态调用
- 当进入会议前配置了允许最小化会议页面，在会中最小化会议页面，通过会议状态**NEMeetingStatus#MEETING_STATUS_INMEETING_MINIMIZED**回调进行通知。
- android 进入会议后，某些机型如果点击了Home，请使用最小化Icon的方式，回到会议界面。实例参考Sample
--------------------

### 创建预约会议

#### 描述

在已登录状态下，预约一个会议

#### 业务流程

1. 创建预约会议

```java
    public NEMeetingItem createScheduleMeetingItem() {
        return NEMeetingSDK.getInstance().getPreMeetingService()
          .createScheduleMeetingItem();
    }
    public void scheduleMeeting(NEMeetingItem item, NECallback<NEMeetingItem> callback) {
        NEMeetingSDK.getInstance().getPreMeetingService().scheduleMeeting(item,callback);
    }
```

2. 调用接口并进行回调处理，可根据错误码判断是否成功

```java
	       neMeetingItem.setSubject("会议主题")	     //预约会议主题
                            .setStartTime(startTime)   //预约会议开始时间
                            .setEndTime(endTime)	     //预约会议结束时间								
                        		.setPassword("passWord");  //预约会议配置密码
                    }
                    NEMeetingItemSetting setting = new NEMeetingItemSetting();
                    setting.isAttendeeAudioOff = false; //是否使用入会时音频开关
                    neMeetingItem.setSetting(setting);
NEMeetingSDK.getInstance().getPreMeetingService().scheduleMeeting(neMeetingItem, new ToastCallback<NEMeetingItem>() {
                        @Override
                        public void onResult(int resultCode, String resultMsg, NEMeetingItem resultData) {
                            if (resultCode == NEMeetingError.ERROR_CODE_SUCCESS) {
                                //TODO do something
                            }
                        }
                    });
```

#### 注意事项

- 预约会议时，scheduleMeeting接口中的参数NEMeetingItem，必须是createScheduleMeetingItem返回的对象。

--------------------

### 取消预约会议

#### 描述

在已登录状态下，取消一个预约会议

#### 业务流程

1. 取消预约会议

```java
      public void cancelMeeting(long meetingUniqueId, NECallback<Void> callback) {
      NEMeetingSDK.getInstance().getPreMeetingService()
        .cancelMeeting(meetingUniqueId,callback);
    }
   
```

2. 调用接口并进行回调处理，可根据错误码判断是否成功

```java
  NEMeetingSDK.getInstance().getPreMeetingService().cancelMeeting(meetingUniqueId, new ToastCallback<Void>() {
                @Override
                public void onResult(int resultCode, String resultMsg, Void resultData) {
                    //TODO  do something
                }
            });
```

#### 注意事项

- 取消预约会议的参数meetingUniqueId是服务端返回的唯一码，从NEMeetingItem#getMeetingUniqueId处获取。
- 会议状态在进行中、已回收状态或者已超过结束时间，是无法取消。

--------------------

### 查询预定会议信息

#### 描述

在已登录状态下，查询一个预约会议

#### 业务流程

1. 查询预定会议信息

```java
  public void getMeetingItemById(int meetingUniqueId, NECallback<NEMeetingItem> callback) {
        NEMeetingSDK.getInstance().getPreMeetingService().getMeetingItemById(meetingUniqueId,callback);
    }
   
```

2. 调用接口并进行回调处理，可根据错误码判断是否成功

```java
  NEMeetingSDK.getInstance().getPreMeetingService().getMeetingItemById(meetingUniqueId, new ToastCallback<NEMeetingItem>() {
                @Override
                public void onResult(int resultCode, String resultMsg, NEMeetingItem resultData) {
                    //TODO  do something
                }
            });
```

#### 注意事项

- 查询预约会议的参数meetingUniqueId是服务端返回的唯一码，从NEMeetingItem#getMeetingUniqueId处获取。

--------------------

### 查询特定状态下的预约会议列表

#### 描述

在已登录状态下，查询特定状态下的预约会议列表

#### 业务流程

1. 查询预约会议列表

```java
  List<NEMeetingItemStatus> status = new ArrayList<>();
        status.add(NEMeetingItemStatus.init);
        status.add(NEMeetingItemStatus.started);
        status.add(NEMeetingItemStatus.ended);

  public void getMeetingList(List<NEMeetingItemStatus> status, NECallback<List<NEMeetingItem>> callback) {
        NEMeetingSDK.getInstance().getPreMeetingService().getMeetingList(status,callback);
    }
   
```

2. 调用接口并进行回调处理，可根据错误码判断是否成功

```java
  NEMeetingSDK.getInstance().getPreMeetingService().getMeetingList(status, new ToastCallback< List<NEMeetingItem> >() {
                @Override
                public void onResult(int resultCode, String resultMsg, List<NEMeetingItem> resultData) {
                    //TODO  do something
                }
            });
```

#### 注意事项

- 查询特定
下的预约会议列表在时间范围上，是默认返回最近一周的。

--------------------

### 监听预约会议状态

#### 描述

通过注册会议状态回调接口，可获取到预约会议状态变更的通知。

#### 业务流程

1. 注册回调接口开始监听，并在回调方法中处理感兴趣的事件

```java
    NEScheduleMeetingStatusListener listener = new NEScheduleMeetingStatusListener() {

    @Override
    public void onScheduleMeetingStatusChange(List<NEMeetingItem> changedMeetingItemList, boolean incremental) {
      //TODO do something        
    }
};
NEMeetingSDK.getInstance().getPreMeetingService().registerScheduleMeetingStatusListener(listener);
```

2. 反注册回调接口停止监听

```java
NEMeetingSDK.getInstance().getPreMeetingService().unRegisterScheduleMeetingStatusListener(listener);
```

#### 注意事项

- 在SDK初始化成功后可以调用
- 会议状态变更回调，一次回调可能包含多个会议信息的变更
- 当状态回调参数是incremental为false，为全量变更；true为增量变更

--------------------



### 监听会议状态

#### 描述

通过注册会议状态回调接口，可获取到会议状态变更的通知。

#### 业务流程

1. 注册回调接口开始监听，并在回调方法中处理感兴趣的事件

```java
NEMeetingStatusListener listener = new NEMeetingStatusListener() {
    @Override
    public void onMeetingStatusChanged(Event event) {
       //处理会议状态变更事件          
    }
};
NEMeetingSDK.getInstance().getMeetingService().addMeetingStatusListener(listener);
```

2. 反注册回调接口停止监听

```java
NEMeetingSDK.getInstance().getMeetingService().removeMeetingStatusListener(listener);
```

#### 注意事项

- 在SDK初始化成功后可以调用
- 1.2.2版本及以后增加了MEETING_STATUS_WAITING状态
- 1.2.4版本及以后当进入会议前配置了允许最小化会议页面，在会中最小化会议页面，通过会议状态**NEMeetingStatus#MEETING_STATUS_INMEETING_MINIMIZED**回调进行通知。若需要返回会议界面，调用接口***NEMeetingSDK.getInstance().getMeetingService().returnToMeeting(this)***
- android 进入会议后，某些机型如果点击了home按键，请使用最小化Icon的方式，回到会议界面。实例参考Sample

--------------------
### 获取当前会议信息

#### 描述

在完成登录授权状态下，获取当前账号关联的个人会议ID。

#### 业务流程

1. 确认已经通过入会方式（加入会议/创建会议/匿名入会）在会议内，

2. 调用接口并进行回调处理。该接口的回调结果数据类型为NEMeetingInfo对象类型；如果当前无正在进行中的会议，则回调数据对象为空

```java

NEMeetingSDK.getInstance().getMeetingService().getCurrentMeetingInfo(new NECallback<NEMeetingInfo>() {
    @Override
    public void onResult(int resultCode, String resultMsg, NEMeetingInfo resultData) {
        Log.d("OnCustomMenuListener", "getCurrentMeetingInfo:resultCode " + resultCode + "#resultData " + resultData.toString());
    }
});
```
#### 注意事项

- 在SDK进入会议会议状态，才能获取当前会议信息

--------------------

### 获取个人会议号

#### 描述

在完成登录授权状态下，获取当前账号关联的个人会议ID。

#### 业务流程

1. 确认已完成SDK登录鉴权

2. 调用接口并进行回调处理。该接口的回调结果数据类型为字符串类型，可根据错误码判断是否成功

```java
NEMeetingSDK.getInstance().getAccountService().getPersonalMeetingId(new NECallback<String>() {
    @Override
    public void onResult(int resultCode, String resultMsg, String result) {
        if (resultCode == NEMeetingError.ERROR_CODE_SUCCESS) {
            //获取个人会议号成功，result即为个人会议号
        } else {
            //获取个人会议号失败
        }
    }
});
```

3. 获取个人会议号后，可用于创建会议

#### 注意事项

- 仅在已登录状态下才会成功返回数据

--------------------

### 监听登录状态

#### 描述

通过注册登录状态回调接口，可获取到登录状态变更的通知。

#### 业务流程

1. 注册回调接口开始监听，并在回调接口中处理感兴趣的事件

```java
NEAuthListener authListener = new NEAuthListener() {
    @Override
    public void onKickOut() {
        //当前账号已在其他设备上登录
    }
  
    @Override
    public void onAuthInfoExpired() {
        //账号信息过期通知，原因为用户修改了密码，应用层随后应该重新登录
    }
};
NEMeetingSDK.getInstance().addAuthListener(authListener);    //添加监听
```

2. 反注册回调接口停止监听

```java
NEMeetingSDK.getInstance().removeAuthListener(authListener); //移除监听
```

#### 注意事项

- 无

--------------------


### 自定义会中【更多】菜单内容
1. 配置匿名入会/创建会议/加入会议的Options相关参数

```java
options.noInvite = false;                                    //入会隐藏"邀请"按钮，默认为false
options.noChat = false;                                      //入会隐藏"聊天"按钮，默认为false
options.injectedMoreMenuItems = addMeetingInfoItem();    //入会隐藏"聊天"按钮，默认为false。（参考注意事项）

private List<NEMeetingMenuItem> addMeetingInfoItem() {
        List<NEMeetingMenuItem> injectedMoreMenuItems = new ArrayList<>();
        NEMeetingMenuItem meetingMenuItem = new NEMeetingMenuItem();
        meetingMenuItem.itemId = 101;
        meetingMenuItem.title = "获取房间信息";
        injectedMoreMenuItems.add(meetingMenuItem);
        return injectedMoreMenuItems;
}
```
2. 设置回调接口开始监听，并在回调方法中处理自定义按钮的事件
  
```java
NEMeetingSDK.getInstance().getMeetingService().setOnInjectedMenuItemClickListener(new OnCustomMenuListener());
   NEMeetingStatusListener listener = new NEMeetingStatusListener() {
       @Override
       public void onMeetingStatusChanged(Event event) {
          //处理会议状态变更事件          
       }
   };
   public class OnCustomMenuListener implements NEMeetingOnInjectedMenuItemClickListener {
        @Override
        public void onInjectedMenuItemClick(NEMeetingMenuItem menuItem, NEMeetingInfo meetingInfo) {
            switch (menuItem.itemId) {
                case 101:
                        //TODO 
                    break;
            }
        }
    }
```

#### 注意事项

- 自定义会中【更多】菜单内容，需要在入会前完成设置，在会议中设置不会生效
- 默认【更多】菜单内容中的邀请和聊天，支持隐藏/显示配置
- 合法的自定义菜单项需满足以下条件： <ul><li>itemId >= 100，且为整数Int类型</li><li>title不为空和空格（对空格做trim处理），且长度不大于10字符</li></ul>
- 会议自定义菜单项，**更多**菜单中最多支持添加**三个**自定义菜单项，如果超过**三个**个仅显示前三个合法自定义按钮

--------------------

### 注销

#### 描述

请求SDK注销当前已登录账号，返回未登录状态。

#### 业务流程

1. 调用接口并进行回调处理。该接口无额外回调结果数据，可根据错误码判断是否成功

```java
NEMeetingSDK.getInstance().logout(new NECallback<Void>() {
    @Override
    public void onResult(int resultCode, String resultMsg, Void result) {
        if (resultCode == NEMeetingError.ERROR_CODE_SUCCESS) {
            //注销登录成功
        } else {
            //注销登录失败
        }
    }
});
```

#### 注意事项

- 账号注销后，登录状态被清空，不再允许创建会议


--------------------

### 使用会议设置服务

#### 描述

通过会议设置服务，可设置和查询用户的当前会议设置，如入会时的音视频开关、会议持续时间的显示等。

#### 业务流程

1. 获取会议设置服务

```java
NESettingsService settingsService = NEMeetingSDK.getInstance().getSettingsService();
```

2. 调用不同接口保存设置项或查询设置项

- 设置并保存会议设置
```java
// 设置并保存会议设置
settingsService.enableShowMyMeetingElapseTime(true);
settingsService.setTurnOnMyAudioWhenJoinMeeting(true);
settingsService.setTurnOnMyVideoWhenJoinMeeting(true);

//查询会议设置
boolean showMeetingElapseTimeEnabled = settingsService.isShowMyMeetingElapseTimeEnabled();
boolean audioEnabled = settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled();
boolean videoEnabled = settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled();
```

- 设置并保存美颜配置
```java

    /**
     * 设置美颜参数
     * @param value 传入美颜等级，参数规则为[0,10]整数
     */
    NEMeetingSDK.getInstance().getSettingsService().setBeautyFaceValue(value);
```
```java
    /**
      * 查询美颜开通状态，开通请咨询下面注意事项官网地址
      * @return true-打开，false-关闭
      */
    boolean isBeautyFaceEnabled = NEMeetingSDK.getInstance().getSettingsService().isBeautyFaceEnabled();
```
```java
    /**
     * 获取当前美颜参数，关闭返回0
     */
    NEMeetingSDK.getInstance().getSettingsService().getBeautyFaceValue((resultCode, resultMsg, resultData)->
    Log.d("SettingsFragment", "initView:getBeautyFaceValue =  " +resultData ));
```
```java
    /**
     * 打开美颜界面，必须在init之后调用该接口，支持会前设置使用。
     *
     * @param context
     * @param callback 回调
     */
    NEMeetingSDK.getInstance().getSettingsService().openBeautyUI(context,(resultCode, resultMsg, resultData) ->
    Log.d("SettingsFragment", "initView:resultData =  " +resultData ));
```

3. 调用不同接口保存设置项或查询设置项
#### 注意事项

- 针对已登录用户而言，每个用户有自己独立的一份会议设置；其他所有未登录用户、匿名用户共享一份会议设置。
- 会议设置项仅在当前设备上保存，不会漫游。
- 调用创建会议/加入会议接口时，如果接口中`NEMeetingOptions`入参为`null`，SDK会使用会议设置服务中已保存的相关配置进行创会/入会。
- 美颜服务开通官网咨询渠道：[云信官网](http://yunxin.163.com/)
- 美颜配置支持多端漫游。


--------------------

### 使用遥控器服务

#### 描述

通过遥控器服务，可打开遥控器页面，和电视进行配对，也可以自定义遥控器的设置、邀请按钮。

#### 业务流程

1. 获取遥控器服务

```java
NEControlService controlService = NEMeetingSDK.getInstance().getControlService();
```

2. 打开遥控器

```java   

NEControlParams params = new NEControlParams();              //遥控器参数
params.displayName = "我的会议昵称";                           //会议昵称


NEControlOptions options = new NEControlOptions();           //遥控器选项
options.settingMenu = new NEControlMenuItem("自定义设置名称"); //自定义【更多】按钮菜单。
options.shareMenu = new NEControlMenuItem("自定义邀请名称");   //自定义【更多】按钮菜单。

 
NEMeetingSDK.getInstance().getControlService().openControlUI(context, params, opts, new NECallback<Void>() {
    @Override
    public void onResult(int resultCode, String resultMsg, Void result) {
        if (resultCode == NEMeetingError.ERROR_CODE_SUCCESS) {
            //打开遥控器成功
        } else {
            //打开遥控器失败
        }
    }
});
```

3. 自定义遥控器的设置、邀请按钮

```java
NEMeetingSDK.getInstance().getControlService().setOnCustomMenuItemClickListener(new NEControlMenuItemClickListener {
        @Override
        public void onSettingMenuItemClick(NEControlMenuItem menuItem) {
            Toast.makeText(MainActivity.this, "点击了" + menuItem.title, Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onShareMenuItemClick(NEControlMenuItem menuItem, NEMeetingInfo meetingInfo) {
            Toast.makeText(MainActivity.this, "点击了" + menuItem.title, Toast.LENGTH_SHORT).show();
        }
    });

```
4. 遥控器内部状态监听注册和反注册

```java

    NEControlListener controlListener = new NEControlListener() {
        @Override
        public void onStartMeetingResult(NEControlResult status) {
            Toast.makeText(MainActivity.this, "遥控器开始会议事件回调:" + status.code + "#" + status.message, Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onJoinMeetingResult(NEControlResult status) {
            Toast.makeText(MainActivity.this, "遥控器加入会议事件回调:" + status.code + "#" + status.message, Toast.LENGTH_SHORT).show();
        }
    };
  NEMeetingSDK.getInstance().getControlService().registerControlListener(listener);
  
  NEMeetingSDK.getInstance().getControlService().unRegisterControlListener(listener);
```

#### 注意事项

- 登陆状态下才能够使用遥控器服务
- 会中状态暂不支持开启遥控器；遥控器打开时，不支持进入会议，二者为互斥逻辑。

