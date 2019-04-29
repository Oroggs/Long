#!/usr/bin/env bash


# 1. setup ghidra.bin
startup_directory=$(pwd)
if [[ ! -d "../ghidra.bin" ]]; then
    mkdir -p ../ghidra.bin/Ghidra/Features/GhidraServer/
    cd /tmp
    curl -OL https://sourceforge.net/projects/yajsw/files/yajsw/yajsw-stable-12.12/yajsw-stable-12.12.zip
    cp yajsw-stable-12.12.zip ${startup_directory}/../ghidra.bin/Ghidra/Features/GhidraServer/
fi

# 2. flat repo dependencies
if [[ ! -d "$HOME/flatRepo" ]]; then
    cat << EOF > $HOME/.gradle/init.d/repos.gradle
    ext.HOME = System.getProperty('user.home')

allprojects {
    repositories {
        mavenCentral()
        jcenter()
        flatDir name:'flat', dirs:["$HOME/flatRepo"]
    }
}
EOF

    mkdir $HOME/flatRepo
    cd /tmp
    curl -OL https://github.com/pxb1988/dex2jar/releases/download/2.0/dex-tools-2.0.zip
    unzip dex-tools-2.0.zip
    cp dex2jar-2.0/lib/dex-*.jar $HOME/flatRepo/
    cd $HOME/flatRepo
    curl -OL https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/android4me/AXMLPrinter2.jar
    cd /tmp
    curl -OL https://sourceforge.net/projects/catacombae/files/HFSExplorer/0.21/hfsexplorer-0_21-bin.zip
    mkdir hfsx
    cd hfsx
    unzip ../hfsexplorer-0_21-bin.zip
    cd lib
    cp csframework.jar hfsx_dmglib.jar hfsx.jar iharder-base64.jar $HOME/flatRepo/
fi

# 3. gradle & gradle wrapper
if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    # OSX has no gradle, install it
    brew install gradle
fi

# setup gradle wrapper to use a correct version
gradle wrapper --gradle-version 5.4 --distribution-type all

# 4. unpack
cd ${startup_directory}
./gradlew yajswDevUnpack
