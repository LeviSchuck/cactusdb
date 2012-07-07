import stdlib.core.date
/*type page = {
	string path,
	string content,
	int counter
}*/
type Plant.id = int
type Plant.Family.id = int
type Plant.Genus.id = int
type Plant.Species.id = int
type Plant.Variety.id = int
type Plant.Family.t = {
	Plant.Family.id id,
	string familyName
}
type Plant.Genus.t = {
	Plant.Genus.id id,
	Plant.Family.id family,
	string genusName
}
type Plant.Species.t = {
	Plant.Species.id id,
	Plant.Genus.id genus,
	int displayId,
	string speciesName
}
type Plant.Variety.t = {
	Plant.Variety.id id,
	Plant.Species.id species,
	int displayId,
	string varietyName
}
type Plant.t = {
	Plant.id id,
	Plant.Family.id family,
	Plant.Genus.id genus,
	Plant.Species.id species,
	Plant.Variety.id variety,
	int memberid,
	string origin,
	string misc,
	int eventcount
}
type Plant.Display = {
	Plant.id id,

	string family,
	string genus,
	string species,
	string variety,

	int speciesid,
	int varietyid,
	int memberid,

	string origin,
	string misc
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
	Plant.Family.t /Plant/Family[{id}]
	Plant.Genus.t /Plant/Genus[{id}]
	Plant.Species.t /Plant/Species[{id}]
	Plant.Variety.t /Plant/Variety[{id}]
	int /Plant/Next/id = 0
	int /Plant/Next/Family/id = 0
	int /Plant/Next/Genus/id = 0
	int /Plant/Next/Species/id = 0
	int /Plant/Next/Variety/id = 0
	int /Plant/Next/Event/Kind/id = 0
}

module Model {
	function get_plant(id) {
		/cactusdb/Plants[{~id}]
	}
	function int get_next_event_for_plant(id) {
		/cactusdb/Plants[{~id}]/eventcount++
		/cactusdb/Plants[{~id}]/eventcount - 1
	}
	function int get_next_id_for_plant() {
		/cactusdb/Plant/Next/id++
		/cactusdb/Plant/Next/id - 1
	}
	function int get_next_id_for_family() {
		/cactusdb/Plant/Next/Family/id++
		/cactusdb/Plant/Next/Family/id - 1
	}
	function int get_next_id_for_genus() {
		/cactusdb/Plant/Next/Genus/id++
		/cactusdb/Plant/Next/Genus/id - 1
	}
	function int get_next_id_for_species() {
		/cactusdb/Plant/Next/Species/id++
		/cactusdb/Plant/Next/Species/id - 1
	}
	function int get_next_id_for_variety() {
		/cactusdb/Plant/Next/Variety/id++
		/cactusdb/Plant/Next/Variety/id - 1
	}

	function Plant.Display get_plant_info(id) {
		plant = /cactusdb/Plants[{~id}]
		var = /cactusdb/Plant/Variety[{id: plant.variety}]
		spec = /cactusdb/Plant/Species[{id: plant.species}]
		gen = /cactusdb/Plant/Genus[{id: plant.genus}]
		fam = /cactusdb/Plant/Family[{id: plant.family}]
		{
			id : plant.id,

			family : fam.familyName,
			genus : gen.genusName,
			species : spec.speciesName,
			variety : var.varietyName,

			speciesid : spec.displayId,
			varietyid : var.displayId,
			memberid : plant.memberid,

			origin : plant.origin,
			misc : plant.misc
		}
	}
	function save_plant(plant) {
		/cactusdb/Plants[{id: plant.id}] <- plant
	}
	function make_plant(variety,memberid,origin,misc) {
		id = get_next_id_for_plant()
		var = /cactusdb/Plant/Variety[{id: variety}]
		spec = /cactusdb/Plant/Species[{id: var.species}]
		gen = /cactusdb/Plant/Genus[{id: spec.genus}]
		fam = /cactusdb/Plant/Family[{id: gen.family}]
		plant = {
			~id,
			family: fam.id,
			genus: gen.id,
			species: spec.id,
			variety: var.id,
			~memberid,
			~origin,
			~misc,
			eventcount : 0
		}
		save_plant(plant)
	}
	function find_species_by_display(id) {
		dbspecid = DbSet.iterator(/cactusdb/Plant/Species[displayId == id])
		Iter.fold(function(spec,_) {spec.id},dbspecid,-1)
	}
	function find_variety_by_display(spec,id) {
		dbvarid = DbSet.iterator(/cactusdb/Plant/Variety[displayId == id, species == spec])
		Iter.fold(function(var,_) {var.id},dbvarid,-1)
	}
	function find_plant(species,variety,memberid) {
		spec = find_species_by_display(species)
		var = find_variety_by_display(spec,variety)

		DbSet.iterator(/cactusdb/Plants[species==spec, variety==var, memberid == memberid])
	}
	function find_plants(species,variety) {
		spec = find_species_by_display(species)
		var = find_variety_by_display(spec,variety)

		DbSet.iterator(/cactusdb/Plants[species==spec, variety==var])
	}
	function find_plants_by_species(species) {
		spec = find_species_by_display(species)

		DbSet.iterator(/cactusdb/Plants[species==spec])
	}
	function save_family(id,name) {
		/cactusdb/Plant/Family[{~id}] <- {
			~id,
			familyName: name
		}
	}
	function make_family(name) {
		id = get_next_id_for_family()
		/cactusdb/Plant/Family[{~id}] <- {
			~id,
			familyName: name
		}
		id
	}
	function save_genus(id,name) {
		/cactusdb/Plant/Genus[{~id}]/genusName <- name
	}
	function make_genus(family,name) {
		id = get_next_id_for_genus()
		/cactusdb/Plant/Genus[{~id}] <- {
			~id,
			~family,
			genusName: name
		}
		id
	}
	function save_species(id,name,displayId) {
		/cactusdb/Plant/Species[{~id}]/speciesName <- name
		/cactusdb/Plant/Species[{~id}]/displayId <- displayId
	}
	function make_species(genus,name, displayId) {
		id = get_next_id_for_species()
		/cactusdb/Plant/Species[{~id}] <- {
			~id,
			~genus,
			speciesName: name,
			~displayId
		}
		id
	}
	function save_variety(id,name,displayId) {
		/cactusdb/Plant/Variety[{~id}]/varietyName <- name
		/cactusdb/Plant/Variety[{~id}]/displayId <- displayId
	}
	function make_variety(species,name, displayId) {
		id = get_next_id_for_variety()
		/cactusdb/Plant/Variety[{~id}] <- {
			~id,
			~species,
			varietyName: name,
			~displayId
		}
		id
	}
	function save_history_event_kind(kind,name) {
		/cactusdb/Plant/History/Kinds[{~kind}]/name <- name
	}
	function make_history_event_kind(name) {
		kind = /cactusdb/Plant/Next/Event/Kind/id
		/cactusdb/Plant/Next/Event/Kind/id++
		/cactusdb/Plant/History/Kinds[{kind:kind}] <- {
			~kind,
			~name
		}
		kind
	}
	function make_history_event(plantid, kind, notes,eventDate) {
		eid = get_next_event_for_plant(plantid)
		string eventid = "{plantid}-{eid}"
		/cactusdb/Plant/History/Event[{~eventid}] <- {
			~eventid,
			~plantid,
			~eventDate,
			~kind,
			~notes
		}
		/cactusdb/Plant/History/LastEvent[{~plantid,~kind}] <- {
			~plantid,
			~kind,
			~eventDate
		}
		eventid
	}
	function save_history_event(event) {
		/cactusdb/Plant/History/Event[{eventid: event.eventid}] <- event
		void
	}

	function get_plant_events(plantid) {
		DbSet.iterator(/cactusdb/Plant/History/Event[plantid == plantid; order -eventDate])
	}
	function get_plant_filtered_events(plantid,kind) {
		DbSet.iterator(/cactusdb/Plant/History/Event[plantid == plantid, kind == kind])
	}
	function get_event_kinds() {
		DbSet.iterator(/cactusdb/Plant/History/Kinds[order +name])
	}
	function get_plant_families() {
		DbSet.iterator(/cactusdb/Plant/Family[order +familyName])
	}
	function get_history_event_kind(kind) {
		/cactusdb/Plant/History/Kinds[{~kind}]
	}
	function get_history_event(eventid) {
		/cactusdb/Plant/History/Event[{~eventid}]
	}
	function get_plant_family(id) {
		/cactusdb/Plant/Family[{~id}]
	}
	function get_plant_genus(id) {
		/cactusdb/Plant/Genus[{~id}]
	}
	function get_plant_species(id) {
		/cactusdb/Plant/Species[{~id}]
	}
	function get_plant_variety(id) {
		/cactusdb/Plant/Variety[{~id}]
	}
	function get_plant_genus_by_family(family) {
		DbSet.iterator(/cactusdb/Plant/Genus[family == family; order +genusName])
	}
	function get_plant_genuses() {
		DbSet.iterator(/cactusdb/Plant/Genus[order +genusName])
	}
	function get_plant_species_by_genus(genus) {
		DbSet.iterator(/cactusdb/Plant/Species[genus == genus; order +displayId])
	}
	function get_plant_variety_by_species(species) {
		DbSet.iterator(/cactusdb/Plant/Variety[species == species; order +displayId])
	}
	function get_plant_display(plant) {
		famname = get_plant_family(plant.family).familyName
		genusname = get_plant_genus(plant.genus).genusName
		species = get_plant_species(plant.species)
		variety = get_plant_variety(plant.variety)
		Plant.Display display = 
		{
			id : plant.id,

			family : famname,
			genus : genusname,
			species : species.speciesName,
			variety : variety.varietyName,

			speciesid : species.id,
			varietyid : variety.id,
			memberid : plant.memberid,

			origin : plant.origin,
			misc: plant.misc
		}
		display
	}

	function delete_history_event(event) {
		Db.remove(@/cactusdb/Plant/History/Event[{eventid: event.eventid}])
	}
}

