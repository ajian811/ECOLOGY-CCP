function zfAction(id){


    var log = function(str) {
        Dialog.alert(str);
    }

    var cos=function (str) {
        new Function("c"+"onsole.log("+str+")")();
    }

    Dialog.confirm('是否作废',function(){
        lhsqzf(id);

    },function(){
        return;
    });


    var lhsqzf = function(reqid) {
        var oAjax = null;
        var postData = 'id=' + reqid;
        oAjax = new XMLHttpRequest();
        oAjax.open("post", "/sapjsp/SOZxjhCancel.jsp", true);
        oAjax.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        oAjax.send(postData);
        oAjax.onreadystatechange = function() {
            if (oAjax.readyState == 4) {
                var msg = oAjax.responseText;
                var data = jQuery.trim(msg);
                log(data);
                data.replace(/(^\s*)|(\s*$)/g, "");

                var jsonDate = JSON.parse(data);

                if (jsonDate) {
                    log(jsonDate.message);
                }
            }
        }
    }


}