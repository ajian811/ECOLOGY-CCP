Ext.ux.SearchField=Ext.extend(Ext.form.TwinTriggerField,{initComponent:function(){if(!this.store.baseParams){this.store.baseParams={}}Ext.ux.SearchField.superclass.initComponent.call(this);this.on("specialkey",function(a,b){if(b.getKey()==b.ENTER){this.onTrigger2Click()}},this)},validationEvent:false,validateOnBlur:false,trigger1Class:"x-form-clear-trigger",trigger2Class:"x-form-search-trigger",hideTrigger1:true,width:180,hasSearch:false,paramName:"query",onTrigger1Click:function(){if(this.hasSearch){this.store.baseParams[this.paramName]="";this.store.removeAll();this.el.dom.value="";this.triggers[0].hide();this.hasSearch=false;this.focus()}},onTrigger2Click:function(){var a=this.getRawValue();if(a.length<1){this.onTrigger1Click();return}if(a.length<2){Ext.Msg.alert("Invalid Search","You must enter a minimum of 2 characters to search the API");return}this.store.baseParams[this.paramName]=a;var b={start:0};this.store.reload({params:b});this.hasSearch=true;this.triggers[0].show();this.focus()}});