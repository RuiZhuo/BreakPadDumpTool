cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd
#动态库名字
libName='libxplan'
dirList=`ls .`
idx=0
#获取所有版本目录
for name in $dirList;
do
  if [ -d $name ];then
    version[idx]=$name
    let idx++
  fi
done

#遍历版本目录
for versionDir in ${version[@]};
do
    echo "versionDir:" $versionDir
    #寻找当前版本里的动态库文件
    soPath=`find $versionDir -name "*.so"`
    for so in $soPath;
    do
       #生存符号文件
       ./dump_syms $so>$libName.so.sym
       headName=`head -n1 $libName.so.sym`
       #获取符号文件的ID信息来创建相应目录
       #并把符号文件移动到创建的目录
       if [ -n "$headName" ];then
          headDir=${headName:17:33}
          headPath=$versionDir/symbols/$libName.so/$headDir
          echo $libName.so.sym "move to" $headPath
          mkdir -p $headPath
          mv $libName.so.sym $headPath/
       fi
    done
    #寻找当前版本目录的dmp文件
    dumpPath=`find $versionDir -name "*.dmp"`
    #遍历所有dmp文件
    #生存解析好的文件，存放在log目录下
    for dump in $dumpPath;
    do 
       dumpName=`basename $dump`
       echo $dumpName
       if [ ! -d "$versionDir/log/" ];then
          mkdir $versionDir/log/
       fi
       ./minidump_stackwalk $dumpPath ./$versionDir/symbols/>$versionDir/log/$dumpName.txt
    done
done

