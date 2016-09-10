# mbalias.sh
# Begin setup env.

if [[ $(hostname | egrep -Ec '(snafu|mac|fedora-srv|fedora|devbox)') == 1 ]]; then
    echo "You're at home, not setting up aliases, etc..." ;
else
    eval "$(curl -ks https://codex.dimenoc.com/scripts/download/colorcodes)" ;
    echo -ne "\033k$HOSTNAME\033\\" ;
    export PS1='\[\e[1;32m\]\u\[\e[1;37m\]@\[\e[0;37m\]\H\[\e[0;36m\]:\w\[\e[0;0m\] \$ ' ;
    export EDITOR="vim" ;
    unset TID
    unset ACT
    unset CPMOVE
    unset PTH
    unset BKP
    unalias cp
    unalias mv
    unalias rm
    unalias ll
    alias ll="ls -lah" ;
    alias grep="egrep --color=auto" ;
    alias hist="history" ;
    alias vim="vim -u /home/.hd/user/michaelb/scripts/vimrc" ;
    alias mv="mv -v" ;
    alias cp="cp -v"
    alias rm="rm -v" ;
    alias zzeximstats="eximstats -h1 -ne -nr /var/log/exim_mainlog" ;
    alias zztopmail="bash <(curl -k -s https://scripts.dimenoc.com/files/Top_Mail_334.sh)" ;
    alias clera="clear" ;
    alias yes="no" ;
    alias zztailapache="tail -f /etc/httpd/logs/error_log | grep 67.23" ;
    alias zztailmysql="tail -f /var/lib/mysql/$(hostname).err" ;
fi

# Begin functions.
zzgetvimrc() {
    CURDIR="$(pwd)"
    mkdir -p /home/.hd/user/michaelb/{notes,scripts} ;
    if [[ -f /home/.hd/user/michaelb/scripts/vimrc ]]; then
        echo -e "\nvimrc Already exists, moving it to vimrc.bak.\n"
        mv -f /home/.hd/user/michaelb/scripts/vimrc{,.bak} ;
    fi
    cd /home/.hd/user/michaelb/scripts ;
    wget --no-check-certificate https://codesilo.dimenoc.com/michaelb/remote-bashrc/raw/master/rcfiles/vimrc ;
    cd ${CURDIR} ;
}

# Call zzgetvimrc and zzgetcheat functions.
zzgetvimrc

spenserjoke() {
    bash <(curl -ks https://codesilo.dimenoc.com/spenserc/joekoutput/raw/master/joek.sh) ;
}

# Begin main functions.
zzcommands() {
    echo -e "\nzzbeanc\nzzphpini\nzzphphandler\nzzphpinfo\nzzmemload\nzzfixtmp\nzzacctdom\nzzacctpkg\nzzmkbackup\nzzversions\nzzgetvimrc"
    echo -e "zzsetnsdvps\nzzmysqltune\nzzapachetune\nzzmysqltuneup\nzzdiskuse\nzzquicknotes\nzzeximstats\nzztopmail\nzzcmsdbinfo\nzzaxonparse"
    echo -e "zzxmlrpcget\nzzcpucheck\nzzmailperms\nzzdusort\nzzhomeperms\nzzmonitordisk\nzzpiniset\nzztophttpd\nzzbackuprest\nzzapachestrace"
    echo -e "zzdizboxsetup\nzzcronscan\nzzinodecheck\nzzeasybackup\nzzrpmquery\nzzopenvzdu\nzzchkdrivehealth\nzzeasybackup\nzzexigrep"
    echo -e "zzexirmlfd\nzzinstallnginx\nzznginxremove\nzzinitnginxvhosts\nzzapachestatus\nzzcpanelinstall\nzzsoftaculousinstall\nzzsoftaculousremove"
    echo -e "zzwhmxtrainstall\nzzwhmxtraremove\nzzsiteresponse\nzzssp\nzzcddr\nzzchk500\nzzchangehandler\nzzpassiveports\nzzweather\nzzinstallplesk"
    echo -e "zzdomconn\nzzpatchsymlink\nzzchksymlink\nzzupdatemodsec\nzzpassiveports\nzztransferver\ntransferrsyncprog\ntransferacctprog\nzzrealmemsar"
    echo -e "zzmysqlhash\nzzmysqlerror\nzzrvsitebuilderuninstall\nzzrvsitebuilderinstall\nzzattractainstall\nzzattractauninstall\nzzgetkey\nzzkeylock"
    echo -e "zzunlock\nzzupdatetweak\nzzticketmonitoroutput\nzzinstallcomposer\nzzlargefileusage\nzzsuhosinsilencer\nzzquikchk\nzzsqlsize"
}

zzphpini() {
    if [[ -f $(pwd)/php.ini ]]; then
        \mv -f $(pwd)/php.ini{,.bak-hd}
    fi
    \cp -f /usr/local/lib/$1.ini php.ini ;
    if [[ $(grep -c suPHP_ConfigPath $(pwd)/.htaccess) == 1 ]]; then
        echo "suPHP_ConfigPath is already set in $(pwd)/.htaccess."
    else
        \mv .htaccess{,.bak-hd}
        echo -e "<IfModule mod_suphp.c>\nsuPHP_ConfigPath $(pwd)\n</IfModule>\n<Files php.ini>\norder allow,deny\ndeny from all\n</Files>\n" >> .htaccess ;
        cat .htaccess.bak-hd >> .htaccess
        chown $(stat -c %U .): .htaccess ;
    fi
    echo -e "\nFor notes:\n"
    if [[ -f $(pwd)/php.ini.bak-hd ]]; then
        echo -e "\`root@$(hostname):$(pwd) # mv $(pwd)/php.ini{,.bak-hd}\`"
    fi
    echo -e "\`root@$(hostname):$(pwd) # cp /usr/local/lib/$1.ini php.ini\`"
    if [[ ! -f $(pwd)/php.ini.bak-hd ]]; then
        echo -e "- Added the following to \`$(pwd)/.htaccess\`"
        echo -e "\`\`\`"
        echo -e "<IfModule mod_suphp.c>\nsuPHP_ConfigPath $(pwd)\n</IfModule>\n<Files php.ini>\norder allow,deny\ndeny from all\n</Files>"
        echo -e "\`\`\`"
    fi
}

zzphphandler() {
    /usr/local/cpanel/bin/rebuild_phpconf --current ;
}

zzcddr() {
    GETDIR="$(egrep -w ^$1 /etc/userdatadomains | cut -d'=' -f9)" ;
    cd ${GETDIR} ;
}

zzexigrep() {
    exigrep $1 /var/log/exim_mainlog
}

zzdomcnt() {
    DPRIM="$(wc -l /etc/trueuserdomains | awk '{ print $1 }')"
    DALL="$(wc -l /etc/userdatadomains | awk '{ print $1 }')"
    echo -e "\nMain Domains: ${DPRIM}"
    echo -e "Total Domains: ${DALL}\n"
}

zzexirmlfd() {
    grep -lr 'lfd on' /var/spool/exim/input | sed -e 's/^.*\/\([a-zA-Z0-9-]*\)-[DH]$/\1/g' | xargs exim -Mrm ;
}

zztophttpd() {
    netstat -pltuna | grep httpd | awk '{ print $5 }' | cut -d':' -f1 | grep -v '0.0.0.0' | grep -v ':::' | sort -nk1 | uniq -c | sort -nrk1 ;
}

zzphpinfo() {
    echo -e "<?php phpinfo(); ?>" > phpinfo.php ;
    chown $(stat -c %U .): phpinfo.php ;
}

zzhomeperms() {
    read -p "Enter cPanel account name: " ACT
    read -p "Enter ticket ID number: " TID
    mkdir -p /home/.hd/logs/$TID/$ACT/ ;
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/fixhome) $ACT | tee -a /home/.hd/logs/$TID/$ACT/homedirperms-$(date +%s).log ;
    echo -e "\n- Reset homedir permissions using the following [codex script](https://codex.dimenoc.com/scripts/download/fixhome)."
    echo -e "- Log located in \`/home/.hd/logs/$TID/$ACT/homedirperms-$(date +%s).log\`"
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
        sleep 3 ;
        cp -Rp /etc /home/.hd/ticket/$TID/original/
        echo -e "/etc backed up to /home/.hd/ticket/$TID/original/etc\n"
        sleep 3 ;
        cd /home/$ACT ;
        chown -vR $ACT:$ACT etc/ mail/ | tee -a /home/.hd/logs/$TID/mailperms0-$(date +%s).log ;
        chown -v $ACT:mail etc/ etc/* etc/*/shadow etc/*/passwd mail/*/*/maildirsize etc/*/*pwcache etc/*/*pwcache/* | tee -a /home/.hd/logs/$TID/$ACT/mailperms1-$(date +%s).log ;
        /scripts/mailperm --verbose $ACT | tee -a /home/.hd/logs/$TID/mailperms2-$(date +%s).log ;
        echo -e "\n- Reset maildir permissions:"
        echo -e "\`root@$(hostname):$(pwd) # chown -vR ${ACT}:${ACT} etc mail\`"
        echo -e "\`root@$(hostname):$(pwd) # chown -v ${ACT}:mail etc/ etc/* etc/*/shadow etc/*/passwd mail/*/*/maildirsize etc/*/*pwcache etc/*/*pwcache/*\`"
        echo -e "\`root@$(hostname):$(pwd) # /scripts/mailperm --verbose ${ACT}\`"
        echo -e "\`**Additional Notes:**\n- Logs located in:\n\`/home/.hd/logs/$TID/mailperms0-$(date +%s).log\`"
        echo -e "\`/home/.hd/logs/$TID/mailperms2-$(date +%s).log\`\n"
    fi
}

zzmemload() {
    echo -e "- Current server load \`(w / sar -q 1 5):\`" ;
    echo "\`\`\`" ;
    CPUCOUNT=$(grep -c proc /proc/cpuinfo)
    echo -e "CPU count: $CPUCOUNT"
    w ;
    sar -q 1 5 ;
    echo "\`\`\`" ;
    echo -e "- Free memory \`(free -m):\`" ;
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
    echo "- CPU Information:"
    echo -e "\`\`\`"
    echo -e "Clock Speeds: ${CLK_ACT} - ${CLK_MAX}"
    dmidecode -t processor | grep Version | sed -e 's/^[ \t]*//' ;
    echo -e "\`\`\`"
    echo -e "- Core Temperatures:"
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
    echo -e "\`root@$(hostname):$(pwd) # find /tmp -type f -mmin +30 -exec rm -vf {} \;\`"
    echo -e "- List of removed files located in \`/home/.hd/logs/$TID/tpmremovedfiles-$(date +%s).log\`\n"
}

zzacctdom() {
    if [[ $(egrep -w ^$1  /etc/trueuserdomains | cut -d':' -f2 | sed -e 's/^[ \t]*//' | while read list;do grep -cw $list /var/cpanel/resellers;done | cut -d':' -f1) == 1 ]];then
        echo -e "Reseller: Yes" ;
        echo -e "Suspended: $(if [[ $(for i in $(egrep -w ^$1 /etc/userdatadomains | cut -d'=' -f7);do whmapi1 accountsummary domain=$i |      egrep -w "suspended:" | awk '{ print $2 }';done) == 0 ]];then echo "No"; else echo "Yes"; fi)" ;
        echo -e "SSL Installed: $(for i in $(egrep -w ^$1 /etc/userdatadomains | cut -d'=' -f7);do egrep -w ^$i /etc/ssldomains&> /dev/null && echo "Yes" || echo "No";done)" ;
        echo -e "Resold Accounts: $(for i in $(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f2 | sed -e 's/^[ \t]*//');do grep $i /etc/trueuserowners | cut -d':' -f1 | grep -v $i | wc -l;done)" ;
        echo -e "Account Owner: $(for i in $(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f1);do egrep -w ^$i /etc/userdatadomains | grep main | cut -d'=' -f3;done)" ;
        echo -e "Account Name: $(grep -w ^$1 /etc/trueuserdomains | cut -d':' -f2 | sed -e 's/^[ \t]*//')" ;
        echo -e "Document Root: $(egrep -w ^$(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f1) /etc/userdatadomains | grep main | cut -d'=' -f9)" ;
        echo -e "IP Address: $(egrep -w ^$(egrep -w ^$1 /etc/trueuserdomains | cut -d':' -f1) /etc/userdatadomains | grep main | cut -d'=' -f11)" ;
    else
        echo -e "Reseller: No" ;
        echo -e "Suspended: $(if [[ $(for i in $(egrep -w ^$1 /etc/userdatadomains | cut -d'=' -f7);do whmapi1 accountsummary domain=$i | egrep -w "suspended:" | awk '{ print $2 }';done) == 0 ]];then echo "No"; else echo "Yes"; fi)" ;
        echo -e "SSL Installed: $(for i in $(egrep -w ^$1 /etc/userdatadomains | cut -d'=' -f7);do egrep -w ^$i /etc/ssldomains &> /dev/null && echo "Yes" || echo "No";done)" ;
        echo -e "Domain Type: $(grep -w ^$1 /etc/userdatadomains | cut -d'=' -f5)"
        echo -e "Account Owner: $(for i in $(egrep -w ^$1 /etc/userdatadomains | cut -d':' -f2 | cut -d'=' -f1);do grep $i /etc/trueuserowners | cut -d':' -f2 | sed -e 's/^[ \t]*//';done)" ;
        echo -e "Account Name: $(egrep -w ^$1 /etc/userdatadomains | cut -d':' -f2 | cut -d'=' -f1 | sed -e 's/^[ \t]*//')" ;
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
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/restorepkg --allow_reseller $CPMOVE | tee -a /home/.hd/logs/$TID/$ACT/restorepkg-$(date +%s).log ;
    \rm -f /home/$CPMOVE ;
    echo -e "\n- Copied backup from \`${BKP}\` to \`/home:\`"
    echo -e "\`root@$(hostname):$(pwd) # cp -vP ${BKP} /home/${CPMOVE}\`"
    echo -e "\n- Restored account \`${ACT}:\`"
    echo -e "\`root@$(hostname):$(pwd) # /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/restorepkg ${CPMOVE}\`"
    echo -e "\n- Removed backup from \`/home:\`"
    echo -e "\`root@$(hostname):$(pwd) # rm -vf /home/${CPMOVE}\`"
    echo -e "\n- Log located in: \`/home/.hd/logs/$TID/$ACT/restorepkg-$(date +%s).log\`"
}

zzacctpkg() {
    read -p "Enter cPanel account name: " ACT
    read -p "Enter ticket ID number: " TID
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly} ;
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/pkgacct $ACT /home/.hd/ticket/$TID/original | tee -a /home/.hd/logs/$TID/$ACT/pkgacct-$(date +%s).log ;
    echo -e "For Notes:\n"
    echo -e "\`root@$(hostname):$(pwd) # mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`root@$(hostname):$(pwd) # /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/pkgacct $ACT /home/.hd/ticket/$TID/original\`" ;
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
    if [[ -f /usr/local/bin/php53 ]]; then
        echo -e " - Multi-PHP 5.3"
    fi
    if [[ -f /usr/local/bin/php54 ]]; then
        echo -e " - Multi-PHP 5.4"
    fi
    if [[ -f /usr/local/bin/php55 ]]; then
        echo -e " - Multi-PHP 5.5"
    fi
    if [[ -f /usr/local/bin/php56 ]]; then
        echo -e " - Multi-PHP 5.6"
    fi
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
    if [[ -f /usr/sbin/dovecot ]]; then
        echo "Dovecot version: $(dovecot --version | awk '{ print $1 }')" ;
    fi
    if [[ -f /etc/init.d/courier-imap ]]; then
        echo "Courier version: $(/usr/lib/courier-imap/bin/imapd --version | cut -d / -f1)" ;
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
        echo -e "\`root@$(hostname):$(pwd) # cp -vP ${PTH} /home/.hd/ticket/${TID}/${DTE}/${CPMOVE}\`\n"
    else
    cd $PTH ;
    cd ..
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/ | tee -a /home/.hd/logs/$TID/$ACT/backup-$(date +%s).log ;
    echo -e "\n\`root@$(hostname):$(pwd) # mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`root@$(hostname):$(pwd) # /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/\`" ;
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
    wall -n "\`root@$(hostname):$(pwd) # mysqlcheck -rA\`"
    wall -n "\`root@$(hostname):$(pwd) # mysqlcheck -oA\`"
    wall -n "Log located in \`/home/.hd/logs/$TID/mysqlcheck-repair-$(date +%s).log\`" ;
    wall -n "Log located in \`/home/.hd/logs/$TID/mysqlcheck-optimize-$(date +%s).log\`" ;
}

zzapachetune() {
    bash <(curl -ks http://lederhostin.com/scripts/apacheworkertune) ;
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
    wget --no-check-certificate https://codesilo.dimenoc.com/michaelb/remote-bashrc/raw/master/scripts/beanc.sh ;
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
      TESTCON="$(mysql --user=$DB_USER --password=$DB_PASS $DB_NAME -e "show tables" &> /dev/null && echo Yes || echo No)"
      echo -e "\nWordpress version: ${DB_VER}"
      echo "Database Name: ${DB_NAME}"
      echo "Database User: ${DB_USER}"
      echo "Database Password: ${DB_PASS}"
      echo -e "Table Prefix: ${TBL_PREFIX}"
      echo -e "Connected: ${TESTCON}\n"
    ;;
   --joomla|-jm)
      DB_VER="$(grep RELEASE libraries/cms/version/version.php | head -n 1 | awk '{ print $4 }' | tr -d "'" | tr -d '    ;')"
      DB_PASS="$(grep password configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      DB_NAME="$(grep -w db configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      DB_USER="$(egrep -w user configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      TBL_PREFIX="$(grep -w dbprefix configuration.php | awk '{ print $4 }' | tr -d "'" | tr -d ';')"
      TESTCON="$(mysql --user=$DB_USER --password=$DB_PASS $DB_NAME -e "show tables" &> /dev/null && echo Yes || echo No)"
      echo -e "\nJoomla version: ${DB_VER}"
      echo "Database Name: ${DB_NAME}"
      echo "Database User: ${DB_USER}"
      echo "Database Password: ${DB_PASS}"
      echo -e "Table Prefix: ${TBL_PREFIX}"
      echo -e "Connected: ${TESTCON}\n"
    ;;
  --drupal|-dr)
    DB_VER="$(grep -w version core/modules/contact/contact.info.yml | tail -n 1 | tr -d "'")"
    DB_NAME="$(grep -w "database" sites/default/settings.php | tail -n 1 | awk '{ print $3 }' | tr -d "'" | tr -d ",")"
    DB_USER="$(grep -w "username" sites/default/settings.php | tail -n 1 | awk '{ print $3 }' | tr -d "'" | tr -d ",")"
    DB_PASS="$(grep -w "password" sites/default/settings.php | tail -n 1 | awk '{ print $3 }' | tr -d "'" | tr -d ",")"
    TBL_PREFIX="$(grep -w "prefix" sites/default/settings.php | tail -n 1 | awk '{ print $3 }' | tr -d "'" | tr -d ",")"
    TESTCON="$(mysql --user=$DB_USER --password=$DB_PASS $DB_NAME -e "show tables" &> /dev/null && echo Yes || echo No)"
    echo -e "\nDrupal ${DB_VER}"
    echo "Database Name: ${DB_NAME}"
    echo "Database User: ${DB_USER}"
    echo "Database Password: ${DB_PASS}"
    echo -e "Table Prefix: ${TBL_PREFIX}"
    echo -e "Connected: ${TESTCON}\n"
    ;;
   --littlefoot|-lf)
    DB_VER="$(cat lf/system/version)"
    DB_NAME="$(grep name lf/config.php | awk '{ print $3}' | tr -d "'" | tr -d ';')"
    DB_USER="$(grep user lf/config.php | awk '{ print $3}' | tr -d "'" | tr -d ';')"
    DB_PASS="$(grep pass lf/config.php | awk '{ print $3}' | tr -d "'" | tr -d ';')"
    TBL_PREFIX="$(grep prefix lf/config.php | awk '{ print $3}' | tr -d "'" | tr -d ';')"
    TESTCON="$(mysql --user=$DB_USER --password=$DB_PASS $DB_NAME -e "show tables" &> /dev/null && echo Yes || echo No)"
    echo -e "\nLittlefoot ${DB_VER}"
    echo "Database Name: ${DB_NAME}"
    echo "Database User: ${DB_USER}"
    echo "Database Password: ${DB_PASS}"
    echo -e "Table Prefix: ${TBL_PREFIX}"
    echo -e "Connected: ${TESTCON}\n"
    ;;
   --owncloud|-oc)
    DB_VER="$(grep version config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    DB_NAME="$(grep dbname config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    DB_USER="$(grep dbuser config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    DB_PASS="$(grep dbpassword config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    TBL_PREFIX="$(grep dbtableprefix config/config.php | awk '{ print $3 }' | tr -d "'" | tr -d ',')"
    TESTCON="$(mysql --user=$DB_USER --password=$DB_PASS $DB_NAME -e "show tables" &> /dev/null && echo Yes || echo No)"
    echo -e "\nOwncloud: ${DB_VER}"
    if [[ $(grep -c sqlite3 config/config.php) == 1 ]]; then
        echo "Database Type: sqlite3"
        echo -e "No additional configuration\n"
    else
        echo "Database Name: ${DB_NAME}"
        echo "Database User: ${DB_USER}"
        echo "Database Password: ${DB_PASS}"
        echo -e "Table Prefix: ${TBL_PREFIX}"
        echo -e "Connected: ${TESTCON}\n"
    fi
    ;;
   --whmcs|-ws)
    DB_VER="$(grep -w Version clients/upgrade.php | awk '{ print $3,$4,$5 }')"
    WS_LIC="$(grep -w license clients/configuration.php | tr -d '=' | tr -d "'" | awk '{ print $2 }' | tr -d ';')"
    DB_NAME="$(grep -w db_name clients/configuration.php | tr -d '=' | tr -d "'" | awk '{ print $2 }' | tr -d ';')"
    DB_USER="$(grep -w db_username clients/configuration.php | tr -d '=' | tr -d "'" | awk '{ print $2 }' | tr -d ';')"
    DB_PASS="$(grep -w db_password clients/configuration.php | tr -d '=' | tr -d "'" | awk '{ print $2 }' | tr -d ';')"
    TBL_PREFIX="None"
    TESTCON="$(mysql --user=$DB_USER --password=$DB_PASS $DB_NAME -e "show tables" &> /dev/null && echo Yes || echo No)"
    echo -e "\nWHMCS ${DB_VER}"
    echo "License: ${WS_LIC}"
    echo "Database Name: ${DB_NAME}"
    echo "Database User: ${DB_USER}"
    echo "Database Password: ${DB_PASS}"
    echo -e "Table Prefix: ${TBL_PREFIX}"
    echo -e "Connected: ${TESTCON}\n"
    ;;
   --help|-h)
    echo "Run this function in the directory of the CMS installation."
    echo "--wordpress -wp [ Extract DB information from a WordPress installation ]"
    echo "--joomla -jm [ Extract DB information from a Joomla installation ]"
    echo "--drupal -dr [ Extract DB information from a Drupal installation ]"
    echo "--littlefoot -lf [ Extract DB information from a Littlefoot installation ]"
    echo "--owncloud -oc [ Extract DB information from an Owncloud installation ]"
    echo "--whmcs -ws [ Extract DB and License information from a WHMCS installation ]"
    ;;
  *)
    echo "Usage: zzcmsdbinfo [ --wordpress / -wp | --joomla / -jm | --drupal / -dr | --littlefoot / -lf | --owncloud / -oc | --whmcs / -ws | --help / -h ]"
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
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/Axon) ;
}

zzxmlrpcget() {
    read -p "Enter domain name: " DOM
    ACT="$(grep -w ^$DOM /etc/userdatadomains | cut -d':' -f2 | cut -d '=' -f1 | sed 's/^[ \t]*//')"
    grep "POST /xmlrpc.php" /usr/local/apache/domlogs/$ACT/$DOM | awk '{ print $1 }' | grep -v $(hostname -i) | sort -nk1 | uniq -c | sort -nrk1 | head -n 10 ;
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
    echo -e "## -- Table Engine Conversion (example) -- ##"
    echo -e "mysql -e SELECT CONCAT(TABLE_SCHEMA, '.', TABLE_NAME) FROM information_schema.TABLES WHERE ENGINE = MyISAM ;"
    echo -e "mysql -e ALTER TABLE 'ENTER_TABLE(s)_HERE ENGINE' = Aria\n"
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
    x=1; while [ $x = 1 ]; do process=`pgrep -u $1`; if [ $process ]; then x=0; fi;  done; strace -vfs 4096  -p $process -o /home/.hd/user/michaelb/notes/strace.k
    echo "Strace located at /home/.hd/user/michaelb/notes/strace.k"
}

zzdizboxsetup() {
    CURDIR="$(pwd)"
    echo -e "\n$R1 Only run this in a sandbox! $RESET" ;
    echo -e " Ctrl+C to exit\n"
    sleep 5 ;
	/usr/local/cpanel/bin/set_hostname openstack.donthurt.us ;
    echo "$(ip addr | awk 'FNR == 8' | cut -d'/' -f1 | sed -e 's/inet//g' | tr -d ' ') openstack.donthurt.us sandbox" >> /etc/hosts ;
    sleep 2 ;
    if [[ ! -d /home/donthurt ]]; then
        cd /home ;
        wget http://filez.dizinc.com/~michaelb/vps_setup/cpmove-donthurt.tar.gz ;
	    /scripts/restorepkg /home/cpmove-donthurt.tar.gz; echo -e "\nCPANEL ACCOUNT RESTORED\n" ;
        sleep 2 ;
    fi
	find /var/cpanel/userdata -type f ! -name *.cache ! -name *.stor | while read line
	do
	    sed -ri "s/198.49.72.[0-9]*/$(hostname -i)/g" $line
	    echo "$line has been updated"
	done
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/convert_modsecurity) ;
    /scripts/rebuildhttpdconf ;
    /scripts/restartsrv_httpd ;
    /scripts/setupnameserver nsd ;
    chkconfig nscd off ;
    sed -i '/nscd/d' /etc/chkserv.d/chkservd.conf ;
    service nscd stop ;
    \rm -f /etc/chkserv.d/nscd ;
    /scripts/restartsrv_chkservd --restart ;
    sleep 2 ;
    sed -i 's/CPANEL=\(.*\)/CPANEL=current/g' /etc/cpupdate.conf ;
    wget http://filez.dizinc.com/~michaelb/vps_setup/sshpubkeys ;
    \rm -f /etc/wwwacct.conf ;
    echo -e "Basic Setup Complete" ;
    wget http://filez.dizinc.com/~michaelb/vps_setup/wwwacct.conf -O /etc/wwwacct.conf ;
    sed -i "s/198.49.72.[0-9]*/$(hostname -i)/g" /etc/wwwacct.conf
    cat sshpubkeys >> /root/.ssh/authorized_keys ;
    \rm sshpubkeys ;
    sed -i '/root/d' /etc/shadow ;
    echo "root:$6$FSI4sWi8$I6iT6plWjTEdGuPU4opUAStpkNm7FKI56BbevkDxbBV4JSAbdScW8zXTdiLdIUFkzIwjXFPVBcNY5/peHh3tr/:17013:0:99999:7:::" >> /etc/shadow ;
    sed -i 's/#ClientAliveInterval\ 0/ClientAliveInterval\ 300/' /etc/ssh/sshd_config ;
    sed -i 's/#ClientAliveCountMax\ 3/ClientAliveCountMax\ 2/' /etc/ssh/sshd_config ;
    service sshd restart ;
    rpm -ihv https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm ;
    yum install -y smem bc man strace git nmap telnet libicu-devel libicu python-pip ;
    cd /etc/yum.repos.d; wget http://repo1.dimenoc.com/dimenoc/DimeNOC.repo; yum -y install axond ;
    pip install --upgrade pip ;
    pip install cheat ;
    chmod 775 /var/run/screen
    echo -e "\nCONFIGURING PHP\n"
    sleep 2 ;
    pear channel-update pear.php.net
    pecl channel-update pecl.php.net
    /usr/local/cpanel/bin/rebuild_phpconf 5 none suphp 1 ;
    /scripts/phpextensionmgr install IonCubeLoader ;
    /scripts/phpextensionmgr install PHPSuHosin ;
    /scripts/installzendopt
    /scripts/vps_optimizer --force ;
    echo -e "\nVPS SANDBOX CONFIGURED\n" ;
    \cd $CURDIR
}

zzinodecheck() {
   ## Flagged as broken in codex bash <(curl -ks https://codex.dimenoc.com/scripts/download/inodeschecker2) ;
   bash <(curl -ks https://codex.dimenoc.com/scripts/download/inodeusagecurrentdirectory) ;
}

zzcronscan() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/cronscanner) ;
}

zzrpmquery() {
    rpm -aq --queryformat '%{installtime} (%{installtime:date}) %{name}\n' | grep -i $1
}

zzeasybackup() {
function backup {
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly} ;
    if [[ -f $PTH ]];then
        CPMOVE="$(ls -lah $PTH | rev | cut -d'/' -f1 | rev)"
        \cp -vP $PTH /home/.hd/ticket/$TID/$DTE ;
        echo -e "\n- Copied ${PTH} to \`/home/.hd/ticket/${TID}/${DTE}:\`"
       	echo -e "\`root@$(hostname):$(pwd) # cp -vP ${PTH} /home/.hd/ticket/${TID}/${DTE}/${CPMOVE}\`\n"
    else
    cd $PTH ;
    cd ..
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/ | tee -a /home/.hd/logs/$TID/$ACT/backup-$(date +%s).log ;
    echo "/home/.hd/ticket/$TID/$DTE/$ACT.tar.gz" > /root/cpmove.lst
    echo -e "\n\`root@$(hostname):$(pwd) # mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`root@$(hostname):$(pwd) # /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/\`" ;
    echo -e "- Backup for account \`$ACT\` created in \`/home/.hd/ticket/$TID/$DTE/$ACT.tar.gz\`" ;
    echo -e "**Additional Notes:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/backup-$(date +%s).log\`\n" ;
fi
    \rm -f /root/cpmove.lst
    \rm -f /root/backup.lst
    \rm -f /root/size.lst
    \rm -f /root/date.lst
}
function package {
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly} ;
    /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/pkgacct $ACT /home/.hd/ticket/$TID/original | tee -a /home/.hd/logs/$TID/$ACT/pkgacct-$(date +%s).log ;
    echo -e "For Notes:\n"
    echo -e "\`root@$(hostname):$(pwd) # mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
    echo -e "\`root@$(hostname):$(pwd) # /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/pkgacct $ACT /home/.hd/ticket/$TID/original\`" ;
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
    read -p "Enter the path of the backup you would like to restore: " BKP
    mkdir -p /home/.hd/logs/$TID/$ACT ;
    echo -e "Copying ${BKP} to /home"
    CPMOVE="$(ls -lah ${BKP} | awk '{ print $9 }' | rev | cut -d'/' -f1 | rev | tr -d ' ')"
    cd /home ;
    \cp -vP $BKP $CPMOVE ;
    /scripts/restorepkg --allow_reseller $CPMOVE | tee -a /home/.hd/logs/$TID/$ACT/restorepkg-$(date +%s).log ;
    \rm /home/$CPMOVE ;
    echo -e "\n- Copied backup from \`${BKP}\` to \`/home:\`"
    echo -e "\`root@$(hostname):$(pwd) # cp -vP ${BKP} /home/${CPMOVE}\`"
    echo -e "\n- Restored account \`${ACT}:\`"
    echo -e "\`root@$(hostname):$(pwd) # /scripts/restorepkg --allow_reseller ${CPMOVE}\`"
    echo -e "\n- Removed backup from \`/home:\`"
    echo -e "\`root@$(hostname):$(pwd) # rm -vf /home/${CPMOVE}\`"
    echo -e "\n- Log located in: \`/home/.hd/logs/$TID/$ACT/restorepkg-$(date +%s).log\`"
}
function killact {
  mkdir -p /home/.hd/logs/$TID/$ACT ;
  /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/removeacct $ACT | tee -a /home/.hd/logs/$TID/$ACT/removeacct-$(date +%s).log ;
  echo -e "\n- Removed account:"
  echo -e "\`root@$(hostname):$(pwd) # /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/removeacct $ACT\`"
  echo -e "- Log located in: \`/home/.hd/logs/$TID/$ACT/removeacct-$(date +%s).log\`"
}
function all {
    echo -e "\nCreate Backup"
    backup
    echo -e "\nPackage Account"
    package
    echo -e "\nRemove Account"
    killact
    echo -e "\nRestore Account"
    if [[ -f /root/cpmove.lst ]]; then
        echo "Previously created backup:"
        cat /root/cpmove.lst ;
        echo ""
    fi
    restore
}
for i in "$@"
do
    case $i in
        -b|--backup)
	        read -p "Enter cPanel account name: " ACT
    	    read -p "Enter ticket ID number: " TID
            echo -e "\nLocating backups for ${ACT}\n"
            find /backup -maxdepth 4 -name "${ACT}*" > /root/backup.lst ;
            for i in $(cat /root/backup.lst);do du -sh $i;done | awk '{ print $1 }' > /root/size.lst ;
            for i in $(cat /root/backup.lst);do stat $i | egrep -w ^Change: | awk '{ print $2 }';done > /root/date.lst ;
            paste /root/backup.lst /root/size.lst /root/date.lst | column -s $'\t' -t ;
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
	        read -p "Enter cPanel account name: " ACT
            read -p "Enter ticket ID number: " TID
            find /backup -maxdepth 4 -type f -name "${ACT}*" -print
            find /backup -maxdepth 4 -type d -name "${ACT}" -print
            read -p "Enter the path of the backup you would like to create: " PTH
            read -p "daily, weekly, or monthly backup? " DTE
            all
        echo -e "\nFULL NOTES:\n"
        echo -e "\n"
		echo -e "\n- Created backup:"
		echo -e "\`root@$(hostname):$(pwd) # mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
		echo -e "\`root@$(hostname):$(pwd) # /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) tar czvf /home/.hd/ticket/$TID/$DTE/$ACT.tar.gz $ACT/\`" ;
		echo -e "- Backup for account \`$ACT\` created in \`/home/.hd/ticket/$TID/$DTE/$ACT.tar.gz\`" ;
		echo -e "**Additional Notes:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/backup-$(date +%s).log\`\n" ;
		echo -e "\n- Packaged current cPanel account:"
		echo -e "\`root@$(hostname):$(pwd) # mkdir -p /home/.hd/ticket/$TID/{original,daily,weekly,monthly}\`" ;
		echo -e "\`root@$(hostname):$(pwd) # /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/pkgacct $ACT /home/.hd/ticket/$TID/original\`" ;
		echo -e "- Account \`$ACT\` packaged in \`/home/.hd/ticket/$TID/original/cpmove-$ACT.tar.gz\`" ;
		echo -e "**Additional Notes:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/pkgacct-$(date +%s).log\`\n" ;
		echo -e "- Removed current cPanel account:"
		echo -e "\`root@$(hostname):$(pwd) # /usr/local/cpanel/bin/cpuwatch $(grep -c proc /proc/cpuinfo) /scripts/removeacct $ACT\`"
		echo -e "**Additional Notes:**\n- Log located in \`/home/.hd/logs/$TID/$ACT/removeacct-$(date +%s).log\`" ;
		echo -e "\n- Restored account from backup:"
		echo -e "- Copied backup from \`${BKP}\` to \`/home:\`"
		echo -e "\`root@$(hostname):$(pwd) # cp -vP ${BKP} /home/${CPMOVE}\`"
		echo -e "\n- Restored account \`${ACT}:\`"
		echo -e "\`root@$(hostname):$(pwd) # /scripts/restorepkg ${CPMOVE}\`"
		echo -e "\n- Removed backup from \`/home:\`"
		echo -e "\`root@$(hostname):$(pwd) # rm -vf /home/${CPMOVE}\`"
		echo -e "\n- Log located in: \`/home/.hd/logs/$TID/$ACT/restorepkg-$(date +%s).log\`"
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
            echo "Usage: [ --backup / -b | --package / -p | --restore / -r | --all / -a | --help / -h ]"
            ;;
    esac
done
unset TID
unset ACT
unset BKP
unset CPMOVE
unset PTH
}

zzrpmquery() {
    rpm -aq --queryformat '%{installtime} (%{installtime:date}) %{name}\n' | grep -i $1
}

zzopenvzdu() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/OpenVZDiskUsage) ;
}

zzchkdrivehealth() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/CheckDriveHealth) ;
}

zzupcpf() {
  /scripts/upcp --force ;
}

zzchkrpms() {
  /scripts/check_cpanel_rpms --fix ;
}

zzinitnginxvhosts() {
  read -p "Enter ticket ID number: " TID
  mkdir -p /home/.hd/ticket/$TID/original ;
  mkdir -p /home/.hd/logs/$TID ;
  \mv -v /etc/nginx/vhosts /home/.hd/ticket/$TID/original | tee -a /home/.hd/logs/$TID/move-vhosts-$(date +%s).log ;
  /scripts/rebuildvhosts ;
  service nginx stop ;
  service nginx start ;
  echo -e "\n**For Notes:**"
  echo -e "\n- Backed up existing Nginx vhosts:"
  echo -e "\`root@$(hostname):$(pwd) # mv -v /etc/nginx/vhosts /home/.hd/ticket/$TID/original\`"
  echo -e "- Rebuilt vhosts:"
  echo -e "\`root@$(hostname):$(pwd) # /scripts/rebuildvhosts\`"
  echo -e "- Restarted Nginx:"
  echo -e "\`root@$(hostname):$(pwd) # service nginx stop\`"
  echo -e "\`root@$(hostname):$(pwd) # service nginx start\`\n"
}

zznginxinstall() {
    if [[ -d /etc/nginx ]]; then
        echo "NginxCP is already installed."
    else
        mkdir -p /usr/local/src ;
        bash <(curl -ks https://codex.dimenoc.com/scripts/download/installnginxcp) ;
        echo -e "\n**For Notes**"
        echo -e "\n- Installed NginxCP:"
        echo -e "\`[root@$(hostname):$(pwd) #] mkdir -p /usr/local/src\`"
        echo -e "- Installed via [codex script](https://codex.dimenoc.com/scripts/download/installnginxcp).\n"
    fi
}

zznginxremove() {
    if [[ -d /etc/nginx ]]; then
        bash <(curl -ks https://codex.dimenoc.com/scripts/download/uninstallnginxcp) ;
        echo -e "\n**For Notes**"
        echo -e "- Uninstalled NginxCP via [codex script](https://codex.dimenoc.com/scripts/download/uninstallnginxcp)."
    else
        echo -e "NginxCP is not installed."
    fi
}

zzapachestatus() {
  lynx --dump http://localhost:$(netstat -pltuna | grep httpd | uniq | head -n 1 | awk '{ print $4 }' | cut -d':' -f2)/whm-server-status
}

zzcpanelinstall() {
    if [[ -d /usr/local/cpanel ]]; then
        echo "cPanel is already installed."
    else
        touch /etc/install_legacy_ea3_instead_of_ea4 ;
        setenforce 0
        cd /home ;
        curl -o latest -L https://securedownloads.cpanel.net/latest ;
        chmod +x latest ;
        sh latest ;
        echo -e "\n**For Notes**"
        echo -e "\n- Installed cPanel:"
        echo -e "\`root@$(hostname):$(pwd) # curl -o latest -L https://securedownloads.cpanel.net/latest\`"
        echo -e "\`root@$(hostname):$(pwd) # chmod +x latest\`"
        echo -e "\`root@$(hostname):$(pwd) # sh latest\`"
    fi
}

zzsoftaculousinstall() {
    if [[ $(grep -c ioncube /var/cpanel/cpanel.config) == 1 ]]; then
        bash <(curl -ks https://codex.dimenoc.com/scripts/download/installsoftaculous) ;
    else
        CURLOAD="$(grep phploader= /var/cpanel/cpanel.config | cut -d'=' -f2)"
        sed -i "s/phploader=$CURLOAD/phploader=ioncube,$CURLOAD/" /var/cpanel/cpanel.config ;
        /usr/local/cpanel/whostmgr/bin/whostmgr2 –updatetweaksettings ;
        /usr/local/cpanel/bin/checkphpini ;
        sleep 5 ;
        /usr/local/cpanel/bin/install_php_inis ;
        bash <(curl -ks https://codex.dimenoc.com/scripts/download/installsoftaculous) ;
    fi
    echo -e "\n- Enabled cPanel \`IonCube\` Loader."
    echo -e "- Installed Softaculous via [codex script](https://codex.dimenoc.com/scripts/download/installsoftaculous).\n"
}

zzsoftaculousremove() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/removesoftaculous) ;
    echo -e "\n- Uninstalled Softaculous via [codex script](curl -ks https://codex.dimenoc.com/scripts/download/removesoftaculous).\n"
}

zzwhmxtrainstall() {
    if [[ $(grep -c ioncube /var/cpanel/cpanel.config) == 1 ]]; then
        bash <(curl -ks https://codex.dimenoc.com/scripts/download/installwhmxtra) ;
    else
        CURLOAD="$(grep phploader= /var/cpanel/cpanel.config | cut -d'=' -f2)"
        sed -i "s/phploader=$CURLOAD/phploader=ioncube,$CURLOAD/" /var/cpanel/cpanel.config ;
        /usr/local/cpanel/whostmgr/bin/whostmgr2 –updatetweaksettings ;
        /usr/local/cpanel/bin/checkphpini ;
        sleep 5 ;
        /usr/local/cpanel/bin/install_php_inis ;
        bash <(curl -ks https://codex.dimenoc.com/scripts/download/installwhmxtra) ;
    fi
        echo -e "\n- Enabled cPanel \`IonCube\` Loader."
        echo -e "- Installed \`WHMXtra\` using [codex script](https://codex.dimenoc.com/scripts/download/installwhmxtra).\n"
}

zzwhmxtraremove() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/na) ;
    echo -e "\n- \`Removed WHMXtra\` using [codex script](https://codex.dimenoc.com/scripts/download/na).\n"
}

zzsiteresponse() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/sitetest) ;
}

zzssp() {
    CURDIR="$(pwd)"
    HDSCRIPTDIR="/home/.hd/techs/scripts/michaelb"
    mkdir -p ${HDSCRIPTDIR} ;
    if [[ -f /usr/bin/git ]];then
        cd ${HDSCRIPTDIR}
        git clone https://github.com/cPanelSSP/SSP.git ;
        cd SSP ;
        chmod +x run ;
        bash run ;
    else
        cd ${HDSCRIPTDIR} ;
        /usr/local/cpanel/3rdparty/bin/git clone https://github.com/cPanelSSP/SSP.git ;
        cd SSP ;
        chmod +x run ;
        bash run ;
    fi
    cd ${CURDIR} ;
}

zzchk500() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/Internalservererror) ;
}

zzchangehandler() {
    if [[ $(whmapi1 ea4_get_ea_pkgs_state | grep -c ea-profiles-cpanel) == 1 ]]; then
        echo -e "\nEasyApache 4 is not supported"
    else
    echo -e "\nHandler Selections"
    echo -e "1. PHP 5 SAPI: suPHP w/ SUEXEC"
    echo -e "2. PHP 5 SAPI: DSO w/ mod_ruid2"
    echo -e "3. PHP 5 SAPI: DSO w/o mod_ruid2"
    echo -e "4. PHP 5 SAPI: fcgi w/ SUEXEC"
    read -p "Select Handler [ 1 2 3 4 ]: " HAND

    if [[ $HAND == 1 ]]; then
       echo "You have selected suPHP with SUEXEC"
       /usr/local/cpanel/bin/rebuild_phpconf 5 none suphp 1 ;
    elif
        [[ $HAND == 2 ]]; then
        echo "You have selected DSO with mod_ruid2"
            if [[ -f /usr/local/apache/modules/mod_ruid2.so ]]; then
            /usr/local/cpanel/bin/rebuild_phpconf 5 none dso 1 ;
        else
            echo "Apache was not built with mod_ruid2 support, rebuild Apache to include this module"
        fi
    elif
        [[ $HAND == 3 ]]; then
            echo "You have selected DSO without mod_ruid2"
            /usr/local/cpanel/bin/rebuild_phpconf 5 none dso 0 ;
    else
        echo "You have selected FCGI with SUEXEC"
        if [[ $(httpd -M | grep -c fcgi) == 1 ]];then
            /usr/local/cpanel/bin/rebuild_phpconf 5 none fcgi 1 ;
        else
            echo "Apache was not built with FCGI support, rebuild Apache to support this handler"
            fi
        fi
    fi
}

zzpassiveports() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/passiveportopener) ;
    echo -e "\n- Enabled passive \`FTP\` ports using [codex script](https://codex.dimenoc.com/scripts/download/passiveportopener)."
}

zzupdatemodsec() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/modsec2latest) ;
    echo -e "\n- Updated \`ModSecurity\` using [codex script](https://codex.dimenoc.com/scripts/download/modsec2latest)."
}

zzchksymlink() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/checksymlinkpatch) ;
}

zzpatchsymlink() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/installsymlinkoptmod) ;
}

zzweather() {
  curl -4 wttr.in ;
}

zzinstallplesk() {
    sh <(curl http://autoinstall.plesk.com/plesk-installer || wget -O - http://autoinstall.plesk.com/plesk-installer) ;
}

zzdomconn() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/domainconnections) ;
}

zztransferver() {
    echo -e "\nRun on Destination Server.\n"
    bash <(curl -ks http://filez.dizinc.com/~michaelb/sh/new_transfer_precheck.sh) ;
}

zzpsdest() {
    PS1="(DEST) $PS1" ;
}

zzpssrc() {
    PS1="(SRC) $PS1" ;
}

zztransferrsyncprog() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/transferrsyncpredefine) ;
}

zztransferacctprog() {
   bash <(curl -ks https://codesilo.dimenoc.com/michaelb/remote-bashrc/raw/master/scripts/homelessrestoreprogress.sh) $1 ;
}

zzrealmemsar() {
    python <(curl -ks https://codex.dimenoc.com/scripts/download/realmemsar) ;
}

zzmysqlhash() {
    HASH="$1"
    case $HASH in
        --predef|-p)
            bash <(curl -ks https://codex.dimenoc.com/scripts/download/checkoldmysqlpass) ;
            ;;
          --list|-l)
            bash <(curl -ks https://codex.dimenoc.com/scripts/download/listmysqloldpasswords) ;
            ;;
                 *)
            echo "Usage: [ --predef / -p | --list / -l ]"
        ;;
    esac
}

zzmysqlerror() {
    curl -s http://dev.mysql.com/doc/refman/$1/en/error-messages-server.html | grep -3 -w "$2" | grep Message | sed -e 's/Message://g' | sed -e 's/^[ \t]*//' ;
    perror $2
}

zzrvsitebuilderuninstall() {
    echo -e "\nThis script will backup RVSitebuilder configuration files and optionally the database then completely remove RVSitebuilder."
    read -p "Enter the ticket ID number: " TID
    \mkdir -p /home/.hd/ticket/$TID/original ;
    \cp -rp /var/cpanel/rvglobalsoft/rvsitebuilder/var /home/.hd/ticket/$TID/original ;
    \cp -rp /var/cpanel/rvglobalsoft/rvsitebuilder/www/project /home/.hd/ticket/$TID/original ;
    \cp -p /var/cpanel/rvglobalsoft/rvsitebuilder/var/rvautosetting.conf.ini.php /home/.hd/ticket/$TID/original ;
    sleep 2 ;
    echo -e "\nRVSitebuilder configuration has been backed up to /home/.hd/ticket/$TID/original\n"
    read -p "Would you like to backup the RVSitebuilder database? (Y/N) " YN
    if [[ $YN = Y ]]; then
        DBAK="$(egrep -w ^name /var/cpanel/rvglobalsoft/rvsitebuilder/var/rvautosetting.conf.ini.php | cut -d'=' -f2)"
        mysqldump $DBAK > /home/.hd/ticket/$TID/original/$DBAK.sql ;
    else
        echo -e "\nNot backing up the RVsitebuilder database."
    fi
    echo -e "\nUnregistering RVSitebuilder plugin files."
    sleep 2 ;
    /usr/local/cpanel/bin/unregister_cpanelplugin /var/cpanel/rvglobalsoft/rvsitebuilder/panelmenus/cpanel/cpanelplugin/rvsitebuilder.cpanelplugin ;
    /usr/local/cpanel/bin/rebuild_sprites ;
    /usr/local/cpanel/scripts/uninstall_plugin /var/cpanel/rvglobalsoft/rvsitebuilder/panelmenus/cpanel/cpanelplugin/register_paper_lantern.tar.bz2 ;
    echo -e "\nRemoving RVsitebuilder files."
    sleep 2 ;
    rm -rvf /usr/local/cpanel/whostmgr/docroot/cgi/rvsitebuilderinstaller.tar ;
    rm -rvf /usr/local/cpanel/whostmgr/docroot/cgi/rvsitebuilderinstaller ;
    rm -rvf /usr/local/cpanel/whostmgr/docroot/cgi/rvsitebuilder ;
    rm -vf /usr/local/cpanel/whostmgr/docroot/cgi/addon_rvsitebuilder.cgi ;
    rm -rvf /var/cpanel/rvglobalsoft ;
    rm -rvf /usr/local/cpanel/base/frontend/*/rvsitebuilder ;
    rm -vf /usr/local/cpanel/base/frontend/x/cells/rvsitebuilder.htm ;
    rm -vf /usr/local/cpanel/base/frontend/x3/dynamicui/dynamicui_rvsitebuilder.conf ;
    echo -e "\nRemoving plugin."
    perl /root/rvadmin/autoupdatewhmaddon.pl ;
    DBUSER="$(egrep -w ^databaseUserPass /home/.hd/ticket/$TID/original/var/rvautosetting.conf.ini.php | cut -d'=' -f2)"
    DBPASS="$(egrep -w ^databaseUser /home/.hd/ticket/$TID/original/var/rvautosetting.conf.ini.php | cut -d'=' -f2)"
    echo -e "\nRVSitebuilder has been removed."
    echo -e "Configuration backups located in /home/.hd/ticket/$TID/original\n"
    echo -e "If you are reinstalling RVSitebuilder and would like to use the original database the credentials are below:"
    echo -e "Database Name: $DBAK"
    echo -e "Database User: $DBUSER"
    echo -e "Database Password: $DBPASS\n"

}

zzrvsitebuilderinstall() {
    CURDIR="$(pwd)"
    if [[ -d /usr/src ]]; then
        cd /usr/src ;
    else
        mkdir -p /usr/src ;
        cd /usr/src ;
    fi
    if [[ -f rvsitebuilderinstall.sh ]]; then
        rm -vf rvsitebuilderinstall.sh
    fi
    wget http://download.rvglobalsoft.com/rvsitebuilderinstall.sh ;
    chmod +x rvsitebuilderinstall.sh ;
    ./rvsitebuilderinstall.sh ;
    cd ${CURDIR} ;
}

zzattractainstall() {
    CURDIR="$(pwd)"
    cd /usr/src ;
    cpan install Mozilla::CA ;
    wget -N http://www.attracta.com/static/download/cpanel-install ;
    chmod +x cpanel-install ;
    sh cpanel-install ;
    cd ${CURDIR} ;
}

zzattractauninstall() {
    /scripts/uninstall-attracta ;
    rm -vf /scripts/uninstall-attracta ;
}

zzgetkey() {
    if [[ -f /root/.ssh/id_rsa.pub ]]; then
        cat /root/.ssh/id_rsa.pub ;
    else
        read -p "No public RSA key found, would you like to generate a key? (Y/N) " YN
            if [[ $YN == Y ]];then
                ssh-keygen ;
                cat /root/.ssh/id_rsa.pub ;
        fi
    fi
}

zzkeylock() {
    vim /root/.ssh/authorized_keys ;
    chattr +ia /root/.ssh/authorized_keys ;
    touch /etc/.transfer_time file ;
    echo -e "~/.ssh/authorized_keys locked."
}

zzunlock() {
    chattr -ia /root/.ssh/authorized_keys ;
    \rm -f /etc/.transfer_time file ;
    echo -e "~/.ssh/authorized_keys unlocked."
}

zzupdatetweak() {
    /usr/local/cpanel/whostmgr/bin/whostmgr2 --updatetweaksettings ;
    /scripts/restartsrv_cpsrvd --restart ;
}

zzticketmonitoroutput() {
    bash <(curl -ks http://filez.dizinc.com/~michaelb/sh/ticketmonitoroutput.sh) $1 ;
}

zzinstallcomposer() {
    CURDIR=$(pwd)
    HAZSUHOSIN=$(php -v | grep -c ^Suhosin)
    read -p "Enter the cPanel account you would like to install composer for: " ACT
    cd /home/${ACT} ;
    if [[ -d /root/.composer ]]; then
        \mv -f /root/.composer{,.bak} ;
    fi
    if [[ ${HAZSUHOSIN} == 1 ]]; then
        curl -sS https://getcomposer.org/installer | php -d allow_url_fopen=1 -d detect_unicode=0 -d suhosin.executor.include.whitelist=phar ;
    else
        curl -sS https://getcomposer.org/installer | php -d allow_url_fopen=1 -d detect_unicode=0 ;
    fi
    chown ${ACT}: composer.phar ;
    \cp -r /root/.composer /home/${ACT} ;
    chown -R ${ACT}: .composer ;
    chmod 664 .composer/*.pub ;
    if [[ -d /root/composer.bak ]]; then
        \mv /root/composer{.bak,}
    fi

    if [[ $(grep ${ACT} /etc/passwd | grep -c jail) == 1 ]]; then
        echo -e "JailedShell is already enabled for $ACT"
    else
        echo -e "JailedShell must be enabled for the $ACT to access the composer.phar application"
        read -p "Would you like to enable JailedShell for $ACT? (Y/N) " JSH
        if [[ $JSH = Y ]]; then
            chsh -s /usr/local/cpanel/bin/jailshell $ACT
        fi
    fi
    cd ${CURDIR} ;
}

zzlargefileusage() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/diskusage) ;
}

zzsuhosinsilencer() {
#    bash <(curl -ks https://codex.dimenoc.com/scripts/download/suhosinsilencer) ;
bash <(curl -ks http://filez.dizinc.com/~michaelb/sh/suhosinsilencer.sh) ;
}

zzquikchk() {
    eval "$(curl -ks https://codex.dimenoc.com/scripts/download/colorcodes)"
    echo -e "${R1}CPU Cores:${G1} $(grep -c proc /proc/cpuinfo)${RS}"
    echo -e "${R1}RAM: ${G1}$(if [[ $(cat /etc/redhat-release | egrep -m1 -o '[0-9]+' | head -1) -gt 5 ]]; then echo "${G1}$(free -hm | awk 'FNR == 2' | awk '{ print $2 }')"; else echo "${G1}$(free -m | awk 'FNR == 2' | awk '{ print $2 }')M"; fi)${RS}"
    echo -e "${R1}Swap: $(if [[ $(cat /etc/redhat-release | egrep -m1 -o '[0-9]+' | head -1) -gt 5 ]]; then echo "${G1}$(free -mh | grep ^Swap: | awk '{ print $2 }')"; else echo "${G1}$(free -m | grep ^Swap: | awk '{ print $2 }')M"; fi)${RS}"
    echo -e "${R1}Load: ${G1}$(awk '{ print $1,$2,$3 }' /proc/loadavg)${RS}"
    echo -e "${R1}Disk Size: ${G1}$(df -h | awk 'FNR == 2' | awk '{ print $2 }')${RS}"
    echo -e "${R1}Raid Card: ${G1}$(if [[ $(megacli -LDInfo -Lall -aALL | grep -c Primary) -gt 0 ]]; then echo "MegaRAID"; elif [[ $(3ware show | grep -c '^No controller found.') == 0 ]]; then echo "3ware"; else echo "None"; fi)${RS}"
    echo -e "${R1}cPanel Accts: ${G1}$(wc -l /etc/trueuserdomains | awk '{ print $1 }')${RS}"
    echo -e "${R1}Uniq Domains: ${G1}$(wc -l /etc/userdatadomains | awk '{ print $1 }')${RS}"
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/QuickServiceCheck) ;
}

zzsqlsize() {
    bash <(curl -ks https://codex.dimenoc.com/scripts/download/sqlsize) ;
}
