import stdlib.core.rpc.core
import stdlib.apis.common
type databasedump = {
	list(Plant.t) Plants,
	list(Plant.History.Kinds) Plant_History_Kinds,
	list(Plant.History.Event) Plant_History_Event,
	list(Plant.Family.t) Plant_Family,
	list(Plant.Genus.t) Plant_Genus,
	list(Plant.Species.t) Plant_Species,
	list(Plant.Variety.t) Plant_Variety,
	int Plant_Next_id,
	int Plant_Next_Family_id,
	int Plant_Next_Genus_id,
	int Plant_Next_Species_id,
	int Plant_Next_Variety_id,
	int Plant_Next_Event_Kind_id
}
module ImportExport {
	
	function export() {
		//int_json = {Int : 2}
		databasedump contents = {
			Plants: doserialize(/cactusdb/Plants[]),
			Plant_History_Kinds: doserialize(/cactusdb/Plant/History/Kinds[]),
			Plant_History_Event: doserialize(/cactusdb/Plant/History/Event[]),
			Plant_Family: doserialize(/cactusdb/Plant/Family[]),
			Plant_Genus: doserialize(/cactusdb/Plant/Genus[]),
			Plant_Species: doserialize(/cactusdb/Plant/Species[]),
			Plant_Variety: doserialize(/cactusdb/Plant/Variety[]),
			Plant_Next_id : /cactusdb/Plant/Next/id,
			Plant_Next_Family_id : /cactusdb/Plant/Next/Family/id,
			Plant_Next_Genus_id: /cactusdb/Plant/Next/Genus/id,
			Plant_Next_Species_id: /cactusdb/Plant/Next/Species/id,
			Plant_Next_Variety_id: /cactusdb/Plant/Next/Variety/id,
			Plant_Next_Event_Kind_id: /cactusdb/Plant/Next/Event/Kind/id,
		}
		OpaSerialize.serialize(contents)
	}
	function doserialize(thing) {
		Iter.to_list(DbSet.iterator(thing))
	}
	function import() {
		<div id=#importarea>
			<textarea width="100%" rows="10" id=#importjson></textarea><br />
			<a class="btn" onclick={function(_){
				processImport()
			}}>Import</a>
			<span id=#testarea></span>
		</div>
	}
	function processImport() {
		// contents = OpaSerialize.unserialize(Dom.get_value(#importjson),databasedump)
		// #testarea = Int.to_string(contents.Plant_Next_Genus_id)
		#testarea = ""
		match(Json.deserialize(Dom.get_value(#importjson))) {
			case {some: jsonObject }: {
				match(OpaSerialize.Json.unserialize_unsorted(jsonObject)) {
					case {some: databasedump contents}  : {
						#testarea =+ <>Calling db cleanup</>
						Model.cleanDatabase()
						putInDatabase(contents)
					}
					default : void
				}
			}
			default: void
		}
		
		void
	}
	function putInDatabase(databasedump d) {
		/cactusdb/Plant/Next/id = d.Plant_Next_id
		/cactusdb/Plant/Next/Family/id = d.Plant_Next_Family_id
		/cactusdb/Plant/Next/Species/id = d.Plant_Next_Species_id
		/cactusdb/Plant/Next/Variety/id = d.Plant_Next_Variety_id
		/cactusdb/Plant/Next/Genus/id = d.Plant_Next_Genus_id
		/cactusdb/Plant/Next/Event/Kind/id = d.Plant_Next_Event_Kind_id

		_ = List.map(function(plant) {
			Model.save_plant(plant)
			#testarea =+ <><br />Saving Plant {plant.id}</>
		},d.Plants);
		_ = List.map(function(a) {
			Model.save_history_event_kind(a.kind, a.name)
			#testarea =+ <><br />Saving Kind {a.name}</>
		},d.Plant_History_Kinds);
		_ = List.map(function(a) {
			Model.save_history_event(a)
			#testarea =+ <><br />Saving event {a.eventid}</>
		},d.Plant_History_Event);
		_ = List.map(function(a) {
			Model.save_family(a.id,a.familyName)
			#testarea =+ <><br />Saving Family {a.familyName}</>
		},d.Plant_Family);
		_ = List.map(function(a) {
			Model.save_genus(a.id,a.genusName)
			#testarea =+ <><br />Saving Genus {a.genusName}</>
		},d.Plant_Genus);
		_ = List.map(function(a) {
			Model.save_species(a.id,a.speciesName,a.displayId)
			#testarea =+ <><br />Saving Species {a.speciesName}</>
		},d.Plant_Species);
		_ = List.map(function(a) {
			Model.save_variety(a.id,a.varietyName,a.displayId)
			#testarea =+ <><br />Saving Variety {a.id} {a.varietyName}</>
		},d.Plant_Variety);


		void
	}
	/*
	list(Plant.Family.t) Plant_Family,
	list(Plant.Genus.t) Plant_Genus,
	list(Plant.Species.t) Plant_Species,
	list(Plant.Variety.t) Plant_Variety,
	*/
	
}