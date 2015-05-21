#!/bin/bash

### This is a shorter version of the Stowaway script that should be used for debugging purposess


REFLECTIONONLY=false

LOC=$1

#############################################################################
# Make sure that permissions are set up correctly
#############################################################################

chmod u+x *.rb
chmod u+x *.py

#############################################################################
# SPECIAL CASE: ACCORDING TO ARGS, FIRST TIME THIS HAS BEEN RUN
#############################################################################


## DK - Added for testing purposes
LOC=$2



#############################################################################
# PROVIDER ANALYSIS
#############################################################################


if [ $REFLECTIONONLY = false ]; then
	if [ ! -d $LOC/ProviderResults ] 
	then
		mkdir $LOC/ProviderResults
	fi
	./provideranalysis.rb $LOC/dedex/ $LOC/ProviderResults/
	./providerperms.py $LOC/ProviderResults/URIuse.txt >> $LOC/ProviderResults/providerpermissions.txt 2>> $LOC/sources
fi

cat $LOC/ProviderResults/providerpermissions.txt >> $LOC/OurPermissions

#############################################################################
# PERSISTENT ACTIVITIES
#############################################################################

if grep -q "android:persistent=\"true\"" $LOC/AndroidManifest.xml
then
	echo "android.permission.PERSISTENT_ACTIVITY" >> $LOC/OurPermissions
	echo "AndroidManifest.xml contains a persistent activity [android.permission.PERSISTENT_ACTIVITY]" >> $LOC/sources
fi



#############################################################################
# REPORTING
#############################################################################

sort -u $LOC/OurPermissions > $LOC/tmp
mv $LOC/tmp $LOC/OurPermissions
#cat $LOC/OurPermissions
./getuses.rb $LOC/AndroidManifest.xml > $LOC/orig 

if [ -e $LOC/Underprivilege ]
then
	rm $LOC/Underprivilege
fi
if [ -e $LOC/Overprivilege ]
then
	rm $LOC/Overprivilege
fi

./compare.py $LOC/orig $LOC/OurPermissions $LOC

correct=true
if [ -e $LOC/Underprivilege ]
then
	echo "The application is underprivileged."
	correct=false
fi
if [ -e $LOC/Overprivilege ]
then
	echo "The application is overprivileged."
	amount=$(wc -l $LOC/Overprivilege )
	correct=false
fi
if $correct ; then
	echo "We agree about permissions."
fi
