#!/bin/zsh

printf "--------------------------------------------\n"
printf "Ed's Baseline Hybris Project Setup Script\n"
printf "--------------------------------------------\n"

# echo "> Enter SAP Commerce Zip filename:"
# read commerceZipFilename
# touch "THIS_PROJECT_IS_BASED_ON_"${commerceZipFilename%.zip}

printf "\n\n"
printf "> Enter the full path to project:\n"
read projectDir
# e.g. 
# /Users/i844958/Work/SAP/Projects/Apple/Apple_baseline_1905p10/CXCOMM190500P_14-70004140
# /Users/i844958/Work/SAP/Projects/baseline-cx-2005/CXCOM200500P_0-70004955

# Use the install.sh + recipe to generate the localextensions.xml
printf "\n\n"
printf "> Enter the recipe to use (e.g. cx (2005+),b2b_acc_plus, b2c_acc_plus):\n"
read recipe

if [ ! -z "$recipe" ]; then
    printf "\n\n"
    printf "Running install.sh with recipe [${recipe}]\n"
    printf "--------------------------------------------\n"
    ${projectDir}/installer/install.sh -r ${recipe} -A local_property:initialpassword.admin=nimda
fi

# The recipe may create the "yb2bacceleratorstorefront" extension.
# This extension depends on "yacceleratorxxxx" extensions (e.g "yacceleratorcore"). However, in modulegen, we want to replace "yacceleratorxxx" 
# with the custom extensions (e.g. "trainingcore"). Hence, to make it work, we have to comment out "yb2bacceleratorstorefront" from localextensions.xml 

# Comment out "<meta key="modulegen-name" value="accelerator"/>"" inside yb2bacceleratorstorefront's extensioninfo.xml file.
cp ${projectDir}/hybris/bin/custom/yb2bacceleratorstorefront/extensioninfo.xml ${projectDir}/hybris/bin/custom/yb2bacceleratorstorefront/extensioninfo.xml.ORiG
sed -i '' 's/<meta key="modulegen-name" value="accelerator"\/>/<!-- <meta key="modulegen-name" value="accelerator"\/> -->/g' ${projectDir}/hybris/bin/custom/yb2bacceleratorstorefront/extensioninfo.xml

# Generate the Accelerator extensions.
printf "> Enter project name. Will be used for naming accelerator extensions.\n"
read projectName

if [ ! -z "$projectName" ]; then
    printf "\n\n"
    printf "Using modulegen to setup Accelerator extensions.\n"
    printf "--------------------------------------------\n"
    . ${projectDir}/hybris/bin/platform/setantenv.sh
    ant -f ${projectDir}/hybris/bin/platform/build.xml modulegen -Dinput.module=accelerator -Dinput.name=${projectName} -Dinput.package=de.hybris.${projectName} -Dinput.template=develop
fi

printf "\n\n"
printf "Configuring the project's localextensions.xml\n"
printf "--------------------------------------------\n"

# Comment out "yaccelerator" extensions from localextensions.xml
cp ${projectDir}/hybris/config/localextensions.xml ${projectDir}/hybris/config/localextensions.xml.ORiG
sed -i "" "s/<extension name='yacceleratorbackoffice' \/>/<!-- <extension name='yacceleratorbackoffice' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "s/<extension name='yacceleratorcore' \/>/<!-- <extension name='yacceleratorcore' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "s/<extension name='yacceleratorfacades' \/>/<!-- <extension name='yacceleratorfacades' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "s/<extension name='yacceleratorinitialdata' \/>/<!-- <extension name='yacceleratorinitialdata' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "s/<extension name='yacceleratorstorefront' \/>/<!-- <extension name='yacceleratorstorefront' \/> -->/g" ${projectDir}/hybris/config/localextensions.xml

# Add the Accelerator extensions
# Remove these outer elements...
sed -i "" "/<\/extensions>/d" ${projectDir}/hybris/config/localextensions.xml
sed -i "" "/<\/hybrisconfig>/d" ${projectDir}/hybris/config/localextensions.xml

echo "     <extension name='${projectName}backoffice' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}initialdata' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}test' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}storefront' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}facades' />" >> ${projectDir}/hybris/config/localextensions.xml
echo "     <extension name='${projectName}core' />" >> ${projectDir}/hybris/config/localextensions.xml

# Put these outer elements back...
echo "  </extensions>" >> ${projectDir}/hybris/config/localextensions.xml
echo "</hybrisconfig>" >> ${projectDir}/hybris/config/localextensions.xml

# Edit localextensions.xml
#  - add the generated extensions.
#  - remove the "yaccelerator" extensions.

# Run extgen, with 'ybackoffice' template,
