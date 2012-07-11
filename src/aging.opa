module Aging {
	function page(_) {
		content = 
		<>
		<h1>Aging report</h1>
		<hr />
		{
			Iter.map(function(a){
				<>
				<h2>{a.name}</h2>
				{
					Iter.map(function(b){
						plant = Model.get_plant_info(b.plantid)

						<>
						<div class="row-fluid">
							<span class="span1">{
								Date.to_string_date_only(b.eventDate)
							}</span>
							<span class="span1">{plant.speciesid}-{plant.varietyid}-{plant.memberid}</span>
							<span class="span2">{plant.genus} {plant.species}</span>
							<span class="span1">{
								
								if(String.length(plant.variety) > 0){
									plant.variety
								}else{
									"{plant.varietyid}"
								}
							}</span>
							<span class="span4">{
								Iter.map(function(c) {
									<>
									{c.notes} 
									</>
								},Model.get_history_event_by_meta(b.plantid,b.kind, b.eventDate))
							}</span>
						</div>
						</>
					},Model.get_history_last_events_of(a.kind))
				}
				<hr />
				</>
			},Model.get_event_kinds())
		}
		</>
		View.template(content)
	}
}