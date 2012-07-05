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
      <ul>
        {
          Iter.map(function(genus) {
            <li> {
            meta_genus(genus)
            }</li>
          }, Model.get_plant_genus(family.id))
        }
      </ul>
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
          }, Model.get_plant_species(genus.id))
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
          }, Model.get_plant_variety(species.id))
        }
      </ul>
    </div>
  }
  function meta_variety(variety) {
    <span class="plant_genus">
      {variety.displayId} : {variety.varietyName}
    </>
  }
  function meta_form_family() { 
    <span class="plant_add_family input-append">
      <input id=#newfamilyname size="20" type="text" />
      <a class="btn" onclick={
        function(_){
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
      }>Add Family!</a>
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
            <li> {
            meta_family(a)
            }</li>
          }, Model.get_plant_families())
      }
      </ul>
      {meta_form_family()}
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

