#!/usr/bin/env bash

# Script that prints out a Major.Minor.Patch version
# based on the VERSION file and the commit history

DEPLOYMAN_COMMIT_TAG=${DEPLOYMAN_COMMIT_TAG:-`cat _deployman/etc/commit-tag`}

function set_major_version() {
    if [ -f "VERSION" ]; then
        MAJOR_VERSION=`cat VERSION`;
    else
        MAJOR_VERSION="0";
    fi
}

function set_minor_version(){
    TEST_MINOR_EXISTS="`git rev-list ${MAJOR_VERSION}.0.0 2>/dev/null`"
    if [ "${TEST_MINOR_EXISTS}" ]; then
        MINOR_VERSION="`git rev-list --merges --count ${MAJOR_VERSION}.0.0..`";
    else
        MINOR_VERSION=0;
    fi
}

function set_patch_version(){
    TEST_MINOR_EXISTS="`git rev-list ${MAJOR_VERSION}.${MINOR_VERSION}.0 2>/dev/null`"
    if [ "${TEST_MINOR_EXISTS}" ]; then
        PATCH_VERSION=`git log --pretty=oneline --abbrev-commit -i --invert-grep --grep="${DEPLOYMAN_COMMIT_TAG}" ${MAJOR_VERSION}.${MINOR_VERSION}.0.. | wc -l | xargs`;
    else
        PATCH_VERSION=0;
    fi
}

GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`;
## Travis checkouts code in a detached mode.
## Can't rely on git to get the branch in that case.
if [ "${TRAVIS}" == "true" ]; then
    GIT_BRANCH=${TRAVIS_BRANCH};
fi

if [ "${GIT_BRANCH}" == "master" ]; then
    set_major_version;
    set_minor_version;
    set_patch_version;
    echo "${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}";
else
    echo "${GIT_BRANCH}";
fi