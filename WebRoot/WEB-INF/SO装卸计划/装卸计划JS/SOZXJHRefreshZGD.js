function reAction(id){


    var log = function(str) {
        Dialog.alert(str);
    }

    var cos=function (str) {
        new Function("c"+"onsole.log("+str+")")();
    }

    Dialog.confirm('是否刷新暂估单',function(){
        cos(id);
        refreshZGD(id);

    },function(){
        return;
    });


    var refreshZGD = function(reqid) {
        var oAjax = null;
        var postData = 'id=' + reqid;
        oAjax = new XMLHttpRequest();
        oAjax.open("post", "/sapjsp/REFRESH_ZGD_SOZXJH.jsp", true);
        oAjax.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        oAjax.send(postData);
        oAjax.onreadystatechange = function() {
            if (oAjax.readyState == 4) {
                var msg = oAjax.responseText;
                var data = jQuery.trim(msg);
                data.replace(/(^\s*)|(\s*$|<)/g, "");
                // log(data);

                var jsonDate = JSON.parse(data);
                if (jsonDate.message) {
                    log(jsonDate.message);
                }
                if(jsonDate.result){
                    log("SUCCESS");
                }
            }
        }
    }


}