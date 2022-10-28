#!/bin/bash
function usage() 
{
    cat << EOF
Error Running Setup Laptop Script

Please Ensure:

1. a git_username and git_password set to in .env to start.

2. host machine is running Debian or Ubuntu

3. script is running as root
EOF
exit 1
}

#Define timestamp in-case we need it for backups
now=$(date +%Y_%m_%d_%H_%M_%S)


#Check Running As Root
if [ "$EUID" -ne 0 ] then ;
    usage
fi

#Read .env file to get credentials
export $(grep -v '^#' .env | xargs)
if [[ -z "$git_username" || -z "$git_password" ]] ; then
    usage
fi

#Grab Distro, Check Its Correct
distro=$(awk -F= '/^ID/{print $2}' /etc/os-release)
if [ "$distro" != "debian" || "$distro" != "ubuntu" ] ; then
    usage
fi

#Check network, connect to wifi
if [[ -n "$wifi_password" && -n "$wifi_network" ]] ; then
    echo "Setting Up Wifi Network"
    nmcli radio wifi on
    nmcli dev wifi connect $wifi_network password "$wifi_password"
fi

echo "Testing Internet Connectivity"
ping -c 5 google.com
if [ $? -ne 0 ] ; then
    echo "Unable To Connect To The Internet, Please Check Internet Connectivity"
    exit 1
else
    echo "Internet Connectivity Established"
fi

echo "Installing Latest Base Package Updates"
apt update
apt upgrade -y

echo "Installing Common Packages"
apt install -y jq ansible
echo "Common Packages Installed"

echo "Installing VS-Code"
curl -L -o /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
apt install -f /tmp/vscode.deb
echo "VS-Code Installed"

echo "Adding Hashicorp Repo And Installing Terraform"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update
apt install -y terraform
echo "Terraform Installed"

echo "Seting Up Desktop"
if [ -d /home/craig/.kde/share/config ] ; then
    mkdir -p /home/craig/.kde/share/config/
fi

if [ -d /home/craig/.kde/share/apps/color-schemes ] ; then
    mkdir -p /home/craig/.kde/share/apps/color-schemes
fi
cat << EOF > /home/craig/.kde/share/apps/color-schemes/Breeze.colors
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=189,195,199
BackgroundNormal=239,240,241
DecorationFocus=61,174,233
DecorationHover=147,206,233
ForegroundActive=61,174,233
ForegroundInactive=127,140,141
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=35,38,39
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Selection]
BackgroundAlternate=29,153,243
BackgroundNormal=61,174,233
DecorationFocus=61,174,233
DecorationHover=147,206,233
ForegroundActive=252,252,252
ForegroundInactive=239,240,241
ForegroundLink=253,188,75
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=189,195,199

[Colors:Tooltip]
BackgroundAlternate=77,77,77
BackgroundNormal=35,38,39
DecorationFocus=61,174,233
DecorationHover=147,206,233
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:View]
BackgroundAlternate=239,240,241
BackgroundNormal=252,252,252
DecorationFocus=61,174,233
DecorationHover=147,206,233
ForegroundActive=61,174,233
ForegroundInactive=127,140,141
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=35,38,39
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Window]
BackgroundAlternate=189,195,199
BackgroundNormal=239,240,241
DecorationFocus=61,174,233
DecorationHover=147,206,233
ForegroundActive=61,174,233
ForegroundInactive=127,140,141
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=35,38,39
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Complementary]
BackgroundAlternate=59,64,69
BackgroundNormal=49,54,59
DecorationFocus=30,146,255
DecorationHover=61,174,230
ForegroundActive=147,206,233
ForegroundInactive=175,176,179
ForegroundLink=61,174,230
ForegroundNegative=231,76,60
ForegroundNeutral=253,188,75
ForegroundNormal=239,240,241
ForegroundPositive=46,204,113
ForegroundVisited=61,174,230

[General]
ColorScheme=Breeze
Name=Breeze
Name[ar]=نسيم
Name[az]=Breeze
Name[bs]=Breeze
Name[ca]=Brisa
Name[ca@valencia]=Brisa
Name[cs]=Breeze
Name[da]=Breeze
Name[de]=Breeze
Name[el]=Breeze
Name[en_GB]=Breeze
Name[es]=Brisa
Name[et]=Breeze
Name[eu]=Breeze
Name[fi]=Breeze
Name[fr]=Brise
Name[gl]=Breeze
Name[he]=Breeze
Name[hu]=Breeze
Name[ia]=Brisa
Name[id]=Breeze
Name[it]=Brezza
Name[ko]=Breeze
Name[lt]=Breeze
Name[nb]=Breeze
Name[nds]=Breeze
Name[nl]=Breeze
Name[nn]=Breeze
Name[pa]=ਬਰੀਜ਼
Name[pl]=Bryza
Name[pt]=Brisa
Name[pt_BR]=Breeze
Name[ro]=Briză
Name[ru]=Breeze
Name[sk]=Vánok
Name[sl]=Sapica
Name[sr]=Поветарац
Name[sr@ijekavian]=Поветарац
Name[sr@ijekavianlatin]=Povetarac
Name[sr@latin]=Povetarac
Name[sv]=Breeze
Name[tg]=Насим
Name[tr]=Esinti
Name[uk]=Breeze
Name[x-test]=xxBreezexx
Name[zh_CN]=Breeze 微风
Name[zh_TW]=Breeze
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=71,80,87
activeBlend=252,252,252
activeForeground=252,252,252
inactiveBackground=239,240,241
inactiveBlend=75,71,67
inactiveForeground=189,195,199
EOF

cat << EOF > /home/craig/.kde/share/apps/color-schemes/BreezeDark.colors
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=77,77,77
BackgroundNormal=49,54,59
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Selection]
BackgroundAlternate=29,153,243
BackgroundNormal=61,174,233
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=252,252,252
ForegroundInactive=239,240,241
ForegroundLink=253,188,75
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=189,195,199

[Colors:Tooltip]
BackgroundAlternate=77,77,77
BackgroundNormal=49,54,59
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:View]
BackgroundAlternate=49,54,59
BackgroundNormal=35,38,41
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Window]
BackgroundAlternate=77,77,77
BackgroundNormal=49,54,59
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Complementary]
BackgroundAlternate=59,64,69
BackgroundNormal=49,54,59
DecorationFocus=30,146,255
DecorationHover=61,174,230
ForegroundActive=246,116,0
ForegroundInactive=175,176,179
ForegroundLink=61,174,230
ForegroundNegative=237,21,21
ForegroundNeutral=201,206,59
ForegroundNormal=239,240,241
ForegroundPositive=17,209,22
ForegroundVisited=61,174,230

[General]
ColorScheme=Breeze Dark
Name=Breeze Dark
Name[ar]=نسيم داكن
Name[az]=Breeze - Tünd
Name[bs]=Breeze tamna
Name[ca]=Brisa fosca
Name[ca@valencia]=Brisa fosca
Name[cs]=Breeze Tmavé
Name[da]=Breeze Dark
Name[de]=Breeze-Dunkel
Name[el]=Breeze σκούρο
Name[en_GB]=Breeze Dark
Name[es]=Brisa oscuro
Name[et]=Breeze tume
Name[eu]=Breeze iluna
Name[fi]=Tumma Breeze
Name[fr]=Brise sombre
Name[gl]=Breeze Dark
Name[he]=Breeze Dark
Name[hu]=Breeze Dark
Name[ia]=Brisa obscure
Name[id]=Breeze Gelap
Name[it]=Brezza scuro
Name[ko]=어두운 Breeze
Name[lt]=Breeze tamsus
Name[nb]=Breeze mørk
Name[nl]=Breeze Dark
Name[nn]=Breeze mørk
Name[pa]=ਬਰੀਜ਼ ਗੂੜ੍ਹਾ
Name[pl]=Ciemna bryza
Name[pt]=Brisa Escura
Name[pt_BR]=Breeze Dark
Name[ro]=Briză, întunecat
Name[ru]=Breeze, тёмный вариант
Name[sk]=Tmavý vánok
Name[sl]=Sapica (temna)
Name[sr]=Поветарац тамни
Name[sr@ijekavian]=Поветарац тамни
Name[sr@ijekavianlatin]=Povetarac tamni
Name[sr@latin]=Povetarac tamni
Name[sv]=Breeze mörk
Name[tg]=Насими торик
Name[tr]=Koyu Esinti
Name[uk]=Темна Breeze
Name[x-test]=xxBreeze Darkxx
Name[zh_CN]=Breeze 微风暗色
Name[zh_TW]=Breeze Dark
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=49,54,59
activeBlend=255,255,255
activeForeground=239,240,241
inactiveBackground=49,54,59
inactiveBlend=75,71,67
inactiveForeground=127,140,141
EOF

cat << EOF > /home/craig/.kde/share/config/kdeglobals
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=77,77,77
BackgroundNormal=49,54,59
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Complementary]
BackgroundAlternate=59,64,69
BackgroundNormal=49,54,59
DecorationFocus=30,146,255
DecorationHover=61,174,230
ForegroundActive=246,116,0
ForegroundInactive=175,176,179
ForegroundLink=61,174,230
ForegroundNegative=237,21,21
ForegroundNeutral=201,206,59
ForegroundNormal=239,240,241
ForegroundPositive=17,209,22
ForegroundVisited=61,174,230

[Colors:Selection]
BackgroundAlternate=29,153,243
BackgroundNormal=61,174,233
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=252,252,252
ForegroundInactive=239,240,241
ForegroundLink=253,188,75
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=189,195,199

[Colors:Tooltip]
BackgroundAlternate=77,77,77
BackgroundNormal=49,54,59
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:View]
BackgroundAlternate=49,54,59
BackgroundNormal=35,38,41
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Window]
BackgroundAlternate=77,77,77
BackgroundNormal=49,54,59
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[General]
ColorScheme=Breeze Dark
Name[en_GB]=Breeze Dark
Name=Breeze Dark
shadeSortColumn=true
widgetStyle=Breeze

[Icons]
Theme=breeze-dark

[KDE]
ShowIconsInMenuItems=true
ShowIconsOnPushButtons=true
contrast=4

[Toolbar style]
ToolButtonStyle=TextBesideIcon
ToolButtonStyleOtherToolbars=TextBesideIcon

[WM]
activeBackground=49,54,59
activeBlend=255,255,255
activeForeground=239,240,241
inactiveBackground=49,54,59
inactiveBlend=75,71,67
inactiveForeground=127,140,141
EOF

chown -R craig.craig /home/craig/.kde/share/config/kdeglobals

#setup SSH config from git, backup any previous SSH keys/config
echo "Setting up SSH"
mkdir /tmp/ssh_config/
cd /tmp/ssh_config
git clone https://$git_username:$git_password@github.com/craigharris98/ssh.git

if [ -d /home/craig/.ssh ] ; then
    echo "Previous SSH installation found, backing up files to /home/craig/ssh_bk_$now.tar.gz"
    tar -czvf /home/craig/ssh_bk_$now.tar.gz /home/craig/.ssh/
    rm -rf /home/craig/.ssh/
fi 
mkdir -p /home/craig/.ssh/

mv /tmp/ssh_config/ssh/* /home/craig/.ssh/
chown craig.craig -R /home/craig/.ssh/
pemfiles=$(find /home/craig/.ssh/ -name "*.pem" -type f)
chmod 400 $pemfiles
echo "SSH Configured."

echo "Installation Complete Restarting PC In 10 seconds"
for i in {10..01}; do 
echo "Restarting in $i....";
sleep 1
done
reboot