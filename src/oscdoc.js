//tb/1406
//regexp search on json object inspired by: http://jsbin.com/ezifi/1/edit

var xotree = new XML.ObjTree();
xotree.attr_prefix='@';
var root;

var last_selected_pattern='';

var legend_hidden=1;

function jq( myid ) 
{
	return myid.replace( /(:|\.|\[|\])/g, "\\$1" );
}

//http://stackoverflow.com/questions/646628/how-to-check-if-a-string-startswith-another-string
if (typeof String.prototype.startsWith != 'function') 
{
	String.prototype.startsWith = function (str)
	{
		return this.indexOf(str) == 0;
	};
}

$(document).ready(function() {

	$(function(){
//if show_tree
if( $('#tree').length )
{
		$("#tree").dynatree({
			onClick: function(node) {
				usePathFromTree(node);
			},
//The web service is expected to return a valid JSON node list, formatted like this:
//[ { ... }, { ... }, ... ]. 
	initAjax: {
		url: "res/tree.json",
		data: { mode: "all"}
		},

	onPostInit: function(isReloading, isError) {
        // 'this' is the current tree
        // isReloading is true, if status was read from existing cookies
        // isError is only used in Ajax mode
        // Fire an onActivate() event for the currently active node
		treeSetKeys();
		treeSetTooltips();
//		this.reactivate();
	}
	});

}//end if show_tree
	});

	var tree = xotree.parseXML( xml );
	root = tree.osc_unit;
		
	$('#input1').focus();

//direction
	$('#opt1').on('change',function(evt)
	{
		updateList();
	});

//refs
	$('#opt2').on('change',function(evt)
	{
		updateList();
	});

//typetag
	$('#input0').keyup(function(evt){
		updateList();
	}); //end keyup on input0

//pattern
	$('#input1').keyup(function(evt){
		updateList();
	}); //end keyup on input1

	//path list
	function updateList()
	{
		setMessage("");

		var text=$('#input1').val();
		var entry_length=text.length;

		if(entry_length<1 || text=='/')
		{
			return;
		}

		var dir=$('#opt1').val();
		if(dir==1 || dir==3)
		{
			handle_messages(root.message_in,text,'in');
		}
		if(dir==2 || dir==3)
		{
			handle_messages(root.message_out,text,'out');
		}

		//cancel the default handling of the event by the browser
		return false;
	}

	//http://api.jquery.com/focus-selector/
	$("#outterDiv" ).delegate( "*", "focus blur", function() 
	{
		var elem = $( this );
		setTimeout(function() 
		{
			elem.toggleClass( "focused", elem.is( ":focus" ) );
		}, 0 );
	});

}); //end document ready

//dir: 'in' / 'out'
function handle_messages(message,text,dir)
{
	if(!message)
	{
		return;
	}

	var direction_=1;
	if(dir=='out')
	{
		direction_=2;
	}

	var unit_uri=root.meta.uri;
	var pattern='';
	var typetag='';
	var out='';
	var match_count=0;

	var refs=$('#opt2').val();
	var typetag_filter=$('#input0').val();

	//case ruled out when no messages available at all
	if(isNaN(message.length))//can happen when only one message available
	{
		pattern=message['@pattern'];
		typetag=message['@typetag'];
		if(!typetag)
		{
			typetag="";
		}
		var regexp=new RegExp(text,"gi");
		if(pattern.match(regexp))
		{

			//not case insensitive
			var regexp_tt=new RegExp(typetag_filter,"g");
			if(typetag.match(regexp_tt))
			{

				var aspect=message['aspect'];
				if(aspect)
				{
					if(refs==1 || refs==2)
					{
						out+='[...] ';
						out+='<a href="#" onclick="javascript:patternClicked('+i+','+direction_+');" onfocus="javascript:patternClicked('+i+','+direction_+');">'+pattern+' '+typetag+'</a></br>';
						match_count++
					}
				}
				else if (refs!=2)
				{
					out+='<a href="#" onclick="javascript:patternClicked('+i+','+direction_+');" onfocus="javascript:patternClicked('+i+','+direction_+');">'+pattern+' '+typetag+'</a></br>';
					match_count++
				}
			}
		}
	}
	else
	{
		var i;
		for(i=0;i<message.length;i++)
		{
			pattern=message[i]['@pattern'];
			typetag=message[i]['@typetag'];	

			if(!typetag)
			{
				typetag="";
			}

			var regexp=new RegExp(text,"gi");

			var pattern_ranges_removed=pattern.replace(/[\[][,0-9]+[\]]/gi, "");

			if(pattern_ranges_removed.match(regexp))
			{

				//not case insensitive
				var regexp_tt=new RegExp(typetag_filter,"g");
				if(typetag.match(regexp_tt))
				{
					var aspect =message[i]['aspect'];
					if(aspect)
					{
						if(refs==1 || refs==2)
						{
							out+='[...] ';
							out+='<a href="#" onclick="javascript:patternClicked('+i+','+direction_+');" onfocus="javascript:patternClicked('+i+','+direction_+');">'+pattern+' '+typetag+'</a></br>';
							match_count++
						}
					}
					else if (refs!=2)
					{
						out+='<a href="#" onclick="javascript:patternClicked('+i+','+direction_+');" onfocus="javascript:patternClicked('+i+','+direction_+');">'+pattern+' '+typetag+'</a></br>';
						match_count++
					}
				}
			}
		}
	}
	addMessage("Found "+match_count+" Matches ("+dir+")<br/><br/>"+out+"<br/>");
}

function patternClicked(index,dir)
{
	//dir 1=in
	//dir 2=out
	var dir_='in';

	var message_;
	if(dir=='1')
	{
		message_=root.message_in;
	}
	else
	{
		message_=root.message_out;
		dir_='out';
	}

	var message;
	if(isNaN(message_.length))
	{
		message=message_;
	}
	else
	{
		message=message_[index];
	}

	var out='';

	var uri=root.meta.uri;

	var generated_id=uri+=';'+message['@pattern']+';';
	if(message['@typetag'])
	{
		generated_id+=message['@typetag'];
	}
	generated_id+=';'+dir_+';';

	last_selected_pattern=message['@pattern'].replace(/[\[][,0-9]+[\]]/gi, "");

	//alert(btoa(generated_id));
	//alert(atob(btoa(generated_id)));

	//base64
	generated_id=btoa(generated_id);
	//replace possible base64 chars +,/,= to make valid html id
	generated_id=generated_id.replace(/\+/g,'-');
	generated_id=generated_id.replace(/\//g,'_');
	generated_id=generated_id.replace(/=/g,'.');

//need escape
/*
// Does not work:
$( "#some:id" )
// Works!
$( "#some\\:id" )
// Does not work:
$( "#some.id" )
// Works!
$( "#some\\.id" )

The following function takes care of escaping these characters and places a "#" at the beginning of the ID string:

function jq( myid ) 
{
	return "#" + myid.replace( /(:|\.|\[|\])/g, "\\$1" );
}

The function can be used like so:

$( jq( "some.id" ) )

*/
	out+=$('#'+jq(generated_id)).html();

	setDescription(out);
}

function showHelp()
{
	setDescription($('#help__').html());
}

function showMeta()
{
	setDescription($('#meta__').html());
}

function addDescription(msg)
{
	$('#desc').append(msg);
}

function setDescription(msg)
{
	$('#desc').html(msg);
}

function addMessage(msg)
{
	$('#list').append(msg);
}

function setMessage(msg)
{
	$('#list').html(msg);
}

function clearInput()
{
	$('#input0').val("");
	$('#input1').val("");
//	$('#input1').focus();
	setMessage("");
}

function recallLastSelected()
{
	$('#input1').val(last_selected_pattern);
	$('#input1').focus();
	setMessage("");

	e = $.Event('keyup');
	e.keyCode= 13; // enter
	$('#input1').trigger(e);
}

function useLeafLastSelected()
{
	//http://stackoverflow.com/questions/8376525/get-value-of-a-string-after-a-slash-in-javascript
	var parts=last_selected_pattern.split("/");
	var s='/'+parts[parts.length - 1]; // Or parts.pop();

	$('#input1').val(s);
	$('#input1').focus();
	setMessage("");

	e = $.Event('keyup');
	e.keyCode= 13; // enter
	$('#input1').trigger(e);
}

function reduceLastSelected()
{
	var n = last_selected_pattern.lastIndexOf('/');
	var s = last_selected_pattern.substring(0,n);

	last_selected_pattern=s;

	$('#input1').val(s);
	$('#input1').focus();
	setMessage("");

	e = $.Event('keyup');
	e.keyCode= 13; // enter
	$('#input1').trigger(e);
}

function syncTree()
{
	treeCollapseAll();

	treeNavigateTo(last_selected_pattern);

	$('#input1').val(last_selected_pattern);
	$('#input1').focus();
	setMessage("");

	e = $.Event('keyup');
	e.keyCode= 13; // enter
	$('#input1').trigger(e);
}

function showAll()
{
	$('#input1').val("/*");
	$('#input1').focus();

	e = $.Event('keyup');
	e.keyCode= 13; // enter
	$('#input1').trigger(e);
}

function usePathFromTree(node)
{
	var s=node.getKeyPath();
	last_selected_pattern=s;

	$('#input1').val(s);
	$('#input1').focus();
	setMessage("");

	e = $.Event('keyup');
	e.keyCode= 13; // enter
	$('#input1').trigger(e);
}

function treeExpandAll()
{
	//if show_tree
	if( $('#tree').length )
	{
		$("#tree").dynatree("getRoot").visit(function(node){
			node.expand(true);
		});
	}
}

function treeCollapseAll()
{
	//if show_tree
	if( $('#tree').length )
	{
		$("#tree").dynatree("getRoot").visit(function(node){
			node.expand(false);
		});
	}
}

function treeSetTooltips()
{
	//if show_tree
	if( $('#tree').length )
	{
		$("#tree").dynatree("getRoot").visit(function(node){
			node.data.tooltip=node.getKeyPath();
		});
	}
}

function treeSetKeys()
{
	//if show_tree
	if( $('#tree').length )
	{
		$("#tree").dynatree("getRoot").visit(function(node){
			node.data.key=node.data.title.replace(/[\[][,0-9]+[\]]/gi, "");
		});
	}
}

function treeNavigateTo(path)
{
	//if show_tree
	if( $('#tree').length )
	{
		$("#tree").dynatree("getRoot").visit(function(node){
			if(path.startsWith(node.getKeyPath()))
			{
				node.expand(true);
				node.activate();
			}
		});
	}
}

function resetForm()
{
	clearInput();

	//dir in+out
	$('#opt1').val(3);
	//refs yes
	$('#opt2').val(1);

	last_selected_pattern='';

	treeCollapseAll();
	showMeta();

	if(legend_hidden==0)
	{
		toggleLegend();
	}
}

function toggleLegend()
{
	if(legend_hidden==1)
	{
		$("#legend").html($("#legend_hidden").html());
		legend_hidden=0;
	}
	else
	{
		$("#legend").html("");
		legend_hidden=1;
	}
}
