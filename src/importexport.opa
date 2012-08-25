import stdlib.core.rpc.core

module ImportExport {
	function export() {
		//int_json = {Int : 2}
		OpaSerialize.Json.serialize({
			Plants: doserialize(/cactusdb/Plants[]),
			Plant_History_Kinds: doserialize(/cactusdb/Plant/History/Kinds[]),
			Plant_History_Event: doserialize(/cactusdb/Plant/History/Event[]),
			Plant_History_LastEventOf: doserialize(/cactusdb/Plant/History/LastEvent[]),
			Plant_Family: doserialize(/cactusdb/Plant/Family[]),
			Plant_Gunus: doserialize(/cactusdb/Plant/Genus[]),
			Plant_Species: doserialize(/cactusdb/Plant/Species[]),
			Plant_Variety: doserialize(/cactusdb/Plant/Variety[]),
			Plant_Display: [],
			Plant_latest_events_cache: [],
			Plant_Next_id : /cactusdb/Plant/Next/id,
			Plant_Next_Family_id : /cactusdb/Plant/Next/Family/id,
			Plant_Next_Genus_id: /cactusdb/Plant/Next/Genus/id,
			Plant_Next_Species_id: /cactusdb/Plant/Next/Species/id,
			Plant_Next_Variety_id: /cactusdb/Plant/Next/Variety/id,
			Plant_Next_Event_Kind_id: /cactusdb/Plant/Next/Event/Kind/id,
		})
	}
	function doserialize(thing) {
		OpaSerialize.Json.serialize(Iter.to_list(DbSet.iterator(thing)))
	}
}