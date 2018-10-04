# nat-ncs2
How to compile and deploy webserver on Ubuntu

## 1. Install Required Software

    sudo apt install git
    sudo apt install openjdk-8-jdk-headless
    sudo apt install nodejs
    sudo apt install curl
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update && sudo apt-get install yarn
    sudo apt-get install hmmer

## 2. Clone Project, compile and deploy

    git clone https://github.com/pvlastaridis/nat-ncs2.git
    cd nat-ncs2/
    yarn install
    sh mvnw -Dmaven.test.skip=true -Pprod package
    cp -R HMMDB/ target/
    sudo java -jar target/nat-ncs2-0.0.1-SNAPSHOT.war
