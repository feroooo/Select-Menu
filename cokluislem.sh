#!/bin/bash
#====================================================================================================
# Baslik:           cokluislem.sh
# Kullanim:         ./cokluislem.sh
# Amaci:            Daha onceden hazirlanan scriptlerin bir menu altindan erisimini kolaylastirmak.
# Sahibi:           Feridun OZTOK
# Versiyon:         2.4
# Tarih:            27 Eylul 2022
#====================================================================================================

echo ""
#====================================================================================================
# Degiskenler
#====================================================================================================
source /etc/profile.d/CP.sh
GAIAPORT=4434
DIZIN=/var/log/egis
MEVCUTSURUM="Script Versiyon: 2.4"

#====================================================================================================
#  Versiyon Function
#====================================================================================================
show_version_info()
{
	echo ""
	echo "Script Versiyon: 2.4"  
	echo "Script Tarihi  : 27 Eylul 2022"  
	echo "Son Guncelleyen: Feridun OZTOK"
	echo ""
	exit 0
}

#====================================================================================================
#  Otomatik Versiyon Kontrol
#====================================================================================================
versiyon_kontrol()
{
	curl_cli http://dynamic.egisbilisim.com.tr/script/cokluislem.sh | grep "MEVCUTSURUM" > surumyakala.txt
	sed '2,$d' surumyakala.txt > surumazalt.txt
	awk -F"MEVCUTSURUM="  '{print $2}' surumazalt.txt > surumkisa.txt
	sed 's/"//g' surumkisa.txt > surumtemizlenmis.txt
	GUNCELSURUM=$(<surumtemizlenmis.txt)
	rm surum*
	if [[ "$MEVCUTSURUM" == "$GUNCELSURUM" ]]
		then
			clear
			echo ""
			echo "Guncel surum kullaniliyor."
		else
			clear
			echo ""
			echo "Kullanilan surum guncel degil. Surumun $GUNCELSURUM olmasi gerekiyor."
	fi		
}

#====================================================================================================
#  Dizin Kontrol
#====================================================================================================
dizin_kontrol()
{
if [ -d $DIZIN ]
	then
	cd $DIZIN
		if [ -f cokluislem.sh ]
			then
				echo ""
			else
				cp /home/admin/cokluislem.sh $DIZIN/cokluislem.sh
		fi
    else
	mkdir $DIZIN
	cp cokluislem.sh $DIZIN/cokluislem.sh
	cd $DIZIN
fi
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
	echo "Script management server uzerinde calistirilmalidir."
	echo "Management GAIA port'u 4434 olarak varsayilan kabul edilmistir."
	echo "GAIA port'u fakliysa degisiklik yapmaniz gerekmektedir."
	echo ""
	echo "Script ./cokluislem.sh seklinde calisir. Kullanilabilir diger parametreler -v -u -h 'dir"
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
	curl_cli http://dynamic.egisbilisim.com.tr/script/cokluislem.sh | cat > cokluislem.sh && chmod 770 cokluislem.sh
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

versiyon_kontrol

dizin_kontrol


#====================================================================================================
#Echo Reklam
#========================================================================================================= 
echo *#######################################################*
echo *#_______________ Menu ile kolay secim _______________##*
echo *#____________________ Version 2.4 ___________________##*
echo *#___________________ Feridun OZTOK __________________##*
echo *#_ Egis Proje ve Danismanlik Bilisim Hiz. Ltd. Sti. _##*
echo *#____________ destek@egisbilisim.com.tr _____________##* 
echo *#######################################################*
echo 
#=========================================================================================================

layer_getir()
{
if [ -f layer* ]
	then
		rm layer*
		mgmt_cli show access-layers -r true --port $GAIAPORT > layer.txt
		awk -F"name:"  '{print $2}' layer.txt > layer_name.txt
		sed 's/"//' layer_name.txt > layer_tirnaksiz.txt
		sed 's/^.//' layer_tirnaksiz.txt > layer_bosluksuz.txt
		grep "\S" layer_bosluksuz.txt > layer_azaltilmis.txt
		grep Network layer_azaltilmis.txt > layer_son.txt
		cat layer_son.txt | tr -d '\r\n' > layer_online.txt
	else
		mgmt_cli show access-layers -r true --port $GAIAPORT > layer.txt
		awk -F"name:"  '{print $2}' layer.txt > layer_name.txt
		sed 's/"//' layer_name.txt > layer_tirnaksiz.txt
		sed 's/^.//' layer_tirnaksiz.txt > layer_bosluksuz.txt
		grep "\S" layer_bosluksuz.txt > layer_azaltilmis.txt
		grep Network layer_azaltilmis.txt > layer_son.txt
		cat layer_son.txt | tr -d '\r\n' > layer_online.txt
	fi	
	

IFS='"'
options=($(cat layer_online.txt))

PS3="Kural yazilacak layer'i secin: "
select opt in "${options[@]}" "Quit" ; do
   if (( REPLY == 1 + ${#options[@]} )) ; then
		rm layer*
		PS3='Yapilacak islemi secin: '
        exit

  elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo "Kural olusturulmasi icin secilen Layer: $opt"
        LAYER=$opt
		rm layer*
		PS3='Yapilacak islemi secin: '
		break
    else
        echo "Gecersiz secim."
    fi
done

}




drop_broadcast ()
{
read -p "Gateway IP Address: " GW
#read -p "Management Server GAIA Port: " GAIAPORT

#g_bash kontrol
#=========================================================================================================
if [ -f $DIZIN/g_bash ]
then
	chmod 770 $DIZIN/g_bash
else
	echo 'HAtest="$2 $3 $4 $5 $6 $7 $8 $9"' > $DIZIN/g_bash 
	echo "echo \$HAtest > /var/log/g_command.txt"  >> $DIZIN/g_bash
	echo "\$CPDIR/bin/cprid_util -server \$1 putfile -local_file /var/log/g_command.txt -remote_file /var/log/g_command.txt" >> $DIZIN/g_bash
	echo "\$CPDIR/bin/cprid_util -server \$1 -verbose rexec -rcmd /bin/bash -f /var/log/g_command.txt" >> $DIZIN/g_bash
	chmod 770 $DIZIN/g_bash
fi
#=========================================================================================================


#IP adreslerinin gateway uzerinden cekilip parse edilmesi
#=========================================================================================================
echo
echo "Broadcast adresleri gateway uzerinden ogreniliyor..."
$DIZIN/g_bash $GW ifconfig | grep Bcast > $DIZIN/ifconfig
awk '{print $3;}' $DIZIN/ifconfig > $DIZIN/ifconfig_name
awk -F":"  '{print $2}' $DIZIN/ifconfig_name > $DIZIN/ifconfig_ip
#=========================================================================================================


SATIR=`grep -o -i Bcast $DIZIN/ifconfig_name | wc -l`


if [ $SATIR != 0 ]
then

#Objelerin olusturulmasi
#=========================================================================================================
echo
echo "Bulunan broadcast interface sayisi $SATIR"
echo "Objeler olusturuluyor..."
echo "Grp_Broadcast"
mgmt_cli add group name Grp_Broadcast color "dark blue" comments "Bu grup gateway uzeride broadcast yukunu hafifletmek icin otomatik olusturulmustur" -r true --port $GAIAPORT

input=$DIZIN/ifconfig_ip
while IFS= read -r line
do
echo
echo Bcast:$line
mgmt_cli add host name Bcast:$line ip-address $line color "dark blue" comments "Bu host objesi Grp_Broadcast icinde kullanilmak uzere otomatik olusturulmustur" -r true --port $GAIAPORT
mgmt_cli set group name "Grp_Broadcast" members.add Bcast:$line -r true --port $GAIAPORT
done < "$input"
#=========================================================================================================


#Kuralarin olusturulmasi
#=========================================================================================================
layer_getir
echo "Kural olusturuluyor..."
mgmt_cli set group name "Grp_Broadcast" members.add "Broadcast" -r true --port $GAIAPORT
mgmt_cli add access-rule layer "$LAYER" name "Drop Broadcast" position top action drop destination "Grp_Broadcast" -r true --port $GAIAPORT
#=========================================================================================================



#Temizlik
#=========================================================================================================
echo
echo "Dosyalar temizleniyor..."
rm $DIZIN/ifconfig*
echo
#=========================================================================================================


echo "Dikkat"
echo "Dikkat"
echo "SmartConsole uzerinde kuralin yerini mutlaka kontrol edin. Kural 1ci sirada oldugu icin DHCP Relay servislerini bozabilir."
echo ""

else
echo "Gateway uzerinden broadcast adresleri ogrenilemedi. Gateway adresini kontrol edin. Islem sonlandiriliyor..."
echo ""
rm $DIZIN/ifconfig*
echo
fi

}

drop_multicast ()
{

#Objelerin olusturulmasi
#=========================================================================================================
echo
echo "Obje olusturuluyor..."
echo "Multicast"
mgmt_cli add network name "Multicast" subnet "224.0.0.0" subnet-mask "240.0.0.0"  comments "Multicast Network" color "dark blue" -r true --port $GAIAPORT
#=========================================================================================================


#Kuralin olusturulmasi
#=========================================================================================================
layer_getir
echo "Kural olusturuluyor..."
mgmt_cli add access-rule layer "$LAYER" name "Drop Multicast" position top action drop destination Multicast -r true --port $GAIAPORT
#=========================================================================================================

}

drop_wudo ()
{

#Objelerin olusturulmasi
#=========================================================================================================
echo
echo "Obje olusturuluyor..."
echo "WUDO TCP 7680 (Windows Update Delivery Optimization)"
mgmt_cli add service-tcp name "WUDO" port 7680 comments "Windows Update Delivery Optimization" color "dark blue" -r true --port $GAIAPORT
#=========================================================================================================


#Kuralin olusturulmasi
#=========================================================================================================
layer_getir
echo "Kural olusturuluyor..."
mgmt_cli add access-rule layer "$LAYER" name "Drop WUDO" position top action drop service.1 "WUDO" -r true --port $GAIAPORT
#=========================================================================================================

}

drop_rfc ()
{

#Objelerin olusturulmasi
#=========================================================================================================
echo ""
echo "Obje olusturuluyor..."
echo "Class_A"
mgmt_cli add network name "Class_A" subnet "10.0.0.0" subnet-mask "255.0.0.0"  comments "Reserverd (Privete) Ranges" color "dark blue" -r true --port $GAIAPORT
echo "Class_B"
mgmt_cli add network name "Class_B" subnet "172.16.0.0" subnet-mask "255.240.0.0"  comments "Reserverd (Privete) Ranges" color "dark blue" -r true --port $GAIAPORT
echo "Class_C"
mgmt_cli add network name "Class_C" subnet "192.168.0.0" subnet-mask "255.255.0.0"  comments "Reserverd (Privete) Ranges" color "dark blue" -r true --port $GAIAPORT
echo "Reserverd_(Private)_Ranges"
mgmt_cli add group name "Reserverd_(Private)_Ranges" members.1 "Class_A" members.2 "Class_B" members.3 "Class_C" color "dark blue" -r true --port $GAIAPORT
echo "RFC_1918"
mgmt_cli add group-with-exclusion name "RFC_1918" include "Reserverd_(Private)_Ranges" except "NoNAT" comments "Reserverd (Privete) Ranges Except NoNAT"  color "dark blue" -r true --port $GAIAPORT
#=========================================================================================================


#Kuralin olusturulmasi
#=========================================================================================================
layer_getir
echo "Kural olusturuluyor..."
mgmt_cli add access-rule layer "$LAYER" name "Drop RFC 1918" position top action drop destination "RFC_1918" -r true --port $GAIAPORT
#=========================================================================================================

}

ftp_backup ()
{
if [ -f cron_yedek.sh ]
	then
		rm cron_yedek.sh
		echo ""
		curl_cli http://dynamic.egisbilisim.com.tr/script/cron_yedek.sh | cat > cron_yedek.sh && chmod 770 cron_yedek.sh
		echo ""
		rm /var/log/egis/upgrade_tools/*bilgi.txt
		rm /var/log/egis/upgrade_tools/*export.tgz
		echo ""
		echo ""
		echo "Mecvut cron takvimi"
		echo "==================================================================="
		echo ""
		crontab -u scpadmin -l
		echo ""
		echo ""
	else
		echo ""
		echo ""
		curl_cli http://dynamic.egisbilisim.com.tr/script/cron_yedek.sh | cat > cron_yedek.sh && chmod 770 cron_yedek.sh
		echo ""
		cd $DIZIN
		if [ -d upgrade_tools ]
			then
				rm -r upgrade_tools
				mkdir $DIZIN/upgrade_tools
				cp $FWDIR/bin/upgrade_tools/* $DIZIN/upgrade_tools/
				cd $DIZIN/
			else	
				mkdir $DIZIN/upgrade_tools
				cp $FWDIR/bin/upgrade_tools/* $DIZIN/upgrade_tools/
				cd $DIZIN/
				if [ -f database.txt ]
					then
						echo "database.txt mevcut. Degisiklik yapilmiyor."
					else
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
						echo "GATEWAY5=" >> database.txt
						echo "GATEWAY6=" >> database.txt
						echo "GATEWAY7=" >> database.txt
						echo "GATEWAY8=" >> database.txt
						echo "SYSLOGTARGET1=" >> database.txt
						echo "SYSLOGTARGET2" >> database.txt
						echo "HOST2=" >> database.txt
						echo "USER2=" >> database.txt
						echo "PASSWD2=" >> database.txt
						chmod 770 database.txt
				fi	
			crontab -u scpadmin -l >> crontab.txt
			SATIR=`wc -l crontab.txt | awk '{ print $1 }'`
			if [ $SATIR != 0 ] 
				then
					echo ""
					echo "Crontab daha once yapilandirilmis."
					echo ""
					rm crontab.txt
				else
					echo ""
					echo "#  This file was AUTOMATICALLY GENERATED"
					echo "#  Generated by /bin/cron_xlate on Wed Jan 14 13:33:33 2015"
					echo "#"
					echo "#  DO NOT EDIT"
					echo "#"
					echo "SHELL=/bin/bash"
					echo "MAILTO=\"\""
					echo "#"
					echo "# mins  hrs     daysinm months  daysinw command"
					echo "#"
					echo "* * * * 6 /var/log/egis/cron_yedek.sh > /var/log/egis/cron_durum.txt"
					echo ""
					rm crontab.txt
			fi
		fi	
fi
}

dynamic_block ()
{
if [ -f opendbl.sh ]
	then
		rm opendbl.sh
		curl_cli http://dynamic.egisbilisim.com.tr/script/opendbl.sh | cat > opendbl.sh && chmod 770 opendbl.sh
		./opendbl.sh
	else
		curl_cli http://dynamic.egisbilisim.com.tr/script/opendbl.sh | cat > opendbl.sh && chmod 770 opendbl.sh
		./opendbl.sh
fi
}
		

super7 ()
{
if [ -f s7pac.sh ]
	then
		rm s7pac.sh
		curl_cli http://dynamic.egisbilisim.com.tr/script/s7pac.sh | cat > s7pac.sh && chmod 770 s7pac.sh
		./s7pac.sh
	else
		curl_cli http://dynamic.egisbilisim.com.tr/script/s7pac.sh | cat > s7pac.sh && chmod 770 s7pac.sh
		./s7pac.sh
fi
}
		
health_check ()
{
if [ -f healthcheck.sh ]
	then
		rm healthcheck.sh
		curl_cli http://dynamic.egisbilisim.com.tr/script/healthcheck.sh | cat > healthcheck.sh && chmod 770 healthcheck.sh
		./healthcheck.sh
		exit 0
	else
		curl_cli http://dynamic.egisbilisim.com.tr/script/healthcheck.sh | cat > healthcheck.sh && chmod 770 healthcheck.sh
		./healthcheck.sh
		exit 0
fi
}			

auto_download ()
{
if [ -f autodownload.sh ]
	then
		rm autodownload.sh
		curl_cli http://dynamic.egisbilisim.com.tr/script/autodownload.sh | cat > autodownload.sh && chmod 770 autodownload.sh
		echo "autodownload.sh silindi ve yeniden indirildi."
		
	else
		curl_cli http://dynamic.egisbilisim.com.tr/script/autodownload.sh | cat > autodownload.sh && chmod 770 autodownload.sh
		echo "autodownload.sh indirildi."
fi
crontab -u scpadmin -l > crontab.txt
chmod 770 crontab.txt
SATIRSAY=`grep -o -i "#" crontab.txt | wc -l`
if [ $SATIRSAY == 0 ]
	then		
	echo "#  This file was AUTOMATICALLY GENERATED" >> crontab.txt
	echo "#  Generated by /bin/cron_xlate on Wed Jan 14 13:33:33 2015" >> crontab.txt
	echo "#" >> crontab.txt
	echo "#  DO NOT EDIT" >> crontab.txt
	echo "#" >> crontab.txt
	echo "SHELL=/bin/bash" >> crontab.txt
	echo "MAILTO=\"\"" >> crontab.txt
	echo "#" >> crontab.txt
	echo "# mins  hrs     daysinm months  daysinw command" >> crontab.txt
	echo "#" >> crontab.txt
	echo "33 * * * * /var/log/egis/autodownload.sh" >> crontab.txt
	crontab -u scpadmin crontab.txt
	echo "crontab olusturuldu."
else
	SATIRBAK=`grep -o -i autodownload.sh crontab.txt | wc -l`
	if [ $SATIRBAK != 1  ]
		then
		echo "33 * * * * /var/log/egis/autodownload.sh" >> crontab.txt
		crontab -u scpadmin crontab.txt
		echo "crontab guncellendi."
	fi
fi
rm crontab.txt
}	

ssl_hardering()
{
if [ -f hardering.sh ]
	then
		rm hardering.sh
		curl_cli http://dynamic.egisbilisim.com.tr/script/hardering.sh | cat > hardering.sh && chmod 770 hardering.sh
		echo "hardering.sh silindi ve yeniden indirildi."
	else
		curl_cli http://dynamic.egisbilisim.com.tr/script/hardering.sh | cat > hardering.sh && chmod 770 hardering.sh
		echo "hardering.sh indirildi."
fi
			select os in "Gorevi simdi calistir" "Gorevi daha sonra el ile calistiracagim" 
			do
			case $os in
			"Gorevi simdi calistir")
				./hardering.sh
				break
			;;
			"Gorevi daha sonra el ile calistiracagim")
                echo "Gorev el ile calistirilacak"
				break
			;;
			*)
				echo "Gecersiz giris."
				break
			;;
			esac
			done
}


policy_install ()
{
if [ -f policyinstall.sh ]
	then
		rm policyinstall.sh
		curl_cli http://dynamic.egisbilisim.com.tr/script/policyinstall.sh | cat > policyinstall.sh && chmod 770 policyinstall.sh
	else
		curl_cli http://dynamic.egisbilisim.com.tr/script/policyinstall.sh | cat > policyinstall.sh && chmod 770 policyinstall.sh
		echo ""	
			
			grep "MAIL_SENDER=" database.txt > sender.txt
			awk -F"="  '{print $2}' sender.txt > sender_atli.txt
			awk -F  "@" '{print $2}' sender_atli.txt > sender_atsiz.txt
			ATSIZ=$(<sender_atsiz.txt)
			echo "MAIL_SENDER2=SmartTask@$ATSIZ" >> database.txt
			echo "MAIL_RECEIVER2=alert@egisbilisim.com.tr" >> database.txt
			rm sender*
			
			
			select os in "Repository uzerinde script mevcut" "Repository uzerinde script mevcut degil, ben olusturacagim" 
			do
			case $os in
			"Repository uzerinde script mevcut")
				mgmt_cli add smart-task name "Policy Install Task" trigger "After Install Policy" comments "Policy install sonrasinda script yardimi ile mail gonderimi" action.run-script.repository-script "Policy Install" color "dark blue" enabled true -r true --port $GAIAPORT
				break
			;;
			"Repository uzerinde script mevcut degil, ben olusturacagim")
				mgmt_cli add smart-task name "Policy Install Task" trigger "After Install Policy" comments "Policy install sonrasinda script yardimi ile mail gonderimi" action.run-script.repository-script "Show Policy Status" color "dark blue" enabled true -r true --port $GAIAPORT
				echo "Task mevcut bit script ile olusuturlmustur. Management uzerine scripti sizin olusturmaniz gerekmektedir."
				echo "Baslik: Policy Install"
				echo "Renk: dark blue"
				echo "Icerik:"
				echo "cd /var/log/egis"
				break
			;;
			*)
				echo "Gecersiz giris."
				break
			;;
			esac
			done
fi
}


echo ""
PS3='Yapilacak islemi secin: '
options=("Drop Broadcast" "Drop Multicast" "Drop WUDO" "Drop RFC 1918" "FTP Backup" "Dynamic Block" "Policy Install Alert" "Health Check" "CCC" "Super7" "Auto Download" "SSL Hardering" "Cikis")
select opt in "${options[@]}"
do
    case $opt in
        "Drop Broadcast")
			drop_broadcast
            ;;
        "Drop Multicast")
			drop_multicast
            ;;
        "Drop WUDO")
			drop_wudo
            ;;
        "Drop RFC 1918")
			drop_rfc
            ;;
		"FTP Backup")
			ftp_backup
            ;;
		"Dynamic Block")
			dynamic_block
            ;;
		"Policy Install Alert")
			policy_install
            ;;	
		"Health Check")
			health_check
            ;;
		"Auto Download")
			auto_download
            ;;	
        "SSL Hardering")
			ssl_hardering
            ;;	
		"CCC")
			curl_cli $(if [[ `grep proxy:ip /config/active` ]]; then echo -n '--proxy '; grep proxy:ip /config/active|cut -f2 -d' '|tr -d '\n'; echo -n :; grep proxy:port /config/active|cut -f2 -d' '; fi) -k https://dannyjung.de/ccc|zcat > /usr/bin/ccc && chmod +x /usr/bin/ccc; . ~/.bashrc
			echo ""
			echo "ccc komutu ile Common Check Point Commands menusune ulasabilirsiniz."
			echo "cokluislem menusunden cikiliyor..."
			exit 0
			;;
		"Super7")
			super7
			;;
        "Cikis")
			echo ""
			echo "Cikis yapliyor..."
			echo ""
            break
            ;;
        *) 
			echo "invalid option $REPLY"
			;;
    esac
done



#Chance Log
#=========================================================================================================
# 2.3.1 Konsol ekrani biraz degisti.
# 2.3 Menuye autodownload.sh eklendi.
# 2.2.1 database.txt icine SYSLOGTARGET degiskeni eklendi.
# 2.2 FTP Backup ile ilgili degisiklikler yapildi.
# 2.1 Super7 eklendi.
# 2.0 Policy Install Mail Alert icin database.txt uzerine otomatik kayit olusturulmaya baslandi.
# 1.9 Kural olusturma asamasinda Layer secimi eklendi.
# 1.8 Policy Install Mail Alert script indirme menuye eklendi.
# 1.7 Otomaik guncelleme kontrolu yapilmaya basladi.
# 1.6 cokluislem.sh kopyalama islemi duzeltildi, Grp_Broadcast tirnak icine alindi. 
# 1.5 dropc_rfc funtion'u yazildi.
# 1.4 broadcast.sh multicast.sh wudo.sh dis kaynaktan almak yerine funtion olarak script icine tanimlanmistir.
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