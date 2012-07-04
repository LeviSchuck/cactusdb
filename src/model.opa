import stdlib.core.date
/*type page = {
	string path,
	string content,
	int counter
}*/
type Plant.id = int
type Plant.t = {
	Plant.id id,
	int species,
	int variant,
	int memberid,
	string name,
	string plantFamily,
	string variety,
	string origin,
	string misc,
	int eventcount
}
type Plant.History.Kind = int
type Plant.History.Kinds = {
	Plant.History.Kind kind,
	string name //Like repot, or inspected
}
type Plant.History.Event = {
	string eventid,//composed like {plantid}-{eventcount}
	Plant.id plantid,
	Date.date eventDate,
	Plant.History.Kind kind,
	string notes
}
type Plant.History.LastEventOf = {
	Plant.id plantid,
	Plant.History.Kind kind,
	Date.date eventDate
}
database cactusdb {
//	page /page[{path}]
	Plant.t /Plants[{id}]
	Plant.History.Kinds /Plant/History/Kinds[{kind}]
	Plant.History.Event /Plant/History/Event[{eventid}]
	Plant.History.LastEventOf /Plant/History/LastEvent[{plantid, kind}]
	Plant.id /Plaint/Next/id = 0
}

module Model {
  
	/*function get_content(path) {
		/cactusdb/page[{~path}]/counter++;
		/cactusdb/page[{~path}]/content
	}

	function set_content(path, content) {
		/cactusdb/page[{~path}]/content <- content
	}

	function statistics() {
		DbSet.iterator(/cactusdb/page)
	}*/

}

