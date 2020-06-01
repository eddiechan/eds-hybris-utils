#!/bin/zsh

timerStart=`date +%s`

printf "--------------------------------------------------------\n"
printf "Ed's SAP Commerce with custom Accelerator Project Setup Script\n"
printf "--------------------------------------------------------\n"

printf "Pre-requisites for using this script:\n"
printf "- SAP Commerce (download from: https://launchpad.support.sap.com/#/softwarecenter/search/CX)\n"
printf "- jEnv (https://www.jenv.be/)\n"

printf "\n\n"
printf "> Enter the full path to project (i.e. the unzipped SAP Commerce product):\n"
read projectDir

# Set the Java version using jenv.
# -----------------------------------------
printf "\n\n"
printf "SAP Commerce 1905+ requires Java 11. Older versions require Java 8.\n"
printf "Choices are:\n"
(cd ${projectDir}; jenv versions)
printf "> Enter the version of Java to use for this project.\n"
read jenvVersionToUse
(cd ${projectDir}; jenv local ${jenvVersionToUse})


# Use SAP Installer Recipe to setup directories, configuration, etc.
# -----------------------------------------
printf "\n\n"
${projectDir}/installer/install.sh --list-recipes
printf "> Enter the SAP Installer Recipe to use:\n"
printf "> Recommended recipe is 'cx' for SAP Commerce 2005+; 'b2b_acc_plus' or 'b2c_acc_plus' for older versions of SAP Commerce.\n"
read recipe

if [ ! -z "$recipe" ]; then
    printf "\n\n"
    printf "Running install.sh with recipe [${recipe}]\n"
    printf "--------------------------------------------------------\n"
    ${projectDir}/installer/install.sh -r ${recipe} -A local_property:initialpassword.admin=nimda
fi

# The recipe may create the "yb2bacceleratorstorefront" extension. Don't use this extension as we will instead generate custom extensions with modulegen.
# Comment out "<meta key="modulegen-name" value="accelerator"/>"" inside yb2bacceleratorstorefront's extensioninfo.xml file.
cp ${projectDir}/hybris/bin/custom/yb2bacceleratorstorefront/extensioninfo.xml ${projectDir}/hybris/bin/custom/yb2bacceleratorstorefront/extensioninfo.xml.ORiG
sed -i '' 's/<meta key="modulegen-name" value="accelerator"\/>/<!-- <meta key="modulegen-name" value="accelerator"\/> -->/g' ${projectDir}/hybris/bin/custom/yb2bacceleratorstorefront/extensioninfo.xml

# Generate the Accelerator extensions using modulegen.
# -----------------------------------------
printf "\n\n"
printf "> Enter a custom project name. E.g. 'training'. This will be used for naming the accelerator extensions.\n"
read projectName

printf "\n\n"
printf "> Enter a custom package name. E.g. 'com.hybris.training'. This will be used in accelerator code.\n"
read customPackageName

if [ ! -z "$projectName" ]; then
    printf "\n\n"
    printf "Using modulegen to setup Accelerator extensions.\n"
    printf "--------------------------------------------------------\n"
    . ${projectDir}/hybris/bin/platform/setantenv.sh
    ant -f ${projectDir}/hybris/bin/platform/build.xml modulegen -Dinput.module=accelerator -Dinput.name=${projectName} -Dinput.package=${customPackageName} -Dinput.template=develop
fi

# Configure localextensions.xml to (1) exclude Accelerator template extensions and (2) include generated Accelerator extensions.
# -----------------------------------------
printf "\n\n"
printf "Configuring the project's localextensions.xml\n"
printf "--------------------------------------------------------\n"

# Comment out "yaccelerator" template extensions.
cp ${projectDir}/hybris/config/localextensions.xml ${projectDir}/hybris/config/localextensions.xml.ORiG
sed -i "" "s/<extension name='yb2bacceleratorstorefront' \/>/<\!-- <extension name='yb2bacceleratorstorefront' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "s/<extension name='yacceleratorbackoffice' \/>/<\!-- <extension name='yacceleratorbackoffice' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "s/<extension name='yacceleratorcore' \/>/<\!-- <extension name='yacceleratorcore' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "s/<extension name='yacceleratorfacades' \/>/<\!-- <extension name='yacceleratorfacades' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "s/<extension name='yacceleratorinitialdata' \/>/<\!-- <extension name='yacceleratorinitialdata' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "s/<extension name='yacceleratorstorefront' \/>/<\!-- <extension name='yacceleratorstorefront' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml

# Add the generated Accelerator extensions
# First, remove the outer elements.
sed -i "" "/<\/extensions>/d" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "/<\/hybrisconfig>/d" ${projectDir}/hybris/config/localextensions.xml
# Second, add the generated Accelerators.
echo "     <extension name='${projectName}backoffice' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}initialdata' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}test' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}storefront' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}facades' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}core' />" >> ${projectDir}/hybris/config/localextensions.xml
# Third, put the outer elements back.
echo "  </extensions>" >> ${projectDir}/hybris/config/localextensions.xml
echo "</hybrisconfig>" >> ${projectDir}/hybris/config/localextensions.xml

# TODO: Run extgen, with 'ybackoffice' template?

# Initialize and build SAP Commerce.
# -----------------------------------------
printf "\n\n"
printf "Build and initializing project..\n"
printf "--------------------------------------------------------\n"
. ${projectDir}/hybris/bin/platform/setantenv.sh
ant -f ${projectDir}/hybris/bin/platform/build.xml clean all
ant -f ${projectDir}/hybris/bin/platform/build.xml initialize

# Output timer stats.
# -----------------------------------------
timerEnd=`date +%s`
timerElapsedSeconds=$((timerEnd-timerStart))
timerElapsedMinutes=$((timerElapsedSeconds/60))
printf "--------------------------------------------------------\n"
printf "This script took $timerElapsedMinutes minutes to run.\n"
printf "bye.\n\n\n"