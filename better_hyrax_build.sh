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
make 2>&1 | tee hyrax-dependencies_make.log
cd ..

# Reconfigure and rebuild libdap4
cd libdap4
autoreconf -vif
./configure --prefix=$prefix --enable-developer 2>&1 | tee libdap4_config.log
make 2>&1 | tee libdap4_make.log
make check 2>&1 | tee libdap4_make_check.log
make install 2>&1 | tee libdap4_make_install.log
cd ..

# Reconfigure and rebuild bes
cd bes
autoreconf -vif
./configure --prefix=$prefix --with-dependencies=$prefix/deps --enable-developer 2>&1 | tee bes_config.log
make 2>&1 | tee bes_make.log
make check 2>&1 | tee bes_make_check.log
make install 2>&1 | tee bes_install.log
cd ..

user='bes'
group='bes_group'
sed -i "/BES.User=*/c\BES.User=${user}" ~/hyrax/build/etc/bes/bes.conf
sed -i "/BES.Group=.*/c\BES.Group=${group}" ~/hyrax/build/etc/bes/bes.conf

./build/bin/besctl start
./build/./apache-tomcat-7.0.57/bin/startup.sh
