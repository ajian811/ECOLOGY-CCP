function fsapzfAction(id, params) {

    var parray = params.split('+');
    var lcid = parray[0];
    var sqr = parray[1];


    var lhsqzf = function(reqid) {
        var oAjax = null;
        //Dialog.alert(reqid);
        var postData = 'reqid=' + reqid;
        oAjax = new XMLHttpRequest();
        oAjax.open("post", "/sapjsp/NONSAP_ZXJH_ZF.jsp", true);
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
    Dialog.confirm('是否作废',function(){
        lhsqzf(lcid);

    },function(){
        return;
    });
}