#!/bin/bash
##Move to /home directory
echo "Changing Directory..."
cd

echo "Installing dependencies"
sudo apt-get install git ruby nmap curl -y > /dev/null
sudo apt install default-jdk postgresql -y > /dev/null
sudo systemctl enable postgresql > /dev/null
sudo systemctl start postgresql > /dev/null

##Fix possible previous attempts to install metasploit/armitage
echo "Fixing possible previous mistakes... (no offense)"
echo "File does not exist errors are common here, this just means you haven't installed Metasploit previously."
echo "Those errors will not impact the install."
sudo apt-get remove metasploit-framework postgresql --purge -y > /dev/null
sudo rm -r /opt/metasploit-framework > /dev/null
sudo rm -r /opt/armitage > /dev/null
sudo rm -r /usr/local/bin/armitage > /dev/null
sudo rm -r /usr/local/bin/teamserver > /dev/null



##Install metasploit
echo "Installing Metasploit-Framework... (This may take some time)"
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
chmod 755 msfinstall && \
./msfinstall
echo "TYPE 'yes' AND PRESS ENTER AT THE PROMPT"
echo "Then follow the remaining prompts for user/pass"
msfdb init > /dev/null

##Manually install armitage
echo "Installing Armitage..."
cd /opt
sudo git clone https://github.com/r00t0v3rr1d3/armitage.git > /dev/null
cd armitage
sudo ./package.sh > /dev/null
cd release/unix
sudo bash -c 'printf "#!/bin/sh\njava -XX:+AggressiveHeap -XX:+UseParallelGC -jar /opt/armitage/release/unix/armitage.jar \$@\n" > armitage'
sudo ln -s /opt/armitage/release/unix/armitage /usr/local/bin/armitage > /dev/null
sudo perl -pi -e 's/armitage.jar/\/opt\/armitage\/release\/unix\/armitage.jar/g' /opt/armitage/release/unix/teamserver > /dev/null

##Create database.yml file
sudo sh -c "echo export MSF_DATABASE_CONFIG=~/.msf4/database.yml >> /etc/profile"
sudo chown -R `whoami` ~/.msf4

## End and close out
echo "So... That should be it, run 'sudo -E armitage' to start armitage and 'sudo msfconsole' to start metasploit"
