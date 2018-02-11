#!/bin/bash 

#ensure chmod +x

#If error "-bash: '\r': command not found" then run
#sed -i 's/\r$//' better_hyrax_build,sh

#sudo -s


pwd

# Uninstall current builds
cd bes 
make uninstall
cd ..
cd libdap4 
make uninstall
cd ..

pwd

# Set prefix var
source spath.sh
echo $prefix

# Build Hyrax dependencies
cd hyrax-dependencies
make
cd ..

# Reconfigure and rebuild libdap4
cd libdap4
autoreconf -vif
./configure --prefix=$prefix --enable-developer
make 
make check
make install
cd ..

# Reconfigure and rebuild bes
cd bes
autoreconf -vif
./configure --prefix=$prefix --with-dependencies=$prefix/deps --enable-developer
make
make check
make install
cd ..

user='bes'
group='bes_group'
sed -i "/BES.User=*/c\BES.User=${user}" ~/hyrax/build/etc/bes/bes.conf
sed -i "/BES.Group=.*/c\BES.Group=${group}" ~/hyrax/build/etc/bes/bes.conf

./build/bin/besctl start
./build/./apache-tomcat-7.0.57/bin/startup.sh
