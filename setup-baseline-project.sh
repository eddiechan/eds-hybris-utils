#!/bin/bash

echo "--------------------------------------------"
echo "Eddis's Baseline Hybris Project Setup Script"
echo "--------------------------------------------"

echo "> Enter SAP Commerce Zip filename:"
read commerceZipFilename
touch "THIS_PROJECT_IS_BASED_ON_"${commerceZipFilename%.zip}

unzip $commerceZipFilename && rm $commerceZipFilename



# Generate the localextensions.xml
# ./install.sh -r b2c_acc

# cd ${HYRBIS_HOME}/hybris/bin/platform
# . ./setantenv.sh

# Generate the Accelerator extensions.
# ant modulegen -Dinput.module=accelerator -Dinput.name=training -Dinput.package=de.hybris.training -Dinput.template=develop

# Edit localextensions.xml
#  - add the generated extensions.
#  - remove the "yaccelerator" extensions.


# Run extgen, with 'ybackoffice' template,
