#!/bin/bash

# Copyright (c) [2023] [@ravindu644]

clear
export WDIR=$(pwd)
chmod +755 -R *
source "$WDIR/res/colors"

echo -e "${BLUE}Samsung Firmware Extractor 3.0 - By @ravindu644${RESET}\n"
echo -e "\n\t${UNBOLD_GREEN}Installing requirements...${RESET}\n"

sudo apt install simg2img lz4 openssl python3-pip -y > /dev/null 2>&1
echo -e "${MAGENTA}\n[+] Success..! ${RESET}\n"
#python3 python-is-python3

echo -e "${UNBOLD_GREEN}[+] Installing Samloader...${RESET}\n"
if [ ! -f "$WDIR/.samloader" ]; then
    cd ~ ; pip3 install git+https://github.com/martinetd/samloader.git --no-warn-script-location
    echo "1" > "$WDIR/.samloader"
    cd "$WDIR"
else
    echo -e "${RED}[x] Existing Installation found..!\n${RESET}"
fi

#tmp variables
#export MODEL="YOUR MODEL"
#export IMEI="YOUR IMEI"
#export CSC="YOUR CSC"
export BASE_TAR_NAME="Stock files - ${MODEL}.tar"

echo -e "====================================\n"
echo -e "${LIGHT_YELLOW}[+] Model: ${BOLD_WHITE}${MODEL}${RESET}\n${LIGHT_YELLOW}"
echo -e "${LIGHT_YELLOW}[+] IMEI: ${BOLD_WHITE}${IMEI}${RESET}\n${LIGHT_YELLOW}"
echo -e "${LIGHT_YELLOW}[+] CSC: ${BOLD_WHITE}${CSC}${RESET}\n${LIGHT_YELLOW}${RESET}"
echo -e "====================================\n"

echo -e "${MINT_GREEN}[+] Fetching Latest Firmware...\n${RESET}"
if ! VERSION=$(python3 -m samloader -m "${MODEL}" -r "${CSC}" -i "${IMEI}" checkupdate 2>/dev/null); then
    echo -e "${RED}\n[x] Model or region not found (403)\n${RESET}"
    exit
else
    echo -e "${LIGHT_YELLOW}[i] Update found: ${BOLD_WHITE}${VERSION}${RESET}\n${LIGHT_YELLOW}${RESET}"
fi

echo -e "${MINT_GREEN}[+] Attempting to Download...\n${RESET}"

if [  -d "$WDIR/Downloads" ];then
    rm -rf Downloads output
fi

if [ ! -d "$WDIR/Downloads" ];then
    mkdir Downloads output
fi

python3 -m samloader -m "${MODEL}" -r "${CSC}" -i "${IMEI}" download -v "${VERSION}" -O "$WDIR/Downloads"

echo -e "\n${MINT_GREEN}[+] Decrypting...\n${RESET}\n"
FILE="$(ls $WDIR/Downloads/*.enc*)"
if ! python3 -m samloader -m "${MODEL}" -r "${CSC}" -i "${IMEI}" decrypt -v "${VERSION}" -i "$FILE" -o "$WDIR/Downloads/firmware.zip"; then
    echo -e "${RED}\n[x] Something Strange Happened :( \n${RESET}"
    exit    
fi

#### Begin of core worker ####

bash "$WDIR/tools/worker.sh"

#### End of core worker ####