//联动属性
function changeshowattr(fieldid,fieldvalue,rownum,workflowid,nodeid){
    len = document.forms[0].elements.length;
    jQuery.ajax({
        type: "POST",
        dataType:"text",
        url: "/formmode/view/FormModeChanegAttrAjax.jsp",
        data: "modeId=661&type=1301&fieldid="+fieldid+"&fieldvalue="+fieldvalue,
        success: function(data){
            try{
                var returnvalues = data;
                if(returnvalues!=""){
                    var tfieldid=fieldid.split("_");
                    var isdetail=tfieldid[1];
                    var fieldarray=returnvalues.split("&");
                    for(n=0;n<fieldarray.length;n++){
                        var fieldattrs=fieldarray[n].split("$");
                        var fieldids=fieldattrs[0];
                        var fieldattr=fieldattrs[1];
                        var fieldidarray=fieldids.split(",");
                        if(fieldattr==4){ // 没有设置联动，恢复原值和恢复原显示属性
                            for(i=0;i<len;i++){
                                for(j=0;j<fieldidarray.length;j++){
                                    var tfieldidarray=fieldidarray[j].split("_");
                                    if (tfieldidarray[1]==isdetail){
                                        if(rownum>-1){
                                            if($GetEle('field'+tfieldidarray[0]+rownum+'span')!=null){
                                                jQuery('#field'+tfieldidarray[0]+rownum+'span').css('display','none');
                                            }
                                            if($GetEle('field'+tfieldidarray[0]+"_"+rownum+'span')!=null){
                                                jQuery('#field'+tfieldidarray[0]+"_"+rownum+'span').css('display','none');
                                            }
                                            if($GetEle('field'+tfieldidarray[0]+"_"+rownum+'_browserbtn')!=null){
                                                jQuery('#field'+tfieldidarray[0]+"_"+rownum+'_browserbtn').css('display','none');
                                                if($GetEle('field'+tfieldidarray[0]+"_"+rownum+'wrapspan')!=null){
                                                    jQuery('#field'+tfieldidarray[0]+"_"+rownum+'wrapspan').css('display','none');
                                                }
                                            }
                                            if($GetEle('field'+tfieldidarray[0]+'_'+rownum)!=null){
                                                jQuery('#field'+tfieldidarray[0]+'_'+rownum).css('display','none');
                                            }
                                            if($GetEle('field_lable'+tfieldidarray[0]+'span_'+rownum)!=null){
                                                jQuery('#field_lable'+tfieldidarray[0]+'span_'+rownum).css('display','none');
                                            }
                                            if($GetEle('field_lable'+tfieldidarray[0]+'_'+rownum)!=null){
                                                jQuery('#field_lable'+tfieldidarray[0]+'_'+rownum).css('display','none');
                                            }if($GetEle('field_chinglish'+tfieldidarray[0]+'span_'+rownum)!=null){
                                                jQuery('#field_chinglish'+tfieldidarray[0]+'span_'+rownum).css('display','none');
                                            }
                                            if($GetEle('field_chinglish'+tfieldidarray[0]+'_'+rownum)!=null){
                                                jQuery('#field_chinglish'+tfieldidarray[0]+'_'+rownum).css('display','none');
                                            }


                                            if($GetEle('field'+tfieldidarray[0]+"_"+rownum+"browser")!=null){
                                                $GetEle('field'+tfieldidarray[0]+"_"+rownum+"browser").disabled=false;
                                            }


                                            jQuery('#field'+tfieldidarray[0]+"_"+rownum).attr("isMustInput","1");
                                            document.forms[0].elements[i].setAttribute('viewtype','0');
                                            var checkstr_=$GetEle("needcheck").value+",";
                                            $GetEle("needcheck").value=checkstr_.replace("field"+tfieldidarray[0]+"_"+rownum+",","");
                                            //判断附件字段
                                            if($GetEle("fsUploadProgress"+tfieldidarray[0]+'_'+rownum)){
                                                attachmentHideOrShow("field"+tfieldidarray[0]+"_"+rownum,"hide");
                                                jQuery("#field_"+tfieldidarray[0]+"span_"+rownum).css('display','none');
                                            }

                                            else{
                                                if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                }
                                            }
                                        }else{     // 主字段
                                            if($GetEle('field'+tfieldidarray[0]+"span")!=null){
                                                jQuery('#field'+tfieldidarray[0]+"span").css('display','none');
                                            }

                                            if($GetEle('field'+tfieldidarray[0]+"browser")!=null){
                                                $GetEle('field'+tfieldidarray[0]+"browser").disabled=false;
                                            }

                                            if($GetEle('field'+tfieldidarray[0]+"_browserbtn")!=null){
                                                if(jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display')!='none'){
                                                    jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display','none');
                                                }
                                            }
                                            if($GetEle('field'+tfieldidarray[0])!=null){
                                                jQuery('#field'+tfieldidarray[0]).css('display','none');
                                            }
                                            if($GetEle('field_lable'+tfieldidarray[0]+'span')!=null){
                                                jQuery('#field_lable'+tfieldidarray[0]+'span').css('display','none');
                                            }
                                            if($GetEle('field_lable'+tfieldidarray[0])!=null){
                                                jQuery('#field_lable'+tfieldidarray[0]).css('display','none');
                                            }if($GetEle('field_chinglish'+tfieldidarray[0]+'span')!=null){
                                                jQuery('#field_chinglish'+tfieldidarray[0]+'span').css('display','none');
                                            }
                                            if($GetEle('field_chinglish'+tfieldidarray[0])!=null){
                                                jQuery('#field_chinglish'+tfieldidarray[0]).css('display','none');
                                            }

                                            jQuery('#field'+tfieldidarray[0]).attr("isMustInput","1");
                                            document.forms[0].elements[i].setAttribute('viewtype','0');
                                            var checkstr_=$GetEle("needcheck").value+",";
                                            $GetEle("needcheck").value=checkstr_.replace("field"+tfieldidarray[0]+",","");

                                            //判断附件字段
                                            if($GetEle("fsUploadProgress"+tfieldidarray[0])){
                                                attachmentHideOrShow("field"+tfieldidarray[0],"hide");
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(fieldattr==-1){ // 没有设置联动，恢复原值和恢复原显示属性
                            for(i=0;i<len;i++){
                                for(j=0;j<fieldidarray.length;j++){
                                    var tfieldidarray=fieldidarray[j].split("_");
                                    //影藏 明细
                                    if(jQuery('#field'+tfieldidarray[0]+rownum+'span').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+rownum+'span').css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+"_"+rownum+'wrapspan').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'_browserbtn').css('display','');
                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'wrapspan').css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'span_'+rownum).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'span_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }if(jQuery('#field_chinglish'+tfieldidarray[0]+'span_'+rownum).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'span_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_chinglish'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }
                                    //判断附件字段
                                    if(jQuery("#field_"+tfieldidarray[0]+"span_"+rownum).css('display')=='none'){
                                        jQuery("#field_"+tfieldidarray[0]+"span_"+rownum).css('display','');
                                    }
                                    else{
                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                        }
                                    }
                                    //主表
                                    if(jQuery('#field'+tfieldidarray[0]+"span").css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+"span").css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display','block');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'span').css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'span').css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]).css('display','');
                                    }if(jQuery('#field_chinglish'+tfieldidarray[0]+'span').css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'span').css('display','');
                                    }
                                    if(jQuery('#field_chinglish'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]).css('display','');
                                    }
                                    //
                                    if (tfieldidarray[1]==isdetail){
                                        if(rownum>-1){  // 明细字段
                                            if(document.forms[0].elements[i].name=='field'+tfieldidarray[0]+"_"+rownum&&$GetEle('oldfieldview'+tfieldidarray[0]+"_"+rownum)){
                                                isedit=$GetEle('oldfieldview'+tfieldidarray[0]+"_"+rownum).value;
                                                if($GetEle('field'+tfieldidarray[0]+"_"+rownum+"span")||$GetEle('field_'+tfieldidarray[0]+"_"+rownum+"span")){
                                                    var checkstr_=$GetEle("needcheck").value+",";
                                                    if(isedit==3){
                                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum).attr("isMustInput","2");
                                                        document.forms[0].elements[i].setAttribute('viewtype','1');
                                                        var imgObj = jQuery('#field'+tfieldidarray[0]+"_"+rownum+"spanimg");
                                                        if(imgObj.length==0){
                                                            imgObj = jQuery('#field'+tfieldidarray[0]+"_"+rownum+"span")
                                                        }
                                                        var objVal = jQuery('#field'+tfieldidarray[0]+"_"+rownum);
                                                        if(objVal.val()==""){
                                                            imgObj.html("<IMG src='/images/BacoError_wev8.gif' align=absMiddle>");
                                                        }

                                                        //子表判断附件字段
                                                        if($GetEle("fsUploadProgress"+tfieldidarray[0]+"_"+rownum)){
                                                            attachmentHideOrShow("field"+tfieldidarray[0]+"_"+rownum);
                                                            imgObj.html("（必填）");
                                                            var isReturn = false;
                                                            jQuery("#fsUploadProgress"+tfieldidarray[0]+"_"+rownum+" .progressBarStatus").each(function(i,obj){
                                                                if(jQuery(obj).text()!='Cancelled'){
                                                                    isReturn = true;
                                                                    return false
                                                                }
                                                            })
                                                            if(isReturn){
                                                                jQuery("#field_"+tfieldidarray[0]+"_"+rownum+"span").hide();
                                                            }else{
                                                                if(jQuery("#field"+tfieldidarray[0]+"_"+rownum).val()==''
                                                                    ||jQuery("#field"+tfieldidarray[0]+"_"+rownum).val()=='NULL'
                                                                    ||jQuery("#field"+tfieldidarray[0]+"_"+rownum).val()=='null'){
                                                                    jQuery("#field_"+tfieldidarray[0]+"_"+rownum+"span").show();
                                                                    jQuery("#field"+tfieldidarray[0]+"_"+rownum).val("");
                                                                }else{
                                                                    jQuery("#field_"+tfieldidarray[0]+"_"+rownum+"span").hide();
                                                                }
                                                            }

                                                            //jQuery("#spanButtonPlaceHolderDis"+tfieldidarray[0]).show();
                                                            attachmentDisd(tfieldidarray[0]+"_"+rownum,false);
                                                        }

                                                        //if(document.forms[0].elements[i].value==""&&$GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")<=0) $GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="<IMG src='/images/BacoError_wev8.gif' align=absMiddle>";
                                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                            //document.all('field'+tfieldidarray[0]+"_"+rownum).disabled=false;
                                                            setCanEdit($GetEle('field'+tfieldidarray[0]+"_"+rownum));
                                                        }
                                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum+"browser")!=null){
                                                            $GetEle('field'+tfieldidarray[0]+"_"+rownum+"browser").disabled=false;
                                                        }
                                                        try{
                                                            if(document.forms[0].elements[i].value==""&&$GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")<=0){
                                                                $GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="<IMG src='/images/BacoError_wev8.gif' align=absMiddle>";
                                                                $GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="";
                                                            }
                                                        }catch(e){}
                                                        if(checkstr_.indexOf("field"+tfieldidarray[0]+"_"+rownum+",")<0) $GetEle("needcheck").value=checkstr_+"field"+tfieldidarray[0]+"_"+rownum;
                                                    }
                                                    if(isedit==2){
                                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum).attr("isMustInput","1");
                                                        document.forms[0].elements[i].setAttribute('viewtype','0');
                                                        var imgObj = jQuery('#field'+tfieldidarray[0]+"_"+rownum+"spanimg");
                                                        if(imgObj.length==0){
                                                            imgObj = jQuery('#field'+tfieldidarray[0]+"_"+rownum+"span")
                                                        }
                                                        if(imgObj.length>0&&imgObj.html().indexOf("/images/BacoError_wev8.gif")>-1){
                                                            imgObj.html("");
                                                        }

                                                        //子表判断附件字段
                                                        if($GetEle("fsUploadProgress"+tfieldidarray[0]+"_"+rownum)){
                                                            attachmentHideOrShow("field"+tfieldidarray[0]+"_"+rownum);
                                                            var isReturn = false;
                                                            jQuery("#fsUploadProgress"+tfieldidarray[0]+"_"+rownum+" .progressBarStatus").each(function(i,obj){
                                                                if(jQuery(obj).text()!='Cancelled'){
                                                                    isReturn = true;
                                                                    return false
                                                                }
                                                            })
                                                            jQuery("#field_"+tfieldidarray[0]+"_"+rownum+"span").hide();
                                                            attachmentDisd(tfieldidarray[0]+"_"+rownum,false);
                                                        }

                                                        //if($GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1) $GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="";
                                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                            //document.all('field'+tfieldidarray[0]+"_"+rownum).disabled=false;
                                                            setCanEdit($GetEle('field'+tfieldidarray[0]+"_"+rownum));
                                                        }
                                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum+"browser")!=null){
                                                            $GetEle('field'+tfieldidarray[0]+"_"+rownum+"browser").disabled=false;
                                                        }


                                                        if(jQuery('#field'+tfieldidarray[0]+"_"+rownum+'span').css('display')=='none'){
                                                            jQuery('#field'+tfieldidarray[0]+"_"+rownum+'span').css('display','');
                                                        }

                                                        try{
                                                            if($GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1){
                                                                $GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="";
                                                            }
                                                        }catch(e){}
                                                        $GetEle("needcheck").value=checkstr_.replace("field"+tfieldidarray[0]+"_"+rownum+",","");
                                                    }
                                                }else{
                                                    if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                        setCanEdit($GetEle('field'+tfieldidarray[0]+"_"+rownum));
                                                    }
                                                }
                                            }
                                        }else{     // 主字段
                                            if(document.forms[0].elements[i].name=='field'+tfieldidarray[0]&&$GetEle('oldfieldview'+tfieldidarray[0])){
                                                isedit=$GetEle('oldfieldview'+tfieldidarray[0]).value;
                                                if($GetEle('field'+tfieldidarray[0]+"span")){
                                                    var checkstr_=$GetEle("needcheck").value+",";
                                                    if(isedit==3) {
                                                        jQuery('#field'+tfieldidarray[0]).attr("isMustInput","2");
                                                        document.forms[0].elements[i].setAttribute('viewtype','1');
                                                        if(document.forms[0].elements[i].value=="") {
                                                            var imgObj = jQuery('#field'+tfieldidarray[0]+"spanimg");
                                                            if(imgObj.length==0){
                                                                imgObj = jQuery('#field'+tfieldidarray[0]+"span")
                                                            }
                                                            if(imgObj.length>0){
                                                                imgObj.html("<IMG src='/images/BacoError_wev8.gif' align=absMiddle>");
                                                            }
                                                            //$GetEle('field'+tfieldidarray[0]+"span").innerHTML="<IMG src='/images/BacoError_wev8.gif' align=absMiddle>";
                                                        }
                                                        //判断附件字段
                                                        if($GetEle("fsUploadProgress"+tfieldidarray[0])){
                                                            //jQuery("#field"+tfieldidarray[0]).prev().show();
                                                            attachmentHideOrShow("field"+tfieldidarray[0]);
                                                            var isReturn = false;
                                                            jQuery("#fsUploadProgress"+tfieldidarray[0]+" .progressBarStatus").each(function(i,obj){
                                                                if(jQuery(obj).text()!='Cancelled'){
                                                                    isReturn = true;
                                                                    return false
                                                                }
                                                            })
                                                            if(isReturn){
                                                                jQuery("#field_"+tfieldidarray[0]+"span").hide();
                                                            }else{
                                                                if(jQuery("#field"+tfieldidarray[0]).val()==''
                                                                    ||jQuery("#field"+tfieldidarray[0]).val()=='NULL'
                                                                    ||jQuery("#field"+tfieldidarray[0]).val()=='null'){
                                                                    jQuery("#field_"+tfieldidarray[0]+"span").show();
                                                                    jQuery("#field"+tfieldidarray[0]).val("");
                                                                }else{
                                                                    jQuery("#field_"+tfieldidarray[0]+"span").hide();
                                                                }
                                                            }
                                                            //jQuery("[uploadprompt='uploadprompt_"+tfieldidarray[0]+"span'").show();
                                                            //jQuery("#spanButtonPlaceHolderDis"+tfieldidarray[0]).show();
                                                            attachmentDisd(tfieldidarray[0],false);
                                                        }
                                                        if($GetEle('field'+tfieldidarray[0])!=null){
                                                            $GetEle('field'+tfieldidarray[0]).disabled=false;
                                                            setCanEdit($GetEle('field'+tfieldidarray[0]));
                                                        }
                                                        if($GetEle('field'+tfieldidarray[0]+"browser")!=null){
                                                            $GetEle('field'+tfieldidarray[0]+"browser").disabled=false;
                                                        }
                                                        try{
                                                            if(document.forms[0].elements[i].value==""){
                                                                $GetEle('field_lable'+tfieldidarray[0]+"span").innerHTML="<IMG src='/images/BacoError_wev8.gif' align=absMiddle>";
                                                                $GetEle('field'+tfieldidarray[0]+"span").innerHTML="";
                                                            }
                                                        }catch(e){}
                                                        if(checkstr_.indexOf("field"+tfieldidarray[0]+",")<0) $GetEle("needcheck").value=checkstr_+"field"+tfieldidarray[0];
                                                    }
                                                    if(isedit==2) {
                                                        jQuery('#field'+tfieldidarray[0]).attr("isMustInput","1");
                                                        document.forms[0].elements[i].setAttribute('viewtype','0');
                                                        var imgObj = jQuery('#field'+tfieldidarray[0]+"spanimg");
                                                        if(imgObj.length==0){
                                                            imgObj = jQuery('#field'+tfieldidarray[0]+"span")
                                                        }
                                                        if(imgObj.length>0&&imgObj.html().indexOf("/images/BacoError_wev8.gif")>-1){
                                                            imgObj.html("");
                                                        }
                                                        //判断附件字段
                                                        if($GetEle("fsUploadProgress"+tfieldidarray[0])){
                                                            //jQuery("#field"+tfieldidarray[0]).prev().show();
                                                            attachmentHideOrShow("field"+tfieldidarray[0]);
                                                            jQuery("#field_"+tfieldidarray[0]+"span").hide();
                                                            //jQuery("[uploadprompt='uploadprompt_"+tfieldidarray[0]+"span'").show();
                                                            //jQuery("#spanButtonPlaceHolderDis"+tfieldidarray[0]).show();
                                                            attachmentDisd(tfieldidarray[0],false);
                                                        }
                                                        //if($GetEle('field'+tfieldidarray[0]+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1) $GetEle('field'+tfieldidarray[0]+"span").innerHTML="";
                                                        if($GetEle('field'+tfieldidarray[0])!=null){
                                                            //document.all('field'+tfieldidarray[0]).disabled=false;
                                                            setCanEdit($GetEle('field'+tfieldidarray[0]));
                                                        }
                                                        if($GetEle('field'+tfieldidarray[0]+"browser")!=null){
                                                            $GetEle('field'+tfieldidarray[0]+"browser").disabled=false;
                                                        }
                                                        try{
                                                            if($GetEle('field_lable'+tfieldidarray[0]+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1){
                                                                $GetEle('field_lable'+tfieldidarray[0]+"span").innerHTML="";
                                                            }
                                                        }catch(e){}
                                                        $GetEle("needcheck").value=checkstr_.replace("field"+tfieldidarray[0]+",","");
                                                    }
                                                }else{
                                                    if($GetEle('field'+tfieldidarray[0])!=null){
                                                        $GetEle('field'+tfieldidarray[0]).disabled=false;
                                                        setCanEdit($GetEle('field'+tfieldidarray[0]));
                                                    }
                                                    //判断附件字段
                                                    if($GetEle("fsUploadProgress"+tfieldidarray[0])){
                                                        attachmentHideOrShow("field"+tfieldidarray[0]);
                                                        //jQuery("#field"+tfieldidarray[0]).prev().show();
                                                        jQuery("#field_"+tfieldidarray[0]+"span").hide();
                                                        //jQuery("[uploadprompt='uploadprompt_"+tfieldidarray[0]+"span'").show();
                                                        //jQuery("#spanButtonPlaceHolderDis"+tfieldidarray[0]).show();
                                                        attachmentDisd(tfieldidarray[0],false);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(fieldattr==1){// 为编辑，显示属性设为编辑
                            for(i=0;i<len;i++){
                                for(j=0;j<fieldidarray.length;j++){
                                    var tfieldidarray=fieldidarray[j].split("_");
                                    //影藏
                                    if(jQuery('#field'+tfieldidarray[0]+rownum+'span').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+rownum+'span').css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+"_"+rownum+'wrapspan').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'_browserbtn').css('display','');
                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'wrapspan').css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'span_'+rownum).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'span_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }if(jQuery('#field_chinglish'+tfieldidarray[0]+'span_'+rownum).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'span_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_chinglish'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }
                                    //判断附件字段
                                    if(jQuery("#field_"+tfieldidarray[0]+"span_"+rownum).css('display')=='none'){
                                        jQuery("#field_"+tfieldidarray[0]+"span_"+rownum).css('display','');
                                    }
                                    else{
                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                        }
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+"span").css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+"span").css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display','block');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'span').css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'span').css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]).css('display','');
                                    }if(jQuery('#field_chinglish'+tfieldidarray[0]+'span').css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'span').css('display','');
                                    }
                                    if(jQuery('#field_chinglish'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]).css('display','');
                                    }
                                    //
                                    if (tfieldidarray[1]==isdetail){
                                        if(rownum>-1){  // 明细字段
                                            if(document.forms[0].elements[i].name=='field'+tfieldidarray[0]+"_"+rownum&&$GetEle('oldfieldview'+tfieldidarray[0]+"_"+rownum)){
                                                isedit=$GetEle('oldfieldview'+tfieldidarray[0]+"_"+rownum).value;
                                                if(isedit>1&&($GetEle('field'+tfieldidarray[0]+"_"+rownum+"span")||$GetEle('field_'+tfieldidarray[0]+"_"+rownum+"span"))){
                                                    jQuery('#field'+tfieldidarray[0]+"_"+rownum).attr("isMustInput","1");
                                                    var checkstr_=$GetEle("needcheck").value+",";
                                                    var imgObj = jQuery('#field'+tfieldidarray[0]+"_"+rownum+"spanimg");
                                                    if(imgObj.length==0){
                                                        imgObj = jQuery('#field'+tfieldidarray[0]+"_"+rownum+"span")
                                                    }
                                                    if(imgObj.length>0&&imgObj.html().indexOf("/images/BacoError_wev8.gif")>-1){
                                                        imgObj.html("");
                                                    }

                                                    //子表判断附件字段
                                                    if($GetEle("fsUploadProgress"+tfieldidarray[0]+"_"+rownum)){
                                                        attachmentHideOrShow("field"+tfieldidarray[0]+"_"+rownum);
                                                        var isReturn = false;
                                                        jQuery("#fsUploadProgress"+tfieldidarray[0]+"_"+rownum+" .progressBarStatus").each(function(i,obj){
                                                            if(jQuery(obj).text()!='Cancelled'){
                                                                isReturn = true;
                                                                return false
                                                            }
                                                        })
                                                        jQuery("#field_"+tfieldidarray[0]+"_"+rownum+"span").hide();
                                                        attachmentDisd(tfieldidarray[0]+"_"+rownum,false);
                                                    }
                                                    //if($GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1) $GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="";
                                                    if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                        //document.all('field'+tfieldidarray[0]+"_"+rownum).disabled=false;
                                                        setCanEdit($GetEle('field'+tfieldidarray[0]+"_"+rownum));
                                                    }
                                                    if($GetEle('field'+tfieldidarray[0]+"_"+rownum+'browser')!=null){
                                                        $GetEle('field'+tfieldidarray[0]+"_"+rownum+'browser').disabled=false;
                                                    }

                                                    if(jQuery('#field'+tfieldidarray[0]+"_"+rownum+'span').css('display')=='none'){
                                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'span').css('display','');
                                                    }

                                                    try{
                                                        if($GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1){
                                                            $GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="";
                                                        }
                                                    }catch(e){}
                                                    $GetEle("needcheck").value=checkstr_.replace("field"+tfieldidarray[0]+"_"+rownum+",","");
                                                    document.forms[0].elements[i].setAttribute('viewtype','0');
                                                }else {
                                                    if(isedit>1){
                                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                            setCanEdit($GetEle('field'+tfieldidarray[0]+"_"+rownum));
                                                        }
                                                    }
                                                }
                                            }
                                        }else{     // 主字段
                                            if(document.forms[0].elements[i].name=='field'+tfieldidarray[0]&&$GetEle('oldfieldview'+tfieldidarray[0])){
                                                isedit=$GetEle('oldfieldview'+tfieldidarray[0]).value;
                                                if(isedit>1&&$GetEle('field'+tfieldidarray[0]+"span")){
                                                    jQuery('#field'+tfieldidarray[0]).attr("isMustInput","1");
                                                    var checkstr_=$GetEle("needcheck").value+",";
                                                    //if($GetEle('field'+tfieldidarray[0]+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1) $GetEle('field'+tfieldidarray[0]+"span").innerHTML="";
                                                    var imgObj = jQuery('#field'+tfieldidarray[0]+"spanimg");
                                                    if(imgObj.length==0){
                                                        imgObj = jQuery('#field'+tfieldidarray[0]+"span")
                                                    }
                                                    if(imgObj.length>0&&imgObj.html().indexOf("/images/BacoError_wev8.gif")>-1){
                                                        imgObj.html("");
                                                    }
                                                    //判断附件字段
                                                    if($GetEle("fsUploadProgress"+tfieldidarray[0])){
                                                        attachmentHideOrShow("field"+tfieldidarray[0]);
                                                        //jQuery("#field"+tfieldidarray[0]).prev().show();
                                                        jQuery("#field_"+tfieldidarray[0]+"span").hide();
                                                        //jQuery("#spanButtonPlaceHolderDis"+tfieldidarray[0]).show();
                                                        attachmentDisd(tfieldidarray[0],false);
                                                    }
                                                    if($GetEle('field'+tfieldidarray[0])!=null){
                                                        //document.all('field'+tfieldidarray[0]).disabled=false;
                                                        setCanEdit($GetEle('field'+tfieldidarray[0]));
                                                    }
                                                    if($GetEle('field'+tfieldidarray[0]+'browser')!=null){
                                                        $GetEle('field'+tfieldidarray[0]+'browser').disabled=false;
                                                    }
                                                    try{
                                                        if($GetEle('field_lable'+tfieldidarray[0]+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1){
                                                            $GetEle('field_lable'+tfieldidarray[0]+"span").innerHTML="";
                                                        }
                                                    }catch(e){}
                                                    $GetEle("needcheck").value=checkstr_.replace("field"+tfieldidarray[0]+",","");
                                                    document.forms[0].elements[i].setAttribute('viewtype','0');
                                                }else{
                                                    if(isedit>1){
                                                        if($GetEle('field'+tfieldidarray[0])!=null){
                                                            setCanEdit($GetEle('field'+tfieldidarray[0]));
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(fieldattr==2){// 为必填，显示属性设为编辑
                            for(i=0;i<len;i++){
                                for(j=0;j<fieldidarray.length;j++){
                                    var tfieldidarray=fieldidarray[j].split("_");
                                    //影藏
                                    if(jQuery('#field'+tfieldidarray[0]+rownum+'span').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+rownum+'span').css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+"_"+rownum+'wrapspan').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'_browserbtn').css('display','');
                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'wrapspan').css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'span_'+rownum).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'span_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }if(jQuery('#field_chinglish'+tfieldidarray[0]+'span_'+rownum).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'span_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_chinglish'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }
                                    //判断附件字段
                                    if(jQuery("#field_"+tfieldidarray[0]+"span_"+rownum).css('display')=='none'){
                                        jQuery("#field_"+tfieldidarray[0]+"span_"+rownum).css('display','');
                                    }
                                    else{
                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                        }
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+"span").css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+"span").css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display','block');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'span').css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'span').css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]).css('display','');
                                    }if(jQuery('#field_chinglish'+tfieldidarray[0]+'span').css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'span').css('display','');
                                    }
                                    if(jQuery('#field_chinglish'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]).css('display','');
                                    }
                                    //
                                    if (tfieldidarray[1]==isdetail){
                                        if(rownum>-1){  // 明细字段
                                            if(document.forms[0].elements[i].name=='field'+tfieldidarray[0]+"_"+rownum&&$GetEle('oldfieldview'+tfieldidarray[0]+"_"+rownum)){
                                                isedit=$GetEle('oldfieldview'+tfieldidarray[0]+"_"+rownum).value;
                                                if(isedit>1&&($GetEle('field'+tfieldidarray[0]+"_"+rownum+"span")||$GetEle('field_'+tfieldidarray[0]+"_"+rownum+"span"))){
                                                    var  nameStr = 'field'+tfieldidarray[0]+"_"+rownum;
                                                    var spanNameStr = nameStr+"span";
                                                    if(jQuery('#field_'+tfieldidarray[0]+"_"+rownum+"span").length>0){
                                                        spanNameStr = 'field_'+tfieldidarray[0]+"_"+rownum+"span";
                                                    }
                                                    //if(document.forms[0].elements[i].value==""&&$GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")<=0) $GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="<IMG src='/images/BacoError_wev8.gif' align=absMiddle>";
                                                    jQuery('#'+nameStr).attr("isMustInput","2");//2：必须输：可编辑
                                                    var imgObj = jQuery('#'+nameStr+"spanimg");
                                                    if(imgObj.length==0){
                                                        imgObj = jQuery('#'+spanNameStr)
                                                    }
                                                    var objVal = jQuery('#'+nameStr);
                                                    if(objVal.val()==""){
                                                        imgObj.html("<IMG src='/images/BacoError_wev8.gif' align=absMiddle>");
                                                    }

                                                    //子表判断附件字段
                                                    if($GetEle("fsUploadProgress"+tfieldidarray[0]+"_"+rownum)){
                                                        attachmentHideOrShow("field"+tfieldidarray[0]+"_"+rownum);
                                                        imgObj.html("（必填）");
                                                        var isReturn = false;
                                                        jQuery("#fsUploadProgress"+tfieldidarray[0]+"_"+rownum+" .progressBarStatus").each(function(i,obj){
                                                            if(jQuery(obj).text()!='Cancelled'){
                                                                isReturn = true;
                                                                return false
                                                            }
                                                        })
                                                        if(isReturn){
                                                            jQuery("#field_"+tfieldidarray[0]+"_"+rownum+"span").hide();
                                                        }else{
                                                            if(jQuery("#field"+tfieldidarray[0]+"_"+rownum).val()==''
                                                                ||jQuery("#field"+tfieldidarray[0]+"_"+rownum).val()=='NULL'
                                                                ||jQuery("#field"+tfieldidarray[0]+"_"+rownum).val()=='null'){
                                                                jQuery("#field_"+tfieldidarray[0]+"_"+rownum+"span").show();
                                                                jQuery("#field"+tfieldidarray[0]+"_"+rownum).val("");
                                                            }else{
                                                                jQuery("#field_"+tfieldidarray[0]+"_"+rownum+"span").hide();
                                                            }
                                                        }

                                                        //jQuery("#spanButtonPlaceHolderDis"+tfieldidarray[0]).show();
                                                        attachmentDisd(tfieldidarray[0]+"_"+rownum,false);
                                                    }

                                                    try{
                                                        if(document.forms[0].elements[i].value==""&&$GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")<=0){
                                                            $GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="<IMG src='/images/BacoError_wev8.gif' align=absMiddle>";
                                                            $GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="";
                                                        }
                                                    }catch(e){}
                                                    if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                        //document.all('field'+tfieldidarray[0]+"_"+rownum).disabled=false;
                                                        setCanEdit($GetEle('field'+tfieldidarray[0]+"_"+rownum));
                                                    }
                                                    if($GetEle('field'+tfieldidarray[0]+"_"+rownum+'browser')!=null){
                                                        $GetEle('field'+tfieldidarray[0]+"_"+rownum+'browser').disabled=false;
                                                    }
                                                    if(jQuery('#field'+tfieldidarray[0]+"_"+rownum+'span').css('display')=='none'){
                                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'span').css('display','');
                                                    }
                                                    var checkstr_=$GetEle("needcheck").value+",";
                                                    if(checkstr_.indexOf("field"+tfieldidarray[0]+"_"+rownum+",")<0) $GetEle("needcheck").value=checkstr_+"field"+tfieldidarray[0]+"_"+rownum;
                                                    document.forms[0].elements[i].setAttribute('viewtype','1');
                                                }else{
                                                    if(isedit>1){
                                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                            setCanEdit($GetEle('field'+tfieldidarray[0]+"_"+rownum));
                                                        }
                                                    }
                                                }
                                            }
                                        }else{     // 主字段
                                            if(document.forms[0].elements[i].name=='field'+tfieldidarray[0]&&$GetEle('oldfieldview'+tfieldidarray[0])){
                                                isedit=$GetEle('oldfieldview'+tfieldidarray[0]).value;
                                                if(isedit>1&&$GetEle('field'+tfieldidarray[0]+"span")){
                                                    jQuery('#field'+tfieldidarray[0]).attr("isMustInput","2");//2：必须输：可编辑
                                                    if(document.forms[0].elements[i].value==""){
                                                        var imgObj = jQuery('#field'+tfieldidarray[0]+"spanimg");
                                                        if(imgObj.length==0){
                                                            imgObj = jQuery('#field'+tfieldidarray[0]+"span")
                                                        }
                                                        if(imgObj.length>0){
                                                            imgObj.html("<IMG src='/images/BacoError_wev8.gif' align=absMiddle>");
                                                        }
                                                        //$GetEle('field'+tfieldidarray[0]+"span").innerHTML="<IMG src='/images/BacoError_wev8.gif' align=absMiddle>";
                                                    }
                                                    //判断附件字段
                                                    if($GetEle("fsUploadProgress"+tfieldidarray[0])){
                                                        attachmentHideOrShow("field"+tfieldidarray[0]);
                                                        var isReturn = false;
                                                        jQuery("#fsUploadProgress"+tfieldidarray[0]+" .progressBarStatus").each(function(i,obj){
                                                            if(jQuery(obj).text()!='Cancelled'){
                                                                isReturn = true;
                                                                return false
                                                            }
                                                        })
                                                        if(isReturn){
                                                            jQuery("#field_"+tfieldidarray[0]+"span").hide();
                                                        }else{
                                                            if(jQuery("#field"+tfieldidarray[0]).val()==''
                                                                ||jQuery("#field"+tfieldidarray[0]).val()=='NULL'
                                                                ||jQuery("#field"+tfieldidarray[0]).val()=='null'){
                                                                jQuery("#field_"+tfieldidarray[0]+"span").show();
                                                                jQuery("#field"+tfieldidarray[0]).val("");
                                                            }else{
                                                                jQuery("#field_"+tfieldidarray[0]+"span").hide();
                                                            }
                                                        }

                                                        //jQuery("#spanButtonPlaceHolderDis"+tfieldidarray[0]).show();
                                                        attachmentDisd(tfieldidarray[0],false);
                                                        if($GetEle("fsUploadProgress"+tfieldidarray[0]).children.length>0){
                                                            $GetEle('field'+tfieldidarray[0]+"span").innerHTML="";
                                                        }
                                                    }

                                                    try{
                                                        if(document.forms[0].elements[i].value==""){
                                                            $GetEle('field_lable'+tfieldidarray[0]+"span").innerHTML="<IMG src='/images/BacoError_wev8.gif' align=absMiddle>";
                                                            $GetEle('field'+tfieldidarray[0]+"span").innerHTML="";
                                                        }
                                                    }catch(e){}
                                                    if($GetEle('field'+tfieldidarray[0])!=null){
                                                        //document.all('field'+tfieldidarray[0]).disabled=false;
                                                        setCanEdit($GetEle('field'+tfieldidarray[0]));
                                                    }
                                                    if($GetEle('field'+tfieldidarray[0]+'browser')!=null){
                                                        $GetEle('field'+tfieldidarray[0]+'browser').disabled=false;
                                                    }
                                                    var checkstr_=$GetEle("needcheck").value+",";
                                                    if(checkstr_.indexOf("field"+tfieldidarray[0]+",")<0) $GetEle("needcheck").value=checkstr_+"field"+tfieldidarray[0];
                                                    document.forms[0].elements[i].setAttribute('viewtype','1');
                                                }else{
                                                    if($GetEle('field'+tfieldidarray[0])!=null){
                                                        setCanEdit($GetEle('field'+tfieldidarray[0]));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(fieldattr==3){//为只读，显示属性设为编辑
                            for(i=0;i<len;i++){
                                for(j=0;j<fieldidarray.length;j++){
                                    var tfieldidarray=fieldidarray[j].split("_");
                                    //影藏
                                    if(jQuery('#field'+tfieldidarray[0]+rownum+'span').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+rownum+'span').css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+"_"+rownum+'wrapspan').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'_browserbtn').css('display','');
                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'wrapspan').css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'span_'+rownum).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'span_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }if(jQuery('#field_chinglish'+tfieldidarray[0]+'span_'+rownum).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'span_'+rownum).css('display','');
                                    }
                                    if(jQuery('#field_chinglish'+tfieldidarray[0]+'_'+rownum).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'_'+rownum).css('display','');
                                    }
                                    //判断附件字段
                                    if(jQuery("#field_"+tfieldidarray[0]+"span_"+rownum).css('display')=='none'){
                                        jQuery("#field_"+tfieldidarray[0]+"span_"+rownum).css('display','');
                                    }
                                    else{
                                        if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                        }
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+"span").css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+"span").css('display','');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]+'_browserbtn').closest('.e8_os').css('display','block');
                                    }
                                    if(jQuery('#field'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field'+tfieldidarray[0]).css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]+'span').css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]+'span').css('display','');
                                    }
                                    if(jQuery('#field_lable'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field_lable'+tfieldidarray[0]).css('display','');
                                    }if(jQuery('#field_chinglish'+tfieldidarray[0]+'span').css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]+'span').css('display','');
                                    }
                                    if(jQuery('#field_chinglish'+tfieldidarray[0]).css('display')=='none'){
                                        jQuery('#field_chinglish'+tfieldidarray[0]).css('display','');
                                    }
                                    //
                                    if (tfieldidarray[1]==isdetail){
                                        if(rownum>-1){  //明细字段
                                            if(document.forms[0].elements[i].name=='field'+tfieldidarray[0]+"_"+rownum&&document.all('oldfieldview'+tfieldidarray[0]+"_"+rownum)){
                                                if(($GetEle('field'+tfieldidarray[0]+"_"+rownum+"span")||$GetEle('field_'+tfieldidarray[0]+"_"+rownum+"span"))){
                                                    jQuery('#field'+tfieldidarray[0]+"_"+rownum).attr("isMustInput","1");
                                                    var checkstr_=$GetEle("needcheck").value+",";
                                                    //提前替换，否则触发checkFileRequired事件时，会判断出错
                                                    $GetEle("needcheck").value=checkstr_.replace("field"+tfieldidarray[0]+"_"+rownum+",","");
                                                    var imgObj = jQuery('#field'+tfieldidarray[0]+"_"+rownum+"spanimg");
                                                    if(imgObj.length==0){
                                                        imgObj = jQuery('#field'+tfieldidarray[0]+"_"+rownum+"span")
                                                    }

                                                    var objVal = jQuery('#field'+tfieldidarray[0]+"_"+rownum);
                                                    if(objVal.val()==""){
                                                        imgObj.html("");
                                                    }

                                                    //子表判断附件字段
                                                    if($GetEle("fsUploadProgress"+tfieldidarray[0]+"_"+rownum)){
                                                        attachmentHideOrShow("field"+tfieldidarray[0]+"_"+rownum);
                                                        var isReturn = false;
                                                        jQuery("#fsUploadProgress"+tfieldidarray[0]+"_"+rownum+" .progressBarStatus").each(function(i,obj){
                                                            if(jQuery(obj).text()!='Cancelled'){
                                                                isReturn = true;
                                                                return false
                                                            }
                                                        })
                                                        jQuery("#field_"+tfieldidarray[0]+"_"+rownum+"span").hide();
                                                        attachmentDisd(tfieldidarray[0]+"_"+rownum,true);
                                                    }

                                                    //if($GetEle('field'+tfieldidarray[0]+"_"+rownum+"span")){
                                                    //	if($GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1){
                                                    //		$GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="";
                                                    //	}
                                                    //$GetEle('field'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="";
                                                    //}
                                                    if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                        //$GetEle('field'+tfieldidarray[0]+"_"+rownum).value="";
                                                        //$GetEle('field'+tfieldidarray[0]+"_"+rownum).disabled=true;
                                                        setReadOnly($GetEle('field'+tfieldidarray[0]+"_"+rownum));
                                                    }
                                                    if($GetEle('field'+tfieldidarray[0]+"_"+rownum+'browser')!=null){
                                                        $GetEle('field'+tfieldidarray[0]+"_"+rownum+'browser').disabled=true;
                                                    }

                                                    if(jQuery('#field'+tfieldidarray[0]+"_"+rownum+'span').css('display')=='none'){
                                                        jQuery('#field'+tfieldidarray[0]+"_"+rownum+'span').css('display','');
                                                    }

                                                    try{
                                                        if($GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1){
                                                            $GetEle('field_lable'+tfieldidarray[0]+"_"+rownum+"span").innerHTML="";
                                                        }
                                                    }catch(e){}
                                                    document.forms[0].elements[i].setAttribute('viewtype','0');
                                                }else{
                                                    if($GetEle('field'+tfieldidarray[0]+"_"+rownum)!=null){
                                                        setReadOnly($GetEle('field'+tfieldidarray[0]+"_"+rownum));
                                                    }
                                                }
                                            }
                                        }else{     //主字段
                                            if(document.forms[0].elements[i].name=='field'+tfieldidarray[0]&&$GetEle('oldfieldview'+tfieldidarray[0])){
                                                if($GetEle('field'+tfieldidarray[0]+"span")){
                                                    jQuery('#field'+tfieldidarray[0]).attr("isMustInput","1");
                                                    var checkstr_=$GetEle("needcheck").value+",";
                                                    //提前替换，否则触发checkFileRequired事件时，会判断出错
                                                    $GetEle("needcheck").value=checkstr_.replace("field"+tfieldidarray[0]+",","");
                                                    var imgObj = jQuery('#field'+tfieldidarray[0]+"spanimg");
                                                    if(imgObj.length==0){
                                                        imgObj = jQuery('#field'+tfieldidarray[0]+"span")
                                                    }
                                                    if(imgObj.length>0&&imgObj.html().indexOf("/images/BacoError_wev8.gif")>-1){
                                                        imgObj.html("");
                                                    }

                                                    //if($GetEle('field'+tfieldidarray[0]+"span")){
                                                    //$GetEle('field'+tfieldidarray[0]+"span").innerHTML="";
                                                    //	if($GetEle('field'+tfieldidarray[0]+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1){
                                                    //		$GetEle('field'+tfieldidarray[0]+"span").innerHTML="";
                                                    //	}
                                                    // }
                                                    //判断附件字段
                                                    if($GetEle("fsUploadProgress"+tfieldidarray[0])){
                                                        attachmentHideOrShow("field"+tfieldidarray[0]);
                                                        //jQuery("#field"+tfieldidarray[0]).prev().hide();
                                                        jQuery("#field_"+tfieldidarray[0]+"span").hide();
                                                        //jQuery("#spanButtonPlaceHolderDis"+tfieldidarray[0]).hide();
                                                        /**
                                                         *附件不可编辑
                                                         **/
                                                        attachmentDisd(tfieldidarray[0],true);
                                                    }
                                                    if($GetEle('field'+tfieldidarray[0])!=null){
                                                        //$GetEle('field'+tfieldidarray[0]).value="";
                                                        //$GetEle('field'+tfieldidarray[0]).disabled=true;
                                                        //$GetEle('field'+tfieldidarray[0]).readOnly=true;
                                                        setReadOnly($GetEle('field'+tfieldidarray[0]));
                                                    }
                                                    if($GetEle('field'+tfieldidarray[0]+"browser")!=null){
                                                        $GetEle('field'+tfieldidarray[0]+"browser").disabled=true;
                                                    }
                                                    try{
                                                        if($GetEle('field_lable'+tfieldidarray[0]+"span").innerHTML.indexOf("/images/BacoError_wev8.gif")>-1){
                                                            $GetEle('field_lable'+tfieldidarray[0]+"span").innerHTML="";
                                                        }
                                                    }catch(e){}
                                                    document.forms[0].elements[i].setAttribute('viewtype','0');
                                                }else{
                                                    if($GetEle('field'+tfieldidarray[0])!=null){
                                                        setReadOnly($GetEle('field'+tfieldidarray[0]));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }catch(e){}
        }
    });
}
