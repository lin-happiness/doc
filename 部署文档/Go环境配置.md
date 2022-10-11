## 1、下载GO安装文件
    wget https://studygolang.com/dl/golang/go1.16.linux-amd64.tar.gz
## 2、解压压缩包
	tar -xvf go1.16.linux-amd64.tar.gz
	
	mv go/ /usr/local/go

## 3、创建目录 /usr/local/gopath/
	mkdir /usr/local/gopath

## 4、设置环境变量
	vi /etc/profile
添加内容

	export GOROOT=/usr/local/go
	export GOPATH=/usr/local/gopath
	export PATH=$PATH:$GOROOT/bin:$GPPATH/bin
## 5、生效配置
	source  /etc/profile 