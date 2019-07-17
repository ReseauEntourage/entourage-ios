#!/bin/bash

# Fail if any command fails
set -e

# Read all tags, separate them into an array
all_tags=`git tag -l | wc -l`

if [ $all_tags = 0 ]; then
    # No tags, exit.
    echo "Repository contains no tags. Please make a tag first."
    exit 1
else
    #echo "Fetching commits since last tag."

    # We have many tags, fetch since last one
    latest_tag=`git describe --tags  --abbrev=0`
    build=`git rev-list HEAD --count`
    previous_tag="$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"

    previous_tag="Version_4.6.837"
    previous_tag="Ent_5.3.971"
    previous_tag="Ent_5.4.974"
    previous_tag="Ent_5.4.1.990"
    previous_tag="Ent_5.5.1002"
    previous_tag="Ent_5.7.1015"
    previous_tag="Ent_5.8.1024"
    previous_tag="Ent_5.8.1.1076"
    previous_tag="Ent_6.0.1124"
    previous_tag="Ent_6.0.5.1155"

    filename="GITCHANGELOG-FROM-$previous_tag-TO-$latest_tag.md"
    echo "#Changelog" > $filename
    echo "##Latest tag: $latest_tag" >> $filename
    echo "##Previous tag: $previous_tag" >> $filename

    # Get commit messages since previous tag
    changelog="$(git log --no-merges --pretty=format:"* %s (%cd) by <%cn>" --date=short $previous_tag...$latest_tag)"
    echo "$changelog" >> $filename
    echo  "Created file: $filename"
fi

# Output collected information

# Set environment variable for bitrise
#envman add --key COMMIT_CHANGELOG --value "$changelog"

exit 0
