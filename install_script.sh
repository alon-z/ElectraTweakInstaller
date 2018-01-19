# Create dir for the tweak
mkdir  -p $1.dir
OLD_PWD=$pwd

# Extract
#tar -xvf $1 -C $1.dir/
cd $1.dir
ar x ../$1
tar -xvf data.tar.*
cd Library/

# Sing using ldid (aka ldid2)
# for bin in $(for file in $(find . | grep -Ev ".*.png" | grep -Ev ".*.plist" | grep -Ev ".*.txt" | grep -Ev ".*.sh"); do file $file; done | grep -v directory | awk '{print $1}' | sed 's@:@@' | sort -u); do echo $bin; ldid -S "$bin"; done

# Copy to device
if find . | grep MobileSubstrate; then
scp -P 2222 MobileSubstrate/DynamicLibraries/* root@$2:/bootstrap/Library/SBInject/.
fi
if find . | grep PreferenceBundles; then
scp -P 2222 -r PreferenceBundles/*.bundle root@$2:/bootstrap/Library/PreferenceBundles/.
scp -P 2222 -r PreferenceLoader/Preferences/*.plist root@$2:/bootstrap/Library/PreferenceLoader/Preferences/.
fi
if find . | grep "Application Support"; then
cd "Application Support"
scp -P 2222 -r * root@$2:"/Library/Application\ Support/."
cd ..
fi
left=$(find . | grep -v MobileSubstrate | grep -v Preference | grep -v "Application Support" | tail -n +2)
echo "Left overs:"
echo "$left"

cd $OLD_PWD
