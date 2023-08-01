# Linux-shell
简单基础的shell脚本标准开头信息<br/>
#/bin/bash<br/>
#===============================================<br/>
#FILE:文件<br/>
#USAGE:用法<br/>
#DESCRIPTION:描述<br/>
#OPTIONS:选项<br/>
#REQUIREMENTS:要求<br/>
#BUGS:已知错误<br/>
#NOTES:备注<br/>
#AUTHOR:作者<br/>
#ORGANIZATION:公司或组织<br/>
#CREATED:创建时间 <br/>
#REVISION:修订版<br/>
#==============================================<br/>


### 1.一个点点进度条
user@Ubuntu:~$ ./8.4.1.sh <br/>
./8.4.1.sh: please wait....10+0 records in<br/>
10+0 records out<br/>
104857600 bytes (105 MB, 100 MiB) copied, 0.0844163 s, 1.2 GB/s<br/>
...done.<br/>
### 2.判断邮箱等正则表达式
user@Ubuntu:~$ ./9.1.4.sh <br/>
Input a email,Please:jsgucfvy@krbfsj.com<br/>
This email address looks fine:jsgucfvy@krbfsj.com<br/>
### 3.case_选项模板函数
user@Ubuntu:~$ ./command.sh<br/>
Backup utility<br/>
Usage: command.sh {sql|sync|snap}<br/>
    sql : Run MySQL backup utility.<br/>
    sync : Run web server backup utility.<br/>
Input a command,Please:sync<br/>
Running backup using rsync tool...<br/>
shopt -s nocasematch   # 打开Bash的开关，忽略大小写<br/>
参数：-u关闭<br/>

### 4.输入的参数相关函数
user@Ubuntu:~$ ./connand.sh one two there<br/>
Listing args With $*:<br/>
Arg #1 = one<br/>
Arg #2 = two<br/>
Arg #3 = there<br/>

