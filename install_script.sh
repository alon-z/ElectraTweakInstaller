# Create dir for the tweak
mkdir $1.dir
OLD_PWD=$pwd

# Extract
tar -xvf $1 -C $1.dir/
cd $1.dir
tar -xvf data.tar.*
cd Library/

# Sing using ldid (aka ldid2)
for bin in $(for file in $(find . | grep -Ev ".*.png" | grep -Ev ".*.plist" | grep -Ev ".*.txt" | grep -Ev ".*.sh"); do file $file; done | grep -v directory | awk '{print $1}' | sed 's@:@@' | sort -u); do echo $bin; ldid -S "$bin"; done

# Copy to device
if find . | grep MobileSubstrate; then
scp MobileSubstrate/DynamicLibraries/* root@$2:/bootstrap/Library/SBInject/.
fi
if find . | grep PreferenceBundles; then
scp -r PreferenceBundles/*.bundle root@$2:/bootstrap/Library/PreferenceBundles/.
scp -r PreferenceLoader/Preferences/*.plist root@$2:/bootstrap/Library/PreferenceLoader/Preferences/.
fi
if find . | grep "Application Support"; then
scp -r "./Application Support/*" root@10.0.0.12:"/Library/Application\ Support/."
fi
left=$(find . | grep -v MobileSubstrate | grep -v Preference | grep -v "Application Support" | tail -n +2)
echo "Left overs:"
echo "$left"

cd $OLD_PWD
