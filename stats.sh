source=`find src -name "*.ml*"`
rm `find src -name "*.[coa]*"`
if [ -e "test" ]
then
    rm "test*"
fi
wc -L $source
wc -l $source | tail -n 1
