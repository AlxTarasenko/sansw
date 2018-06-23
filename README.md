# sansw
Scan SAN switches and save info to CSV with addons

In English
----------

This is Bash script for invetory SAN switches (Brocade) to CSV format, then convert to XLS format and export to BD (MySQL) and copy result to SMB share (by Kerberos auth).

Additional i make some analise of result.
I have some rules:
1) Use Alias (Name - WWN), with all WWNs of device
2) Name switch port is as Alias
3) Support multi Fabrics, by pair as A-B, C-D, E-F for splited SAN nets (by LSAN example). Analise work by each pair.
4) Connect to SAN switch by SSH, i use login: admin. If used pair Public-Private key, may use login and keyword SSH
5) For convert to XLS used my script - csv2xls, export to BD used my script - csv2mysql

In Russian
----------

В своей работе я использую беспланоый софт для мониторинга SAN (Brocade) и СХД - Stor2RRD. 
В дополнении к нему я написал ряд скриптов который производят инвентаризацию SAN и СХД, с дополнением анализа.

Для выполнения анализа приняты следующие условия:
1) Используются алиасы, с указанием ВСЕХ WWN устройства (это облегчает монтаж и способстувет зеркальной конфигурации в фабриках)
2) Имя порта такое же, как алиас
3) Поддержка множества фабрик, разбитых по парам: A-B, C-D и т.д. Это случай сегментированной SAN сети, скажем с использованием LSAN. Анализ выполняется по парам.
4) Соединение со свитчами по SSH, обычно используя логин admin. Если вы используете пару публичный-приватный ключ, можно использовать ключевое слово SSH вместо пароля.
5) Конвертация результатов в формат XLS используя мой скрипт csv2xls с удобным оформлением (заголовок, выравнивание, ширина колонки, перенос слов, селектор на каждой колонке). Экспорт в БД (MySQL) также моим скриптом - csv2mysql, по выбранным полям.
