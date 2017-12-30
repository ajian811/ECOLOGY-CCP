Ext.layout.ToolbarLayout=Ext.extend(Ext.layout.ContainerLayout,{onLayout:function(d,e){if(!this.leftTr){e.addClass("x-toolbar-layout-ct");e.createChild([{tag:"table",cls:"x-toolbar-left",cellspacing:0,cn:{tag:"tbody",cn:{tag:"tr"}}},{tag:"table",cls:"x-toolbar-right",cellspacing:0,cn:{tag:"tbody",cn:{tag:"tr"}}}]);this.leftTr=e.child(".x-toolbar-left tr",true);this.rightTr=e.child(".x-toolbar-right tr",true)}else{this.align=this.container.initialConfig.align;while(this.leftTr.lastChild){this.leftTr.removeChild(this.leftTr.lastChild)}while(this.rightTr.lastChild){this.rightTr.removeChild(this.rightTr.lastChild)}}var b=d.items.items;for(var c=0,a=b.length;c<a;c++){this.renderItem(b[c],c,e)}},getNextCell:function(a){return(((a.align=="right")||(this.container.align=="right")||(this.align=="right"))?this.rightTr:this.leftTr).appendChild(document.createElement("td"))},renderItem:function(d,a,b){if(d){if(d.isFill){this.align="right"}else{if(d instanceof Ext.Element){this.getNextCell().appendChild(d.dom)}else{if(d.rendered){if(this.renderOnLayout){d.el.remove();delete d.el;d.rendered=false}else{this.getNextCell(d).appendChild(d[d.wrap?"wrap":"el"].dom)}}else{d.render(this.getNextCell(d))}}}}}});Ext.Container.LAYOUTS.toolbar=Ext.layout.ToolbarLayout;Ext.Toolbar=function(a){if(Ext.isArray(a)){a={items:a,layout:"toolbar"}}else{a=Ext.apply({layout:"toolbar"},a);if(a.buttons){a.items=a.buttons}}Ext.Toolbar.superclass.constructor.call(this,a)};(function(){var a=Ext.Toolbar;Ext.extend(a,Ext.Container,{defaultType:"tbbutton",trackMenus:true,autoCreate:{cls:"x-toolbar x-small-editor"},onRender:function(c,b){this.el=c.createChild(Ext.apply({id:this.id},this.autoCreate),b)},add:function(){var c=arguments,b=c.length;for(var d=0;d<b;d++){var e=c[d];if(e.isFormField){this.addField(e)}else{if(e.render){this.addItem(e)}else{if(typeof e=="string"){if(e=="separator"||e=="-"){this.addSeparator()}else{if(e==" "){this.addSpacer()}else{if(e=="->"){this.addFill()}else{this.addText(e)}}}}else{if(e.tag){this.addDom(e)}else{if(e.tagName){this.addElement(e)}else{if(typeof e=="object"){if(e.xtype){this.addItem(Ext.ComponentMgr.create(e,"button"))}else{this.addButton(e)}}}}}}}}},addSeparator:function(){return this.addItem(new a.Separator())},addSpacer:function(){return this.addItem(new a.Spacer())},addFill:function(){this.addItem(new a.Fill())},addElement:function(b){var c=new a.Item({el:b});this.addItem(c);return c},addItem:function(b){Ext.Toolbar.superclass.add.apply(this,arguments);return b},addButton:function(e){if(Ext.isArray(e)){var g=[];for(var f=0,d=e.length;f<d;f++){g.push(this.addButton(e[f]))}return g}var c=e;if(!(e instanceof a.Button)){c=e.split?new a.SplitButton(e):new a.Button(e)}this.initMenuTracking(c);this.addItem(c);return c},initMenuTracking:function(b){if(this.trackMenus&&b.menu){b.on({menutriggerover:this.onButtonTriggerOver,menushow:this.onButtonMenuShow,menuhide:this.onButtonMenuHide,scope:this})}},addText:function(c){var b=new a.TextItem(c);this.addItem(b);return b},insertButton:function(c,f){if(Ext.isArray(f)){var e=[];for(var d=0,b=f.length;d<b;d++){e.push(this.insertButton(c+d,f[d]))}return e}if(!(f instanceof a.Button)){f=new a.Button(f)}Ext.Toolbar.superclass.insert.call(this,c,f);return f},addDom:function(b){var c=new a.Item({autoEl:b});this.addItem(c);return c},addField:function(b){this.addItem(b);return b},onDisable:function(){this.items.each(function(b){if(b.disable){b.disable()}})},onEnable:function(){this.items.each(function(b){if(b.enable){b.enable()}})},onButtonTriggerOver:function(b){if(this.activeMenuBtn&&this.activeMenuBtn!=b){this.activeMenuBtn.hideMenu();b.showMenu();this.activeMenuBtn=b}},onButtonMenuShow:function(b){this.activeMenuBtn=b},onButtonMenuHide:function(b){delete this.activeMenuBtn}});Ext.reg("toolbar",Ext.Toolbar);a.Item=Ext.extend(Ext.BoxComponent,{hideParent:true,enable:Ext.emptyFn,disable:Ext.emptyFn,focus:Ext.emptyFn});Ext.reg("tbitem",a.Item);a.Separator=Ext.extend(a.Item,{onRender:function(c,b){this.el=c.createChild({tag:"span",cls:"ytb-sep"},b)}});Ext.reg("tbseparator",a.Separator);a.Spacer=Ext.extend(a.Item,{onRender:function(c,b){this.el=c.createChild({tag:"div",cls:"ytb-spacer"},b)}});Ext.reg("tbspacer",a.Spacer);a.Fill=Ext.extend(a.Item,{render:Ext.emptyFn,isFill:true});Ext.reg("tbfill",a.Fill);a.TextItem=Ext.extend(a.Item,{constructor:function(b){if(typeof b=="string"){b={autoEl:{cls:"ytb-text",html:b}}}else{b.autoEl={cls:"ytb-text",html:b.text||""}}a.TextItem.superclass.constructor.call(this,b)},setText:function(b){if(this.rendered){this.el.dom.innerHTML=b}else{this.autoEl.html=b}}});Ext.reg("tbtext",a.TextItem);a.Button=Ext.extend(Ext.Button,{hideParent:true,onDestroy:function(){a.Button.superclass.onDestroy.call(this);if(this.container){this.container.remove()}}});Ext.reg("tbbutton",a.Button);a.SplitButton=Ext.extend(Ext.SplitButton,{hideParent:true,onDestroy:function(){a.SplitButton.superclass.onDestroy.call(this);if(this.container){this.container.remove()}}});Ext.reg("tbsplit",a.SplitButton);a.MenuButton=a.SplitButton})();