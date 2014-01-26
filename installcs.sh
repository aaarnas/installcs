#!/bin/bash
# Counter Strike 1.6 serverio instaliacijos skriptas
# Autorius: aaarnas
# amxmodx.lt

VERSION=2.4.6

SCRIPT_NAME=`basename $0`
MAIN_DIR="/usr"

STEAMCMD_URL="http://media.steampowered.com/client/steamcmd_linux.tar.gz"
STEAMCMD_DIR="$MAIN_DIR/steamcmd"
STEAMCMD_CMD="steamcmd.sh"
STEAMCMD_COMMANDS_FILE="/usr/_steamcmd_commands_list.txt"

SERVER_DIR="hlds"
INSTALL_DIR="$MAIN_DIR/$SERVER_DIR"

FILES_ALL="server_files.tgz"
FILES_DPROTO="server_files_dproto.tgz"
echo "-------------------------------------------------------------------------------"
echo "Amxmodx.lt Counter Strike 1.6 serverio instaliacija"
echo "Oficialus saltinis: http://amxmodx.lt/viewtopic.php?f=19&t=161"
echo "-------------------------------------------------------------------------------"

check_version() {
	echo "Tikrinama diegimo irankio versija..."
	LATEST_VERSION=`wget -qO - http://www.amxmodx.lt/installer_files/installcs.sh | grep "VERSION=[0-9]"`
	
	if [ -z $LATEST_VERSION ]; then
		echo "Klaida: Nepavyko patikrinti naujausios versijos is serverio. Nutraukiama..."
		exit 1
	fi
	
	if [ "VERSION=$VERSION" != $LATEST_VERSION ]; then
		echo "Yra nauja diegimo irankio versija. Atsiunciama..."
		wget -q -O installcs.tempfile http://www.amxmodx.lt/installer_files/installcs.sh
		if [ ! -e "installcs.tempfile" ]; then
			echo "Klaida: Nepavyko gauti naujos diegimo irankio versijos is serverio..."
			exit 1
		fi
		
		mv $SCRIPT_NAME _installcs.old
		mv installcs.tempfile installcs.sh
		chmod +x installcs.sh
		rm _installcs.old
		echo "Atnaujinta i naujausia versija! Paleiskite ./installcs.sh komanda dar karta"
		exit
	else
		echo "Naudojate naujausia $VERSION versija"
	fi
}
check_packages() {
	
	BIT64_CHECK=false && [ $(getconf LONG_BIT) == "64" ] && BIT64_CHECK=true
	LIB_CHECK=false && [ "`(dpkg --get-selections lib32gcc1 | egrep -o \"(de)?install\") 2> /dev/null`" = "install" ] && LIB_CHECK=true
	SCREEN_CHECK=false && [ "`(dpkg --get-selections screen | egrep -o \"(de)?install\") 2> /dev/null`" = "install" ] && SCREEN_CHECK=true
	
	if $BIT64_CHECK && ! $LIB_CHECK || ! $SCREEN_CHECK; then
		echo "-------------------------------------------------------------------------------"
		echo "Serveryje truksta instaliacijai reikiamu paketu"
		echo -e "Bus paleistos sios komandos:\n"
		echo "apt-get update"
		if $BIT64_CHECK && ! $LIB_CHECK; then
		echo "apt-get -y install lib32gcc1"
		fi
		if ! $SCREEN_CHECK; then
		echo "apt-get -y install screen"
		fi
		echo -e "\nInstaliuoti?"
		echo "1. Taip"
		echo "2. Iseiti"
		read -p "Iveskite pasirinkta skaiciu: " NUMBER
	
		case "$NUMBER" in
		"1")
			if $BIT64_CHECK && ! $LIB_CHECK; then
				apt-get -y install lib32gcc1
			fi
			if ! $SCREEN_CHECK; then
				apt-get -y install screen
			fi
			;;
		*)
			echo "Ate" 
			exit 0
			;;
		esac
	fi
}

check_dir() {
	echo "-------------------------------------------------------------------------------"
	if [ -e $INSTALL_DIR ]; then
		
		echo "Serveri ketinta instaliuoti i '$INSTALL_DIR' direktorija, bet ji jau sukurta"
		NUMBER=1
		until [ ! -e $INSTALL_DIR ]; do
			((NUMBER++))
			INSTALL_DIR="$MAIN_DIR/$SERVER_DIR$NUMBER"
		done
		echo "Instaliuoti i '$INSTALL_DIR'?"
		echo "1. Taip"
		echo "2. Noriu nurodyti kita direktorija"
		echo "3. Iseiti"
		read -p "Iveskite pasirinkta skaiciu: " MENU_NUMBER
	
		case "$MENU_NUMBER" in
		"1")
			SERVER_DIR="$SERVER_DIR$NUMBER"
			return 0
			;;
		"2")
			read -p "Norima direktorija: $MAIN_DIR/" SERVER_DIR
			INSTALL_DIR="$MAIN_DIR/$SERVER_DIR"
			check_dir
			;;
		*)
			echo "Ate" 
			exit 0
			;;
		esac
	else
		echo "Instaliuoti serveri i '$INSTALL_DIR'?"
		echo "1. Taip"
		echo "2. Noriu nurodyti kita direktorija"
		echo "3. Iseiti"
		read -p "Iveskite pasirinkta skaiciu: " MENU_NUMBER
		
		case "$MENU_NUMBER" in
		"1")
			return 0
			;;
		"2")
			read -p "Norima direktorija: $MAIN_DIR/" SERVER_DIR
			INSTALL_DIR="$MAIN_DIR/$SERVER_DIR"
			check_dir
			;;
		*)
			echo "Ate" 
			exit 0
			;;
		esac
	fi
}
check_version
check_packages
check_dir

#------------
METAMOD=$((1<<0))
DPROTO=$((1<<1))
AMXMODX=$((1<<2))
CHANGES=$((1<<3))
echo "-------------------------------------------------------------------------------"
echo "Pasirinkite modifikacijas, kurios bus instaliuotos."
echo "([modifikacija] | (serverio tipas)):"
echo "1. [metamod][dproto][amxmodx] | (Numatytasis)(non-steam)"
echo "2. [metamod][dproto] | (non-steam)"
echo "3. [metamod][amxmodx] | (steam)"
echo "4. [metamod] | (steam)"
echo "5. Nieko papildomai neinstaliuoti"
echo "6. Palikti sviaria serverio instaliacija (be jokiu pakeitimu, papildymu)"
echo "7. Iseiti"
read -p "Iveskite pasirinkta skaiciu: " NUMBER

INSTALL_TYPE=0
case "$NUMBER" in
"1")
	INSTALL_TYPE=$(($INSTALL_TYPE|$METAMOD))
	INSTALL_TYPE=$(($INSTALL_TYPE|$DPROTO))
	INSTALL_TYPE=$(($INSTALL_TYPE|$AMXMODX))
	INSTALL_TYPE=$(($INSTALL_TYPE|$CHANGES))
	;;
"2")
	INSTALL_TYPE=$(($INSTALL_TYPE|$METAMOD))
	INSTALL_TYPE=$(($INSTALL_TYPE|$DPROTO))
	INSTALL_TYPE=$(($INSTALL_TYPE|$CHANGES))
	;;
"3")
	INSTALL_TYPE=$(($INSTALL_TYPE|$METAMOD))
	INSTALL_TYPE=$(($INSTALL_TYPE|$AMXMODX))
	INSTALL_TYPE=$(($INSTALL_TYPE|$CHANGES))
	;;
"4")
	INSTALL_TYPE=$(($INSTALL_TYPE|$METAMOD))
	INSTALL_TYPE=$(($INSTALL_TYPE|$CHANGES))
	;;
"5")
	INSTALL_TYPE=$(($INSTALL_TYPE|$CHANGES))
	;;
"6")
	;;
*)
	echo "Ate"
	exit 0
	;;
esac
#------------
mkdir $INSTALL_DIR
cd $MAIN_DIR
if [ ! -e "$STEAMCMD_DIR/$STEAMCMD_CMD" ]; then
	if [ ! -e $STEAMCMD_DIR ]; then
		mkdir $STEAMCMD_DIR
	fi
	cd $STEAMCMD_DIR
	wget $STEAMCMD_URL
	tar -xzf steamcmd_linux.tar.gz
	rm steamcmd_linux.tar.gz
fi

echo -e  "login anonymous\nforce_install_dir $INSTALL_DIR\napp_update 90 -beta beta validate\napp_update 90 -beta beta validate\napp_update 90 -beta beta validate\nquit" > $STEAMCMD_COMMANDS_FILE
$STEAMCMD_DIR/$STEAMCMD_CMD +runscript $STEAMCMD_COMMANDS_FILE
rm $STEAMCMD_COMMANDS_FILE

EXITVAL=$?
if [ $EXITVAL -gt 0 ]; then
	echo "-------------------------------------------------------------------------------"
	echo "SteamCMD vidine klaida. Klaidos kodas: $EXITVAL"
	echo "Instaliacija nutraukiama..."
	rmdir --ignore-fail-on-non-empty $INSTALL_DIR
	exit 1
fi

cd $INSTALL_DIR

echo "-------------------------------------------------------------------------------"
if [ $(($INSTALL_TYPE&$METAMOD)) != 0 ]; then
echo "instaliuojamas Metamod..."
mkdir -p cstrike/addons
mkdir -p cstrike/addons/metamod
mkdir -p cstrike/addons/metamod/dlls
wget -q -P cstrike/addons/metamod/dlls http://www.amxmodx.lt/installer_files/metamod.so
if [ ! -e "cstrike/addons/metamod/dlls/metamod.so" ]; then
	echo "Klaida: Nepavyko gauti metamod failo is serverio. Nutraukiama..."
	exit 1
fi
sed -r -i s/gamedll_linux.+/"gamedll_linux \"addons\/metamod\/dlls\/metamod.so\""/ cstrike/liblist.gam
fi
if [ $(($INSTALL_TYPE&$DPROTO)) != 0 ]; then
echo "instaliuojamas Dproto..."
mkdir -p cstrike/addons
mkdir -p cstrike/addons/dproto
wget -q -P cstrike/addons/dproto http://www.amxmodx.lt/installer_files/dproto_i386.so
wget -q -P cstrike http://www.amxmodx.lt/installer_files/dproto.cfg
if [ ! -e "cstrike/addons/dproto/dproto_i386.so" ] || [ ! -e "cstrike/dproto.cfg" ]; then
	echo "Klaida: Nepavyko gauti dproto failu is serverio. Nutraukiama..."
	exit 1
fi
echo "linux addons/dproto/dproto_i386.so" >> cstrike/addons/metamod/plugins.ini
fi
if [ $(($INSTALL_TYPE&$AMXMODX)) != 0 ]; then
echo "instaliuojamas Amxmodx..."
wget -q -P cstrike http://www.amxmodx.lt/installer_files/amxmodx-base.tar.gz
wget -q -P cstrike http://www.amxmodx.lt/installer_files/amxmodx-cstrike.tar.gz
if [ ! -e "cstrike/amxmodx-base.tar.gz" ] || [ ! -e "cstrike/amxmodx-cstrike.tar.gz" ]; then
	echo "Klaida: Nepavyko gauti amxmodx failu is serverio. Nutraukiama..."
	exit 1
fi
tar -xzf cstrike/amxmodx-base.tar.gz -C cstrike
tar -xzf cstrike/amxmodx-cstrike.tar.gz -C cstrike
rm cstrike/amxmodx-base.tar.gz
rm cstrike/amxmodx-cstrike.tar.gz
echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> cstrike/addons/metamod/plugins.ini
fi
if [ $(($INSTALL_TYPE&$CHANGES)) != 0 ]; then
echo "atliekami pakeitimai..."
wget -q -O cstrike/_server.cfg http://www.amxmodx.lt/installer_files/server.cfg
if [ ! -e "cstrike/_server.cfg" ]; then
	echo "Klaida: Nepavyko gauti server.cfg failo is serverio. Nutraukiama..."
	exit 1
fi
rm cstrike/server.cfg
mv cstrike/_server.cfg cstrike/server.cfg

wget -q http://www.amxmodx.lt/installer_files/update
if [ ! -e "update" ]; then
	echo "Klaida: Nepavyko gauti update failo is serverio. Nutraukiama..."
	exit 1
fi
chmod +x update

echo "#!/bin/bash" >> start
echo "SESSION=\$(screen -ls | egrep -o -e [0-9]+\\.$SERVER_DIR | sed -r -e \"s/[0-9]+\\.//\")" >> start
echo "if [ \"\$SESSION\" == \"$SERVER_DIR\" ]; then" >> start
echo "	screen -dr $SERVER_DIR" >> start
echo "else" >> start
echo "	cd $INSTALL_DIR && screen -A -m -d -S $SERVER_DIR ./hlds_run -game cstrike +ip $(wget -qO - http://ipecho.net/plain) +port 27015 +map cs_assault +maxplayers 15" >> start
echo "	sleep 1" >> start
echo "	screen -dr $SERVER_DIR" >> start
echo "fi" >> start
echo "exit" >> start
chmod +x start

echo "#!/bin/bash" >> stop
echo "SESSION=\$(screen -ls | egrep -o -e [0-9]+\\.$SERVER_DIR | sed -r -e \"s/[0-9]+\\.//\")" >> stop
echo "SERVER_NAME=\$(cat cstrike/server.cfg | egrep \"hostname\\s+\\\"[^\\\"]+\\\"\" | sed \"s/hostname //\" | tr -d \"\\\"\\r\")" >> stop
echo "STATUS=\"\"" >> stop
echo "if [ \"\$SESSION\" == \"$SERVER_DIR\" ]; then" >> stop
echo "	screen -S $SERVER_DIR -X quit" >> stop
echo "	STATUS=\"sustabdytas\"" >> stop
echo "else" >> stop
echo "	STATUS=\"nera ijungtas, tad negalima jo sustabdyti\"" >> stop
echo "fi" >> stop
echo 'echo "-------------------------------------------------------------------------------"' >> stop
echo "echo \"Serveris \$SERVER_NAME \$STATUS\"" >> stop
echo 'echo "-------------------------------------------------------------------------------"' >> stop
echo "exit" >> stop
chmod +x stop

echo "#!/bin/bash" >> restart
echo "SESSION=\$(screen -ls | egrep -o -e [0-9]+\\.$SERVER_DIR | sed -r -e \"s/[0-9]+\\.//\")" >> restart
echo "SERVER_NAME=\$(cat cstrike/server.cfg | egrep \"hostname\\s+\\\"[^\\\"]+\\\"\" | sed \"s/hostname //\" | tr -d \"\\\"\\r\")" >> restart
echo "STATUS=\"\"" >> restart
echo "if [ \"\$SESSION\" == \"$SERVER_DIR\" ]; then" >> restart
echo "	screen -S $SERVER_DIR -X restart" >> restart
echo "	STATUS=\"perkraunamas...\"" >> restart
echo "else" >> restart
echo "	STATUS=\"nera ijungtas, tad negalima jo perkrauti\"" >> restart
echo "fi" >> restart
echo 'echo "-------------------------------------------------------------------------------"' >> restart
echo "echo \"Serveris \$SERVER_NAME \$STATUS\"" >> restart
echo 'echo "-------------------------------------------------------------------------------"' >> restart
echo "exit" >> restart
chmod +x restart

sed -i s/"if test \$retval -eq 0 && test -z \"\$RESTART\" ; then"/"if test \$retval -eq 0 ; then"/ hlds_run
sed -i s/"debugcore \$retval"/"debugcore \$retval\n\n\t\t\tif test -z \"\$RESTART\" ; then\n\t\t\t\tbreak; # no need to restart on crash\n\t\t\tfi"/ hlds_run
sed -i s/"if test -n \"\$DEBUG\" ; then"/"if test \"\$DEBUG\" -eq 1; then"/ hlds_run

mkdir steamcmd
echo "../steamcmd/steamcmd.sh +login anonymous +force_install_dir $INSTALL_DIR +app_update 90 -beta beta validate +quit" > steamcmd/steamcmd.sh
chmod +x steamcmd/steamcmd.sh
fi

echo "-------------------------------------------------------------------------------"
echo "Serveris instaliuotas direktorijoje '$INSTALL_DIR'"
if [ $(($INSTALL_TYPE&$CHANGES)) != 0 ]; then
echo "$INSTALL_DIR/start - paleisti serveri. $INSTALL_DIR/update - atnaujinti serveri"
fi
echo "-------------------------------------------------------------------------------"

exit 0
# Counter Strike 1.6 serverio instaliacijos skriptas
# Autorius: aaarnas
# amxmodx.lt
