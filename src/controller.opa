resources = @static_resource_directory("resources")

function start(url) {
    match(url) {
        case {path: [] ... } : Resource.default_redirection_page("/main")
        case {path: ["main"] ...} : View.pageWrapper("Cactus DB", View.page(""))
        case {path: ["meta" | path ] ... } : View.pageWrapper("Meta Information", Meta.page(path))
        case {path: ["aging" | path ] ... } : View.pageWrapper("Aging Report", View.aging(path))
        case {path: ["plant" | path ] ... } : View.pageWrapper("Plant", View.plant(path))
        case {path: ["find" | path ] ... } : View.pageWrapper("Search", View.find(path))
        case {~path ...}: Resource.error_page("404 Not Found", <h1>Bad URL {path}</h1>,{wrong_address})
    }
}
custom = {
    parser {
        case r={Server.resource_map(resources)} : r
    }
}

Server.start({
    port: 58000, netmask:0.0.0.0, encryption: {no_encryption}, name:"cactusdb"
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
