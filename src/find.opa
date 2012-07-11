module Find {
	function page(list(string) path) {
		dosearch = match(path) {
			case {nil} : {false}
			case _ : {true}
		}
		unknown = <h2>Full Search not ready</>

		content = 
		if(dosearch == {true}) {
			Log.info("search", "Figuring out path: {path}")
			match(path) {
				case ["plants" | plantspath] : {
					searchterm = List.head(plantspath)
					termparser = parser {
									case n=([0-9]+) : by_species(Text.to_string(n))
									case s=([0-9]+) "-" v=([0-9]+) : by_species_and_variety(Text.to_string(s),Text.to_string(v))
									case .* : unknown
								}
					<>
					<h1>Search {plantspath}</h1>
					{
						Parser.parse(termparser,searchterm)
					}
					</>
				}
				case _ : unknown
			}
			
		} else {
			<h1>No search terms provided</h1>
		}
		


		View.template(content)
	}
	function by_species(species) {
		speciesnum = Int.of_string(species)
		allplants = Iter.to_list(Model.find_plants_by_species(speciesnum))
		Plant.render_plant_grid(allplants)
	}
	function by_species_and_variety(species,variety) {
		speciesnum = Int.of_string(species)
		varietynum = Int.of_string(variety)
		allplants = Iter.to_list(Model.find_plants(speciesnum,varietynum))
		Plant.render_plant_grid(allplants)
	}
	
  
}