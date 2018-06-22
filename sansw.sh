#!/bin/bash
#
# Version 4.6, as CSV
#
#
# Usage: sansw.sh
#
# The program inventory Brocade SAN switches and export to CSV file.
# All ports on SAN switch need have name: "PortName" OR "portNN" OR "extNN" OR ""
# Support multi Fabric (A,B,C,D,...)
# Added analitics based on Aliases and Host-to-Host
#
# 06/2018, Alexey Tarasenko, atarasenko@mail.ru
#
# To_Do:
# 1. exclude LSAN from processing, zonename: lsan_NAME
#

Fout="sansw_rep.csv";
FoutXLS="sansw_rep.xls";
Fout2="sansw_rep.txt";
Ftmp="/tmp/sansw_tmp.txt";

if [[ -f $Ftmp ]]; then rm $Ftmp; fi
if [[ -f $Fout ]]; then rm $Fout; fi
if [[ -f $Fout2 ]]; then rm $Fout2; fi
if [[ -f $FoutXLS ]]; then rm $FoutXLS; fi

fab_chars="A B C D E F G H I J K L M N O P Q R S T U V W X Y"

index=0
for i in $fab_chars
do
    if [[ -f "$Ftmp.Fabric_$i.unused" ]]; then rm "$Ftmp.Fabric_$i.unused"; fi
    if [[ -f "$Ftmp.Fabric_$i.wwnali" ]]; then rm "$Ftmp.Fabric_$i.wwnali"; fi
    if [[ -f "$Ftmp.Fabric_$i.wwnname" ]]; then rm "$Ftmp.Fabric_$i.wwnname"; fi
    if [[ -f "$Ftmp.Fabric_$i.portali" ]]; then rm "$Ftmp.Fabric_$i.portali"; fi
    if [[ -f "$Ftmp.Fabric_$i.portname" ]]; then rm "$Ftmp.Fabric_$i.portname"; fi
done  

index=0
while read line; do
    sansw[$index]="$line"
    index=$(($index+1))
done < sansw.lst

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

recomp() {
    local fout="$1"
    local key="$2"
    local index=0
    while read line; do
	arrstr[$index]="$line"
        index=$(($index+1))
    done < $fout

    echo -n "" > $fout

    local buf=""
    local s=""
    local a=0;
    for ((a=0; a < ${#arrstr[*]}; a++))
    do
        s=$( trim "${arrstr[$a]}" )
        if [[ ${s:0:${#key}} == $key ]]
        then
    	    if [[ $buf != ""  ]]; then echo "$buf" | tr ' ' '\t' | tr -s '\t'  >> $fout; fi
    	    buf=$( trim "$s" )
        else
    	    local tmp=( $buf )
    	    if [[ ${#tmp[@]} -gt 2 ]]; then buf="$buf; $s"; else buf="$buf $s"; fi
        fi
    done
    if [[ $buf != ""  ]]; then echo "$buf" | tr ' ' '\t' | tr -s '\t'  >> $fout; fi
    unset arrstr
}

swtype() {
    local var="$*"
    declare -a matrix

    matrix[1]="Brocade 1000"
    matrix[2]="Brocade 2010"
    matrix[3]="Brocade 2400"
    matrix[4]="Brocade 20x0"
    matrix[5]="Brocade 22x0"
    matrix[6]="Brocade 2800"
    matrix[7]="Brocade 2000"
    matrix[9]="Brocade 3800"
    matrix[10]="Brocade 12000"
    matrix[12]="Brocade 3900"
    matrix[16]="Brocade 3200"
    matrix[17]="Brocade 3800VL"
    matrix[18]="Brocade 3000"
    matrix[21]="Brocade 24000"
    matrix[22]="Brocade 3016"
    matrix[26]="Brocade 3850"
    matrix[27]="Brocade 3250"
    matrix[29]="Brocade 4012 Embedded"
    matrix[32]="Brocade 4100"
    matrix[33]="Brocade 3014"
    matrix[34]="Brocade 200E"
    matrix[37]="Brocade 4020 Embedded"
    matrix[38]="Brocade 7420 SAN Router"
    matrix[40]="Brocade FCR Front Domain"
    matrix[41]="Brocade FCR Xlate Domain"
    matrix[42]="Brocade 48000 Director"
    matrix[43]="Brocade 4024 Embedded"
    matrix[44]="Brocade 4900"
    matrix[45]="Brocade 4016 Embedded"
    matrix[46]="Brocade 7500"
    matrix[51]="Brocade 4018 Embedded"
    matrix[55]="Brocade 7600"
    matrix[58]="Brocade 5000"
    matrix[61]="Brocade 4424 Embedded"
    matrix[62]="Brocade DCX Backbone"
    matrix[64]="Brocade 5300"
    matrix[66]="Brocade 5100"
    matrix[67]="Brocade Encryption Switch"
    matrix[69]="Brocade 5410"
    matrix[70]="Brocade 5410 Embedded"
    matrix[71]="Brocade 300"
    matrix[72]="Brocade 5480 Embedded"
    matrix[73]="Brocade 5470 Embedded"
    matrix[75]="Brocade 5424 Embedded"
    matrix[76]="Brocade 8000"
    matrix[77]="Brocade DCX-4S"
    matrix[83]="Brocade 7800"
    matrix[86]="Brocade 5450 Embedded"
    matrix[87]="Brocade 5460 Embedded"
    matrix[90]="Brocade 8470 Embedded"
    matrix[92]="Brocade VA-40FC"
    matrix[95]="Brocade VDX 6720-24 Data Center"
    matrix[96]="Brocade VDX 6730-32 Data Center"
    matrix[97]="Brocade VDX 6720-60 Data Center"
    matrix[98]="Brocade VDX 6730-76 Data Center"
    matrix[108]="Dell M8428-k FCoE Embedded"
    matrix[109]="Brocade 6510"
    matrix[116]="Brocade VDX 6710 Data Center"
    matrix[117]="Brocade 6547 Embedded"
    matrix[118]="Brocade 6505"
    matrix[120]="Brocade DCX8510-8 Backbone"
    matrix[121]="Brocade DCX8510-4 Backbone"
    matrix[133]="Brocade 6520"

    #if [[ ${sw_type:(-2)}==".0" ]]; then sw_type=${sw_type/%".0"/""}; fi
    var=${var%.*}
    
    local res=${matrix[$var]}

    if [[ "$res" == "" ]]
    then     
        echo -n "$var"
    else
        echo -n "$res"
    fi
    
    unset matrix
}


echo "Room,Fabric+,Switch Name+,Domen+,IP,Switch WWN,Model,Firmware,Serial#,Config,Port#+,Port Name,Speed+,Status,State,Type,WWN,WWPN,Alias,Zone,SFP#+,Wave+,Vendor,Serial#,Speed" > $Fout
declare -a Fabric
for ((a=0; a < ${#sansw[*]}; a++))
do
#continue;
    declare -a item="( ${sansw[$a]} )"

    Fname="${item[0]}"
    Fip="${item[1]}"
    Flogin="${item[2]}"
    Fpasswd="${item[3]}"
    Ffab="${item[4]}"
    Froom="${item[5]}"
    
    #Fsnmp="${item[6]}"
    #Flsan="${item[6]}"
    
    #SW-MIB, Brocade-REG-MIB, Brocade-TC, FCMGMT-MIB, FA-EXT-MIB, FIBRE-CHANNEL-FE-MIB
    FcmdSNMP="snmpwalk -v 1 -c public $Fip"

    Fcmd=""
    if [[ "$Fpasswd" == "SSH" ]]
    then 
        Fcmd="ssh -i /home/$Flogin/.ssh/id_rsa -o \"StrictHostKeyChecking no\" $Flogin@$Fip"
    else
	Fcmd="sshpass -p $Fpasswd ssh -o \"StrictHostKeyChecking no\" $Flogin@$Fip"
    fi

    fab_id="${Ffab:(-1)}"
    fab_num=0
    index=0
    for i in $fab_chars
    do
	if [[ "$i" == "$fab_id" ]]
	then
	    fab_num=$index
	    break
	fi
	index=$(($index+1))
    done  
    
    if [[ "${Fabric[$fab_num]}" == "" ]] 
    then 
	if [[ -f "$Ftmp.Fabric_$fab_id" ]]; then rm "$Ftmp.Fabric_$fab_id"; fi
	Fabric[$fab_num]="0"; 
    fi
    
    unuse=""
    if [[ "${Fabric[$fab_num]}" == "0" && "$Ffab" == "Fabric_$fab_id" ]] 
    then 
        echo -n "Processing ZoneShow in $Ffab..."
	Fabric[$fab_num]="1";
	eval "$Fcmd \"zoneshow\" > $Ftmp.Fabric_$fab_id"
	unuse="$Ftmp.Fabric_$fab_id"
	echo " end"
    fi

    if [[ "$unuse" != "" ]] 
    then 
        echo -n "Processing Unused in $Ffab..."
        Fout2F="$unuse.unused"
    
    	#Effective zones (and WWNs)
    	grep -A 5000 "Effective configuration:" "$unuse" | head -n -1 | tail -n +3 > $Ftmp
    	recomp "$Ftmp" "zone:"
	cat "$Ftmp" | tr '\t' ' ' | tr -s ' ' | tr -s ';' | sed -e 's/; /#/g' | tr ' ' '\t' > "$unuse.zone"
    	
	#All zones in configuration (and Aliases)
    	grep -B 5000 "Effective configuration:" "$unuse" | grep -A 5000 "default" | head -n -2 | tail -n +2 > $Ftmp
	echo -n > "$unuse.zone_cfg"
	while read 
	do
	    if [[ "${REPLY:0:7}" != " alias:" ]]; then `echo "$REPLY" >> "$unuse.zone_cfg"`; else break; fi
	done < "$Ftmp"
    	recomp "$unuse.zone_cfg" "zone:"
	cat "$unuse.zone_cfg" | tr '\t' ' ' | tr -s ' ' | tr -s ';' | sed -e 's/; /#/g' | tr ' ' '\t' > "$Ftmp"
	cp "$Ftmp" "$unuse.zone_cfg"

    	#Aliases in configuration
    	grep -A 5000 "alias:" "$unuse" | grep -B 5000 "Effective" | head -n -2 > $Ftmp
    	recomp "$Ftmp" "alias:"
	cat "$Ftmp" | tr '\t' ' ' | tr -s ' ' | tr -s ';' | sed -e 's/; /#/g' | tr ' ' '\t' > "$unuse.alias_cfg"
	#not need sort, switch do it
	#echo -n "" > $Ftmp
	#while read line; do
	#    i=`echo "$line" | cut -f1`; i=$( trim "$i" )
	#    ii=`echo "$line" | cut -f2`; ii=$( trim "$ii" )
	#    iii=`echo "$line" | cut -f3 | tr '#' '\n' | sort`; iii=$( trim "$iii" )
	#    iii=`echo -n "$iii" | tr '\n' '#'`
	#    echo -e "$i\t$ii\t$iii" >> $Ftmp
	#    unset i
	#    unset ii
	#    unset iii
	#done < "$unuse.alias_cfg"
	#rm "$unuse.alias_cfg"; cp $Ftmp "$unuse.alias_cfg"
	
	
	#Unused Zones
	index=0
	while read line; do
	    cfg_lst[$index]=`echo "$line" | cut -f2`
	    index=$(($index+1))
	done < "$unuse.zone_cfg"

	index=0
	while read line; do
	    ef_zone[$index]=`echo "$line" | cut -f2`
	    index=$(($index+1))
	done < "$unuse.zone"
	
	echo "Unused zones" >> $Fout2F
	echo "------------" >> $Fout2F
	
	echo -n "" > $Ftmp
	
	for ((i=0; i < ${#cfg_lst[*]}; i++))
	do
	    unused=1
	    for ((j=0; j < ${#ef_zone[*]}; j++))
	    do
		if [[ $unused -eq 1 && "${cfg_lst[$i]}" == "${ef_zone[$j]}" ]]; then unused=0; fi
	    done
	    if [[ $unused -eq 1 ]]; then echo "${cfg_lst[$i]}" >> "$Ftmp"; fi
	done
	cat "$Ftmp" | sort | uniq >> $Fout2F
	echo "" >> $Fout2F


	#Unused Aliases
	#collect used AliasName in $cfg_lst
	index=0
	while read line; do
	    i=`echo "$line" | cut -f3 | sed -e 's/#/ /g'`
	    declare -a i="( $i )"
	    for ((j=0; j < ${#i[*]}; j++))
	    do
		cfg_lst[$index]="${i[$j]}"
		index=$(($index+1))
	    done
	    unset i
	done < "$unuse.zone_cfg"

	#collect used AliasName by his WWN in $ef_alias
	index=0
	while read line; do
	    i=`echo "$line" | cut -f3 | sed -e 's/#/ /g'`
	    declare -a i="( $i )"
	    for ((j=0; j < ${#i[*]}; j++))
	    do
		#WWN in "${i[$j]}"
		ef_alias[$index]=`grep "${i[$j]}" $unuse.alias_cfg | head -n 1 | cut -f2`
		index=$(($index+1))
	    done
	    unset i
	done < "$unuse.zone"

	
	echo "Unused aliases" >> $Fout2F
	echo "--------------" >> $Fout2F

	echo -n "" > $Ftmp
	
	for ((i=0; i < ${#cfg_lst[*]}; i++))
	do
	    unused=1
	    for ((j=0; j < ${#ef_alias[*]}; j++))
	    do
		if [[ $unused -eq 1 && "${cfg_lst[$i]}" ==  "${ef_alias[$j]}" ]]; then unused=0; fi
	    done
	    if [[ $unused -eq 1 ]]; then echo "${cfg_lst[$i]}" >> "$Ftmp"; fi
	done
	cat "$Ftmp" | sort | uniq >> $Fout2F

	unset cfg_lst
	unset ef_zone
	unset ef_alias
	
	#Need for processing on finish
	#rm "$unuse.zone"
	#rm "$unuse.alias_cfg"
	#rm "$unuse.zone_cfg"

	unuse=""
	echo " end"
    fi
#continue

    eval "$Fcmd \"switchshow\" | head -10 > $Ftmp"
    eval "$Fcmd \"chassisshow\" | grep \"Serial Num:\" | sed 's/^/HW /' >> $Ftmp"
    eval "$Fcmd \"version\" | grep \"Fabric OS:\" >> $Ftmp"

    # ISL array
    eval "$Fcmd \"islshow\" | tr ' ' '\t' | tr -s '\t' > $Ftmp.isl"
    #san01:admin> islshow
    #1: 13->  3 10:00:00:27:f8:be:57:c6   3 san05           sp:  4.000G bw:  4.000G 
    declare -a isl
    # read - delete first and last  spaces and tabs!
    while read line; do
	isl_from=`echo -n "$line" | cut -f2`; isl_from=$( trim "$isl_from" ); isl_from=${isl_from:0:(${#isl_from}-2)}
	isl_to=`echo -n "$line" | cut -f3`; isl_to=$( trim "$isl_to" )
	isl_tosw=`echo -n "$line" | cut -f6`; isl_tosw=$( trim "$isl_tosw" )
	#isl_dom=`echo -n "$line" | cut -f5`; isl_dom=$( trim "$isl_dom" )
	isl[$isl_from]="--> ${isl_tosw} (port${isl_to})"
    done < "$Ftmp.isl"
    
    # SFP array
    eval "$Fcmd \"sfpshow\" | tr ',' '\/' | tr '\t' ' ' | tr -s ' ' > $Ftmp.sfp"
    #san10:admin> sfpshow
    #Port  0: id (sw) Vendor: BROCADE          Serial No: HAA21749100L0P5  Speed: 4,8,16_Gbps
    #Port 12: --
    declare -a sfp
    # read - delete first and last  spaces and tabs!
    while read line; do
	sfp_id=`echo -n "$line" | cut -d: -f1`; sfp_id=${sfp_id:5:${#sfp_id}}; sfp_id=$( trim "$sfp_id" )
	
	sfp_vendor=""
	sfp_sn=""
	sfp_speed=""
	
	sfp_wave=`echo -n "$line" | cut -d: -f2`; sfp_wave=${sfp_wave:1:2}; sfp_wave=$( trim "$sfp_wave" )
	if [[ "$sfp_wave" == "id" ]]
	then
	    sfp_wave=`echo -n "$line" | cut -d: -f2 | cut -d\( -f2 | cut -d\) -f1`; sfp_wave=$( trim "$sfp_wave" )
	    sfp_vendor=`echo -n "$line" | cut -d: -f3`; sfp_vendor=${sfp_vendor:0:(${#sfp_vendor}-9)}; sfp_vendor=$( trim "$sfp_vendor" )
	    sfp_sn=`echo -n "$line" | cut -d: -f4`; sfp_sn=${sfp_sn:0:(${#sfp_sn}-5)}; sfp_sn=$( trim "$sfp_sn" )
	    sfp_speed=`echo -n "$line" | cut -d: -f5`; sfp_speed=$( trim "$sfp_speed" )
	fi
	
	sfp[$sfp_id]="$sfp_wave#$sfp_vendor#$sfp_sn#$sfp_speed"
	#echo "SFP: ${sfp[$sfp_id]}"
    done < "$Ftmp.sfp"
#continue;

    sw_fab="$Ffab"
    sw_room="$Froom"
    sw_name=`grep "switchName:" $Ftmp | cut -d: -f2`; sw_name=$( trim "$sw_name" )
    sw_wwn=`grep "switchWwn:" $Ftmp | sed -e 's/switchWwn:/switchWwn#/g' | cut -d# -f2`; sw_wwn=$( trim "$sw_wwn" )

    part0="$sw_room,$sw_fab,$sw_name"
    echo -n "Processing $part0..."
    
    part1=",,,,,,"
    part2=",,,,,,,,,"
    part3=",,,,"

    sw_dom=`grep "switchDomain:" $Ftmp | cut -d: -f2`; sw_dom=$( trim "$sw_dom" )
    sw_ip="$Fip"
    sw_type=`grep "switchType:" $Ftmp | cut -d: -f2`; sw_type=$( trim "$sw_type" ); sw_type=$( swtype "$sw_type" )
    sw_os=`grep "Fabric OS:" $Ftmp | cut -d: -f2`; sw_os=$( trim "$sw_os" )
    sw_sn=`grep "HW Serial Num:" $Ftmp | cut -d: -f2`; sw_sn=$( trim "$sw_sn" )
    sw_cfg=`grep "zoning:" $Ftmp | cut -d: -f2`; sw_cfg=$( trim "$sw_cfg" )

    echo "$part0,$sw_dom,$sw_ip,$sw_wwn,$sw_type,$sw_os,$sw_sn,$sw_cfg,$part2,$part3" >> $Fout


    eval "$Fcmd \"switchshow\" | grep -A 100 \"=========\" | tail -n +2 > $Ftmp"

    index=0
    while read line; do
	portsw[$index]="$line"
        index=$(($index+1))
    done < $Ftmp
    
    for ((b=0; b < ${#portsw[*]}; b++))
    do
	p_num="$b"
        
        eval "$Fcmd \"portshow $p_num\" > $Ftmp"
        #as key: value
        p_name=`grep "portName:" $Ftmp | cut -d: -f2`; p_name=$( trim "$p_name" )
	if [[ "$p_name" == "" ]]; then p_name="port${p_num}"; fi
        p_speed=`grep "portSpeed:" $Ftmp | cut -d: -f2`; p_speed=$( trim "$p_speed" )
        p_speed=${p_speed//"Gbps"/""}
        p_wwn=`grep "portWwn:" $Ftmp | sed -e 's/portWwn:/portWwn#/g' | cut -d# -f2`; p_wwn=$( trim "$p_wwn" )
        #with digit code of value
        p_state=`grep "portState:" $Ftmp | tr ' ' '\t' | tr -s '\t' | cut -f3`; p_state=$( trim "$p_state" )
        #may be into one or two strings
        p_phys=`grep "portPhys:" $Ftmp | tr ' ' '\t' | tr -s '\t' | cut -f3`; p_phys=$( trim "$p_phys" )
        p_scn=`grep "portScn:" $Ftmp | cut -d: -f1`; p_scn=$( trim "$p_scn" )
            if [[ "$p_scn" == "portPhys" ]]
	    then p_scn=`grep "portScn:" $Ftmp | tr ' ' '\t' | tr -s '\t' | cut -f6`; p_scn=$( trim "$p_scn" );
    	    else p_scn=`grep "portScn:" $Ftmp | tr ' ' '\t' | tr -s '\t' | cut -f3`; p_scn=$( trim "$p_scn" );
            fi
        #two strings parse
        p_wwnd=`grep -A 1 "portWwn of" $Ftmp | tail -1`; p_wwnd=$( trim "$p_wwnd" )
	#search alias and zone for device WWN
	p_ali=""
	p_zone=""
	if [[ "$p_wwnd" != "" ]]
	then
	    Fali="$Ftmp.Fabric_$fab_id"
    	    
    	    #Aliases
    	    grep -A 1000 "alias:" "$Fali" | grep -B 1000 "Effective" | head -n -2 > $Ftmp
    	    recomp "$Ftmp" "alias:"
    	    #if [[ "$p_num" == "8" ]]; then cat $Ftmp > "ali_test.log"; fi
    	    #if [[ "$p_num" == "8" ]]; then echo "Search : [$p_wwnd]" >> "ali_test.log"; fi
    	    #If multiline (1..2) source
    	    #p_ali=`grep "$p_wwnd" "$Ftmp" | cut -f2`; p_ali=$( trim "$p_ali" )
	    #if [[ "$p_ali" == "" ]]; then p_ali=`grep -B 1 "$p_wwnd" "$Ftmp" | head -1 | cut -f2`; p_ali=$( trim "$p_ali" ); fi
	    #If use recomp function
    	    p_ali=`grep "$p_wwnd" "$Ftmp" | cut -f2 | tr '\n' ';'` 
    	    if [[ ${p_ali:(-1)} == ";" ]]; then p_ali=${p_ali:0:(${#p_ali}-1)}; fi 
    	    p_ali=${p_ali//";"/"; "}
    	    #if [[ "$p_num" == "8" ]]; then echo "Searched : [$p_ali]" >> "ali_test.log"; fi

    	    #Zonnes
	    grep -A 1000 "Effective configuration:" "$Fali" | head -n -1 | tail -n +3 > $Ftmp
    	    recomp "$Ftmp" "zone:"
    	    p_zone=`grep "$p_wwnd" "$Ftmp" | cut -f2 | tr '\n' ';'`
    	    if [[ ${p_zone:(-1)} == ";" ]]; then p_zone=${p_zone:0:(${#p_zone}-1)}; fi 
    	    p_zone=${p_zone//";"/"; "}
	fi

	#check WWN without...
	if [[ "$p_wwnd" != "" ]]
	then
	    #	    
	    echo "$part0,port${p_num},wwn: ${p_wwnd}" >> "$Ftmp.Fabric_$fab_id.port_cfg"
	    
	    # Alias
	    if [[ "$p_ali" == "" ]]
	    then 
		echo "$part0,port${p_num},wwn: $p_wwnd,name: $p_name">> "$Ftmp.$Ffab.wwnali"
	    fi
	    # PortName
	    if [[ "$p_name" == "" ]] || [[ "$p_name" == "port${p_num}" ]] || [[ "$p_name" == "ext${p_num}" ]]
	    then 
		echo "$part0,port${p_num},wwn: $p_wwnd,alias: $p_ali">> "$Ftmp.$Ffab.wwnname"
	    fi

	    # PortName not equal Alias
	    if [[ "$p_ali" != "" ]] && [[ "$p_name" != "" ]] && [[ "$p_name" != "port${p_num}" ]] && [[ "$p_name" != "ext${p_num}" ]]
	    then 
		if [[ "$p_name" != "$p_ali" ]]; then echo "$part0,port${p_num},wwn: $p_wwnd,name: $p_name,alias: $p_ali">> "$Ftmp.$Ffab.portali"; fi
	    fi
	fi

	# if ISL port, set WWND as ISL description
	if [[ "${isl[$p_num]}" != "" ]] && [[ "$p_wwnd" == "" ]]; then p_wwnd="${isl[$p_num]}"; fi
	
	#check PortName without...
	if [[ "$p_wwnd" == "" ]]
	then
	    # WWN
	    if [[ "$p_name" != "port${p_num}" ]] && [[ "$p_name" != "ext${p_num}" ]]
	    then 
		echo "$part0,port${p_num},name: $p_name">> "$Ftmp.$Ffab.portname"
	    fi
	fi

	sfp_num="$b"
	sfp_wave=`echo "${sfp[$p_num]}" | cut -d# -f1`
	sfp_vendor=`echo "${sfp[$p_num]}" | cut -d# -f2`
	sfp_sn=`echo "${sfp[$p_num]}" | cut -d# -f3`
	sfp_speed=`echo "${sfp[$p_num]}" | cut -d# -f4`
	
	echo "$part0,$part1,$p_num,$p_name,$p_speed,$p_state,$p_phys,$p_scn,$p_wwn,$p_wwnd,$p_ali,$p_zone,$sfp_num,$sfp_wave,$sfp_vendor,$sfp_sn,$sfp_speed" >> $Fout
    done
    unset isl
    unset sfp
    unset portsw

    echo " end"
done        
unset sansw
unset Fabric


echo "" > $Fout2
index=0
for i in $fab_chars
do
    if [[ -f $Ftmp ]]; then rm $Ftmp; fi
    
    if [[ -f "$Ftmp.Fabric_$i.unused" ]]
    then
	cat "$Ftmp.Fabric_$i.unused" >> $Ftmp
	echo "" >> $Ftmp
	rm "$Ftmp.Fabric_$i.unused"
    fi

    if [[ -f "$Ftmp.Fabric_$i.wwnali" ]]
    then
	echo "WWN without Alias" >> $Ftmp
	echo "-----------------" >> $Ftmp
	cat "$Ftmp.Fabric_$i.wwnali" >> $Ftmp
	echo "" >> $Ftmp
	rm "$Ftmp.Fabric_$i.wwnali"
    fi

    if [[ -f "$Ftmp.Fabric_$i.wwnname" ]]
    then
	echo "WWN without PortName" >> $Ftmp
	echo "--------------------" >> $Ftmp
	cat "$Ftmp.Fabric_$i.wwnname" >> $Ftmp
	echo "" >> $Ftmp
	rm "$Ftmp.Fabric_$i.wwnname"
    fi

    if [[ -f "$Ftmp.Fabric_$i.portname" ]]
    then
	echo "PortName without WWN" >> $Ftmp
	echo "--------------------" >> $Ftmp
	cat "$Ftmp.Fabric_$i.portname" >> $Ftmp
	echo "" >> $Ftmp
	rm "$Ftmp.Fabric_$i.portname"
    fi

    if [[ -f "$Ftmp.Fabric_$i.portali" ]]
    then
	echo "PortName not equal Alias" >> $Ftmp
	echo "------------------------" >> $Ftmp
	cat "$Ftmp.Fabric_$i.portali" >> $Ftmp
	echo "" >> $Ftmp
	rm "$Ftmp.Fabric_$i.portali"
    fi

    if [[ -f "$Ftmp.Fabric_$i.zone_cfg" ]] && [[ -f "$Ftmp.Fabric_$i.zone" ]]
    then 
	echo -n "" > "$Ftmp.A"
	
	index=0
	while read line; do
	    zone=`echo "$line" | cut -f2`; zone=$( trim "$zone" )
	    x=`echo "$line" | cut -f3 | sed -e 's/#/\n/g' | wc -l`
	    if [[ $x -gt 2 ]]
	    then
		# check in effective configuration
		y=`grep "$zone" "$Ftmp.Fabric_$i.zone" | wc -l`
		if [[ $y -eq 0 ]]
		then
		    echo "$x: $zone" >> "$Ftmp.A"
		else
		    echo "$x*: $zone" >> "$Ftmp.A"
		fi
	    fi
	done < "$Ftmp.Fabric_$i.zone_cfg"

	x=`cat "$Ftmp.A" | wc -l`
	if [[ $x -gt 0 ]]
	then 
	    echo "Zones contain more 2 Aliases (* effective)" >> $Ftmp
	    echo "------------------------------------------" >> $Ftmp
	    cat "$Ftmp.A" >> $Ftmp
	    echo "" >> $Ftmp
	fi
	
	rm "$Ftmp.A"
    fi

    charnum=$( printf "%d" "'${i}" )
    let chet=$charnum%2
    if [[ $chet == 1 ]]
    then
	ii=$( printf "%b" "$( printf "\%03o" "$((charnum+1))" )" )
	
	if [[ -f "$Ftmp.Fabric_$i.alias_cfg" ]] && [[ -f "$Ftmp.Fabric_$ii.alias_cfg" ]]
	then 
	    sed 's/#/; /g' < "$Ftmp.Fabric_$i.alias_cfg"  > "$Ftmp.A"
	    sed 's/#/; /g' < "$Ftmp.Fabric_$ii.alias_cfg" > "$Ftmp.B"
	    diff "$Ftmp.A" "$Ftmp.B" > "$Ftmp.C"
	    lines=$( cat "$Ftmp.C" | wc -l )
	    if [[ "$lines" != "0" ]]
	    then
		echo "Diff all Aliases in Fabric_$i and Fabric_$ii" >> $Ftmp
		echo "-----------------------------------------" >> $Ftmp
		cat "$Ftmp.C" >> $Ftmp
		echo "" >> $Ftmp
	    fi
	fi
	
	if [[ -f "$Ftmp.Fabric_$i.zone_cfg" ]] && [[ -f "$Ftmp.Fabric_$ii.zone_cfg" ]]
	then 
	    sed 's/#/; /g' < "$Ftmp.Fabric_$i.zone_cfg"  > "$Ftmp.A"
	    sed 's/#/; /g' < "$Ftmp.Fabric_$ii.zone_cfg" > "$Ftmp.B"
	    diff "$Ftmp.A" "$Ftmp.B" > "$Ftmp.C"
	    lines=$( cat "$Ftmp.C" | wc -l )
	    if [[ "$lines" != "0" ]]
	    then
		echo "Diff all Zones in Fabric_$i and Fabric_$ii" >> $Ftmp
		echo "---------------------------------------" >> $Ftmp
		cat "$Ftmp.C" >> $Ftmp
		echo "" >> $Ftmp
	    fi
	fi
	
	if [[ -f "$Ftmp.Fabric_$i.zone_cfg" ]] && [[ -f "$Ftmp.Fabric_$ii.zone_cfg" ]]
	then 
	    sed 's/#/; /g' < "$Ftmp.Fabric_$i.zone"  > "$Ftmp.A"
	    sed 's/#/; /g' < "$Ftmp.Fabric_$ii.zone" > "$Ftmp.B"
	    diff "$Ftmp.A" "$Ftmp.B" > "$Ftmp.C"
	    lines=$( cat "$Ftmp.C" | wc -l )
	    if [[ "$lines" != "0" ]]
	    then
		echo "Diff effective Zones in Fabric_$i and Fabric_$ii" >> $Ftmp
		echo "---------------------------------------------" >> $Ftmp
		cat "$Ftmp.C" >> $Ftmp
		echo "" >> $Ftmp
	    fi
	fi
	
	if [[ -f "$Ftmp.A" ]]; then rm "$Ftmp.A"; fi
	if [[ -f "$Ftmp.B" ]]; then rm "$Ftmp.B"; fi
	if [[ -f "$Ftmp.C" ]]; then rm "$Ftmp.C"; fi
	
	unset ii
    fi

    if [[ -f "$Ftmp.Fabric_$i.port_cfg" ]] && [[ -f "$Ftmp.Fabric_$i.alias_cfg" ]]
    then 
	echo "Online WWN in Alias" >> $Ftmp
	echo "-------------------" >> $Ftmp

	echo -n > "$Ftmp.Fabric_$i.alias"
	
	while read line; do
	    x=`echo "$line" | cut -f2`; x=$( trim "$x" )
	    x="alias: $x"
	    xl=${#x}
	    if [[ $xl -lt 40 ]]; then x="${x}\t"; fi
	    if [[ $xl -lt 32 ]]; then x="${x}\t"; fi
	    if [[ $xl -lt 24 ]]; then x="${x}\t"; fi
	    if [[ $xl -lt 16 ]]; then x="${x}\t"; fi
	    if [[ $xl -lt 8  ]]; then x="${x}\t"; fi
	    ii=`echo "$line" | cut -f3 | tr '#' '\n' | sort | tr '\n' ' '`; ii=$( trim "$ii" )
	    declare -a ii="( $ii )"
	    for ((j=0; j < ${#ii[*]}; j++))
	    do
		#WWN in "${ii[$j]}"
		iw=$( trim "${ii[$j]}" )
		ic=`cat "$Ftmp.Fabric_$i.port_cfg" | grep "${ii[$j]}" | wc -l`
		if [[ $ic -eq 0 ]]
		then
		    x="$x  $iw  "
    		else
		    x="$x =$iw= "
    		fi
		unset iw
		unset ic
	    done
	    echo -e "${x}" >> "$Ftmp.Fabric_$i.alias"
	    unset x
	    unset xl
	    unset ii
	done < "$Ftmp.Fabric_$i.alias_cfg"
	
	cat "$Ftmp.Fabric_$i.alias" >> $Ftmp
	rm "$Ftmp.Fabric_$i.alias"
	echo "" >> $Ftmp
    fi
    
    if [[ -f "$Ftmp.Fabric_$i.zone" ]]; then rm "$Ftmp.Fabric_$i.zone"; fi
    if [[ -f "$Ftmp.Fabric_$i.alias_cfg" ]]; then rm "$Ftmp.Fabric_$i.alias_cfg"; fi
    if [[ -f "$Ftmp.Fabric_$i.zone_cfg" ]]; then rm "$Ftmp.Fabric_$i.zone_cfg"; fi
    if [[ -f "$Ftmp.Fabric_$i.port_cfg" ]]; then rm "$Ftmp.Fabric_$i.port_cfg"; fi

    if [[ -f $Ftmp ]]
    then 
	echo "Check Fabric_$i" >> $Fout2
	echo "==============" >> $Fout2
	echo "" >> $Fout2
	cat $Ftmp >> $Fout2
	echo "" >> $Fout2
	echo "" >> $Fout2
    fi

    index=$((index+1))
done  

for i in $fab_chars
do
    if [[ -f "$Ftmp.Fabric_$i" ]]
    then
	echo "Config of Fabric_$i" >> $Fout2
	echo "==================" >> $Fout2
	cat "$Ftmp.Fabric_$i" >> $Fout2
	echo "" >> $Fout2
	echo "" >> $Fout2
	echo "" >> $Fout2
	rm "$Ftmp.Fabric_$i"
    fi
done  

if [[ -f "../csv2xls/csv2xls.pl" ]]
then
    echo -n "Converting report file CSV to XLS..."
    eval "../csv2xls/csv2xls.pl $Fout $FoutXLS"
    echo " end"
fi

#if [[ -f "../smb/smbupload.sh" ]]
#then
#    echo "Upload to Inventory share.."
#    eval "../smb/smbupload.sh sansw $Fout $FoutXLS $Fout2"
#    echo "..end"
#fi

if [[ -f "../csv2mysql/csv2mysql.sh" ]]
then
    echo "Upload to MySQL base.."
    eval "../csv2mysql/csv2mysql.pl sansw_rep.csv san \"Switch Name+,Port#+,WWN,Wave+,Speed,WWNP,Alias\" \"swname,pnum,wwn,wave,speed,wwnp,host\""
    echo "..end"
fi

if [[ -f $Ftmp ]]; then rm $Ftmp; fi
if [[ -f "$Ftmp.sfp" ]]; then rm "$Ftmp.sfp"; fi
if [[ -f "$Ftmp.isl" ]]; then rm "$Ftmp.isl"; fi
