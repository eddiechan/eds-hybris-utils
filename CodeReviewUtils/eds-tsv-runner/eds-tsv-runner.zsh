#!/bin/zsh

#### vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv ---- Change line below!
pathToTSVJar="/Users/i844958/Work/SAP/Tools/tsv/target"
#### ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ---- Change line above!

timerStart=`date +%s`

printf "--------------------------------------------------------\n"
printf "Ed's TSV Runner Script\n"
printf "--------------------------------------------------------\n"

outputRootDirectory="$HOME/Downloads" # Hardcoded to "Downloads" directory for now.. 

printf "\n"
printf "> Enter the full path to project's 'custom' directory:\n"
read projectCustomDir

printf "\n"
printf "> Enter project name (e.g. 'mujiCodeReview-201704'):\n"
read projectName

outputDirectory=${outputRootDirectory}/tsvOutput_${projectName}
mkdir -p ${outputDirectory}

# TSV - Type System Validation
printf "\n"
printf "--- Running Type System Validation...\n"

# FIXME: the list of extensions that have items.xml files. this is manually defined. How to make it automatic?
#### vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv ---- Change line below!
# declare -a arr=("globallinkpackage/globallink" "hpe/hpecore" "hpe/hpefulfilmentprocess" "hpe/hpeintegrations" "hpe/hpemulticountry" "mirakl/mirakladdon" "mirakl/miraklfulfilmentprocess" "mirakl/miraklservices" "multicountrypackage/multicountry" "multicountrypackage/contextualattributevalues" "multicountrypackage/multicountry" "arvatoAvalaraConnector") 
declare -a arr=("commonaddon" "cybersourceb2bpaymentaddon" "cybersourcepayment" "cybersourcepaymentaddon" "fbmbackoffice" "fbmcheckoutflowaddon" "fbmcore" "fbmcybersourceaddon" "fbmfacades" "fbminitialdata" "fbmordermanagement" "fbmshoppinglist" "fbmstorefront" "fbmwebservicesclient" "qspcommerceorgaddon") 
#### ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ---- Change line above!

for currentExtension in "${arr[@]}"
do
    printf "\n"
    printf "--Running TSV on: $currentExtension...\n"
    java -jar "${pathToTSVJar}/tsv-2.1.2-jar-with-dependencies.jar" -o "${outputDirectory}/temp_tsv_${currentExtension//\//}.csv" "${projectCustomDir}/${currentExtension}/resources"
done

cat $outputDirectory/temp_tsv_*.csv > $outputDirectory/TypeSystemValidation_results.csv
rm $outputDirectory/temp_tsv_*.csv

# Output timer stats.
# -----------------------------------------
timerEnd=`date +%s`
timerElapsedSeconds=$((timerEnd-timerStart))
timerElapsedMinutes=$((timerElapsedSeconds/60))
printf "\n\n"
printf "--------------------------------------------------------\n"
printf "TSV analysis complete! Results can be found in: ${outputDirectory}\n"
printf "This script took $timerElapsedMinutes minutes to run.\n"
printf "bye.\n\n\n"