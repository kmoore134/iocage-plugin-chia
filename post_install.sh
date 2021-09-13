#!/usr/local/bin/bash

# Change local shell to BASH
chsh -s /usr/local/bin/bash

# Clone our chia repo
cd /root
git clone  -b 1.2.6 https://github.com/Chia-Network/chia-blockchain.git

# Setup virtual environment
cd chia-blockchain
python3 -m venv venv
source venv/bin/activate 

# Upgrade PIP
pip install --upgrade pip

# Build and install clvm_rs
cd /root
git clone -b 0.1.10 https://github.com/Chia-Network/clvm_rs.git 
cd clvm_rs
maturin develop --release
pip install git+https://github.com/Chia-Network/clvm@use_clvm_rs


# Hack(s)!
cd /root/chia-blockchain
sed -i '' 's|elif platform == "linux":|elif platform == "linux" or platform.startswith("freebsd"):|g' chia/util/keychain.py
sed -i '' 's|cryptography==3.4.7|cryptography==3.3.2|g' setup.py

# Moar Hacks!
portsnap --interactive fetch
portsnap extract update
cd /usr/ports/security/py-cryptography
echo "DEFAULT_VERSIONS+=ssl=openssl python=3.8 python3=3.8" >> /etc/make.conf
make BATCH=yes

# Even mooaarr hacks!
echo "cp -R /usr/ports/security/py-cryptography/work-py38/stage/usr/local/lib/python3.8/site-packages/cryptography ${VIRTUAL_ENV}/lib/python3.8/site-packages/cryptography"
cp -R /usr/ports/security/py-cryptography/work-py38/stage/usr/local/lib/python3.8/site-packages/cryptography ${VIRTUAL_ENV}/lib/python3.8/site-packages/cryptography
if [ $? -ne 0 ] ; then
  exit 1
fi

echo "cp -R /usr/ports/security/py-cryptography/work-py38/stage/usr/local/lib/python3.8/site-packages/cryptography-3.3.2-py3.8.egg-info ${VIRTUAL_ENV}/lib/python3.8/site-packages/cryptography-3.3.2-py3.8.egg-info"
cp -R /usr/ports/security/py-cryptography/work-py38/stage/usr/local/lib/python3.8/site-packages/cryptography-3.3.2-py3.8.egg-info ${VIRTUAL_ENV}/lib/python3.8/site-packages/cryptography-3.3.2-py3.8.egg-info
if [ $? -ne 0 ] ; then
  exit 1
fi
find ${VIRTUAL_ENV}/lib/python3.8/site-packages/cryptography -name __pycache__ | xargs -I{} rm -rf "{}"


make clean BATCH=yes

# Install Chia
cd /root/chia-blockchain
sh install.sh

# Setup bashrc so that chia is ready to rock and roll at startup
echo "source /root/chia-blockchain/activate" >/root/.bashrc

# Init Chia and done!
./venv/bin/chia init
