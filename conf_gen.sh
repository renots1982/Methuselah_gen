#!/bin/bash

#Color codes
RED='\033[0;91m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

read -e -p "Enter your private key:" genkey;
read -e -p "Confirm your private key: " genkey2;


#Confirming match
  if [ $genkey = $genkey2 ]; then
     echo -e "${GREEN}MATCH! ${NC} \a" 
else 
     echo -e "${RED} Error: Private keys do not match. Try again or let me generate one for you...${NC} \a";exit 1
fi
sleep .5
clear

# Determine primary public IP address
dpkg -s dnsutils 2>/dev/null >/dev/null || sudo apt-get -y install dnsutils
publicip=$(dig +short myip.opendns.com @resolver1.opendns.com)

if [ -n "$publicip" ]; then
    echo -e "${YELLOW}IP Address detected:" $publicip ${NC}
else
    echo -e "${RED}ERROR: Public IP Address was not detected!${NC} \a"
    clear_stdin
    read -e -p "Enter VPS Public IP Address: " publicip
    if [ -z "$publicip" ]; then
        echo -e "${RED}ERROR: Public IP Address must be provided. Try again...${NC} \a"
        exit 1
    fi
fi

#Methuselah TCP port
PORT=7555
RPC=7556

rm ~/.methuselah/methuselah.conf

 #Create methuselah datadir
 if [ ! -f ~/.methuselah/methuselah.conf ]; then 
 	sudo mkdir ~/.methuselah
 fi

#Generating Random Password for methuselahd JSON RPC
rpcuser=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Create methuselah.conf
cat <<EOF > ~/.methuselah/methuselah.conf
rpcallowip=127.0.0.1
rpcuser=$rpcuser
rpcpassword=$rpcpassword
server=1
daemon=1
listen=1
rpcport=$RPC
onlynet=ipv4
maxconnections=64
masternode=1
masternodeprivkey=$genkey
externalip=$publicip
promode=1
EOF
