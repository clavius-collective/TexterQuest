# basic maintenance script for squirrely use
# mostly used to enforce the 79-character limit, count LOC, etc.
# incidentally, this thing also clears out binaries

source=`find . -name "*.ml*"`
touch .dummy
rm `find . -name "*.[coa]*"` `ls | grep test` .dummy
wc -L $source
wc -l $source | tail -n 1
