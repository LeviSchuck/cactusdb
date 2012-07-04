type page = {
	string path,
	string content,
	int counter
}

database cactusdb {
	page /page[{path}]
}

module Model {
  
	function get_content(path) {
		/cactusdb/page[{~path}]/counter++;
		/cactusdb/page[{~path}]/content
	}

	function set_content(path, content) {
		/cactusdb/page[{~path}]/content <- content
	}

	function statistics() {
		DbSet.iterator(/cactusdb/page)
	}

}

