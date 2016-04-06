**mbalias.sh**
- Aliases, functions and environment setup, subject to change and breakage; use
at your own risk.  
- List of available commands:

| **command** | **description** | **usage** | **Note output** |
| ------- | ----------- | ----- | --------- | --------------- |
| `zzphpini` | creates a local `php.ini` | use by specifying `php` or `php53` if using dual PHP | yes |
| `zzphphandler` | displays current and avaliable PHP handlers | accepts no arguments | no |
| `zzphpinfo` | creates a `phpinfo.php` file | accepts no arguments | yes |
| `zzmemload` | shows number of `CPU` cores, `w` and `sar -q` over 5 seconds | accepts no arguments | yes |
| `zzfixtmp` | sets `/tmp` permissions to `1777` and removes files older than `30` minutes | accepts no arguments | log |
| `zzacctdom` | shows domain owner account and searches `/etc/*domains` | supply either `FQDN` | no |
| `zzacctpkg` | sets up HD working dir and packages a live cPanel account | enter cPanel account name and ticket ID number | yes and log |
| `zzmkbackup` | searches for New and Legacy style backups, sets up HD working dir and compresses a backup | supply cPanel account, ticket ID number and type of backup | yes and log |
| `zzversions` | shows CentOS version, kernel version, cPanel version, PHP version, MySQL version and NGINX version | accepts no arguments | yes |
| `zzgetvimrc` | wgets my personal `.vimrc` file to `/root/vimrc` creates backup if one already exists | accepts no argments | no |
| `zzsetdnsvps` | auto detects and configures nameserver service to avoid issues with misconfiguration | accepts no arguments | no |
| `zzmysqltune` | downloads and executes the perl MySQL tuner script | specify tuner script, see --help for usage | no |
| `zzmysqltuneup` | runs mysqlcheck repair and optimize on all databases | enter ticket ID number | yes and log |
| `zzapachetune` | downloads and executes the perl Apache tuner script | accepts no arguments | no |
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
| `zztailapache` | alias to tail -f main Apache log | pipe to standard Linux commands | no |
| `zztailmysql` | alias to tail -f MySQL log | pipe to standard Linux commands | no |
| `zzmailperms` | corrects mail permissions on all cPanel accounts | no | no |
| `zzdusort` | from Kevin B.s aliases - sorts the output of du by size and taking into consideration type of measurement (K,M,G,T) | no | no |
| `zzhomeperms` | executes codex fix homedir permissions script | supply cPanel account name and ticket ID number | yes and log |
| `zzmonitordisk` | from Kevin B.s aliases - shows number of processes accessing the disk(s) using iostat | no | no |
| `zzpiniset` | allows setting of various PHP configuration directives | menu driven | no |
| `zztophttpd` | shows top 10 httpd connections by IP | no | no |
| `zzbackuprest` | restore an account from a cPanel style backup | supply cPanel account name, backup location and ticket ID number | yes and log |
| `zzapachestrace` | strace PHP processes for a user, output to `strace.k` | supply cPanel account name | no |
| `zzdizboxsetup` | sets up a dizbox sandbox with my custom configuration | no | no |
| `zzcronscan` | Codex cron scanner script | no | no |
| `zzinodecheck` | Codex top inode abusers script | no | no |
| `zzeasybackup` | Packages a cPanel backup, packages a live cPanel account, kills a live cPanel account and restores the account from the created backup - BETA AF | accepts multiple arguments, see --help for usage | yes and log |
| `zzrpmquery` | `rpm -qa` with timestamps | yes | no |
