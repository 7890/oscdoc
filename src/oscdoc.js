//tb/1406
//regexp search on json object inspired by: http://jsbin.com/ezifi/1/edit

var xotree = new XML.ObjTree();
xotree.attr_prefix='@';
var root;

var last_selected_pattern='';

function jq( myid ) 
{
	return myid.replace( /(:|\.|\[|\])/g, "\\$1" );
}

$(document).ready(function() 
{
	var tree = xotree.parseXML( xml );
	root = tree.osc_unit;
		
	$('#input1').focus();

	$('#opt1').on('change',function(evt)
	{
		$('#input1').focus();
		e = $.Event('keyup');
		e.keyCode= 13; // enter
		$('#input1').trigger(e);
	});

	$('#opt2').on('change',function(evt)
	{
		$('#input1').focus();
		e = $.Event('keyup');
		e.keyCode= 13; // enter
		$('#input1').trigger(e);
	});

	$('#input1').keyup(function(evt){

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

	}); //end keyup on input1

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

	//case ruled out when no messages available at all
	if(isNaN(message.length)) //can happen when only one message available
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
			if(pattern.match(regexp))
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

	last_selected_pattern=message['@pattern'];

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
	setDescription($('#__help').html());
}

function showMeta()
{
	setDescription($('#__meta').html());
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
	$('#input1').val("");
	$('#input1').focus();
	setMessage("");
}

function useSelected()
{

var s=last_selected_pattern;
//s = s.substring(0, s.indexOf('/'));

	$('#input1').val(s);
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
