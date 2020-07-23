#! /bin/bash

export PYTHONPATH=/usr/lib/anaconda

VERSION=build8
BUILDDIR=/home/centos/build2
DISTDIR=/centos-3/$VERSION
BUILDTIME=`date +%Y%m%d%H%M`
LOGFILE=/centos-3/$VERSION/build.$BUILDTIME.log

echo "Starting Build ... - logging to $LOGFILE"
echo "Starting Build" > $LOGFILE
#run as root ...

## Clean out build area

rm -f $BUILDDIR/SRPMS/*
rm -f $BUILDDIR/RPMS/i386/*
rm -f $BUILDDIR/RPMS/noarch/*
rm -f $BUILDDIR/RPMS/athlon/*
rm -f $BUILDDIR/RPMS/i686/*
rm -f $BUILDDIR/RPMS/i486/*
rm -f $BUILDDIR/RPMS/i586/*
rm -f $BUILDDIR/BUILD/*

## Build comps
echo "Building Comps"

rpmbuild -ba $BUILDDIR/SPECS/comps-centos.spec >> $LOGFILE 2>&1

cp $BUILDDIR/SRPMS/comps* $DISTDIR/SRPMS.centos/ >> $LOGFILE 2>&1
rm -f $DISTDIR/i386/RedHat/RPMS/comps-3* >> $LOGFILE 2>&1
cp $BUILDDIR/RPMS/i386/comps* $DISTDIR/i386/RedHat/RPMS/ >> $LOGFILE 2>&1
cp -f $BUILDDIR/RPMS/i386/comps* $DISTDIR/i386/RedHat/base/comps.rpm >> $LOGFILE 2>&1

## Build centos-yumcache
echo "Building Yumcache"

rpmbuild -ba $BUILDDIR/SPECS/centos-yumcache-3.1.spec >> $LOGFILE 2>&1
cp $BUILDDIR/SRPMS/centos-yumcache* $DISTDIR/SRPMS.centos/ >> $LOGFILE 2>&1
rm -f $DISTDIR/i386/RedHat/RPMS/centos-yumcache* >> $LOGFILE 2>&1
cp $BUILDDIR/RPMS/noarch/centos-yumcache* $DISTDIR/i386/RedHat/RPMS/ >> $LOGFILE 2>&1

## Build rpmdb
echo Â"Building Rpmdb"

rpmbuild -ba  $BUILDDIR/SPECS/rpmdb-redhat.spec >> $LOGFILE 2>&1
cp $BUILDDIR/SRPMS/rpmdb-redhat* $DISTDIR/SRPMS.centos/ >> $LOGFILE 2>&1
rm -f $DISTDIR/i386/RedHat/RPMS/rpmdb-redhat* >> $LOGFILE 2>&1
cp $BUILDDIR/RPMS/i386/rpmdb-redhat* $DISTDIR/i386/RedHat/RPMS/ >> $LOGFILE 2>&1

cd /centos-3/$VERSION/

## Run genhd first time
echo "Running genhdlist"

/usr/lib/anaconda-runtime/genhdlist \
--fileorder /centos-3/$VERSION/i386/pkgorder-i386.txt \
/centos-3/$VERSION/i386 >> $LOGFILE 2>&1

## then pkgorder
echo "Getting pkgorder"

/usr/lib/anaconda-runtime/pkgorder \
/centos-3/$VERSION/i386 i386 \
>/centos-3/$VERSION/i386/pkgorder-i386.txt >> $LOGFILE 2>&1

## then genhd again 
echo "Running genhdlist again"

/usr/lib/anaconda-runtime/genhdlist \
--fileorder /centos-3/$VERSION/i386/pkgorder-i386.txt \
/centos-3/$VERSION/i386 >> $LOGFILE 2>&1

## then build installer
echo "Building Installer"

/usr/lib/anaconda-runtime/buildinstall --comp dist-3.0 \
	--pkgorder /centos-3/$VERSION/i386/pkgorder-i386.txt \
	--release final \
	--product CentOS-3 \
	--version 3.0 /centos-3/$VERSION/i386/ >> $LOGFILE 2>&1

echo "Making srpm repo"

cd /centos-3/$VERSION/scripts >> $LOGFILE 2>&1
./mksrpms >> $LOGFILE 2>&1
cd /centos-3/$VERSION >> $LOGFILE 2>&1

echo "Splitting Tree"

/usr/lib/anaconda-runtime/splittree.py --arch=i386 --total-discs=6 \
	--bin-discs=3 --src-discs=3 \
	--release-string=CentOS-3 \
	--pkgorderfile=/centos-3/$VERSION/i386/pkgorder-i386.txt \
	--distdir=/centos-3/$VERSION/i386/ \
	--srcdir=/centos-3/$VERSION/SRPMS/ >> $LOGFILE 2>&1

rm -rf i386-disc* >> $LOGFILE 2>&1

mv i386/-disc1/ i386-disc1 >> $LOGFILE 2>&1
mv i386/-disc2/ i386-disc2 >> $LOGFILE 2>&1
mv i386/-disc3/ i386-disc3 >> $LOGFILE 2>&1
mv i386/-disc4/ i386-disc4 >> $LOGFILE 2>&1
mv i386/-disc5/ i386-disc5 >> $LOGFILE 2>&1
mv i386/-disc6/ i386-disc6 >> $LOGFILE 2>&1

## run genhd on isos
echo "Running genhdlist on isos"

rm /centos-3/$VERSION/i386-disc1/RedHat/base/hdlist* >> $LOGFILE 2>&1

/usr/lib/anaconda-runtime/genhdlist \
--withnumbers --fileorder /centos-3/$VERSION/i386/pkgorder-i386.txt \
/centos-3/$VERSION/i386-disc[123] >> $LOGFILE 2>&1

echo "Building final comps"

## build final comps

rm -f $BUILDDIR/RPMS/i386/comps* >> $LOGFILE 2>&1
rpmbuild -ba $BUILDDIR/SPECS/comps-centos.spec >> $LOGFILE 2>&1
cp $BUILDDIR/SRPMS/comps* $DISTDIR/SRPMS.centos/ >> $LOGFILE 2>&1
rm -f $DISTDIR/i386-disc1/RedHat/RPMS/comps-3* >> $LOGFILE 2>&1
cp $BUILDDIR/RPMS/i386/comps* $DISTDIR/i386-disc1/RedHat/RPMS/ >> $LOGFILE 2>&1
rm -f $DISTDIR/i386-disc1/RedHat/base/comps.rpm >> $LOGFILE 2>&1
cp -f $BUILDDIR/RPMS/i386/comps* $DISTDIR/i386-disc1/RedHat/base/comps.rpm >> $LOGFILE 2>&1

echo "Writing isos"
## write the isos

publisher='Caos Project'
bootimg='isolinux/isolinux.bin'
bootcat='isolinux/boot.cat'
distname='CentOS'
distvers='3.1'
#mkisopts='-r -N -L -d -D -J'
mkisopts='-r -J'
today="$(date '+%d %b %Y')"
mkisofs $mkisopts \
	-V "CentOS-3 Disk 1" \
	-A "CentOS-3 created on $today" \
	-P "$publisher" \
	-p "$publisher" \
	-b "$bootimg" \
	-c "$bootcat" \
	-no-emul-boot -boot-load-size 4 -boot-info-table \
	-x lost+found \
	-o "$distname"-1.iso \
	i386-disc1 >> $LOGFILE 2>&1

/usr/lib/anaconda-runtime/implantisomd5 "$distname"-1.iso >> $LOGFILE 2>&1

for i in 2 3 4 5 6 ; do
	mkisofs $mkisopts \
	-V "CentOS-3 Disk $i" \
	-A "CentOS-3 created $today" \
	-P "$publisher" \
	-p "$publisher" \
	-x lost+found \
	-o "$distname"-${i}.iso \
	i386-disc${i} >> $LOGFILE 2>&1

	/usr/lib/anaconda-runtime/implantisomd5 "$distname"-${i}.iso >> $LOGFILE 2>&1

done

echo "Finished - log is $LOGFILE"

