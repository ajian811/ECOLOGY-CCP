Ext.namespace("Ext.ux.Wiz");Ext.ux.Wiz.Card=Ext.extend(Ext.FormPanel,{header:false,hideMode:"display",skip:false,wizard:null,initComponent:function(){this.addEvents("beforecardhide");Ext.ux.Wiz.Card.superclass.initComponent.call(this)},isValid:function(){if(this.monitorValid){return this.bindHandler()}return true},bindHandler:function(){if(!this.bound){return false}var d=true;this.form.items.each(function(e){if(e.isValid&&!e.isValid(true)){d=false;return false}});if(this.buttons){for(var c=0,a=this.buttons.length;c<a;c++){var b=this.buttons[c];if(b.formBind===true&&b.disabled===d){b.setDisabled(!d)}}}this.fireEvent("clientvalidation",this,d)},initEvents:function(){var a=this.monitorValid;this.monitorValid=false;Ext.ux.Wiz.Card.superclass.initEvents.call(this);this.monitorValid=a;this.on("beforehide",this.bubbleBeforeHideEvent,this);this.on("beforecardhide",this.isValid,this);this.on("show",this.onCardShow,this);this.on("hide",this.onCardHide,this)},bubbleBeforeHideEvent:function(){var a=this.ownerCt.layout;var b=a.activeItem;if(b&&b.id===this.id){return this.fireEvent("beforecardhide",this)}return true},onCardHide:function(){if(this.monitorValid){this.stopMonitoring()}},onCardShow:function(){if(this.monitorValid){this.startMonitoring()}},getPrevious:function(){var a=this.wizard.getCardPosition(this);if(a<=0){return -1}while(--a>=0){if(this.wizard.cards[a].skip==false){return a}}return a},getNext:function(){var a=this.wizard.getCardPosition(this);if(a>=(this.wizard.cards.length-1)){return -1}while(++a<this.wizard.cards.length){if(this.wizard.cards[a].skip==false){return a}}return -1},setSkip:function(a){if(this.wizard.cards[this.wizard.currentCard]==this){return false}if(this.skip!=a){this.skip=a;this.wizard.headPanel.initIndicators();this.wizard.headPanel.updateStep();return true}return false}});