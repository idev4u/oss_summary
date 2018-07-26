#!/bin/bash -ex

HOME_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
WORKDIR=""${PWD%/*}""

output_file=commit_summary.txt

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo 'usage ./get-commits.sh -c "<your name>" -g "<github user>" '
    exit 1
fi

# cli option parser
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -c|--committer)
    Committer="$2"
    shift # past argument
    shift # past value
    ;;
    -g|--github_id)
    Github_Id="$2"
    shift # past argument
    shift # past value
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)    # unknown option
    ;;
esac
done

# cli option validation
if [ -z "$Committer" ]
  then
    echo "No committer supplied"
    echo 'usage ./get-commits.sh -c "<your name>" -g "<github user>" '
    exit 1
fi

if [ -z "$Github_Id" ]
  then
    echo "No github  supplied"
    echo 'usage ./get-commits.sh -c "<your name>" -g "<github user>" '
    exit 1
fi

# cleanup old summary file
if [ -f ${output_file} ]; then
 rm -f ${output_file}
fi

# generate commit count summary
echo "Committer name: ${Committer} / Github Id:  ${Github_Id}" >> ${output_file}
echo "" >> ${output_file}

projects="bits-service-ci bits-service-client bits-service-release bits-service-migration-tests bosh-deployment cf-deployment cloud_controller_ng bits-service bitsgo"

for project in ${projects}
do
    pushd ${WORKDIR}/${project} > /dev/null
        url=$(git remote get-url --all origin)
        commit_count=$(git log --all --pretty=medium --after="2017-07-01" --until="2018-06-30" --grep="$(echo ${Committer})" | grep "commit" | wc -l )
    popd > /dev/null
    echo "Project name: ${project} url:  ${url}">> ${output_file}
    echo "Commit count: ${commit_count} " >> ${output_file}
done

echo "Commit summary has been written to commit_summary.txt"
exit 0

