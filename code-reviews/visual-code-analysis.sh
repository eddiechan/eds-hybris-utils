export VISUAL_REVIEW_OUTPUT=~/Downloads ## ChangeMe as needed.
export TSV_JAR_PATH=/Users/i844958/Work/SAP/Tools/tsv/target

echo "--------------------------------------------"
echo "Ed Chan's Visual Code Analysis Script"
echo "--------------------------------------------"

echo "> Enter project name (e.g. 'mujiCodeReview-201704'):"
read projectName

echo "> Enter the full path to the project's 'hybris/bin/custom' directory (e.g. '/Users/i844958/Work/SAP/Projects/HPE/2019-09_CodeReview/commerce-suite-6.7.0.0-RELEASE/hybris/bin/custom'):"
read projectPath

# TODO: check the projectPath that the user entered is valid. If not, fail. 

export outputPath=$VISUAL_REVIEW_OUTPUT/$projectName
mkdir -p $outputPath

# Web Modules check. Lists extensions that define a webmobule.
echo "--- Detecting extensions that declare a webmodule..."
grep -r "webmodule" $projectPath/* --include "extensioninfo.xml" > $outputPath/webmodule_check_output.txt
sed -i'.bak' -e "s/^/* /" $outputPath/webmodule_check_output.txt

# Controllers check.
echo "--- Searching for Controllers that reference: Models, DAOs, and Services..."
grep -r "import .*model.*" $projectPath/* | sed -n '/Controller.java/p' | sed -e "s,$projectPath,,g" > $outputPath/controllers-using-models.txt
grep -r "import .*dao.*" $projectPath/* | sed -n '/Controller.java/p' | sed -e "s,$projectPath,,g" > $outputPath/controllers-using-daos.txt
grep -r "import .*servicelayer.*Service.*" $projectPath/* | sed -n '/Controller.java/p' | sed -e "s,$projectPath,,g" > $outputPath/controllers-using-services.txt

# Facades check.
echo "--- Searching for Facades that reference: DAOs, Models..."
grep -r "import .*dao.*" $projectPath/* | sed -n '/FacadeImpl/p' | sed -e "s,$projectPath,,g" > $outputPath/facades-using-daos.txt;
grep -r "= .*new.*Model().*" $projectPath/* | sed -n '/FacadeImpl/p' | sed -e "s,$projectPath,,g" > $outputPath/facades-instantiate-models.txt;
grep -r "getModelService().create" $projectPath/* | sed -n '/FacadeImpl/p' | sed -e "s,$projectPath,,g" >> $outputPath/facades-instantiate-models.txt;
grep -r ".*\.set.*(.*\.get.*" $projectPath/* | sed -n '/FacadeImpl/p' | sed -e "s,$projectPath,,g" > $outputPath/facades-populate-objects.txt;

# Services check.
echo "--- Searching for Services with FlexibleSearch queries..."
grep -r "import .*FlexibleSearchQuery.*" $projectPath/* | sed -n '/ServiceImpl/p' | sed -e "s,$projectPath,,g" > $outputPath/services-using-flexiblesearch.txt;

# DAOs check.
echo "--- Searching for DAOs with hardcoded FlexibleSearch queries..."
grep -Ri "SELECT" $projectPath/* | grep -i dao | grep java | grep -v Model | sed -e "s,$projectPath,,g" > $outputPath/daos-hardcoded-flexible.txt;

# TSV - Type System Validation
# echo "--- Running Type System Validation..."
# declare -a arr=("globallinkpackage/globallink" "hpe/hpecore" "hpe/hpefulfilmentprocess" "hpe/hpeintegrations" "hpe/hpemulticountry" "mirakl/mirakladdon" "mirakl/miraklfulfilmentprocess" "mirakl/miraklservices" "multicountrypackage/multicountry") # FIXME: the list of extensions that have items.xml files. this is manually defined. How to make it automatic?
# for i in "${arr[@]}"
# do
#    echo "Running TSV on: $i..."
#    # java -jar "$TSV_JAR_PATH/tsv-2.1.2-jar-with-dependencies.jar" -o "$outputPath/temp_tsv_$i.csv" "$projectPath/gcpplus/$i/resources" # FIXME: this is manually defined. How to make it automatic?
#    java -jar "$TSV_JAR_PATH/tsv-2.1.2-jar-with-dependencies.jar" -o "$outputPath/temp_tsv_$i.csv" "$projectPath/$i/resources"
# done

cat $outputPath/temp_tsv_*.csv > $outputPath/TypeSystemValidation_results.csv
rm $outputPath/temp_tsv_*.csv