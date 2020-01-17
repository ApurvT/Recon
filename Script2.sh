#!/bin/bash

#Get  the  ip addresses


#To make directory with Every IP name



#Nmap Scan on IP Address
function nmap_scan(){

	cd /root/Desktop/Script/$1
	nmap -sV -sC -o nmap.txt $1 > /dev/null 
	nmap -p- -sV -o allports.txt $1 > /dev/null &
	echo "==============Done Nmap Scan and saved in $1/nmap.txt=================="
}

#Nikto Scan if port 80 is running
function nikto_scan(){
	cd /root/Desktop/Script/$1
	CHECK_80=$(cat nmap.txt | grep 80/tcp | wc -l) 
	echo $CHECK_80
	if (( $CHECK_80 > 0 )); then
		nikto -h $1 -o nikto.txt > /dev/null &  
		echo "==============Done NIKTO Scanning=================="
		http_enum $1 &
		gobuster $1 &
		
	fi

}

#If port 80/443 running, do buster
function gobuster(){

	cd /root/Desktop/Script/$1
	CHECK_443=$(cat nmap.txt | grep 443/tcp | wc -l)
	echo $CHECK_443."a"
	python3 /root/Github_Repo/dirsearch/dirsearch.py -u http://$1 -w /usr/share/wordlists/dirb/common.txt -e aspx,html,php,json > dirsearch.txt &
	echo "===================Done GOBUSTER==========================="
	#if (( $CHECK_443 > 0 )); then
	#echo gobuster -u http://10.10.10.101:443 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o gobuster2.txt -t 50  
	#fi
	}
#If port 139,445 is running, then do enum4linux and smbmap

function smb_check(){
	
	cd /root/Desktop/Script/$1
	CHECK_SMB=$(cat nmap.txt | grep smb | wc -l)
	echo $CHECK_SMB."1"
	if (( $CHECK_SMB > 0 )); then
		enum4linux $1 > enum4linux.txt 
		smbmap -H $1 > smbmap.txt 
		smb_nmap $1 
	echo "===================SMB TESTING... DONE======================="
	fi

}

#If port 21 is running, Ftp Enumeration using nmap
function ftp_enum(){
	
	cd /root/Desktop/Script/$1
	FTP_CHECK=$(cat nmap.txt | grep 21/tcp | wc -l)
	echo $FTP_CHECK."2"
	if (( $FTP_CHECK > 0 )); then
	nmap -sV -p21 --script ftp-* -o ftp_nmap.txt $1 > /dev/null 
	echo "======================DONE FTP ENUMERATION========================="
	fi

}
#If port 25 or smtp is running , SMTP Enumeration using nmap
function smtp_enum(){
	
	cd /root/Desktop/Script/$1
	SMTP_CHECK=$(cat nmap.txt | grep smtp | wc -l)
	echo $SMTP_CHECK."3"
	if (( $SMTP_CHECK > 0 )); then
	nmap -sV -p25 --script smtp-* -o smtp_nmap.txt $1 > /dev/null 
	echo "==================SMTP_ENUMERATION DONE....=================="
       	fi	

}

#SMB ENUM using nmap

function smb_nmap(){
	
	cd /root/Desktop/Script/$1
	SMB_CHECK=$(cat nmap.txt | grep smb | wc -l)
	if (( $SMB_CHECK > 0 )); then
	nmap -sV -p139,445 --script smb-* -o smb_nmap.txt $1 > /dev/null 
	echo "=================SMB_NMAP done======================="
       	fi	

}

function http_enum(){
	
	cd /root/Desktop/Script/$1
	nmap -sV -p80 --script http-* -o http_nmap.txt $1  > /dev/null &
	echo "============CHECK http_nmap.txt for HTTPENUM DETAILS==================="

}
#make directory and call nmap_scan
function make_dir(){
	
	mkdir /root/Desktop/Script/$1
	cd /root/Desktop/Script/$1
	echo "Done making Directory"


}

for IP
do
cd /root/Desktop/Script
make_dir $IP
nmap_scan $IP
nikto_scan $IP
smtp_enum $IP
smb_check $IP
ftp_enum $IP
done
