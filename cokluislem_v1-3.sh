#!/bin/bash
#=========================================================================================================
# Baslik:           cokluislem.sh
# Kullanim:         ./cokluislem.sh
# Amaci:            Daha onceden hazirlanan scriptlerin bir menu altindan erisimini kolaylastirmak.
# Sahibi:           Feridun OZTOK
# Versiyon:         1.3
# Tarih:            01 Ocak 2022
#=========================================================================================================

echo ""

#====================================================================================================
#  Version Function
#====================================================================================================
show_version_info()
{
	echo ""
	echo "Script Versiyon: 1.3"  
	echo "Script Tarihi  : 01 Ocak 2021"  
	echo "Son Guncelleyen: Feridun OZTOK"
	echo ""
	exit 0
}


#====================================================================================================
#  Help Function
#====================================================================================================
show_help_info()
{
    echo ""
    echo "Bu script, Egis Bilisim olarak en cok kullandigimiz diger scriptleri"
	echo "Egis sunucularindan indirip hizlica calistirmak icin yapilmistir."
	echo ""
	echo "Scipt ./cokluislem.sh seklinde calisir. Kullanilabilir diğer parametreler -v -u -h 'dir"
	echo ""
	echo "./cokluislem.sh -v ile mecvut scriptin surumunu ogrenebilirsiniz."
	echo "./cokluislem.sh -u ile script surumunu guncelleyebilirsiniz."
	echo "./cokluislem.sh -h ve diger tum tuslar su an okudugunuz yardim menusunu getirecektir."
	echo ""
	exit 0
}


#====================================================================================================
#  Script Update
#====================================================================================================
check_updates()
{
	rm cokluislem.sh
	curl_cli http://www.egisbilisim.com.tr/script/cokluislem.sh | cat > cokluislem.sh && chmod 770 cokluislem.sh
	exit 0
}

#====================================================================================================
# Fonksiyon Tuslari
#====================================================================================================
while getopts ":v :u :h" opt; do
    case "${opt}" in
       
        h)
            show_help_info
            ;;
        u)
			check_updates
            ;;
        v)
            show_version_info
            ;;
        *)
            #Catch all for any other flags
            show_help_info
            exit 1
            ;;
    esac
done


#Echo Reklam
#=========================================================================================================
echo 
echo
echo *#######################################################*
echo *#_______________ Menu ile kolay secim _______________##*
echo *#____________________ Version 1.3 ___________________##*
echo *#___________________ Feridun OZTOK __________________##*
echo *#_ Egis Proje ve Danismanlik Bilisim Hiz. Ltd. Sti. _##*
echo *#____________ destek@egisbilisim.com.tr _____________##* 
echo *#######################################################*
echo 
#=========================================================================================================


if [ -d /var/log/egis ]
	then
	cd /var/log/egis
	echo "Biz hep buradaydik :)"
    else
	mkdir /var/log/egis
	echo "Egis artik burada"
	cp cokluislem.sh /var/log/egis/cokluislem.sh
	cd /var/log/egis
fi

PS3='Yapilacak islemi secin: '
options=("Drop Broadcast" "Drop Multicast" "Drop WUDO" "FTP Backup" "Dynamic Block" "Health Check" "CCC" "Cikis")
select opt in "${options[@]}"
do
    case $opt in
        "Drop Broadcast")
			if [ -f broadcast.sh ]
				then
					rm broadcast.sh
					curl_cli http://www.egisbilisim.com.tr/script/broadcast.sh | cat > broadcast.sh && chmod 770 broadcast.sh
					./broadcast.sh
				else
					curl_cli http://www.egisbilisim.com.tr/script/broadcast.sh | cat > broadcast.sh && chmod 770 broadcast.sh
					./broadcast.sh
			fi
            ;;
        "Drop Multicast")
			if [ -f multicast.sh ]
				then
					rm multicast.sh
					curl_cli http://www.egisbilisim.com.tr/script/multicast.sh | cat > multicast.sh && chmod 770 multicast.sh
					./multicast.sh
				else
					curl_cli http://www.egisbilisim.com.tr/script/multicast.sh | cat > multicast.sh && chmod 770 multicast.sh
					./multicast.sh
			fi
            ;;
        "Drop WUDO")
			if [ -f wudo.sh ]
				then
					rm wudo.sh
					curl_cli http://www.egisbilisim.com.tr/script/wudo.sh | cat > wudo.sh && chmod 770 wudo.sh
					./wudo.sh
				else
					curl_cli http://www.egisbilisim.com.tr/script/wudo.sh | cat > wudo.sh && chmod 770 wudo.sh
					./wudo.sh
			fi
            ;;
		"FTP Backup")
			if [ -f cron_yedek.sh ]
				then
					rm cron_yedek.sh
					curl_cli http://www.egisbilisim.com.tr/script/cron_yedek.sh | cat > cron_yedek.sh && chmod 770 cron_yedek.sh
					crontab -u scpadmin -l
				else
					curl_cli http://www.egisbilisim.com.tr/script/cron_yedek.sh | cat > cron_yedek.sh && chmod 770 cron_yedek.sh
					mkdir /var/log/egis/upgrade_tools
					cp $FWDIR/bin/upgrade_tools/* /var/log/egis/upgrade_tools/
					cd /var/log/egis
					if [ -f database.txt ]
						then
							echo "#####Degisken Degiskenler" >> database.txt
							echo "SMTP_SERVER=" >> database.txt
							echo "MAIL_SENDER=" >> database.txt
							echo "USER=" >> database.txt
							echo "PASSWD=" >> database.txt
							echo "MAIL_RECEIVER=" >> database.txt
							echo "HOST=corvus.egisbilisim.com.tr" >> database.txt
							echo "GATEWAY1=" >> database.txt
							echo "GATEWAY2=" >> database.txt
							echo "GATEWAY3=" >> database.txt
							echo "GATEWAY4=" >> database.txt
							echo "HOST2=" >> database.txt
							echo "USER2=" >> database.txt
							echo "PASSWD2=" >> database.txt
						else
							echo "database.txt mevcut. Degisiklik yapilmiyor."
					fi	
					crontab -u scpadmin -l > crontab.txt
					SATIR=`wc -l crontab.txt | awk '{ print $1 }'`
					if [ $SATIR != 0 ] 
						then
							echo "Crontab daha once yapilandirilmis."
							rm crontab.txt
						else
							echo ""
							echo "#  This file was AUTOMATICALLY GENERATED"
							echo "#  Generated by /bin/cron_xlate on Wed Jan 14 13:33:33 2015"
							echo "#"
							echo "#  DO NOT EDIT"
							echo "#"
							echo "SHELL=/bin/bash"
							echo "MAILTO="""
							echo "#"
							echo "# mins  hrs     daysinm months  daysinw command"
							echo "#"
							echo "30 4 * * 6 /var/log/egis/cron_yedek.sh > /var/log/egis/cron_durum.txt"
							echo ""
							rm crontab.txt
					fi
			fi
			
            ;;
		"Dynamic Block")
			if [ -f opendbl.sh ]
				then
					rm opendbl.sh
					curl_cli http://www.egisbilisim.com.tr/script/opendbl.sh | cat > opendbl.sh && chmod 770 opendbl.sh
					./opendbl.sh
				else
					curl_cli http://www.egisbilisim.com.tr/script/opendbl.sh | cat > opendbl.sh && chmod 770 opendbl.sh
					./opendbl.sh
			fi
            ;;
		"Health Check")
			if [ -f healthcheck.sh ]
				then
					rm healthcheck.sh
					curl_cli http://www.egisbilisim.com.tr/script/healthcheck.sh | cat > healthcheck.sh && chmod 770 healthcheck.sh
					./healthcheck.sh
				else
					curl_cli http://www.egisbilisim.com.tr/script/healthcheck.sh | cat > healthcheck.sh && chmod 770 healthcheck.sh
					./healthcheck.sh
			fi
            ;;
		"CCC")
			curl_cli $(if [[ `grep proxy:ip /config/active` ]]; then echo -n '--proxy '; grep proxy:ip /config/active|cut -f2 -d' '|tr -d '\n'; echo -n :; grep proxy:port /config/active|cut -f2 -d' '; fi) -k https://dannyjung.de/ccc|zcat > /usr/bin/ccc && chmod +x /usr/bin/ccc; . ~/.bashrc
			echo ""
			echo "ccc komutu ile Common Check Point Commands menusune ulasabilirsiniz."
			echo "cokluislem menusunden cikiliyor..."
			exit 0
			;;
        "Cikis")
			echo ""
			echo "Cikis yapliyor..."
			echo ""
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done



#Chance Log
#=========================================================================================================
# 1.3 Crontab kontrol ve oneri eklendi.
# 1.2 FTP Backup icin database.txt dosyasi olusturulmaya baslandi.
# 1.1 Funtion tuslari eklendi.
# 1.0 Drop Broadcast menuye eklendi.
# 1.0 Drop Multicast menuye eklendi.
# 1.0 Drop WUDO menuye eklendi.
# 1.0 Health Check menuye eklendi.
# 1.0 Dynamic Block menuye eklendi.
# 1.0 FTP Backup menuye eklendi.
# 1.0 Common Check Point Commands menuye eklendi.