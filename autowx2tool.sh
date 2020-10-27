#####################################################
#    This Script automatically Updates MLRPT to     #
#    Version 1.6.2, setting up new config files     #
#   and set the new Path to the new config files    #
#    Created by Daniel Ackermann aka Foxocnn11      # 
#####################################################


cd /home/pi/

update(){
wget http://5b4az.org/pkg/lrpt/mlrpt-1.6.2.tar.bz2
tar jxvf mlrpt-1.6.2.tar.bz2
cd mlrpt-1.6.2/
./autogen.sh
./configure CFLAGS="-g -O2"
make -j4
sudo make install
rm mlrpt-1.6.2.tar.bz2* -f
rm mlrpt-1.6.2 -r -f
}

getconfig(){
cd /home/pi/autowx2/modules
cp meteor-m2 meteor-m2-2 -r
cd /home/pi/mlrpt
rm * -r -f
mkdir images
wget http://web42216.pfweb.eu/Downloads/mlrptconf/M2-1-72k.cfg
wget http://web42216.pfweb.eu/Downloads/mlrptconf/M2-2-72k.cfg
cd /home/pi/autowx2/modules/meteor-m2
rm meteor_record.sh -f
wget http://web42216.pfweb.eu/Downloads/mlrptconf/m2/meteor_record.sh
cd /home/pi/autowx2/modules/meteor-m2-2
rm meteor_record.sh -f
wget http://web42216.pfweb.eu/Downloads/mlrptconf/m22/meteor_record.sh
}

verify(){
clear
echo If everything is ok, the next 2 Lines should have -c configfile in it.
echo
sed -n '13 p' /home/pi/autowx2/modules/meteor-m2/meteor_record.sh
sed -n '13 p' /home/pi/autowx2/modules/meteor-m2-2/meteor_record.sh
echo
read -p "Press enter if its ok."
clear
echo MLRPT Directory should have the 2 new Meteor Configs:
echo
ls /home/pi/mlrpt
echo
read -p "Press enter if its ok."
clear
echo MLRPT should be Version 1.6.2
echo
mlrpt -v
echo
read -p "Press enter if its ok."
}

restartautowx2(){
echo Lets restart AutoWX2
echo 
read -p "Press enter if its ok. Otherwise Press CTRL + C"
killall screen

while [ 1 ]
do
    pid=`ps -ef | grep "SDR_AutoWX2" | grep -v grep | awk ' {print $2}'`
    if [ "$pid" = "" ]
    then
            clear
            echo "AutoWX2 has not restarted yet"

    else
        clear
	echo "AutoWX2 has started lets get this radiowaves down!"
        sleep 3
	return 0
    fi
    sleep 1
done
}

cleanupraw(){
echo Cleaning up all raw files
find /home/pi/autowx2/ -name '*.raw' -delete
}

updatekeps(){
/home/pi/autowx2/bin/update-keps.sh
}

genpasstable(){
/home/pi/autowx2/genpasstable.py
}

genstaticpage(){
/home/pi/autowx2/bin/gen-static-page.sh
}

show_menu(){
    clear
    normal=`echo "\033[m"`
    menu=`echo "\033[36m"` #Blue
    number=`echo "\033[33m"` #yellow
    bgred=`echo "\033[41m"`
    fgred=`echo "\033[31m"`
    printf "\n${menu}*********************************************${normal}\n"
    printf "${menu}**${number} 1)${menu} Update/rebuild mlrpt, Update Confs, Verify and Restart Autowx2 ${normal}\n"
    printf "${menu}**${number} 2)${menu} Verify only ${normal}\n"
    printf "${menu}**${number} 3)${menu} Restart AutoWX2 ${normal}\n"
    printf "${menu}**${number} 4)${menu} Update Configs and Verify ${normal}\n"
    printf "${menu}**${number} 5)${menu} Cleanup RAW files${normal}\n"
    printf "${menu}**${number} 6)${menu} Update Kepler Data${normal}\n"
    printf "${menu}**${number} 7)${menu} Generate new Passtable${normal}\n"
    printf "${menu}**${number} 8)${menu} Generate updated Staticpage${normal}\n"
    printf "${menu}*********************************************${normal}\n"
    printf "Please enter a menu option and enter or ${fgred}x to exit. ${normal}"
    read opt
}

option_picked(){
    msgcolor=`echo "\033[01;31m"` # bold red
    normal=`echo "\033[00;00m"` # normal white
    message=${@:-"${normal}Error: No message passed"}
    printf "${msgcolor}${message}${normal}\n"
}

show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        4) clear;
			option_picked "Option Update Configs and Verify Picked";
            getconfig;
			verify;
			restartautowx2;
            show_menu;
        ;;
        2) clear;
            option_picked "Option Verify only Picked";
            verify;
            show_menu;
        ;;
        3) clear;
            option_picked "Option restart AutoWX2 Picked";
            restartautowx2;
            show_menu;
        ;;
        1) clear;
            option_picked "Option Update Everything Picked";
            update;
			getconfig;
			verify;
			restartautowx2;
            show_menu;
        ;;
        5) clear;
            option_picked "Option Cleanup RAW files Picked";
            cleanupraw;
            show_menu;
        ;;
        6) clear;
            option_picked "Option Update Kelper Data Picked";
            updatekeps;
            show_menu;
        ;;
        7) clear;
            option_picked "Option Generate new Passtable Picked";
            genpasstable;
            show_menu;
        ;;
        8) clear;
            option_picked "Option Generate updated Staticpage Picked";
            genstaticpage;
            show_menu;
        ;;
        x)clear;
          exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Pick an option from the menu";
            show_menu;
        ;;
      esac
    fi
done
