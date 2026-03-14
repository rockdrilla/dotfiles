set -ef ;
apt-get update -yy ;
apt-get install -yy cpp-15 g++-15 gcc-15 gnat-15 gfortran-15 ;
apt-get autoremove -yy ;
apt-get clean
