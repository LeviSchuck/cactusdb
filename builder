#!/bin/sh

BINURL="http://download.opalang.org/linux/opa_1.0.5%2Bbuild2988_amd64.release.run"

# Installing OPA, first push only
if [ ! -d ~/opa ] ; then
    mkdir ~/opa
    wget $BINURL -O install
    sh install -- ~/opa
    rm install
    # Install node dependencies
    (cd ~ && npm install -g n && npm install mongodb formidable nodemailer imap )
fi

# Runscript
cp run ~/

# Install the code
#cp app.opa ~/
cp -r resources ~/
cp -r src ~/
cp -r Makefile ~/
cp -r Makefile.common ~/
cp opa.conf ~/

export PATH=$PATH:${HOME}/opa/bin/
echo $PATH
which opa

# Compiling the OPA app
cd ~ && make
npm install -g n
