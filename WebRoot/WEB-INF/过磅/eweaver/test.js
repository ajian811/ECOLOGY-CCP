//监听明细表的增加
jQuery("#indexnum0").bindPropertyChange(function(){
    //获得明细表下标indexs 数组
    var indexs=jQuery("#submitdtlid0").val().splite(",");
    //遍历明细表下标数组，并监听相应的字段变化
    for(var i=0;i<indexs.length;i++){
        var index=indexs[i];
        jQuery("#fieldname_"+index).bindPropertyChange(function(){
            //执行相应算法

        });

    }

})