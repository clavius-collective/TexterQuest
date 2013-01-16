source=`find . -name "*.ml*"`
rm `find . -name "*.[coa]*"`
if [ -e "test" ]
then
    rm "test*"
fi
wc -L $source
wc -l $source | tail -n 1
