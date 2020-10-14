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

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
	EVENT_ACTION=$(jq -r ".action" "${GITHUB_EVENT_PATH}")

	if [[ "${EVENT_ACTION}" != "opened" ]]; then
		echo "pull request opened"
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
			-Dsonar.branch.name=${GITHUB_HEAD_REF} \
			-Dsonar.branch.target=${GITHUB_BASE_REF} \
			-Dsonar.pullrequest.base=${BASE_BRANCH} \
			-Dsonar.pullrequest.branch=${GITHUB_HEAD_REF} \
			-Dsonar.pullrequest.key=${GITHUB_REF#$pr_prefix}
	fi
else
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



