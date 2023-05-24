# Linux-shell
简单基础的shell脚本

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


