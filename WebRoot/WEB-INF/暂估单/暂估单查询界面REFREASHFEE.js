function onAction(id){


    var log = function(str) {
        Dialog.alert(str);
    }

    var cos=function (str) {
        new Function("c"+"onsole.log("+str+")")();
    }

    Dialog.confirm('是否费用重算',function(){
        refreashFee(id);

    },function(){
        return;
    });


    var refreashFee = function(reqid) {
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
                data.replace(/(^\s*)|(\s*$)/g, "");
                // cof(data)
                var jsonDate = JSON.parse(data);
                // cof(jsonDate);
                if (jsonDate) {
                    console.log(jsonDate.message);
                }
            }
        }
    }


}