#!/bin/zsh

timerStart=`date +%s`

printf "--------------------------------------------------------\n"
printf "Ed's SAP Commerce Visual Code Analysis Script\n"
printf "--------------------------------------------------------\n"

outputRootDirectory="$HOME/Downloads" # Hardcoded to "Downloads" directory for now.. 

printf "\n"
printf "> Enter the full path to project's 'custom' directory:\n"
read projectCustomDir

printf "\n"
printf "> Enter project name (e.g. 'mujiCodeReview-201704'):\n"
read projectName

outputDirectory=${outputRootDirectory}/visualCodeAnalysisOutput_${projectName}
mkdir -p ${outputDirectory}

# Web Modules check. Lists extensions that define a webmobule.
printf "\n"
printf "--- Detecting extensions that declare a webmodule...\n"
grep -r "webmodule" $projectCustomDir/* --include "extensioninfo.xml" > $outputDirectory/webmodule_check_output.txt
sed -i '' 's/^/* /' $outputDirectory/webmodule_check_output.txt

# Controllers check.
printf "\n"
printf "--- Searching for Controllers that reference: Models, DAOs, and Services...\n"
grep -r "import .*model.*" $projectCustomDir/* | sed -n '/Controller.java/p' | sed -e "s,$projectCustomDir,,g" > $outputDirectory/controllers-using-models.txt
grep -r "import .*dao.*" $projectCustomDir/* | sed -n '/Controller.java/p' | sed -e "s,$projectCustomDir,,g" > $outputDirectory/controllers-using-daos.txt
grep -r "import .*servicelayer.*Service.*" $projectCustomDir/* | sed -n '/Controller.java/p' | sed -e "s,$projectCustomDir,,g" > $outputDirectory/controllers-using-services.txt

# # Facades check.
printf "\n"
printf "--- Searching for Facades that reference: DAOs, Models...\n"
grep -r "import .*dao.*" $projectCustomDir/* | sed -n '/FacadeImpl/p' | sed -e "s,$projectCustomDir,,g" > $outputDirectory/facades-using-daos.txt;
grep -r "= .*new.*Model().*" $projectCustomDir/* | sed -n '/FacadeImpl/p' | sed -e "s,$projectCustomDir,,g" > $outputDirectory/facades-instantiate-models.txt;
grep -r "getModelService().create" $projectCustomDir/* | sed -n '/FacadeImpl/p' | sed -e "s,$projectCustomDir,,g" >> $outputDirectory/facades-instantiate-models.txt;
grep -r ".*\.set.*(.*\.get.*" $projectCustomDir/* | sed -n '/FacadeImpl/p' | sed -e "s,$projectCustomDir,,g" > $outputDirectory/facades-populate-objects.txt;

# Services check.
printf "\n"
printf "--- Searching for Services with FlexibleSearch queries...\n"
grep -r "import .*FlexibleSearchQuery.*" $projectCustomDir/* | sed -n '/ServiceImpl/p' | sed -e "s,$projectCustomDir,,g" > $outputDirectory/services-using-flexiblesearch.txt;

# DAOs check.
printf "\n"
printf "--- Searching for DAOs with hardcoded FlexibleSearch queries...\n"
grep -Ri "SELECT" $projectCustomDir/* | grep -i dao | grep java | grep -v Model | sed -e "s,$projectCustomDir,,g" > $outputDirectory/daos-hardcoded-flexible.txt;

# # TSV - Type System Validation
# # echo "--- Running Type System Validation..."
# # declare -a arr=("globallinkpackage/globallink" "hpe/hpecore" "hpe/hpefulfilmentprocess" "hpe/hpeintegrations" "hpe/hpemulticountry" "mirakl/mirakladdon" "mirakl/miraklfulfilmentprocess" "mirakl/miraklservices" "multicountrypackage/multicountry") # FIXME: the list of extensions that have items.xml files. this is manually defined. How to make it automatic?
# # for i in "${arr[@]}"
# # do
# #    echo "Running TSV on: $i..."
# #    # java -jar "$TSV_JAR_PATH/tsv-2.1.2-jar-with-dependencies.jar" -o "$outputDirectory/temp_tsv_$i.csv" "$projectCustomDir/gcpplus/$i/resources" # FIXME: this is manually defined. How to make it automatic?
# #    java -jar "$TSV_JAR_PATH/tsv-2.1.2-jar-with-dependencies.jar" -o "$outputDirectory/temp_tsv_$i.csv" "$projectCustomDir/$i/resources"
# # done

# cat $outputDirectory/temp_tsv_*.csv > $outputDirectory/TypeSystemValidation_results.csv
# rm $outputDirectory/temp_tsv_*.csv

# Output timer stats.
# -----------------------------------------
timerEnd=`date +%s`
timerElapsedSeconds=$((timerEnd-timerStart))
timerElapsedMinutes=$((timerElapsedSeconds/60))
printf "\n\n"
printf "--------------------------------------------------------\n"
printf "Visual code analysis complete! Results can be found in: ${outputDirectory}\n"
printf "This script took $timerElapsedMinutes minutes to run.\n"
printf "bye.\n\n\n"