#/bin/bash

INITIAL_LD_LIBRARY_PATH=$LD_LIBRARY_PATH

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

binary_path=`dirname $BINARY`
binary_name=`basename $BINARY`

$CONFIG
#original f1x execution
rm -rf original.txt
pushd $SUBJECT_DIR > /dev/null
  /src/f1x-oss-fuzz/repair/CInterface/profile -f $BUGGY_FILE -t $TESTCASE -T $T_TIMEOUT -d $DRIVER -b $BUILD --output-one-per-loc -a -P $binary_path -N $binary_name -M 16 &> $SUBJECT_DIR/original.txt
popd > /dev/null

location=`cat $SUBJECT_DIR/location.txt`
#$SUBJECT_DIR/afl-generateDistance.sh $location

#export CFLAGS="$CFLAGS_INSTALL -distance=$OUT/distance.cfg.txt"
#export CXXFLAGS="$CXXFLAGS_INSTALL -distance=$OUT/distance.cfg.txt"

#execute f1x with fuzzing
: '
pushd $SUBJECT_DIR > /dev/null
  make clean
  make distclean
  ./project_config.sh
popd > /dev/null
'
rm -rf f1x_with_fuzzing.txt

cooling_time=120m
export LD_LIBRARY_PATH=$binary_path:$LD_LIBRARY_PATH
export AFL_NO_AFFINITY=" "

mkdir -p $SUBJECT_DIR/patches
f1x_cmd="f1x -f $BUGGY_FILE -t $TESTCASE -T $T_TIMEOUT -d $DRIVER -b $BUILD -a -P $binary_path -N $binary_name -M 16 -o $SUBJECT_DIR/patches"
echo $f1x_cmd > $SCRIPT_DIR/f1xcmd.sh

BINARY_ARGS=`echo "${BINARY_INPUT/\$POC/@@}"`
pushd $SUBJECT_DIR >/dev/null
  echo "executing:"
  echo "/src/aflgo/afl-fuzz -S ef709ce2 -m 100 -z exp -c $cooling_time -i ./seed-dir -o ./out -s part ${MEMMODE} -t ${T_TIMEOUT} -R $SCRIPT_DIR/f1xcmd.sh ${BINARY}_profile $BINARY_ARGS"
  /src/aflgo/afl-fuzz -S ef709ce2 -m 100 -z exp -c $cooling_time -i ./seed-dir -o ./out -s part -t $T_TIMEOUT -R $SCRIPT_DIR/f1xcmd.sh ${BINARY}_profile $BINARY_ARGS
popd > /dev/null

export LD_LIBRARY_PATH=$INITIAL_LD_LIBRARY_PATH
