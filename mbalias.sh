# mbalias.sh
# Begin setup env.

if [[ $(hostname | egrep -Ec '(snafu|mac|fedora-srv)') == 1 ]]; then
    echo "You're at home, not setting up aliases, etc..." ;
else
    eval "$(curl -ks https://codex.dimenoc.com/scripts/download/colorcodes)" ;
    echo -ne "\033k$HOSTNAME\033\\" ;
    export PS1='\[\e[1;32m\]\u\[\e[1;37m\]@\[\e[0;37m\]\H\[\e[0;36m\]:\w\[\e[0;0m\] \$ ' ;
    export EDITOR="vim" ;
    alias ll="ls -lah" ;
    alias grep="egrep --color=auto" ;
    alias hist="history" ;
    alias vim="vim -u /root/vimrc" ;
    alias rm="rm -v" ;
    alias zzeximstats="eximstats -h1 -ne -nr /var/log/exim_mainlog" ;
    alias zztopmail="bash <(curl -k -s https://scripts.dimenoc.com/files/Top_Mail_334.sh)" ;
    alias clera="clear" ;
fi

# Begin functions.
zzgetvimrc() {
    if [[ -f /root/vimrc ]]; then
        echo -e "\nvimrc Already exists, moving it to vimrc.bak.\n"
        mv -f /root/vimrc{,.bak}
fi
    wget --no-check-certificate http://filez.dizinc.com/~michaelb/sh/vimrc && mv vimrc /root/vimrc ;
}

# Call zzgetvimrc function.
zzgetvimrc

# Begin main functions.
zzcommands() {
    echo -e "\nzzphpini\nzzphphandler\nzzphpinfo\nzzmemload\nzzfixtmp\nzzacctdom\nzzacctpkg\nzzmkbackup\nzzversions\nzzgetvimrc"
    echo -e "zzsetnsdvps\nzzmysqltune\nzzapachetune\nzzdiskuse\nzzquicknotes\nzzeximstats\nzztopmail\nzzcmsdbinfo\nzzaxonparse"
    echo -e "zzxmlrpcget\n"
}

zzphpini() {
    cp /usr/local/lib/$1.ini php.ini ;
    if [[ -f $(pwd)/php.ini ]]; then
        mv $(pwd)php.ini{,.bak}
    fi
    if [[ $(grep -c suPHP_ConfigPath $(pwd)/.htaccess) == 1 ]]; then
        echo "suPHP_ConfigPath is already set in $(pwd)/.htaccess."
            else
        mv .htaccess{,.bak}
        echo -e "<IfModule mod_suphp.c>\nsuPHP_ConfigPath $(pwd)\n</IfModule>\n" >> .htaccess ;
        cat .htaccess.bak >> .htaccess
        chown $(stat -c %U .): .htaccess ;
    fi
    echo -e "\nFor notes:\n"
    echo -e "- Backed up existing \`php.ini\`:"
    echo -e "\`[root@$(hostname):$(pwd) #] mv $(pwd)/php.ini{,.bak}\`"
    echo -e "\`[root@$(hostname):$(pwd) #] cp /usr/local/lib/$1.ini php.ini\`"
    echo -e "- Added the following to \`$(pwd)/.htaccess\`"
    echo -e "\`\`\`"
    echo -e "<IfModule mod_suphp.c>\nsuPHP_ConfigPath $(pwd)\n</IfModule>\n"
    echo -e "\`\`\`"
}

zzphphandler() {
    /usr/local/cpanel/bin/rebuild_phpconf --current
}

zzphpinfo() {
    echo -e "<?php phpinfo(); ?>" > phpinfo.php ;
    chown $(stat -c %U .): phpinfo.php ;
}

zzmemload() {
    echo -e "- Current server load \`(w / sar -q 1 5):\`\n" ;
    echo "\`\`\`" ;
    CPUCOUNT=$(grep -c proc /proc/cpuinfo)
    echo -e "CPU count: $CPUCOUNT\n"
    w ;
    sar -q 1 5 ;
    echo "\`\`\`" ;
    echo -e "\n- Free memory \`(free -m):\`\n" ;
    echo "\`\`\`" ;
    free -m ;
    echo "\`\`\`" ;
}

zzdiskuse() {
    echo -e "\n- Disk usage and inode count \`(df -h / df -i):\`\n" ;
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
    find /tmp -type f -mmin +30 -exec rm -vf {} \; | tee -a /home/.hd/logs/$TID/tmpremovedfiles-$(date +%s).log
    echo -e "\n- List of removed files located in \`/home/.hd/logs/$TID/tpmremovedfiles-$(date +%s).log\`\n"
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
    echo -e "- Account \`$ACT\` packaged in \`/home/.hd/ticket/$TID/original/cpmove-$ACT.tar.gz\`" ;
    echo -e "**Additional Info:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/pkgacct-$(date +%s).log\`\n" ;
}

zzversions() {
    echo -e "- \`Software Versions:\`"
    echo "\`\`\`"
    cat /etc/redhat-release ;
    echo "Kernel version: $(uname -r)" ;
    echo "cPanel version: $(cat /usr/local/cpanel/version)" ;
    echo "MySQL version: $(mysql -V | awk '{ print $5 }' | tr -d ',')" ;
    echo "PHP version: $(php -v | head -n 1 | awk '{ print $2 }')" ;
    echo "Apache version: $(httpd -v | head -n 1 | cut -d'/' -f2 | awk '{ print $1 }')" ;
    if
        # CentOS 6 and lower - SysV
        [[ -f /etc/init.d/nginx ]]; then
        nginx -v ;
        if
          # CentOS 7 - Systemd
          [[ -f /usr/lib/systemd/system/nginx.service ]]; then
          nginx -v ;
        fi
    fi
    echo "\`\`\`"
}

zzmkbackup() {
    read -p "Enter cPanel account name: " ACT
    read -p "Enter ticket ID number: " TID
    find /backup -maxdepth 4 -type f -name "${ACT}*" -print
    find /backup -maxdepth 4 -type d -name "${ACT}" -print
    read -p "Enter the path of the backup you would like to create: " PTH
    read -p "daily, weekly, or monthly backup? " DTE
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly} ;
    cd $PTH ;
    cd ..
    tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/ | tee -a /home/.hd/logs/$TID/$ACT/backup-$(date +%s).log ;
    echo -e "\`[root@$(hostname):$(pwd) #] mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`[root@$(hostname):$(pwd) #] tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/\`" ;
    echo -e "- Backup for account $ACT created in \`/home/.hd/ticket/$TID/$DTE/$ACT.tar.gz\`" ;
    echo -e "**Additional Info:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/backup-$(date +%s).log\`\n" ;
}

zzmysqltune() {
    perl <(curl -k -L http://raw.github.com/rackerhacker/MySQLTuner-perl/master/mysqltuner.pl) ;
}

zzmysqltuneup() {
    echo -e "\nMake sure to run in a screen session." ;
    sleep 5 ;
    read -p "Enter ticket ID number: " TID
    mkdir -p /home/.hd/ticket/$TID/logs ;
    for db in $(find /var/lib/mysql -type f -name "*.MYI"); do myisamchk -r $db; done | tee -a /home/.hd/ticket/$TID/logs/myisamchk-repair-$(date +%s).log ;
    mysqlcheck -rA | tee -a /home/.hd/ticket/$TID/logs/mysqlcheck-repair-$(date +%s).log ;
    mysqlcheck -oA | tee -a /home/.hd/ticket/$TID/logs/mysqlcheck-optimize-$(date +%s).log ;
    wall -n "MySQL table repair and optimize complete." ;
    wall -n "Log located in \`/home/.hd/ticket/$TID/logs/mysqlcheck-repair-$(date +%s).log\`" ;
    wall -n "Log located in \`/home/.hd/ticket/$TID/logs/myisamchk-repair-$(date +%s).log\`" ;
    wall -n "Log located in \`/home/.hd/ticket/$TID/logs/mysqlcheck-optimize-$(date +%s).log\`" ;
}

zzapachetune() {
    curl -L http://apachebuddy.pl/ | perl ;
}

zzsetnsdvps() {
    echo -e "Current NameServer set to $G1$(/scripts/setupnameserver --current | awk '{ print $4 }')$RESET."
    if [[ $(/scripts/setupnameserver --current | awk '{ print $4 }') == bind ]];then
        echo "Disabling nsd and mydns in init..."
        chkconfig nsd off 2&>1 /dev/null ;
        chkconfig mydns off 2&>1 /dev/null ;
            if [[ -f /var/lock/nsd ]]; then
                service nsd stop ;
                service named restart ;
            fi
    elif
        [[ $(/scripts/setupnameserver --current | awk '{ print $4 }') == nsd ]];then
            echo "Disabling named and mynds in init..."
            chkconfig mydns off 2&>1 /dev/null ;
            chkconfig named off 2&>1 /dev/null ;
                if [[ -f /var/lock/named ]]; then
                    service named stop ;
                    service nsd restart ;
                fi
    fi

}

zzbeanc() {
    wget --no-check-certificate http://filez.dizinc.com/~michaelb/sh/beanc.sh ;
    chmod +x beanc.sh ;
    bash beanc.sh ;
}

zzcleanup() {
    if [[ -f /root/beanc.sh ]]; then
        rm -vf /root/beanc.sh
        if [[ -f /root/vimrc ]]; then
            rm -vf /root/vimrc
            if [[ -f /root/vimrc.bak ]]; then
              mv /root/vimrc{.bak,}
            fi
        fi
    fi
}

zzcmsdbinfo() {
 CMS="$1"
 NOTE="$2"
 case $CMS in
   --wordpress|-wp)
      DB_VER="$(grep wp_version wp-includes/version.php | tail -n 1 | awk '{ print $3 }' | tr -d "'" | tr -d ';')"
      DB_NAME="$(grep DB_NAME wp-config.php | awk '{ print $2}' | tr -d "'" | tr -d ')' | tr -d ';')"
      DB_USER="$(grep DB_USER wp-config.php | awk '{ print $2}' | tr -d "'" | tr -d ')' | tr -d ';')"
      DB_PASS="$(grep DB_PASSWORD wp-config.php | awk '{ print $2}' | tr -d "'" | tr -d ')' | tr -d ';')"
      TBL_PREFIX="$(grep table_prefix wp-config.php | awk '{ print $3}' | tr -d "'" | tr -d ';')"
      echo -e "\nWordpress version: ${DB_VER}"
      echo "Database Name: ${DB_NAME}"
      echo "Database User: ${DB_USER}"
      echo "Database Password: ${DB_PASS}"
      echo -e "Table Prefix: ${TBL_PREFIX}\n"
    ;;
   --joomla|-jm)
      DB_VER="$(grep RELEASE libraries/cms/version/version.php | head -n 1 | awk '{ print $4 }' | tr -d "'" | tr -d '    ;')"
      DB_NAME="$(grep password configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      DB_USER="$(grep -w db configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      DB_PASS="$(grep user configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      TBL_PREFIX="$(grep -w dbprefix configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      echo -e "\nJoomla version: ${DB_VER}"
      echo "Database Name: ${DB_NAME}"
      echo "Database User: ${DB_USER}"
      echo "Database Password: ${DB_PASS}"
      echo -e "Table Prefix: ${TBL_PREFIX}\n"
    ;;
  --drupal|-dr)
    DB_VER="$(grep -w version core/modules/contact/contact.info.yml | tail -n 1 | tr -d "'")"
    DB_NAME="$(grep -w "database" sites/default/settings.php | tail -n 1 | awk '{ print $3 }' | tr -d "'" | tr -d ",")"
    DB_USER="$(grep -w "username" sites/default/settings.php | tail -n 1 | awk '{ print $3 }' | tr -d "'" | tr -d ",")"
    DB_PASS="$(grep -w "password" sites/default/settings.php | tail -n 1 | awk '{ print $3 }' | tr -d "'" | tr -d ",")"
    TBL_PREFIX="$(grep -w "prefix" sites/default/settings.php | tail -n 1 | awk '{ print $3 }' | tr -d "'" | tr -d ",")"
    echo -e "\nDrupal ${DB_VER}"
    echo "Database Name: ${DB_NAME}"
    echo "Database User: ${DB_USER}"
    echo "Database Password: ${DB_PASS}"
    echo -e "Table Prefix: ${TBL_PREFIX}\n"
    ;;
  --help|-h)
    echo "Run this function in the directory of the CMS installation."
    echo "--wordpress -wp [ Extract DB information from a WordPress installation ]"
    echo "--joomla -jm [ Extract DB information from a Joomla installation ]"
    echo "--drupal -dr [ Extract DB information from a Drupal installation ]"
    ;;
  *)
    echo "Usage: zzcmsdbinfo [ --wordpress / -wp | --joomla / -jm | --drupal / -dr | --help / -h ]"
    ;;
  esac
}


zzaxonparse() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/Axon)
}

zzxmlrpcget() {
    read -p "Enter domain name: " DOM
    ACT="$(grep $DOM /etc/trueuserdomains | awk '{ print $2 }')"
    grep xmlrpc.php /usr/local/apache/domlogs/$ACT/$DOM | awk '{ print $1 }' | grep -v $(hostname -i) | sort -nk1 | uniq -c | sort -nrk1 | head -n 10
}

zzquicknotes() {
    echo -e "\n## -- Change home/siteurl -- ##"
    echo -e "select * from wp_options where option_value = 'SITEURL';"
    echo -e "update wp_options set option_value = 'SITEURL' where option_id = 2;"
    echo -e "update wp_options set option_value = 'SITEURL' where option_id = 1;"
    echo -e "\n## -- MySQL user password update -- ##"
    echo -e "UPDATE mysql.user SET Password=PASSWORD('[PASSWORD]') WHERE User='[USER]';"
    echo -e "\n## -- Disable WordPress plugins through MySQL -- ##"
    echo -e "SELECT * FROM wp_options WHERE option_name = 'active_plugins';"
    echo -e "UPDATE wp_options SET option_value = 'a:0:{}' WHERE option_name = 'active_plugins';"
    echo -e "UPDATE wp_options SET option_value = '' WHERE option_name = 'active_plugins';"
}
