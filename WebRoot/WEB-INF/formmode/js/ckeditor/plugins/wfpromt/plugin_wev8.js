/**
 * @author lsj
 * @date 2014/2/20
 */

CKEDITOR.plugins.add( 'wfpromt',
    {
        requires : [ 'richcombo', 'styles' ],
        init : function( editor )
        {
            var config = editor.config,

            lang = editor.lang.format;

            var tags = [];


            var items=jQuery("#phraseselect").find("option");

			var promtitem;

            for(var i=1;i<items.length;i++)
			{
			  
			  promtitem=jQuery(items[i]).text();
			  tags[i-1]=[promtitem,promtitem,promtitem];
			 
			}

           editor.ui.addRichCombo( 'wfpromt',
                {
                    label : '<%=SystemEnv.getHtmlLabelName(22409,user.getLanguage())%>',	 
                    title : '<%=SystemEnv.getHtmlLabelName(22409,user.getLanguage())%>',
                    className : 'cke_format',
                    panel :
                    {
                        css : editor.skin.editor.css.concat( config.contentsCss ),
                        multiSelect : false,
                        attributes : { 'aria-label' : lang.panelTitle
                        }
                    },
                    init : function()
                    {
                        this.startGroup( '<%=SystemEnv.getHtmlLabelName(22409,user.getLanguage())%>' );
                        for (var this_tag in tags){
                            //function add( 值, html,文本 )
                            this.add(tags[this_tag][0], tags[this_tag][1], tags[this_tag][2]);
                        }
                    },
                    onClick : function( value )
                    {
                        editor.focus();
                        editor.fire( 'saveSnapshot' );
						//添加短语
                        onAddPhrase(value+"<br/>");

                        editor.fire( 'saveSnapshot' );
                    }
                });
        }
    });





