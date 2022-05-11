#!/bin/bash

# Script ffmpeg compile for Centos 7.x
# linlefu, thanks to Hunter,Alvaro Bustos.
# Updated 20-1-2021
# URL base https://trac.ffmpeg.org/wiki/CompilationGuide/Centos

clear
echo 安装进程开始
sleep 1s
clear
echo 安装进程开始  3
sleep 1s
clear
echo 安装进程开始  3  2
sleep 1s
clear
echo 安装进程开始  3  2  1
sleep 1s
# Install libraries
yum install -y autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel

echo 创建目录
sleep 1s
# Create a temporary directory for sources.
SOURCES=$(mkdir ~/ffmpeg_sources)
cd ~/ffmpeg_sources

echo 下载安装文件
sleep 1s
# Download the necessary sources.
curl -O http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2
wget ftp://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20191217-2245.tar.bz2
wget https://bitbucket.org/multicoreware/x265_git/downloads/x265_3.3.tar.gz
wget https://sourceforge.net/projects/opencore-amr/files/fdk-aac/fdk-aac-2.0.1.tar.gz/download
mv download fdk-aac-2.0.1.tar.gz
curl -O -L http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
wget http://www.mirrorservice.org/sites/distfiles.macports.org/libopus/opus-1.3.1.tar.gz
wget https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.4.tar.gz
wget http://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.7.tar.gz
curl -O -L https://ftp.osuosl.org/pub/xiph/releases/theora/libtheora-1.1.1.tar.gz
wget https://github.com/webmproject/libvpx/archive/v1.9.0.tar.gz
wget http://ffmpeg.org/releases/ffmpeg-4.3.tar.gz

echo 解压文件
sleep 3s
# Unpack files
for file in `ls ~/ffmpeg_sources/*.tar.*`; do
tar -xvf $file
done


echo 5秒钟后开始安装
sleep 5s
# Install files

echo 安装nasm
sleep 1s

cd nasm-*/
./autogen.sh 
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" 
make
make install 
cd ..

cp /root/bin/nasm /usr/bin

echo 安装yasm
sleep 1s

cd yasm-*/
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && make && make install
cd ..

cp /root/bin/yasm /usr/bin

echo 安装x264
sleep 1s

cd x264-*/
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static && make && make install
cd ..

echo 安装x265
sleep 1s
cd /root/ffmpeg_sources/x265_3.3/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source && make && make install 
cd ~/ffmpeg_sources

echo 安装acc
sleep 1s

cd fdk-aac-*/
autoreconf -fiv && ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && make && make install
cd ..

echo 安装lame
sleep 1s

cd lame-*/
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm && make && make install
cd ..

echo 安装opus
sleep 1s

cd opus-*/
./configure --prefix="$HOME/ffmpeg_build" --disable-shared && make && make install
cd ..

echo 安装libogg
sleep 1s

cd libogg-*/
./configure --prefix="$HOME/ffmpeg_build" --disable-shared && make && make install
cd ..

echo 安装libvorbis
sleep 1s

cd libvorbis-*/
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared && make && make install
cd ..


echo 安装libtheora
sleep 1s

cd libtheora-*/
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared && make && make install
cd ..

echo 安装libvpx
sleep 1s

cd libvpx-*/
./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && make && make install
cd ..

echo 安装ffmpeg
sleep 1s

cd ffmpeg-*/
PATH="$HOME/bin:$PATH" 
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig:$PKG_CONFIG_PATH
./configure --prefix="$HOME/ffmpeg_build" --pkg-config-flags="--static" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --extra-libs=-lpthread --extra-libs=-lm --bindir="$HOME/bin" --enable-gpl --enable-libfdk_aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libtheora --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree && make && make install && hash -r 

# copy file
cd ..
cd ~/bin
cp ffmpeg ffprobe lame x264 /usr/local/bin
cd /root/ffmpeg_build/bin
cp x265 /usr/local/bin

echo 安装进程结束
sleep 3s
ffmpeg -version
echo "FFmpeg Compilation is Finished!"
