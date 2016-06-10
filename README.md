**mbalias.sh**
- Aliases, functions and environment setup, subject to change and breakage; use
at your own risk.  
- List of available commands:

| **command** | **description** | **usage** | **Note output** |
| ------- | ----------- | ----- | --------- | --------------- |
| `zzphpini` | creates a local `php.ini` | use by specifying `php` or `php53,54,etc` if using multi PHP | yes |
| `zzphphandler` | displays current and avaliable PHP handlers | accepts no arguments | no |
| `zzphpinfo` | creates a `phpinfo.php` file | accepts no arguments | yes |
| `zzmemload` | shows number of `CPU` cores, `w` and `sar -q` over 5 seconds; displays free memory and swappiness value | accepts no arguments | yes |
| `zzfixtmp` | sets `/tmp` permissions to `1777` and removes files older than `30` minutes | accepts no arguments | log |
| `zzacctdom` | displays helpful information for a domain, `SSL, IP, DocRoot, etc` | supply `FQDN` | no |
| `zzacctpkg` | sets up HD working dir and packages a live cPanel account | enter cPanel account name and ticket ID number | yes and log |
| `zzmkbackup` | searches for New and Legacy style backups, sets up HD working dir and compresses a backup | supply cPanel account, ticket ID number and type of backup | yes and log |
| `zzversions` | shows CentOS version, kernel version, cPanel version, PHP version, MySQL version and NGINX version | accepts no arguments | yes |
| `zzgetvimrc` | wgets my personal `.vimrc` file to `/root/vimrc` creates backup if one already exists | accepts no argments | no |
| `zzsetdnsvps` | auto detects and configures nameserver service to avoid issues with misconfiguration | accepts no arguments | no |
| `zzmysqltune` | downloads and executes the perl MySQL tuner script | specify tuner script, see --help for usage | no |
| `zzmysqltuneup` | runs `mysqlcheck` repair and optimize on all databases | enter ticket ID number | yes and log |
| `zzapachetune` | executes Spencers Apache evaluation script | accepts no arguments | no |
| `zzdiskuse` | shows disk and inode usage for all mounted partitions | accepts no arguments | yes |
| `zztopmail` | shows top email accounts by usage | accepts no arguments | no |
| `zzeximstats` | shows eximstats | accepts no arguments | no |
| `zzquicknotes` | echos notes, MySQL syntax | accepts no arguments | no |
| `zzbeanc` | outsourced script, displays and resets UBC failcounts | accepts multiple arguments, read source | no |
| `zzcmsdbinfo` | displays database, database prefix, database user, CMS version and password | specify CMS, see --help for usage | no |
| `zzcleanup` | clean up files created from invoking `mbalias.sh` | accepts no arguments | no |
| `zzaxonparse` | L2 Axon log parser | menu driven | no |
| `zzxmlrpcget` | searches apache domlogs for xmlrpc.php and sorts by IP hits | enter domain name | no |
| `zzcpucheck` | shows cpu core temperatures, cpu type, current and maximum clock speeds | accepts no arguments | yes |
| `zztailapache` | alias to `tail -f` main Apache log with pipe to `grep` `67.23` | no | no |
| `zztailmysql` | alias to `tail -f` MySQL log | pipe to standard Linux commands | no |
| `zzmailperms` | corrects mail permissions on all cPanel accounts | menu driven | no |
| `zzdusort` | from Kevin B.s aliases - sorts the output of du by size and taking into consideration type of measurement (K,M,G,T) | no | no |
| `zzhomeperms` | executes codex fix homedir permissions script | supply cPanel account name and ticket ID number | yes and log |
| `zzmonitordisk` | from Kevin B.s aliases - shows number of processes accessing the disk(s) using iostat | no | no |
| `zzpiniset` | allows setting of various PHP configuration directives | menu driven | no |
| `zztophttpd` | shows top 10 httpd connections by IP | accepts no arguments | no |
| `zzbackuprest` | restore an account from a cPanel style backup | supply cPanel account name, backup location and ticket ID number | yes and log |
| `zzapachestrace` | strace PHP processes for a user, output to `strace.k` | supply cPanel account name | no |
| `zzdizboxsetup` | sets up a dizbox sandbox with my custom configuration | no | no |
| `zzcronscan` | codex cron scanner script | accepts no arguments | no |
| `zzinodecheck` | codex top inode abusers script | run in `pwd` | no |
| `zzrpmquery` | `rpm -qa` with timestamps | supply rpm name | no |
| `zzeasybackup` | Packages a cPanel backup, packages a live cPanel account, kills a live cPanel account and restores the account from the created backup | accepts multiple arguments, see --help for usage | yes and log |
| `zzopenvzdu` | codex script, calculates container disk usage | accepts no arguments | no |
| `zzchkdiskhealth` | codex script, check status of raid arrays and disks | accepts no arguments | no |
| `zzexigrep` | use `exigrep` without specifying the log path | supply email address | no |
| `zzexirmlfd` | removes queued/frozen `lfd` emails | accepts no arguments | no |
| `zznginxinstall` | installs `NginxCP` | accepts no arguments | yes |
| `zznginxremove` | uninstalls `NginxCP` | accepts no arguments | yes |
| `zzinitnginxvhosts` | backs up `/etc/nginx/vhosts`, creates new `vhosts` and restarts `Nginx` | accepts no arguments | yes and log |
| `zzapachestatus` | invoke `lynx --dump` and grab Apache port from `netstat` | accepts no arguments | no |
| `zzinstallcpanel` | installs `cPanel` | accepts no arguments | yes |
| `zzsoftaculousinstall` | installs `Softaculous` | accepts no arguments | yes |
| `zzsoftaculousremove` | uninstalls `Softaculous` | accepts no arguments | yes |
| `zzwhmxtrainstall` | installs `Xtra Ultimate` | accepts no arguments | yes |
| `zzwhmxtraremove` | uninstalls `Xtra Ultimate ` | accepts no arguments | yes |
| `zzsiteresponse` | codex script, checks domain resolution | accepts no arguments | no |
| `zzcddr` | `cd` to the `DocRoot` of a domain | supply `FQDN` | no |
| `zzssp` | `git clone` and execution of cPanels `System Status Probe` | accepts no arguments | no |
| `zzchk500` | Adam B.s `500` error checking script | accepts no arguments | no |
| `zzchangehandler` | change `PHP` handler | menu driven | no |
| `zzpassiveports` | enable passive ports in `FTP` client and `CSF` | accepts no arguments | yes |
| `zzupdatemodsec` | codex script updates `modsec` configuration | accepts no arguments | yes |
| `zzchksymlink` | codex script checks for `Apache` `SymLink` protection | accetps no arguments | no |
| `zzpatchsymlink` | codex script applies `SymLink` patch | accepts no arguments | no |
| `zzinstallplesk` | install `Plesk` for `Linux` | menu driven | no |
| `zzweather` | checks weather forecast using `curl` | append city to `URL` | no |
| `zzdomcon` | codex script checks connections by `domain` | no | no |
