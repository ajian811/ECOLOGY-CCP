Ext.namespace("Ext.ux.Andrie");Ext.ux.Andrie.pPageSize=function(a){Ext.apply(this,a)};Ext.extend(Ext.ux.Andrie.pPageSize,Ext.util.Observable,{beforeText:"Show",afterText:"items",addBefore:"-",addAfter:null,dynamic:false,variations:[5,10,20,50,100,200,500,1000],comboCfg:undefined,init:function(a){this.pagingToolbar=a;this.pagingToolbar.pageSizeCombo=this;this.pagingToolbar.setPageSize=this.setPageSize.createDelegate(this);this.pagingToolbar.getPageSize=function(){return this.pageSize};this.pagingToolbar.on("render",this.onRender,this)},addSize:function(a){if(a>0){this.sizes.push([a])}},updateStore:function(){if(this.dynamic){var b=this.pagingToolbar.pageSize,e;b=(b>0)?b:1;this.sizes=[];var c=this.variations;for(var d=0,a=c.length;d<a;d++){this.addSize(b-c[c.length-1-d])}this.addToStore(b);for(var d=0,a=c.length;d<a;d++){this.addSize(b+c[d])}}else{if(!this.staticSizes){this.sizes=[];var c=this.variations;var b=0;for(var d=0,a=c.length;d<a;d++){this.addSize(b+c[d])}this.staticSizes=this.sizes.slice(0)}else{this.sizes=this.staticSizes.slice(0)}}this.combo.store.loadData(this.sizes);this.combo.collapse();this.combo.setValue(this.pagingToolbar.pageSize)},setPageSize:function(f,j){var k=this.pagingToolbar;this.combo.collapse();f=parseInt(f)||parseInt(this.combo.getValue());f=(f>0)?f:1;if(f==k.pageSize){return}else{if(f<k.pageSize){k.pageSize=f;var a=Math.round(k.cursor/f)+1;var h=(a-1)*f;var g=k.store;if(h>g.getTotalCount()){this.pagingToolbar.pageSize=f;this.pagingToolbar.doLoad(h-f)}else{g.suspendEvents();for(var b=0,c=h-k.cursor;b<c;b++){g.remove(g.getAt(0))}while(g.getCount()>f){g.remove(g.getAt(g.getCount()-1))}g.resumeEvents();g.fireEvent("datachanged",g);k.cursor=h;var e=k.getPageData();k.afterTextEl.el.innerHTML=String.format(k.afterPageText,e.pages);k.field.dom.value=a;k.first.setDisabled(a==1);k.prev.setDisabled(a==1);k.next.setDisabled(a==e.pages);k.last.setDisabled(a==e.pages);k.updateInfo()}}else{this.pagingToolbar.pageSize=f;this.pagingToolbar.doLoad(Math.floor(this.pagingToolbar.cursor/this.pagingToolbar.pageSize)*this.pagingToolbar.pageSize)}}this.updateStore()},onRender:function(){this.combo=Ext.ComponentMgr.create(Ext.applyIf(this.comboCfg||{},{store:new Ext.data.SimpleStore({fields:["pageSize"],data:[]}),displayField:"pageSize",valueField:"pageSize",mode:"local",triggerAction:"all",width:50,xtype:"combo"}));this.combo.on("select",this.setPageSize,this);this.updateStore();if(this.addBefore){this.pagingToolbar.add(this.addBefore)}if(this.beforeText){this.pagingToolbar.add(this.beforeText)}this.pagingToolbar.add(this.combo);if(this.afterText){this.pagingToolbar.add(this.afterText)}if(this.addAfter){this.pagingToolbar.add(this.addAfter)}}});