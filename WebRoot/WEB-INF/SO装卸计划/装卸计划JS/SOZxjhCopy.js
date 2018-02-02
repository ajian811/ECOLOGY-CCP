function onXiuGai(id, params) {

    var log = function(str) {
        new Function('Dialog.a' + 'lert("' + str + '")')();
    }

    var cof = function(str) {
        return new Function('return c' + 'onfirm("' + str + '")')();
    }

    var r = cof('是否复制');
    if (r != true) {
        return;
    }
   alert(cd);
    var parray = params.split('+');
    var lcid = parray[0];
    var sqr = parray[1];

    var importWf = function(wfid, requestid, importuser) {
        var oAjax = null;
        var postData = 'workflowid=' + wfid + '&location=Boston&importuser=' + importuser;
        oAjax = new XMLHttpRequest();
        oAjax.open("post", "/workflow/request/RequestImportJson.jsp?f_weaver_belongto_userid=" + importuser + "&f_weaver_belongto_usertype=0", true);
        oAjax.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        oAjax.send(postData);
        oAjax.onreadystatechange = function() {
            if (oAjax.readyState == 4) {
                var msg = oAjax.responseText;

                var data = jQuery.trim(msg);
                data.replace(/(^\s*)|(\s*$)/g, "");
                var contentarray = eval('(' + data + ')');
                if (contentarray.length === 0) {} else {
                    contentarray.forEach(function(suggestion) {
                        if (suggestion.data == requestid) {
                            var params = "src=import&imprequestid=" + suggestion.data + "&workflowid=" + wfid + "&formid=" + suggestion.formid + "&isbill=" + suggestion.isbill + "&nodeid=1081&nodetype=" + suggestion.nodetype + "&requestname=" + escape(suggestion.value);
                            var width = screen.availWidth - 10;
                            var height = screen.availHeight - 50;
                            var szFeatures = "top=0,";
                            szFeatures += "left=0,";
                            szFeatures += "width=" + width + ",";
                            szFeatures += "height=" + height + ",";
                            szFeatures += "directories=no,";
                            szFeatures += "status=yes,toolbar=no,location=no,";
                            szFeatures += "menubar=no,";
                            szFeatures += "scrollbars=yes,";
                            szFeatures += "resizable=yes"; //channelmode
                            window.open("/workflow/request/RequestImportOption.jsp?newmodeid=0&ismode=0&" + params, "", szFeatures);

                        }
                    });
                }
            };
        };


    }


                    importWf(841, lcid, sqr);


}