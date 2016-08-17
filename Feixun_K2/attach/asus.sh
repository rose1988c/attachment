#!/bin/sh
# http://www.right.com.cn/forum/thread-187521-1-1.html
# by 1556284689
[ -f /tmp/asus.lock -o -f /tmp/all.lock ] && exit
web=/etc_ro/web/index.asp
web1=/etc_ro/web/diagnosis.asp
web2=http://www.right.com.cn/forum/thread-187521-1-1.html
server=http://code.taobao.org/svn/asus_bin
log() {
echo "<br>$1 ..." >> $web
}
rm -f /tmp/*.bin
touch /tmp/asus.lock
cat > $web <<EOF
<head>
<meta http-equiv="refresh" content="3;url=$web2">
</head>
Begin ...<br>
<br>Downloading breed ...
EOF
if wget -O /tmp/breed.bin $server/breed.bin;then
md51=$(wget -qO- $server/md5.txt |awk '/breed/ {print $1}')
md52=$(openssl md5 /tmp/breed.bin |awk '{print $2}')
if [ "$md51" = "$md52" ];then
log "Version : $(wget -qO- $server/md5.txt |awk '/breed/ {print $3}')"
log "Writing Bootloader"
[ -f /tmp/breed.lock ] || mtd_write write /tmp/breed.bin Bootloader
log "Breed ok!"
touch /tmp/breed.lock
else
log "Breed md5 error"
fi
else
log "Breed download error"
fi
[ "$1" = "breed" ] || {
echo "<br>" >> $web
log "Downloading asus.bin"
if wget -O /tmp/asus.bin $server/asus.bin;then
md53=$(wget -qO- $server/md5.txt |awk '/AC54U/ {print $1}')
md54=$(openssl md5 /tmp/asus.bin |awk '{print $2}')
if [ "$md53" = "$md54" ];then
log "Version : $(wget -qO- $server/md5.txt |awk '/AC54U/ {print $3}')"
log "Writing Kernel"
[ -f /tmp/Kernel.lock ] || mtd_write write /tmp/asus.bin Kernel
log "Asus ok!"
touch /tmp/Kernel.lock
else
log "Asus md5 error"
fi
else
log "Asus download error"
fi
echo "<br>" >> $web
staus=$(grep ok $web |wc -l)
if [ "$staus" = "2" ];then
log "All done!"
touch /tmp/all.lock
else
log "Something error"
fi
}
[ -z "$(grep error $web)" ] || {
cat >> $web <<EOF
<br><br>
<a href="$web2" target="_blank">$web2</a>
EOF
sed -i '/refresh/d' $web
}
cat >> $web <<EOF
<br><br>
<a href="/goform/gra_doReboot?reboot=1" target="_blank">Click here to reboot your router</a>
<br><br>
<a href="$web2" target="_blank">By : 1556284689</a>
EOF
if [ -f "$web1" ]; then
nvram set system_command=
nvram commit
sed -i 's#/gra_doReboot?reboot=1#/doReboot#' $web
cp $web $web1
fi
cp $web /etc_ro/web/link.asp
rm -f /tmp/*.bin /tmp/*.sh
rm -f /tmp/asus.lock
