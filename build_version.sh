#!/usr/bin/env bash
set -x
set -o pipefail
export PS4='+{$LINENO `date "+%Y-%m-%d_%H:%M:%S"` :${FUNCNAME[0]}}    '
cur=`dirname "${0}"`
cd "${cur}"
cur=`pwd`

BUILD_DATE_TIME=`date`
BUILD_HOSTNAME=`hostname`
BUILD_GCC_VERSION=`gcc --version | head -n 1`

gen_info_template_header ()
{
    echo "// Generated by the build_version.sh.  DO NOT EDIT!"
    echo " "
    echo "#include <iostream>"
    echo "#include \"version.h\""
    echo "const char kGitInfo[] = \"\\"
}


gen_info_template_foot ()
{
    echo "\";"
    echo "const char kBuildTime[] = \"$BUILD_DATE_TIME\";"
    echo "const char kBuilderName[] = \"$USER\";"
    echo "const char kHostName[] = \"$BUILD_HOSTNAME\";"
}

gen_info_print_template ()
{
    echo "void PrintSystemVersion() {"
    echo "    std::cout << \"Baidu File System v\" << kMajorVersion << \".\" << kMinorVersion << \".\" << kRevision << std::endl;"
    echo "    std::cout << \"=====  Git Info ===== \" << std::endl;"
    echo "    std::cout << kGitInfo << std::endl;"
    echo "    std::cout << \"=====  Build Info ===== \" << std::endl;"
    echo "    std::cout << \"Build Time: \" << kBuildTime << std::endl;"
    echo "    std::cout << \"Builder Name: \" << kBuilderName << std::endl;"
    echo "    std::cout << \"Build Host Name: \" << kHostName << std::endl;"
    echo "    std::cout << \"Build Compiler: \" << kCompiler << std::endl;"
    echo "    std::cout << std::endl;"
    echo "};"
}

TEMPLATE_HEADER_FILE=template_header.tmp
TEMPLATE_FOOT_FILE=template_foot.tmp
GIT_INFO_FILE=git_info.tmp
VERSION_CPP_FILE=src/version.cc

# generate template file
git remote -v | sed 's/$/&\\n\\/g' > $GIT_INFO_FILE
git log | head -n 3 | sed 's/$/&\\n\\/g' >> $GIT_INFO_FILE
gen_info_template_header > $TEMPLATE_HEADER_FILE
gen_info_template_foot > $TEMPLATE_FOOT_FILE
gen_info_print_template >> $TEMPLATE_FOOT_FILE

# generate version cpp
cat $TEMPLATE_HEADER_FILE $GIT_INFO_FILE $TEMPLATE_FOOT_FILE > $VERSION_CPP_FILE
rm -rf $TEMPLATE_HEADER_FILE $GIT_INFO_FILE $TEMPLATE_FOOT_FILE
