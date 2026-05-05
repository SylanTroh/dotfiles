function list-installed-packages --wraps='pacman -Qei | awk \'/^Name/ { name=$3 } /^Groups/ { if ( $3 != "base" && $3 != "base-devel" ) { print name } }\'' --description 'alias list-installed-packages=pacman -Qei | awk \'/^Name/ { name=$3 } /^Groups/ { if ( $3 != "base" && $3 != "base-devel" ) { print name } }\''
  pacman -Qei | awk '/^Name/ { name=$3 } /^Groups/ { if ( $3 != "base" && $3 != "base-devel" ) { print name } }' $argv
        
end
