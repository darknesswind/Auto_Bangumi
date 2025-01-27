#!/bin/bash

webDir=/templates
versionFile=$webDir/version
version=$AB_WEBUI_VERSION

echo '获取webui最新版本号'
tag=$(curl 'https://api.github.com/repos/Rewrite0/Auto_Bangumi_WebUI/releases/latest' | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
if [ -f $versionFile ]; then
	oldTag=$(cat $versionFile)
fi

getWeb() {
	echo '准备下载最新版本webui'
	wget https://cdn.jsdelivr.net/gh/Rewrite0/Auto_Bangumi_WebUI@$1/build/dist.zip
	file=./dist.zip

	# 检查是否下载完成
	if [ -f $file ]; then
		unzip $file
		rm $file && mv dist $webDir
		echo $1 > $versionFile
		echo 'webui下载完成'
	else
		echo 'webui下载失败, 重新下载'
		getWeb $1
	fi
}

reGetWeb() {
	rm -rf $webDir
	getWeb $1
}

# 检查是否指定了版本号
if [ $version ]; then

	# 检查是否有旧版本
	if [ $oldTag ]; then
		if [ $version == $oldTag ]; then
			echo '版本一致, 无需更新'
		else
			reGetWeb $version
		fi
	else
		getWeb $version
	fi

else

	# 检查是否有旧版本
	if [ $oldTag ]; then

		# 版本不符则下载最新版本
		if [ $tag != $oldTag ]; then
			reGetWeb $tag
		else
			echo '当前webui为最新版本, 无需更新'
		fi

	else
		getWeb $tag
	fi
fi
