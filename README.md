# sansw
Scan SAN switches and save info to CSV with addons

This is Bash script for invetory SAN switches (Brocade) to CSV format, then convert to XLS format and export to BD (MySQL) and copy result to SMB share (by Kerberos auth).

Additional i make some analise of result.
I have some rules:
1) Use Alias (Name - WWN), with all WWNs of device
2) Name switch port is as Alias
3) Support multi Fabrics, by pair as A-B, C-D, E-F for splited SAN nets (by LSAN example). Analise work by each pair.
4) Connect to SAN switch by SSH, i use login: admin. If used pair Public-Private key, may use login and keyword SSH
5) For convert to XLS used my script - csv2xls, export to BD used my script - csv2mysql
