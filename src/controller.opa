resources = @static_resource_directory("resources")

/*custom = {
    parser {
    case r={Server.resource_map(resources)} : r
    case "/" : Resource.default_redirection_page("/main")
    case "/meta" : Resource.page("Meta Information",View.meta(""))
    case "/aging" : Resource.page("Aging Report",View.aging(""))
    case {p : ["meta"] | p} : path = Text.to_string(p); Resource.page("Meta : " ^ path, View.meta(path))
    case p=(.*) : path = Text.to_string(p); Resource.page(path, View.page(path))	
    }
}*/
function start(url) {
    match(url) {
        case {path: [] ... } : Resource.default_redirection_page("/main")
        case {path: ["main"] ...} : Resource.page("Cactus DB", View.page(""))
        case {path: ["meta" | path ] ... } : Resource.page("Meta Information", View.meta(path))
        case {path: ["aging" | path ] ... } : Resource.page("Aging Report", View.aging(path))
        case {~path ...}: Resource.error_page("404 Not Found", <h1>Bad URL</h1>,{wrong_address})
    }
}
custom = {
    parser {
        case r={Server.resource_map(resources)} : r
    }
}

Server.start({
    port: 58000, netmask:255.0.0.0, encryption: {no_encryption}, name:"cactusdb"
}, [
	{ register : 
		[ { doctype : { html5 } },
		  {  js : [ ] },
		  { css : [ "/resources/css/style.css"] }
        ]
	},
	{ ~custom },
    {dispatch: start}
    //{~custom}
])
