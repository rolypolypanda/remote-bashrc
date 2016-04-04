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
    alias yes="no" ;
    alias zztailapache="tail -f /etc/httpd/logs/error_log"
    alias zztailmysql="tail -f /var/lib/mysql/$(hostname).err"
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
    echo -e "zzsetnsdvps\nzzmysqltune\nzzapachetune\nzzmysqltuneup\nzzdiskuse\nzzquicknotes\nzzeximstats\nzztopmail\nzzcmsdbinfo\nzzaxonparse"
    echo -e "zzxmlrpcget\nzzcpucheck\nzzmailperms\nzzdusort\nzzhomeperms\nzzmonitordisk\nzzpiniset\nzztophttpd\nzzbackuprest\nzzapachestrace"
    echo -e "zzdizboxsetup\nzzcronscan\nzzinodecheck\n"
}

zzphpini() {
    if [[ -f $(pwd)/php.ini ]]; then
        mv $(pwd)/php.ini{,.bak}
    fi
    cp /usr/local/lib/$1.ini php.ini ;
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
    echo -e "<IfModule mod_suphp.c>\nsuPHP_ConfigPath $(pwd)\n</IfModule>"
    echo -e "\`\`\`"
}

zzphphandler() {
    /usr/local/cpanel/bin/rebuild_phpconf --current
}


zztophttpd() {
    netstat -pltuna | grep httpd | awk '{ print $5 }' | cut -d':' -f1 | grep -v '0.0.0.0' | grep -v ':::' | sort -nk1 | uniq -c | sort -nrk1
}

zzphpinfo() {
    echo -e "<?php phpinfo(); ?>" > phpinfo.php ;
    chown $(stat -c %U .): phpinfo.php ;
}

zzhomeperms() {
    read -p "Enter ticket ID number: " TID
    read -p "Enter cPanel account name: " ACT
    mkdir -p /home/.hd/logs/$TID/$ACT/homedirperms-$(date +%s).log
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/fixhome) $ACT | tee -a /home/.hd/logs/$TID/$ACT/homedirperms-$(date +%s).log
    echo -e "\n- Log located in \`/home/.hd/logs/$TID/$ACT/homedirperms-$(date +%s).log\`"
}

zzmailperms() {
    unset $ACT
    unset $TID
    read -p "Enter cPanel account name: " ACT
    read -p "Enter ticket ID number: " TID

    if [ ! -f /var/cpanel/users/$ACT ]; then
        echo -e "${ACT} is not present on this server"
    else
        mkdir -p /home/.hd/logs/$TID/$ACT
        mkdir -p /home/.hd/ticket/$TID/$ACT/original
        echo -e "\nBacking up /etc first\n"
        sleep 5 ;
        cp -Rp /etc /home/.hd/ticket/$TID/$ACT/original
        cd /home/$ACT ;
        chown -vR $ACT:$ACT etc/ mail/ | tee -a /home/.hd/logs/$TID/$ACT/mailperms0-$(date +%s).log ;
        chown -v $ACT:mail etc/ etc/* etc/*/shadow etc/*/passwd mail/*/*/maildirsize etc/*/*pwcache etc/*/*pwcache/* | tee -a /home/.hd/logs/$TID/$ACT/mailperms1-$(date +%s).log ;
        /scripts/mailperm --verbose $ACT | tee -a /home/.hd/logs/$TID/$ACT/mailperms2-$(date +%s).log ;
        echo -e "\n- Reset maildir permissions:"
        echo -e "\`[root@$(hostname):$(pwd) #] chown -vR ${ACT}:${ACT} etc mail\`"
        echo -e "\`[root@$(hostname):$(pwd) #] chown -v ${ACT}:mail etc/ etc/* etc/*/shadow etc/*/passwd mail/*/*/maildirsize etc/*/*pwcache etc/*/*pwcache/*\`"
        echo -e "\`[root@$(hostname):$(pwd) #] /scripts/mailperm --verbose ${ACT}\`\n"
    fi        
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
    echo "Swappiness Value: $(cat /proc/sys/vm/swappiness)"
    echo "\`\`\`" ;
}

zzdiskuse() {
    echo -e "\n- Disk usage and inode count \`(df -h / df -i):\`" ;
    echo "\`\`\`" ;
    df -h ;
    echo "\`\`\`" ;
    echo "\`\`\`" ;
    df -i ;
    echo "\`\`\`" ;
}

zzcpucheck() {
    CLK_ACT="$(dmidecode -t processor | grep "Current Speed" | sed -e 's/^[ \t]*//')"
    CLK_MAX="$(dmidecode -t processor | grep "Max Speed" | sed -e 's/^[ \t]*//')"
    echo "- \`CPU Information:\`"
    echo -e "\`\`\`"
    echo -e "Clock Speeds: ${CLK_ACT} - ${CLK_MAX}"
    dmidecode -t processor | grep Version | sed -e 's/^[ \t]*//' ;
    echo -e "\`\`\`"
    echo -e "\n- \`Core Temperatures:\`"
    echo -e "\`\`\`"
    echo "CPU      Actual  High   Critical"
    sensors | grep "Core" | awk '{ print $1,$2,$3,$6,$9 }' | tr -d ')' ;
    echo "\`\`\`"
}

zzdusort() {
    FILE='/root/$(date +%s)-unsorted-du.tmp'
    du -h --max-depth=1 $1 > "$FILE" ;
    cat "$FILE" | awk '$1 ~ /T/' | sort -nrk1 ;
    cat "$FILE" | awk '$1 ~ /G/' | sort -nrk1 ;
    cat "$FILE" | awk '$1 ~ /M/' | sort -nrk1 ;
    cat "$FILE" | awk '$1 ~ /K/' | sort -nrk1 ;
    cat "$FILE" | awk '$1 ~ /[0-9]$/' | sort -nrk1 ;
    \rm -f "$FILE" ;
}

zzfixtmp() {
    read -p "Enter ticket ID number: " TID
    mkdir -p /home/.hd/logs/$TID
    chmod 1777 /tmp ;
    find /tmp -type f -mmin +30 -exec rm -vf {} \; | tee -a /home/.hd/logs/$TID/tmpremovedfiles-$(date +%s).log
    echo -e "\n- Cleared \`/tmp:\`"
    echo -e "\`[root@$(hostname):$(pwd) #] find /tmp -type f -mmin +30 -exec rm -vf {} \;\`"
    echo -e "\n- List of removed files located in \`/home/.hd/logs/$TID/tpmremovedfiles-$(date +%s).log\`\n"
}

zzacctdom() {
    if [[ $(egrep -w ^$1  /etc/trueuserdomains | cut -d':' -f2 | sed -e 's/^[ \t]*//' | while read list;do grep -cw $list /var/cpanel/resellers;done | cut -d':' -f1) == 1 ]];then
        echo -e "Reseller: Yes" ;
        echo -e "Resold Accounts: $(for i in $(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f2 | sed -e 's/^[ \t]*//');do grep $i /etc/trueuserowners | cut -d':' -f1 | grep -v $i | wc -l;done)" ;
        echo -e "Account Owner: $(for i in $(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f1);do egrep -w ^$i /etc/userdatadomains | grep main | cut -d'=' -f3;done)" ;
        echo -e "Account Name: $(grep -w ^$1 /etc/trueuserdomains | cut -d':' -f2 | sed -e 's/^[ \t]*//')" ;
        echo -e "Document Root: $(egrep -w ^$(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f1) /etc/userdatadomains | grep main | cut -d'=' -f9)" ;
        echo -e "IP Address: $(egrep -w ^$(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f1) /etc/userdatadomains | grep main | cut -d'=' -f11)" ;
    else
        echo -e "Reseller: No" ;
        echo -e "Account Owner: $(for i in $(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f2);do grep $i /etc/trueuserowners | cut -d':' -f2 | sed -e 's/^[ \t]*//';done)" ;
        echo -e "Account Name: $(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f2 | sed -e 's/^[ \t]*//')" ;
        echo -e "Document Root: $(grep -w ^$1 /etc/userdatadomains | cut -d'=' -f9)" ;
        echo -e "IP Address: $(grep -w ^$1 /etc/userdatadomains | cut -d'=' -f11)" ;
    fi
}

zzbackuprest() {
    read -p "Enter cPanel account name: " ACT
    read -p "Enter ticket ID number: " TID
    read -p "Enter location of backup: " BKP
    if [[ -d /home/$ACT ]];then
        echo -e "\ncPanel account home still exists, either the account was not removed or there may be immutable files present"
        echo -e "Ensure the account has been completely removed before proceeding"
        echo -e "Ctrl+C to exit\n"
        sleep 100 ;
    fi
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    echo -e "Copying ${BKP} to /home"
    CPMOVE="$(ls -lah $BKP | rev | cut -d'/' -f1 | rev)"
    \cp -vP $BKP /home/$CPMOVE ;
    cd /home ;
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/restorepkg $CPMOVE | tee -a /home/.hd/logs/$TID/$ACT/restorepkg-$(date +%s).log ;
    \rm -f /home/$CPMOVE ;
    echo -e "\n- Copied backup from \`${BKP}\` to \`/home:\`"
    echo -e "\`[root@$(hostname):$(pwd) #] cp -vP ${BKP} /home/${CPMOVE}\`"
    echo -e "\n- Restored account \`${ACT}:\`"
    echo -e "\`[root@$(hostname):$(pwd) #] /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/restorepkg ${CPMOVE}\`"
    echo -e "\n- Removed backup from \`/home:\`"
    echo -e "\`[root@$(hostname):$(pwd) #] rm -vf /home/${CPMOVE}\`"
    echo -e "\n- Log located in: \`/home/.hd/logs/$TID/$ACT/restorepkg-$(date +%s).log\`"
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
    echo -e "**Additional Notes:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/pkgacct-$(date +%s).log\`\n" ;
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
    if [[ -f $PTH ]];then
        CPMOVE="$(ls -lah $PTH | rev | cut -d'/' -f1 | rev)"
        cp -vP $PTH /home/.hd/ticket/$TID/$DTE ;
        echo -e "\n- Copied ${PTH} to \`/home/.hd/ticket/${TID}/${DTE}:\`"
        echo -e "\`[root@$(hostname):$(pwd) #] cp -vP ${PTH} /home/.hd/ticket/${TID}/${DTE}/${CPMOVE}\`\n"
    else
    cd $PTH ;
    cd ..
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/ | tee -a /home/.hd/logs/$TID/$ACT/backup-$(date +%s).log ;
    echo -e "\n\`[root@$(hostname):$(pwd) #] mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`[root@$(hostname):$(pwd) #] /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/\`" ;
    echo -e "- Backup for account \`$ACT\` created in \`/home/.hd/ticket/$TID/$DTE/$ACT.tar.gz\`" ;
    echo -e "**Additional Notes:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/backup-$(date +%s).log\`\n" ;
fi
}

zzmysqltune() {
    SQL="$1"
    case $SQL in
        --primer|-p)
            bash <(curl -s http://day32.com/MySQL/tuning-primer.sh) ;
            ;;
        --tuner|-t)
            perl <(curl -k -L http://raw.github.com/rackerhacker/MySQLTuner-perl/master/mysqltuner.pl) ;
            ;;
                 *)
            echo "Usage: [ --primer / -p | --tuner / -t ]"
            ;;
    esac
}

zzmysqltuneup() {
    echo -e "\nMake sure to run in a screen session." ;
    sleep 5 ;
    read -p "Enter ticket ID number: " TID
    mkdir -p /home/.hd/logs/$TID ;
    mysqlcheck -rA | tee -a /home/.hd/logs/$TID/mysqlcheck-repair-$(date +%s).log ;
    mysqlcheck -oA | tee -a /home/.hd/logs/$TID/mysqlcheck-optimize-$(date +%s).log ;
    wall -n "MySQL table repair and optimize complete." ;
    wall -n "Log located in \`/home/.hd/logs/$TID/mysqlcheck-repair-$(date +%s).log\`" ;
    wall -n "Log located in \`/home/.hd/logs/$TID/mysqlcheck-optimize-$(date +%s).log\`" ;
}

zzapachetune() {
    curl -L http://apachebuddy.pl/ | perl ;
}

zzsetdnsvps() {
    echo -e "Current NameServer set to $G1$(/scripts/setupnameserver --current | awk '{ print $4 }')$RESET."
    if [[ $(/scripts/setupnameserver --current | awk '{ print $4 }') == bind ]];then
        echo "Disabling nsd and mydns in init..."
        chkconfig nsd off 2&>1 /dev/null ;
        chkconfig mydns off 2&>1 /dev/null ;
        echo "Restarting Bind..."
                service nsd stop 2&>1 /dev/null ;
                service named restart 2&>1 /dev/null ;
    elif
        [[ $(/scripts/setupnameserver --current | awk '{ print $4 }') == nsd ]];then
            echo "Disabling named and mynds in init..."
            chkconfig mydns off 2&>1 /dev/null ;
            chkconfig named off 2&>1 /dev/null ;
            echo "Restarting NSD..."
                    service named stop 2&>1 /dev/null ;
                    service nsd restart 2&>1 /dev/null ;
    fi
}

zzbeanc() {
    wget --no-check-certificate http://filez.dizinc.com/~michaelb/sh/beanc.sh ;
    chmod +x beanc.sh ;
    bash beanc.sh ;
}

zzcleanup() {
    if [[ -f /root/vmirc ]]; then
        rm -vf /root/vimrc
    fi
    if [[ -f /root/vimrc.bak ]]; then
        mv /root/vimrc{.bak,}
    fi
    if [[ -f /root/beanc.sh ]]; then
        rm -vf /root/beanc.sh
    fi
    if [[ -f /root/strace.k ]]; then
        rm -vf /root/strace.k
    fi
}

zzcmsdbinfo() {
 CMS="$1"
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
      DB_PASS="$(grep password configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      DB_NAME="$(grep -w db configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      DB_USER="$(grep user configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
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
   --littlefoot|-lf)
    DB_VER="$(cat lf/system/version)"
    DB_NAME="$(grep name lf/config.php | awk '{ print $3}' | tr -d "'" | tr -d ';')"
    DB_USER="$(grep user lf/config.php | awk '{ print $3}' | tr -d "'" | tr -d ';')"
    DB_PASS="$(grep pass lf/config.php | awk '{ print $3}' | tr -d "'" | tr -d ';')"
    TBL_PREFIX="$(grep prefix lf/config.php | awk '{ print $3}' | tr -d "'" | tr -d ';')"
    echo -e "\nLittlefoot ${DB_VER}"
    echo "Database Name: ${DB_NAME}"
    echo "Database User: ${DB_USER}"
    echo "Database Password: ${DB_PASS}"
    echo -e "Table Prefix: ${TBL_PREFIX}\n"
    ;;
   --owncloud|-oc)
    DB_VER="$(grep version config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    DB_NAME="$(grep dbname config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    DB_USER="$(grep dbuser config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    DB_PASS="$(grep dbpassword config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    TBL_PREFIX="$(grep dbtableprefix config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    echo -e "\nOwncloud: ${DB_VER}"
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
    echo "--littlefoot -lf [ Extract DB information from a Littlefoot installation ]"
    echo "--owncloud -oc [ Extract DB information from an Owncloud installation ]"
    ;;
  *)
    echo "Usage: zzcmsdbinfo [ --wordpress / -wp | --joomla / -jm | --drupal / -dr | --littlefoot / -lf | --owncloud / -oc | --help / -h ]"
    ;;
  esac
}

zzmonitordisk() {
    watch -n 1 'w ; \
    echo -e "\nProcesses hitting disk:" ; \
    ps faux | awk '"'"'$8 ~ /D/'"'"' | tee /root/processeshittingdisk.tmp ; \
    echo -e "\nNumber of processes hitting disk:" ; \
    cat /root/processeshittingdisk.tmp | wc -l ; rm -f /root/processeshittingdisk.tmp ; \
    echo"" ; iostat -x' ;
}

zzaxonparse() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/Axon)
}

zzxmlrpcget() {
    read -p "Enter domain name: " DOM
    ACT="$(grep -w ^$DOM /etc/userdatadomains | cut -d':' -f2 | cut -d '=' -f1 | sed 's/^[ \t]*//')"
    grep "POST /xmlrpc.php" /usr/local/apache/domlogs/$ACT/$DOM | awk '{ print $1 }' | grep -v $(hostname -i) | sort -nk1 | uniq -c | sort -nrk1 | head -n 10
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
    echo -e "\n## -- Display current theme / Change current theme -- ##"
    echo -e "SELECT * FROM wp_options WHERE option_name='template' OR option_name='stylesheet';"
    echo -e "UPDATE wp_options SET option_value='' WHERE option_name='template' OR option_name='stylesheet' LIMIT 2;\n"
}

zzpiniset() {
    MEM="$(egrep -w '^memory_limit' php.ini | grep -v ';')"
    POST="$(egrep -w '^post_max_size' php.ini | grep -v ';')"
    FOPEN="$(egrep -w '^allow_url_fopen' php.ini | grep -v ';')"
    UPL="$(egrep -w '^upload_max_filesize' php.ini | grep -v ';')"
    MAGQ="$(egrep -w 'magic_quotes_gpc' php.ini | tr -d ';')"

    cp -p php.ini{,-$(date +%s).bak}

    echo -e "\nCurrent PHP values:"
    echo "1. ${MEM}"
    echo "2. ${POST}"
    echo "3. ${UPL}"
    echo "4. ${FOPEN}"
    echo "5. ${MAGQ}"
    echo -e "6. Exit \n"
    read -p "Which value would you like to change? " VAL
        case $VAL in
            1)
                echo "You selected ${MEM}"
                read -p "Enter new value: " PMEM
                sed -i '/memory_limit/d' php.ini
                echo "memory_limit = ${PMEM}" >> php.ini
                echo "memory_limit is now ${PMEM}"
            ;;
            2)
                echo "You selected ${POST}"
                read -p "Enter new value: " PST
                sed -i '/post_max_size/d' php.ini
                echo "post_max_size = ${PST}" >> php.ini
                echo "post_max_size is now ${PST}"
            ;;
            3)
                echo "You selected ${UPL}"
                read -p "Enter new value: " UPLD
                sed -i '/upload_max_filesize/d' php.ini
                echo "upload_max_filesize = ${UPLD}" >> php.ini
                echo "upload_max_filesize is now ${UPLD}"
            ;;
            4)
                echo "You selected ${FOPEN}"
                read -p "Enter new value [Off/On]: " FOP
                sed -i '/allow_url_fopen/d' php.ini
                echo "allow_url_fopen = ${FOP}" >> php.ini
                echo "allow_url_fopen is now ${FOP}"
            ;;
            5)
                echo "You selected ${MAGQ}"
                read -p "Enter new value [Off/On]: " MGQ
                sed -i '/magic_quotes_gpc/d' php.ini
                echo "magic_quotes_gpc = ${MGQ}" >> php.ini
                echo "magic_quotes_gpc is now ${MGQ}"
            ;;
            6)
                echo "Exiting..."
            ;;
            *) 
                echo "Invalid selection"
            ;;
esac
}

zzapachestrace() {
    ps aufx | grep $1 | grep -v 'root' | grep 'php' | awk '{ print "-p " $2 }' | paste -sd ' ' | xargs strace -vfs 4096 -o strace.k
}

zzdizboxsetup() {
    echo -e "\n$R1 Only run this in a sandbox! $RESET" ;
    echo -e " Ctrl+C to exit\n"
    sleep 5 ;
	hostname sandbox.donthurt.us ;
	sed -i 's/sandbox.donthurt.us/$(hostname)/g' /etc/localdomains ;
    sleep 2 ;
    if [[ -f /home/cpmove-donthurt.tar.gz ]]; then
	    cd /home; /scripts/restorepkg /home/cpmove-donthurt.tar.gz; echo -e "\nCPANEL ACCOUNT RESTORED\n" ;
        sleep 2 ;
    else
        cd /home ;
        wget http://filez.dizinc.com/~michaelb/vps_setup/cpmove-donthurt.tar.gz
        /scripts/restorepkg /home/cpmove-donthurt.tar.gz; echo -e "\nCPANEL ACCOUNT RESTORED\n" ;
    fi
    sed -i "s/node10.explus4host.com/$(hostname)/g" /etc/localdomains ;
	find /var/cpanel/userdata -type f ! -name *.cache ! -name *.stor | while read line
	do 
	    sed -ri "s/198.49.72.[0-9]+/$(hostname -i)/g" $line
	    echo "$line has been updated"
	done
    /scripts/rebuildhttpdconf ;
    /scripts/restartsrv_httpd ;
    sleep 2 ;
    sed -i 's/#ClientAliveInterval\ 0/ClientAliveInterval\ 300/' /etc/ssh/sshd_config ;
    sed -i 's/#ClientAliveCountMax\ 3/ClientAliveCountMax\ 2/' /etc/ssh/sshd_config ;
    service sshd restart ;
    yum install -y bc man strace nmap telnet ;
    cd /etc/yum.repos.d; wget http://repo1.dimenoc.com/dimenoc/DimeNOC.repo; yum -y install axond; csf -a 72.29.79.51 ;
    chmod 777 /var/run/screen
    echo -e "\nVPS SANDBOX CONFIGURED\n" ;
}

zzinodecheck() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/inodeschecker2)
}

zzcronscan() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/cronscanner)
}

zzeasybackup() {
function backup { 
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly} ;
    if [[ -f $PTH ]];then
        CPMOVE="$(ls -lah $PTH | rev | cut -d'/' -f1 | rev)"
        cp -vP $PTH /home/.hd/ticket/$TID/$DTE ;
        echo -e "\n- Copied ${PTH} to \`/home/.hd/ticket/${TID}/${DTE}:\`"
       	echo -e "\`[root@$(hostname):$(pwd) #] cp -vP ${PTH} /home/.hd/ticket/${TID}/${DTE}/${CPMOVE}\`\n"
    else
    cd $PTH ;
    cd ..
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/ | tee -a /home/.hd/logs/$TID/$ACT/backup-$(date +%s).log ;
    echo -e "\n\`[root@$(hostname):$(pwd) #] mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`[root@$(hostname):$(pwd) #] /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/\`" ;
    echo -e "- Backup for account \`$ACT\` created in \`/home/.hd/ticket/$TID/$DTE/$ACT.tar.gz\`" ;
    echo -e "**Additional Notes:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/backup-$(date +%s).log\`\n" ;
fi
}
function package {
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly} ;
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/pkgacct $ACT /home/.hd/ticket/$TID/original | tee -a /home/.hd/logs/$TID/$ACT/pkgacct-$(date +%s).log ;
    echo -e "For Notes:\n"
    echo -e "\`[root@$(hostname):$(pwd) #] mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`[root@$(hostname):$(pwd) #] /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/pkgacct $ACT /home/.hd/ticket/$TID/original\`" ;
    echo -e "- Account \`$ACT\` packaged in \`/home/.hd/ticket/$TID/original/cpmove-$ACT.tar.gz\`" ;
    echo -e "**Additional Notes:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/pkgacct-$(date +%s).log\`\n" ;
}
function restore {
    if [[ -d /home/$ACT ]];then
        echo -e "\ncPanel account home still exists, either the account was not removed or there may be immutable files present"
        echo -e "Ensure the account has been completely removed before proceeding"
        echo -e "Ctrl+C to exit\n"
       	sleep 100 ;
    fi
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    echo -e "Copying ${BKP} to /home"
    CPMOVE="$(ls -lah $BKP | rev | cut -d'/' -f1 | rev)"
    \cp -vP $BKP /home/$CPMOVE ;
    cd /home ;
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/restorepkg $CPMOVE | tee -a /home/.hd/logs/$TID/$ACT/restorepkg-$(date +%s).log ;
    \rm -f /home/$CPMOVE ;
    echo -e "\n- Copied backup from \`${BKP}\` to \`/home:\`"
    echo -e "\`[root@$(hostname):$(pwd) #] cp -vP ${BKP} /home/${CPMOVE}\`"
    echo -e "\n- Restored account \`${ACT}:\`"
    echo -e "\`[root@$(hostname):$(pwd) #] /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/restorepkg ${CPMOVE}\`"
    echo -e "\n- Removed backup from \`/home:\`"
    echo -e "\`[root@$(hostname):$(pwd) #] rm -vf /home/${CPMOVE}\`"
    echo -e "\n- Log located in: \`/home/.hd/logs/$TID/$ACT/restorepkg-$(date +%s).log\`"
}
function killact {
mkdir -p /home/.hd/logs/$TID/$ACT ;
/usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/removeacct $ACT | tee -a /home/.hd/logs/$TID/$ACT/removeacct-$(date +%s).log ;
}
function all {
    echo -e "\nCreate Backup"
    backup
    echo -e "\nPackage Account"
    package
    echo -e "\nRemove Account"
    killact
    echo -e "\nRestore Account"
    restore
}
for i in "$@"
do
    case $i in
        -b|--backup)
	    read -p "Enter cPanel account name: " ACT
    	    read -p "Enter ticket ID number: " TID
            find /backup -maxdepth 4 -type f -name "${ACT}*" -print
            find /backup -maxdepth 4 -type d -name "${ACT}" -print
            read -p "Enter the path of the backup you would like to create: " PTH
            read -p "daily, weekly, or monthly backup? " DTE
            backup
            ;;
        -p|--package)
             read -p "Enter cPanel account name: " ACT
             read -p "Enter ticket ID number: " TID
            package
            ;;
        -r|--restore)
             read -p "Enter cPanel account name: " ACT
             read -p "Enter ticket ID number: " TID
             read -p "Enter location of backup: " BKP
           restore
            ;;
        -k|--kill)
	    read -p "Enter cPanel account name: " ACT
	    read -p "Enter ticket ID number: " TID
            killact
            ;;
        -a|--all)
            all
            ;;
        -h|--help)
            echo "easybackup:"
            echo "--backup / -b  | Create a cPanel backup"
            echo "--package / -p | Package a live cPanel account"
            echo "--restore / -r | Restore a cPanel account from a backup"
            echo "--kill / -k    | Remove a live cPanel account"
            echo "--all / -a     | Create a backup, package a live account, kill a live account and restore account from backup"
            ;;
                *)
            echo "Usage: [ --backup / -b | --package / -p | --restore / -r | --all / -a | --help /-h ]"
            ;;
    esac
done
}
