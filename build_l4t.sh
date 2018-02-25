#!/bin/bash
# simple bash script for executing build

# root directory of NetHunter Mipad1[mocha] git repo (default is this script's location)
RDIR=$(pwd)

[ "$VER" ] ||
# version number
VER=$(cat "$RDIR/VERSION")

#Make binary
 if [ -f /usr/local/bin/make ] ; then
        MAKE=/usr/local/bin/make
  else 
       MAKE=make
   fi


############## Variables for build env..##############
   
# ARCH
ARCH=arm
# Target deconfig name  
DEVICE_DEFCONFIG=mocha_linux_defconfig 
 
#default dtb name..
DTBNAME=tegra124-mocha.dtb

# Flevor

FLEVOR=Linux4tegra 

##########################################################


############## SCARY NO-TOUCHY STUFF ###############
BUILD=$RDIR/../BUILD
zImage=$BUILD/arch/${ARCH}/boot/zImage
DTBFILES=$BUILD/arch/arm/boot/dts
DTB=$BUILD/DTB
FWR=$BUILD/lib/firmware
MOD=$BUILD/lib/modules
MDIR=$BUILD/MODULES_DIR
TV=$BUILD/thevirus
ZS=Thevirus_kernel_flasher-signed.zip


export ARCH=${ARCH}
export CROSS_COMPILE=arm-linux-gnueabihf-  

 
  DEFCONFIG=${DEVICE_DEFCONFIG}


export LOCALVERSION=-V$VER-$FLEVOR

	if [ -d $BUILD ] ; then
                 echo "You have already build folder.."
 else
	   mkdir -p $BUILD
	
	fi
if [ -f $zImage ]; then
   rm -r $zImage
   
   fi

         $MAKE -C "$RDIR" O=$BUILD "$DEFCONFIG"
	 $MAKE -C "$RDIR" O=$BUILD menuconfig



 echo " "
	echo "Starting build for $LOCALVERSION..."
	 $MAKE -C "$RDIR" O=$BUILD zImage
		
	if [ -f $zImage ] ; then
  	{
	echo "Creating dtb for $LOCALVERSION..."
	
          $MAKE -C "$RDIR" O=$BUILD "dtbs"	
      if [ -d $DTB ] ; then
                 echo "You have already ${DTB} folder.."
             rm -rf $DTB/*
          else 
	         mkdir -p $DTB 
	fi
             
           cp -R `find $DTBFILES -name "*.dtb"` $DTB 
            echo "collect dtb files from ${DTB} folder ..  \n"
      if [ -d $MDIR ] ; then
       rm -rf $MDIR/*
      else 
        mkdir -p $MDIR 
      fi
	echo "Installing kernel modules to ${MDIR}..." 
           $MAKE -C "$RDIR" O=$BUILD modules
	   $MAKE -C "$RDIR" O=$BUILD INSTALL_MOD_PATH=$MDIR modules_install 
          # $MAKE -C "$RDIR" O=$BUILD INSTALL_HDR_PATH=$MDIR headers_install_all   
          rm -rf $MDIR/lib/modules/*/build $MDIR/lib/modules/*/source 
                
        }
      fi

if [ -f $zImage ]; then
   {
   
	echo "Making flashable zip.."
 echo " "
  if [ -d $TV ]; then
      echo "you have already cloned"
   else
       echo "Downloading required files...."
    git clone https://github.com/RahulTheVirus/kernel_flasher.git $TV

  fi
   
     mkdir -p $TV/src
     rm -rf $TV/src/*
      rm -rf $TV/src/zImage
     cp $zImage $TV/src/zImage
     

if [ -d $MDIR ]; then
    cp -R $MDIR/lib/modules $TV/src/ 
         
      fi 
     
   if [ -f $DTB/$DTBNAME ]; then
    cp $DTB/$DTBNAME $TV/src/default.dtb 
         
      fi 
      
if [ -d $FWR ]; then
    mkdir -p $TV/src/firmware
    chmod 777 $TV/src/firmware
      rm -rf $TV/firmware
      cp -R $FWR $TV/src/
      
      fi

 cd $TV
 
 . build.sh
 
 if [ -f $TV/sign/$ZS ]; then
    {
         if [ -f $BUILD/*.zip ]; then
	 echo "CLRANING OLD ZIP"
         rm -r $BUILD/*.zip
    
       fi
       
    chmod 777 $TV/sign/$ZS
    cp -R $TV/sign/$ZS $BUILD/${FLEVOR}_${LOCALVERSION}-signed.zip
    echo " Done ! " \n
	echo "Collect ${BUILD}/${FLEVOR}_${LOCALVERSION}-signed.zip File..."
    
       }
   
       fi
     }
   fi
     cd $RDIR
	echo " Done ! "

