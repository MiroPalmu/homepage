#!/bin/bash

# This action will:
# - Setup meson to $HOMEPAGE_TEMP_DIR (default: /tmp)
# - Build sphinx target
# - Add .nojekyll (https://stackoverflow.com/questions/59486442/python-sphinx-css-not-working-on-github-pages)
# - Init repository
# - Commit all files
# - Fetch from created repository
# - Sets website branch to FETCH_HEAD

THIS_REPO_ROOT=$(dirname "$0")
MESON_BUILD_ROOT="${HOMEPAGE_TEMP_DIR:=/tmp}/homepage-meson-build-root-${RANDOM}"
SPHINX_BUILD_ROOT="${MESON_BUILD_ROOT}/docs/build"

# To homepage repo root
cd $THIS_REPO_ROOT                                      || { echo "Line number ${LINENO} failed!"; exit; }
# Save current reference at HEAD
HEAD_GIT_REF=$(git rev-parse HEAD)                      || { echo "Line number ${LINENO} failed!"; exit; }
meson setup $MESON_BUILD_ROOT                           || { echo "Line number ${LINENO} failed!"; exit; }
ninja -C $MESON_BUILD_ROOT sphinx                       || { echo "Line number ${LINENO} failed!"; exit; }

# To sphinx build directory
pushd $SPHINX_BUILD_ROOT                                || { echo "Line number ${LINENO} failed!"; exit; }
git init                                                || { echo "Line number ${LINENO} failed!"; exit; }
touch .nojekyll                                         || { echo "Line number ${LINENO} failed!"; exit; }
git add -A                                              || { echo "Line number ${LINENO} failed!"; exit; }
git commit -m "Based on: ${HEAD_GIT_REF}"               || { echo "Line number ${LINENO} failed!"; exit; }

# Back to homepage
popd
git fetch $SPHINX_BUILD_ROOT                            || { echo "Line number ${LINENO} failed!"; exit; }
git branch -f website FETCH_HEAD                        || { echo "Line number ${LINENO} failed!"; exit; }
echo "To update git pages run: git push --force origin website"
