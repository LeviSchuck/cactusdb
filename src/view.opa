import stdlib.web.client
module View {
  function pageWrapper(title, content) {
    Resource.full_page(
      title,
      content,
      <meta name="viewport" content="width=device-width, initial-scale=1.0 , maximum-scale=1.0"/>
      ,
      web_response {success},
      {nil}
      );
  }
  function template(content) {
    <div class="navbar">
      <div class="navbar-inner">
        <div class="container">
          <a class="brand span2" href="/main">Cactus DB</a>
          <span class="nav-collapse collapse">
            <span class="form-search pull-right" style="text-align: right">
              <input id=#searchtext type="text" class="input-medium search-query" />
              <input type="button" class="btn btn-info" value="locate" onclick={function(_) {findPlant()}} />
            </>
            <ul class="nav">
              <li><a href="/main">Main</a></li>
              <li><a href="/aging">Aging Report</a></li>
              <li><a href="/meta">Meta</a></li>
            </ul>
          </>
          
        </>
      </>
    </>
    <div id=#main class="container-fluid">
      <div class="row-fluid">     
        {content} 
      </div>
      <hr>
      <footer>
        <p>Cactus DB</p>
      </footer>
    </div>
  }

  function page(path) {
    
    content = 
      <div class="">
        Eggs brah <br />
        {path}
      </>
    template(content)
  }

  function meta_family(Plant.Family.t family) {
    <div class="plant_family">
      <h3>{family.familyName}</h3>
      <ul id={"family_{family.id}_list"}>
        {
          Iter.map(function(genus) {
            <li> {
            meta_genus(genus)
            }</li>
          }, Model.get_plant_genus_by_family(family.id))
        }
      </ul>
      <a class="btn" onclick={function(_){
        Dom.set_value(#newgenusfamilyid,"{family.id}")
        #newgenusfamily = family.familyName
        Dom.remove_class(#newgenus,"hide")
        Dom.scroll_into_view(#newgenus)
        Dom.give_focus(#newgenusname)
        void
      }}>Add Genus</a>
    </div>
  }
  function meta_genus(genus) {
    <div class="plant_genus">
      <h4>{genus.genusName}</h4>
      <ul>
        {
          Iter.map(function(spec) {
            <li> {
            meta_species(spec)
            }</li>
          }, Model.get_plant_species_by_genus(genus.id))
        }
      </ul>
    </div>
  }
  function meta_species(species) {
    <div class="plant_genus">
      <h4>{species.displayId} : {species.speciesName}</h4>
      <ul>
        {
          Iter.map(function(a) {
            <li> {
            meta_variety(a)
            }</li>
          }, Model.get_plant_variety_by_species(species.id))
        }
      </ul>
    </div>
  }
  function meta_variety(variety) {
    <span class="plant_genus">
      {variety.displayId} : {variety.varietyName}
    </>
  }
  function meta_form_family_submit() {
    famname = Dom.get_value(#newfamilyname)
    Dom.clear_value(#newfamilyname)
    id = Model.make_family(famname)
    result = 
    <li>
    {
      meta_family(Model.get_plant_family(id))
    }
    </li>

    #meta_family_list =+ result
    void
  }
  function meta_form_family() { 
    <span class="plant_add_family input-append">
      <input id=#newfamilyname size="20" type="text" onnewline={function(_){meta_form_family_submit()}} />
      <a class="btn" onclick={function(_){meta_form_family_submit()}}>Add Family!</a>
    </>
  }
  function meta_form_genus_submit() {
    famidstring = Dom.get_value(#newgenusfamilyid);
    famparser = parser {
      case p = ([0-9+]) : Int.of_string(Text.to_string(p))
      case .* : (-1)
    };
    famid = Parser.parse(famparser,famidstring);
    genusname = Dom.get_value(#newgenusname);
    #newgenusfamily = "";
    Dom.clear_value(#newgenusfamilyid);
    Dom.clear_value(#newgenusname);
    Dom.scroll_to_bottom(#{"family_{famid}_list"})
    id = Model.make_genus(famid,genusname);
    result = 
    <li>
    {
      meta_genus(Model.get_plant_genus(id))
    }
    </li>
    #{"family_{famid}_list"} =+ result
    Dom.add_class(#newgenus,"hide")
    
    void
  }
  function meta_form_genus() {
    <span class="plant_add_genus input-append hide" id=#newgenus>
      <span id=#newgenusfamily type="text" size="10" class="uneditable-input" ></span> : 
      <input id=#newgenusfamilyid type="hidden" />
      <input id=#newgenusname size="10" type="text" onnewline={function(_){meta_form_genus_submit()}}/>
      <a class="btn" onclick={function(_){meta_form_genus_submit()}}>Add Genus!</a>
    </>
  }
  function meta(path) {

    content = 
      <div id=#meta_root>
      <h1>Meta Data: {path}</h1>
      <h2>Families</>
      <ul id=#meta_family_list>
      {
        Iter.map(function(a) {
            <li id={"meta_family_{a.id}"}> {
            meta_family(a)
            }</li>
          }, Model.get_plant_families())
      }
      </ul>
      {meta_form_family()}<br />
      {meta_form_genus()}
      </>

    template(content)
  }
  function aging(path) {

    content = 
      <div>
      Aging: {path}
      </>
    template(content)
  }
  function find(path) {

    content = 
      <div>
      Find: {path}
      </>
    template(content)
  }
  function plant(path) {
    content = 
      <div>
      Plant: {path}
      </>
    template(content)
  }


  function findPlant() {
    searchtext = Dom.get_value(#searchtext)
    Dom.clear_value(#searchtext)
    search_type = parser {
      case [0-9]+ "-" [0-9]+ "-" [0-9]+ : {fullDisplayId}
      case [0-9]+ "-" [0-9]+ : {speciesVariantAll}
      case [0-9]+ : {speciesAll}
      case (.*) : {other}
    }
    st = Parser.parse(search_type,searchtext)
    match(st) {
      case {fullDisplayId} : Client.goto("/plant/" ^ searchtext)
      case {speciesVariantAll} : Client.goto("/find/plants/" ^ searchtext)
      case {speciesAll} : Client.goto("/find/plants/" ^ searchtext)
      case {other} : Client.goto("/find/all/" ^ searchtext)
    }

    void
  }
}

