#!/bin/sh

f="process.txt"
db=`pwd`/db

n=`pwd | awk 'BEGIN {FS="/"};{printf $NF }'`
p=`sudo podman ps | grep "$n" | awk 'BEGIN {FS=" "};{print $1}'`

if [ ! -z "$p" ]; then
	echo Már fut.
else
	if [ -d $db ]; then
		rm -r $db/*
		echo DB ok.
	else
		mkdir $db
		chmod 777 $db
		echo DB ok.
	fi
	if [ -d /var/lib/mysql ]; then
		echo DB2 ok.
	else
		ln -s $db /var/lib/mysql
		echo DB2 ok.
	fi
	if [ -d $(pwd)/log ]; then
		rm -r $(pwd)/log/*
		echo Log ok.
	else
		mkdir $(pwd)/log
		chmod 777 $(pwd)/log
		echo Log ok.
	fi
	if [ -d /var/log/mysql ]; then
		echo Log2 ok.
	else
		ln -s $(pwd)/log /var/log/mysql
		echo Log2 ok.
	fi
	sudo podman run --name pod-deb-mariadb -p 3306:3306 \
			--mount type=bind,source=$(pwd)/log,target=/var/log/mysql \
			--mount type=bind,source=$(pwd)/db,target=/var/lib/mysql \
			$n &
			#--mount type=bind,source=./log,target=/var/log/mysql \
			#--mount type=bind,source=/var/lib/mysql,target=/var/lib/mysql \
			#-v "mysqldb:/var/lib/mysql" \
	sleep 5
	podman exec pod-deb-mariadb /usr/local/bin/sqlinit.sh
	c=`sudo podman ps | grep "$n" | awk 'BEGIN {FS=" "};{print $1}'`
	if [ ! -z "$c" ]; then
		echo $c >$f
		echo Fut.
	else
		echo Nem indult el.
	fi
fi
