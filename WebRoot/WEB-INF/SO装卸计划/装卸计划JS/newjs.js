function onXiuGai(id,lcid,sqr){
    new Function('a=c'+'onfirm("是否确认作废")')();
    /*
  导入流程
  wfid:流程id
  importuser:用户id
  */
    var requestid=lcid;
    var importuser=sqr;
    var wfid=861;


    var  importWf =function(wfid, requestid, importuser) {
        jQuery.ajax({
            type: "POST",
            url: "/workflow/request/RequestImportJson.jsp?f_weaver_belongto_userid=" + importuser + "&f_weaver_belongto_usertype=0",
            data: { workflowid: wfid, location: "Boston", importuser: importuser },
            success: function(msg) {
                // var data = $.trim(msg);
                data.replace(/(^\s*)|(\s*$)/g, "");
                var contentarray = eval('(' + data + ')');
                if (contentarray.length === 0) {
                    console.log('没有可以导入的流程');
                } else {
                    contentarray.forEach(function(suggestion) {
                        if (suggestion.data == requestid) {
                            var params = "src=import&imprequestid=" + suggestion.data + "&workflowid=" + wfid + "&formid=" + suggestion.formid + "&isbill=" + suggestion.isbill + "&nodeid=" + suggestion.nodeid + "&nodetype=" + suggestion.nodetype + "&requestname=" + escape(suggestion.value);
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
            }
        });
    }
    importWf(wfid, requestid, importuser);

}