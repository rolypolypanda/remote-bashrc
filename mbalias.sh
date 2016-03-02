# mbalias.sh
# Begin setup env.

if [[ $(hostname | egrep -Ec '(snafu|mac|fedora-srv)') == 1 ]]; then
    echo "You're at home, not setting up aliases, etc..." ;
else
    echo -ne "\033k$HOSTNAME\033\\" ;
    export PS1='\[\e[1;32m\]\u\[\e[1;37m\]@\[\e[0;37m\]\H\[\e[0;36m\]: \w\[\e[0;0m\] \$ ' ;
    export EDITOR="vim" ;
    alias ll="ls -lah" ;
    alias grep="egrep --color=auto" ;
    alias hist="history" ;
    alias vim="vim -u /root/vimrc" ;
fi


# Begin functions.

zzgetvimrc() {
    if [[ -f /root/vimrc ]]; then
        echo -e "\nvimrc Already exists, moving it to vimrc.bak.\n"
        mv /root/vimrc{,.bak}
fi
    wget --no-check-certificate http://filez.dizinc.com/~michaelb/sh/vimrc && mv vimrc /root/vimrc ;
}
zzgetvimrc

zzcommands() {
    echo -e "\nzzphpini\nzzphphandler\nzzphpinfo\nzzmemload\nzzfixtmp\nzzacctdom\nzzacctpkg\nzzmkbackup\nzzversions\nzzgetvimrc"
    echo -e "zzsetnsdvps\nzzmysqltune\nzzapachetune\nzzdiskuse\n"
}

zzphpini() {
    if [[ $(/usr/local/cpanel/bin/rebuild_phpconf --current | grep -c dso) == 1 ]]; then
        echo -i "This server is using DSO, you must set PHP directives in the $(pwd)/.htaccess file.\n" ;
        sleep 10 ;
    fi
    cp /usr/local/lib/$1.ini . ;
    if [[ $(grep -qwc suPHP_ConfigPath $(pwd)/.htaccess) == 1 ]]; then
        echo "suPHP_ConfigPath is already set in $(pwd)/.htaccess."
            else
        echo -e "<IfModule mod_suphp.c>\nsuPHP_ConfigPath $(pwd)\n</IfModule>\n" >> .htaccess ;
        chown $(stat . | grep -w 'Uid:' | awk '{ print $6 }' | tr -d ')'): .htaccess ;
    fi
    echo -e "\nFor notes:\n"
    echo -e "\`[root@$(hostname):$(pwd) #] cp /usr/local/lib/$1.ini .\`"
    echo -e "- Added the following to \`$(pwd)/.htaccess\`"
    echo -e "\`\`\`"
    echo -e "<IfModule mod_suphp.c>\nsuPHP_ConfigPath $(pwd)\n</IfModule>\n"
    echo -e "\`\`\`"
}

zzphphandler() {
    /usr/local/cpanel/bin/rebuild_phpconf --current
}

zzphpinfo() {
    echo -e "<?php phpinfo.php(); ?>" > phpinfo.php ;
    chown $(stat . | grep -w 'Uid:' | awk '{ print $6 }' | tr -d ')'): phpinfo.php ;
}

zzmemload() {
    echo -e "- Current server load \`(w / sar -q 15)\`:\n" ;
    echo "\`\`\`" ;
    CPUCOUNT=$(grep -c proc /proc/cpuinfo)
    echo -e "CPU count: $CPUCOUNT\n"
    w ;
    sar -q 1 5 ;
    echo "\`\`\`" ;
    echo -e "\n- Free memory \`(free -m)\`:\n" ;
    echo "\`\`\`" ;
    free -m ;
    echo "\`\`\`" ;
}

zzdiskuse() {
    echo -e "\n- Disk usage and inode count \`(df -h / df -i)\`:\n" ;
    echo "\`\`\`" ;
    df -h ;
    echo "\`\`\`" ;
    echo "\`\`\`" ;
    df -i ;
    echo "\`\`\`" ;
}

zzfixtmp() {
    read -p "Enter ticket ID number: " TID
    mkdir -p /home/.hd/logs/$TID
    chmod 1777 /tmp ;
    find /tmp -type f -mmin +30 -exec rm -vf {} \; | tee -a /home/.hd/logs/$TID/tmpremovedfiles.log
    echo -e "\n- List of removed files located in \`/home/.hd/logs/$TID/tpmremovedfiles.log\`\n"
}

zzacctdom() {
    echo -e "Account Owner: $(grep $1 /etc/trueuserdomains | cut -d':' -f2)"
    egrep -Hrn $1 /etc/*domains
}

zzacctpkg() {
    read -p "Enter cPanel account name: " ACT
    read -p "Enter ticket ID number: " TID
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly} ;
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/pkgacct $ACT /home/.hd/ticket/$TID/original | tee -a /home/.hd/logs/$TID/$ACT/pkgacct-$(date +%s).log ;
    echo -e "For Notes:\n"
    echo -e "\`[root@$(hostname):$(pwd) #] mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`[root@$(hostname):$(pwd) #] /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/pkgacct $ACT /home/.hd/ticket/$TID/original\`" ;
    echo -e "\n- Account \`$ACT\` packaged in \`/home/.hd/ticket/$TID/cpmove-$ACT.tar.gz\`\n" ;
    echo -e "\n**Additional Info:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/pkgacct-$(date +%s).log\`\n" ;
}

zzversions() {
    echo -e "- Software Versions:\n"
    echo "\`\`\`"
    cat /etc/redhat-release ;
    echo "Kernel version: $(uname -r)" ;
    echo "cPanel version: $(cat /usr/local/cpanel/version)" ;
    echo "MySQL version: $(mysql -V | awk '{ print $5 }' | tr -d ',')" ;
    echo "PHP version: $(php -v | head -n 1 | awk '{ print $2 }')" ;
    echo "Apache version: $(httpd -v | head -n 1 | cut -d'/' -f2 | awk '{ print $1 }')" ;
    if
        [[ -f /etc/init.d/nginx ]]; then
        nginx -v ;
    fi
    echo "\`\`\`"
}

zzmkbackup() {
    read -p "Enter cPanel account name: " ACT
    read -p "Enter ticket ID number: " TID
    find /backup -maxdepth 4 -type f -name "${ACT}*" -print
    find /backup -maxdepth 4 -type d -name "${ACT}" -print
    read -p "Enter the path of the backup you would like to create: " PTH
    read -p "Daily, Weekly, or Monthly backup? " DTE
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly} ;
    cd $PTH ;
    cd ..
    tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/ | tee -a /home/.hd/logs/$TID/$ACT/backup-$(date +%s).log ;
    echo -e "\`[root@$(hostname):$(pwd) #] mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`[root@$(hostname):$(pwd) #] tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/\`" ;
    echo -e "- Backup for account $ACT created in \`/home/.hd/ticket/$TID/$DTE/$ACT.tar.gz\`\n" ;
    echo -e "**Additional Info:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/backup-$(date +%s).log\`\n" ;
}

zzmysqltune() {
    perl <(curl -k -L http://raw.github.com/rackerhacker/MySQLTuner-perl/master/mysqltuner.pl) ;
}

zzapachetune() {
    curl -L http://apachebuddy.pl/ | perl
}

zzsetnsdvps() {
    echo -e "\nNOT READY FOR USE YET!\n" ;
    sleep 1 ;
    echo -e "\nNOT READY FOR USE YET!\n" ;
    sleep 1 ;
    echo -e "\nNOT READY FOR USE YET!\n" ;
    sleep 1
    echo -e "\nNOT READY FOR USE YET!\n" ;
    sleep 10 ;
    if [[ $(/scripts/setupnameserver --current | grep -c nsd) = 1 ]]; then
        chkconfig --list | egrep -E '(named|nsd)' ;
        service named stop;service nsd restart;chkconfig --level 2345 named off ;
        chkconfig --list | egrep -E '(named|nsd)' ;
    elif
        [[ $(/scripts/setupnameserver --current | grep -c bind) = 1 ]];then
        chkconfig --list | egrep -E '(named|nsd)' ;
        service nsd stop;service named restart;chkconfig --level 2345 nsd off ;
        chkconfig --list | egrep -E '(named|nsd)' ;
    elif
        [[ $(/scripts/setupnameserver --current | grep -c mydns) = 1 ]]; then
        chkconfig --list | egrep -E '(named|nsd|mydns)'
        service nsd stop;service named stop;service mydns restart;chkconfig --level 2345 nsd off;chkconfig --level 2345 named off;
        chkconfig --list | egrep -E '(named|nsd|mydns)'
    else
        echo -e "\nThis server is either not configured to resolve DNS queries or is using a non-standard nameserver service.\n"
    fi
}
