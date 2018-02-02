function zuofei(id, params) {

    var parray = params.split('+');
    var lcid = parray[0];
    var sqr = parray[1];

    Dialog.alert(params);

    Dialog.confirm('是否作废', function() {
        lhsqzf(lcid);
    }, function() {
        return;
    });



    var lhsqzf = function(reqid) {
        var oAjax = null;
        var postData = 'reqid=' + reqid;
        oAjax = new XMLHttpRequest();
        oAjax.open("post", "/sapjsp/lhsqzf.jsp", true);
        oAjax.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        oAjax.send(postData);
        oAjax.onreadystatechange = function() {
            if (oAjax.readyState == 4) {
                var msg = oAjax.responseText;
                var data = jQuery.trim(msg);
                data.replace(/(^\s*)|(\s*$)/g, "");
                if (data != '1') {
                    return;
                } else {
                    Dialog.alert('作废成功');
                }
            }
        }
    }


}