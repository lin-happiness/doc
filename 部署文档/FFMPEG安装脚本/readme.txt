安装说明：
1、脚本分为在线和半离线版本，分别为：ffmpegInstallOnline.sh、ffmpegInstallHalfOffline.sh
2、在线版本ffmpeg安装所有依赖包都需要在线下载安装，使用方法：
	a、上传脚本ffmpegInstallOnline.sh到/root目录下
	b、给予执行权限，命令：chmod u+x ffmpegInstallOnline.sh
	c、执行脚本 命令： ./ffmpegInstallOnline.sh
3、半离线版本是为了解决ffmpeg部分依赖下载很慢的问题，使用方法：
	a、上传脚本ffmpegInstallHalfOffline.sh和ffmpeg_sources文件夹到/root目录下
	b、给予执行权限，命令：chmod u+x ffmpegInstallHalfOffline.sh
	c、执行脚本 命令： ./ffmpegInstallHalfOffline.sh


