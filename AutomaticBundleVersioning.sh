#!/bin/bash

set -o nounset

oldPath="${PWD}"

cd "$(git rev-parse --show-toplevel)"

# * * *.

commitSHA1=$(git rev-parse HEAD)

echo "Commit SHA1: ${commitSHA1}"

# * * *.

commitsCount=$(git rev-list --count HEAD 2>/dev/null)

echo "Commits count: ${commitsCount}"

# * * *.

versionTagOrNil=$(git describe --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' HEAD 2>/dev/null)

echo "Version tag: ${versionTagOrNil}"

# * * *.

versionTagWithoutPrefixOrNil=${versionTagOrNil##v}

echo "Version tag without prefix: ${versionTagWithoutPrefixOrNil}"

# * * *.

if [ $versionTagOrNil ]; then
  commitsSinceLastTag=$(git rev-list --count ${versionTagOrNil}..)
else
  commitsSinceLastTag=$commitsCount
fi

echo "Commits since last tag: ${commitsSinceLastTag}"

# * * *.

test -z "$(git status --untracked-files=normal --porcelain)"

isWorkingCopyDirty="${?}"

if [ $isWorkingCopyDirty -eq 1 ]; then
  message="${commitSHA1}-dirty"
else
  message="$commitSHA1"
fi

echo "isDirty: ${isWorkingCopyDirty}"

# * * *.

branchName=$(git rev-parse --symbolic-full-name --verify "$(git name-rev --name-only --no-undefined HEAD 2>/dev/null)" 2>/dev/null | sed -e 's:refs/heads/::' | sed -e 's:refs/::')

echo "Branch name: ${branchName}"

# * * *.

/usr/libexec/PlistBuddy -c "Delete :ABVGitCommitSHA1" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

/usr/libexec/PlistBuddy -c "Add :ABVGitCommitSHA1 string $message" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

# * * *.

function setBundleVersion()
{
  /usr/libexec/PlistBuddy -c "Delete :CFBundleVersion" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
  /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $1" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

  if [ "$DEBUG_INFORMATION_FORMAT" == "dwarf-with-dsym" ]; then
    /usr/libexec/PlistBuddy -c "Delete :CFBundleVersion" "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $1" "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"
  fi
}

setBundleVersion $commitsCount

# * * *.

function setBundleShortVersionString
{
  local fullString

  if [ $2 -gt 0 ]; then
    fullString="$1+$2"
  else
    fullString="$1"
  fi

  /usr/libexec/PlistBuddy -c "Delete :CFBundleShortVersionString" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
  /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $fullString" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

  if [ "$DEBUG_INFORMATION_FORMAT" == "dwarf-with-dsym" ]; then
    /usr/libexec/PlistBuddy -c "Delete :CFBundleShortVersionString" "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $fullString" "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"
  fi
}

if [ $versionTagWithoutPrefixOrNil ]; then
  setBundleShortVersionString $versionTagWithoutPrefixOrNil $commitsSinceLastTag
else
  setBundleShortVersionString 0.0.0 $commitsCount
fi

# * * *.

echo "AutomaticBundleVersioning: success."

cd "${oldPath}"
