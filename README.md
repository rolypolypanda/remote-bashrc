**mbalias**
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
| `zzacctdom` | shows domain owner account and searches `/etc/*domains` | supply either `FQDN` or cPanel account name | no |
| `zzacctpkg` | sets up HD working dir and packages a live cPanel account | enter cPanel account name and ticket ID number | yes and log |
| `zzmkbackup` | searches for New and Legacy style backups, sets up HD working dir and compresses a backup | supply cPanel account, ticket ID number and type of backup | yes and log |
| `zzversions` | shows CentOS version, kernel version, cPanel version, PHP version, MySQL version and NGINX version | accepts no arguments | yes |
| `zzgetvimrc` | wgets my personal `.vimrc` file to `/root/vimrc` creates backup if one already exists | accepts no argments | no |
| `zzsetnsdvps` | auto detects and configures nameserver service to avoid issues with misconfiguration | accepts no arguments - BETA | no |
| `zzmysqltune` | downloads and executes the perl MySQL tuner script | accepts no arguments | no |
| `zzmysqltuneup` | runs myisamchk and mysqlcheck repar and optimize on all databases | enter ticket ID number | yes and log |
| `zzapachetune` | downloads and executes the perl Apache tuner script | accepts no arguments | no |
| `zzdiskuse` | shows disk and inode usage for all mounted partitions | accepts no arguments | yes |
| `zztopmail` | shows top email accounts by usage | accepts no arguments | no |
| `zzeximstats` | shows eximstats | accepts no arguments | no |
| `zzquicknotes` | echos notes, MySQL syntax | accepts no arguments | no |
| `zzbeanc` | outsourced script, displays and resets UBC failcounts | accepts multiple arguments, read source | no |
| `zzcmsdbinfo` | displays database, database prefix, database user, CMS version and password | specify CMS, --wordpress, --joomla, --drupal | no |
| `zzcleanup` | clean up files created from invoking `mbalias.sh` | accepts no arguments | no |
