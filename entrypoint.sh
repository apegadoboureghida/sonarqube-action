#!/bin/bash

set -e

REPOSITORY_NAME=$(basename "${GITHUB_REPOSITORY}")

[[ ! -z ${INPUT_PASSWORD} ]] && SONAR_PASSWORD="${INPUT_PASSWORD}" || SONAR_PASSWORD=""
[[ -z ${INPUT_PROJECTKEY} ]] && SONAR_PROJECTKEY="${REPOSITORY_NAME}" || SONAR_PROJECTKEY="${INPUT_PROJECTKEY}"
[[ -z ${INPUT_PROJECTNAME} ]] && SONAR_PROJECTNAME="${REPOSITORY_NAME}" || SONAR_PROJECTNAME="${INPUT_PROJECTNAME}"
[[ -z ${INPUT_PROJECTVERSION} ]] && SONAR_PROJECTVERSION="" || SONAR_PROJECTVERSION="${INPUT_PROJECTVERSION}"
prefix="refs/heads/"
pr_prefix="refs/pull/"
pr_suffix="/merge"


echo "${GITHUB_EVENT_NAME}"
echo "${BASE_BRANCH}"
echo "${GITHUB_EVENT_NUMBER}"
echo "${GITHUB_HEAD_REF}"
echo "${GITHUB_BASE_REF}"
echo "${EVENT_ACTION}"

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
	echo "Fire 1"
	EVENT_ACTION=$(jq -r ".action" "${GITHUB_EVENT_PATH}")
	echo "${EVENT_ACTION}"
	if [[ "${EVENT_ACTION}" != "" ]]; then
		echo "Fire 2"
		id=${GITHUB_REF}
		id=${id#$pr_prefix}
		id=${id%$pr_suffix}
		
		sha=${GITHUB_SHA}
		echo "pull request opened"
		echo "ID: ${id}"
		echo "Branch: ${GITHUB_HEAD_REF}"
		echo "Base: ${GITHUB_BASE_REF}"
		echo "SHA:" ${sha}
		echo "Key: ${GITHUB_EVENT_NUMBER}"

		sonar-scanner \
			-Dsonar.host.url=${INPUT_HOST} \
			-Dsonar.projectKey=${SONAR_PROJECTKEY} \
			-Dsonar.projectName=${SONAR_PROJECTNAME} \
			-Dsonar.projectVersion=${SONAR_PROJECTVERSION} \
			-Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} \
			-Dsonar.login=${INPUT_LOGIN} \
			-Dsonar.password=${INPUT_PASSWORD} \
			-Dsonar.sources=. \
			-Dsonar.sourceEncoding=UTF-8 \
			-Dsonar.key=${GITHUB_EVENT_NUMBER} \
			-Dsonar.pullrequest.base=${GITHUB_BASE_REF} \
			-Dsonar.pullrequest.branch=${GITHUB_HEAD_REF} \
			-Dsonar.pullrequest.key=${id} \
			-Dsonar.scm.revision=${sha}
	fi
else
echo "Fire 3"
sonar-scanner \
	-Dsonar.host.url=${INPUT_HOST} \
	-Dsonar.projectKey=${SONAR_PROJECTKEY} \
	-Dsonar.projectName=${SONAR_PROJECTNAME} \
	-Dsonar.projectVersion=${SONAR_PROJECTVERSION} \
	-Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} \
	-Dsonar.login=${INPUT_LOGIN} \
	-Dsonar.password=${INPUT_PASSWORD} \
	-Dsonar.sources=. \
	-Dsonar.sourceEncoding=UTF-8 \
	-Dsonar.branch.name=${GITHUB_REF#$prefix}

fi



