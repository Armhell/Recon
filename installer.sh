#!/bin/bash
apt-get -y update && sudo apt-get upgrade -y

apt-get install -y curl
apt-get install -y libcurl4-openssl-dev
apt-get install -y libssl-dev
apt-get install -y jq
apt-get install -y ruby-full
apt-get install -y libldns-dev
apt-get install -y python3-pip
apt-get install -y python-pip
apt-get install -y python-dnspython
apt-get install -y build-essential chrpath libssl-dev libxft-dev libfreetype6-dev libfreetype6 libfontconfig1-dev libfontconfig1 -y
apt-get install -y libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev build-essential libgmp-dev zlib1g-dev
apt-get install -y build-essential libssl-dev libffi-dev python-dev
apt-get install -y python-setuptools
apt-get install curl -y 
apt-get install jq -y
apt-get install build-essential chrpath libssl-dev libxft-dev libfreetype6-dev libfreetype6 libfontconfig1-dev libfontconfig1 -y
apt-get install python-setuptools -y
apt-get install jq -y
cd ~/

#install go
if [[ -z "$GOPATH" ]];then
echo "It looks like go is not installed, would you like to install it now"
PS3="Please select an option : "
choices=("yes" "no")
select choice in "${choices[@]}"; do
        case $choice in
                yes)
					echo "Installing Golang"
					wget https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
					tar -C /usr/local -xzf go1.14.2.linux-amd64.tar.gz
					echo "export GOROOT=/usr/local/go" >> ~/.bashrc
					echo "export GOPATH=$HOME/go"	>> ~/.bashrc			
					echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> ~/.bashrc	
					source ~/.bashrc
					sleep 1
					break
					;;
				no)
					echo "Please install go and rerun this script"
					echo "Aborting installation..."
					exit 1
					;;
	esac	
done
fi


#Create a tools folder
mkdir ~/pentest

#install assetfinder
echo "Installing assetfinder"
go get -u github.com/tomnomnom/assetfinder
echo "done"

#install findomain

wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux
chmod +x findomain-linux
mv findomain-linux /usr/local/bin/findomain-linux
echo "done"

#install massdns
cd ~/Recon
git clone https://github.com/blechschmidt/massdns.git
cd ~/Recon/massdns
make
mv ~/Recon/massdns ~/pentest
mv ~/Recon/all.txt ~/pentest/massdns/lists/
echo "done"

#install shuffledns
cd ~/
GO111MODULE=on go get -u -v github.com/projectdiscovery/shuffledns/cmd/shuffledns

#install chaos-clinet
GO111MODULE=on go get -u github.com/projectdiscovery/chaos-client/cmd/chaos
echo "done"

#install httpx
GO111MODULE=on go get -u -v github.com/projectdiscovery/httpx/cmd/httpx
echo "done"

#install amass
sudo snap install amass
sudo snap refresh
echo "done"

#install subfinder
go get -v github.com/projectdiscovery/subfinder/cmd/subfinder
echo "done"

#install phantomjs
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/
ln -s /usr/local/share/phantomjs-2.1.1-linux-x86_64.tar.bz2/bin/phantomjs /usr/local/bin/
rm phantomjs-2.1.1-linux-x86_64.tar.bz2

#install webscreenshot
pip install webscreenshot

#install asnip
go get -v github.com/harleo/asnip
echo "done"

#install naabu
GO111MODULE=on go get -v github.com/projectdiscovery/naabu/cmd/naabu
echo "done"

#Finalize
source ~/.bashrc
mkdir ~/projects
mv ~/Recon/recon.sh /usr/local/bin/recon
echo "Required tools have been added in ~/pentest!"
