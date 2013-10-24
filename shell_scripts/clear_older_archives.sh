cd jerry
for host in `ls | cut -d. -f1  | sort -u `; do
echo $host'######';
latest=`ls -td $host* | head -1`;
for d in `ls -dt ${host}*` ; do
    if [ "$latest" != "$d" ] ; then
        echo deleted $d
    fi
done

done
