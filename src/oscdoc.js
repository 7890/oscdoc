//tb/1406
//regexp search on json object inspired by: http://jsbin.com/ezifi/1/edit

var xotree = new XML.ObjTree();
xotree.attr_prefix='@';
var root;

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

	//case ruled out when no messages available at all
	if(isNaN(message.length)) //can happen when only one message available
	{
		pattern=message['@pattern'];
		typetag=message['@typetag'];
		if(!typetag)
		{
			typetag="";
		}
		var regexp=new RegExp(text,"g");
		if(pattern.match(regexp))
		{
			out+='<a href="#'+unit_uri+'_'+pattern+'_'+typetag+'" onfocus="javascript:patternClicked('+0+','+direction_+');">'+pattern+' '+typetag+'</a><br/>';
			match_count++
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
				var regexp=new RegExp(text,"g");
				if(pattern.match(regexp))
			{
				out+='<a href="#'+unit_uri+';'+pattern+';'+typetag+';" onfocus="javascript:patternClicked('+i+','+direction_+');">'+pattern+' '+typetag+'</a><br/>';
				match_count++
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

function showAll()
{
	$('#input1').val("/*");
	$('#input1').focus();

	e = $.Event('keyup');
	e.keyCode= 13; // enter
	$('#input1').trigger(e);
}
