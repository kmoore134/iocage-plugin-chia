#!/usr/local/bin/bash

# Change local shell to BASH
chsh -s /usr/local/bin/bash

# Clone our chia repo
cd /root
git clone  -b 1.1.6 https://github.com/Chia-Network/chia-blockchain.git

# Setup virtual environment
cd chia-blockchain
python3 -m venv venv
source venv/bin/activate 

# Upgrade PIP
pip install --upgrade pip

# Build and install clvm_rs
cd /root
git clone -b 0.1.7 https://github.com/Chia-Network/clvm_rs.git 
cd clvm_rs
maturin develop --release
pip install git+https://github.com/Chia-Network/clvm@use_clvm_rs

cd /root/chia-blockchain

# Hack(s)!
sed -i '' 's|elif platform=="linux":|elif platform=="linux" or platform.startswith("freebsd"):|g' chia/util/keychain.py
sed -i '' 's|cryptography==3.4.6|cryptography==3.3.2|g' setup.py

# Install Chia
sh install.sh

# Init Chia and done!
./venv/bin/chia init
